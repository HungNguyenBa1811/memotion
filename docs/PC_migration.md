# PC Flutter pose-overlay migration

Status: implementation guide

Target repository: `D:/Code/Mobile/memotion_pc`

Audited PC commit: `7c14f3bc39bc05b004462cd7511ec62cb30e69e6`

Mobile reference commit: `00478727973ca7d37228a6a9b752729e689c6bd8`

Backend contract commit: `e02ec17a74e1e5eaa811954dd298e472ce55780f`

## 1. Goal

Migrate the PC Flutter app to the backend's real pose contract and render the
webcam plus landmarks through one aspect-preserving viewport.

The required visible outcome is:

- the full webcam frame fits inside its panel without stretching;
- keypoints and skeleton bones use the same fitted rectangle as that frame;
- `pose.connections` from the backend defines the skeleton;
- a no-pose result clears the old skeleton immediately;
- high-frequency pose samples do not rebuild the whole exercise screen.

This is a PC-specific migration. Reuse the mobile transport, parsing, overlay,
and geometry decisions, but do not copy `CameraPreview`: the PC app previews the
same JPEG bytes that it sends to the backend.

## 2. Authoritative backend contract

The backend repository is the source of truth:

- [WebSocket request and response schema](https://github.com/HaiNam-temp/Memotion/blob/e02ec17a74e1e5eaa811954dd298e472ce55780f/app/schemas/sche_pose.py#L45-L80)
- [WebSocket response construction](https://github.com/HaiNam-temp/Memotion/blob/e02ec17a74e1e5eaa811954dd298e472ce55780f/app/api/api_pose_detection.py#L265-L299)
- [Pose landmark payload construction](https://github.com/HaiNam-temp/Memotion/blob/e02ec17a74e1e5eaa811954dd298e472ce55780f/app/mediapipe/mediapipe_be/service/engine_service.py#L502-L542)
- [Frontend keypoint contract](https://github.com/HaiNam-temp/Memotion/blob/e02ec17a74e1e5eaa811954dd298e472ce55780f/docs/POSE_KEYPOINT_FRONTEND.md)

### 2.1 Request

Send this shape for each JPEG:

```json
{
  "frame_data": "<base64 JPEG>",
  "timestamp_ms": 1722057000123
}
```

`timestamp_ms` is mandatory at the schema boundary and is echoed in the
response. The WebSocket endpoint injects `session_id`; the client does not need
to put it in every message.

Use a strictly increasing client timestamp:

```dart
final nowMs = DateTime.now().millisecondsSinceEpoch;
final timestampMs = nowMs > lastTimestampMs ? nowMs : lastTimestampMs + 1;
```

Do not send only `timestamp`. The current backend ignores that key and creates a
new server-side time, which prevents the PC from matching a result to its JPEG.

### 2.2 Response

The real frame response is flat at the top level:

```json
{
  "phase": 3,
  "phase_name": "sync",
  "data": {
    "current_score": 84.2,
    "rep_count": 6,
    "fatigue_level": "MILD"
  },
  "pose": {
    "detected": true,
    "landmark_count": 33,
    "landmarks": [
      {
        "index": 0,
        "x": 0.501,
        "y": 0.184,
        "z": -0.12,
        "visibility": 0.99,
        "presence": 0.99
      }
    ],
    "connections": [[11, 13], [13, 15]],
    "coordinate_system": "normalized",
    "frame_width": 640,
    "frame_height": 480,
    "timestamp_ms": 1722057000123,
    "error": null
  },
  "message": "Keep your shoulders level",
  "warning": null,
  "timestamp": 1722057000.456,
  "frame_number": 42,
  "frame_timestamp_ms": 1722057000123,
  "fps": 14.5
}
```

Important rules:

- phase semantics come from top-level `data`, not `detection`, `sync`, or
  `final_report` wrappers;
- overlay landmarks come from `pose.landmarks`, not `data.landmarks`;
- `pose.landmark_count` is normally `33` when detected and `0` otherwise;
- every landmark contains `index`, `x`, `y`, `z`, `visibility`, and `presence`;
- `x` and `y` are normalized against `pose.frame_width/frame_height` and may be
  outside `0..1` when a body part leaves the frame;
- use `pose.connections` directly; do not duplicate the edge registry in PC
  code;
- `pose.timestamp_ms` and top-level `frame_timestamp_ms` identify the submitted
  JPEG that produced the result;
- `frame_number` is monotonic within the backend session;
- phases in frame responses are `1..4`; completion can still arrive as the
  separate `session_completed` event already handled by the PC app.

The stable empty-pose shape is:

```json
{
  "pose": {
    "detected": false,
    "landmark_count": 0,
    "landmarks": [],
    "connections": [[11, 13], [13, 15]],
    "coordinate_system": "normalized",
    "frame_width": 640,
    "frame_height": 480,
    "timestamp_ms": 1722057000123,
    "error": null
  }
}
```

## 3. Verified problems in the current PC app

| File | Current behavior | Required correction |
|---|---|---|
| `lib/services/backend_ws_service.dart` | Sends `timestamp`, not `timestamp_ms` | Send the exact request contract and retain the timestamp with the captured JPEG |
| `lib/models/pose_result.dart` | Prefers named phase wrappers and parses landmarks from `data` | Read semantic fields from `data` and pose fields from `pose` |
| `lib/models/pose_result.dart` | Keeps `List<Map<String, dynamic>>` in UI state | Decode once into immutable typed landmarks, connections, and frame metadata |
| `lib/providers/pairing_provider.dart` | Sends every camera event with no explicit in-flight bound | Keep at most two unacknowledged frames and prefer the newest eligible frame |
| `lib/providers/pairing_provider.dart` | Stores each pose result in the full `PairingState` | Split overlay repaint data from semantic phase/score/repetition state |
| `lib/screens/exercise_screen.dart` | `Image.memory(..., fit: BoxFit.cover)` crops the webcam | Use a shared `BoxFit.contain` viewport for image and overlay |
| `lib/screens/exercise_screen.dart` | Painter multiplies normalized coordinates by the full panel | Multiply against the fitted JPEG-sized child only |
| `lib/screens/exercise_screen.dart` | Draws points only and hardcodes no backend connections | Draw visible bones from `pose.connections` before drawing joints |
| `lib/screens/exercise_screen.dart` | Old landmarks can remain when detection is lost | Clear immediately on `detected == false` or invalid landmark count |

## 4. Target PC data path

```text
FlutterLiteCamera.captureFrame
        |
        v
CapturedJpegFrame(bytes, width, height, timestampMs)
        |                         |
        |                         +--> PC preview provider
        v
newest-only sender --> backend WebSocket
                            |
                            v
                    typed frame decoder
                       /           \
                      v             v
        PoseOverlayController   PairingState
        painter-only updates    phase/reps/score/text
                      |
                      v
             PoseCameraViewport
             JPEG + overlay share
             one contain transform
```

Use one captured-frame object for both consumers:

```dart
final class CapturedJpegFrame {
  const CapturedJpegFrame({
    required this.jpegBytes,
    required this.widthPx,
    required this.heightPx,
    required this.timestampMs,
  });

  final Uint8List jpegBytes;
  final int widthPx;
  final int heightPx;
  final int timestampMs;
}
```

Capture `timestampMs` when capture begins, preserve it through JPEG encoding,
and pass it unchanged to `BackendWsService.sendFrame`.

## 5. File-by-file implementation plan

### 5.1 Add typed pose models

Add `lib/models/pose_landmark.dart` with:

- `NormalizedPoseLandmark(index, x, y, z, visibility, presence)`;
- `PoseSkeletonEdge(start, end)`;
- `PoseFrameMetadata(detected, landmarkCount, connections,
  coordinateSystem, frameWidthPx, frameHeightPx, poseTimestampMs,
  frameTimestampMs, frameNumber, error)`.

Keep normalized coordinates unchanged in the model. Any clipping or optional
clamping belongs in the painter.

### 5.2 Add one strict decoder

Add `lib/services/pose_result_decoder.dart` and route all backend frame messages
through it. The decoder must:

1. parse phase semantics from `json['data']`;
2. parse overlay data from `json['pose']`;
3. verify `coordinate_system == 'normalized'`;
4. verify `landmark_count == landmarks.length`;
5. require exactly 33 landmarks when `detected == true`;
6. require zero landmarks when `detected == false`;
7. validate landmark indices and connection endpoints in `0..32`;
8. reject duplicate landmark indices and non-finite coordinates;
9. verify `pose.timestamp_ms == frame_timestamp_ms` when both are non-zero;
10. return unmodifiable typed lists.

For a short compatibility window, named phase wrappers may be accepted only
when `data` is absent. Do not let a wrapper override a valid `data` object.

### 5.3 Correct frame sending and add backpressure

Change `BackendWsService.sendFrame` to accept a `CapturedJpegFrame` and send:

```dart
void sendFrame(CapturedJpegFrame frame) {
  if (_channel == null) return;
  _channel!.sink.add(jsonEncode({
    'frame_data': base64Encode(frame.jpegBytes),
    'timestamp_ms': frame.timestampMs,
  }));
}
```

In `PairingNotifier`, do not blindly transmit all ~33 camera frames per second.
Track submitted timestamps until their results return:

- allow at most two timestamps in flight;
- when full, retain only the newest pending frame;
- remove an in-flight timestamp when the matching
  `frame_timestamp_ms` arrives;
- discard a response older than the latest accepted timestamp;
- clear pending and in-flight state on disconnect, reset, or session end.

This is application-level backpressure; WebSocket buffering alone is not a
freshness policy.

### 5.4 Split visual and semantic state

Keep phase, score, repetition count, fatigue, connection state, message, and
warning in `PairingState`.

Move landmarks into a session-scoped `PoseOverlayController` that extends
`ChangeNotifier`. It should prepare painter-ready buffers and notify only the
overlay painter. Recommended first-pass behavior:

- visibility/presence show threshold: `0.65`;
- hide threshold: `0.45` for hysteresis;
- draw a bone only when both endpoint joints are visible;
- clear immediately for an explicit no-pose frame;
- begin fading after 100 ms without a result;
- clear at 250 ms;
- allocate `Paint` objects once, not inside every `paint` call.

The exercise screen should use Riverpod selectors or small `Consumer` widgets
for semantic values. A pose sample must not rebuild the trainer video or the
whole page.

### 5.5 Add one shared PC camera viewport

Add `lib/widgets/pose_camera_viewport.dart`. The JPEG and overlay must be
children of the same fixed source-sized box, and that box must be fitted once:

```dart
ClipRect(
  child: FittedBox(
    fit: BoxFit.contain,
    alignment: Alignment.center,
    child: SizedBox(
      width: frame.widthPx.toDouble(),
      height: frame.heightPx.toDouble(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            frame.jpegBytes,
            fit: BoxFit.fill,
            gaplessPlayback: true,
          ),
          PoseLandmarkOverlay(controller: overlayController),
        ],
      ),
    ),
  ),
)
```

`BoxFit.fill` is safe only inside the box with the JPEG's exact source aspect;
the outer `FittedBox` performs the visible `contain` scaling. This avoids both
stretching and duplicated fit calculations.

The PC currently displays the raw submitted JPEG without mirroring. Therefore,
do not mirror landmarks. If a future UX mirrors the webcam, apply the same
horizontal transform to both image and overlay in this shared viewport.

### 5.6 Draw backend connections

The painter receives prepared normalized points and the decoded backend
connections. In its source-sized canvas:

```dart
final point = Offset(landmark.x * size.width, landmark.y * size.height);
```

Draw bones first, then joints. Wrap the viewport in `ClipRect`; do not mutate the
stored normalized coordinates when a point is outside `0..1`.

### 5.7 Update `exercise_screen.dart`

Replace `_CameraFill` plus the sibling `CustomPaint` with one
`PoseCameraViewport`. Delete the private dynamic `_LandmarkPainter` after the
new typed overlay is wired.

Use the overlay in detection and calibration too, not only phase 3/4. The
backend returns `pose` on every processed frame, independent of phase.

## 6. Temporal alignment modes

The backend result belongs to an older submitted JPEG while a live preview may
already show a newer JPEG. Correct geometry does not remove network latency.

Support two explicit modes:

| Mode | Preview source | Use |
|---|---|---|
| `livePredictive` | latest captured JPEG plus latest accepted overlay | normal exercise UI; smooth but approximate during fast movement |
| `frameLocked` | retained JPEG whose timestamp equals `frame_timestamp_ms` | QA, calibration screenshots, and alignment diagnosis |

For `frameLocked`, retain a bounded map of submitted JPEGs keyed by
`timestampMs`. Remove a frame after its result or after a short timeout. Never
keep an unbounded frame history.

The current backend has no separate `client_frame_id`; the echoed timestamp is
the correlation key. A future protocol can add an explicit frame ID without
changing the viewport or typed overlay design.

## 7. Required tests in `memotion_pc`

Add these tests before replacing the old painter:

- `test/pose_result_decoder_test.dart`
  - real `data` plus `pose` fixture;
  - detected 33-point fixture;
  - stable no-pose fixture;
  - malformed count, duplicate index, non-finite coordinate;
  - malformed/out-of-range connection;
  - pose/frame timestamp mismatch;
  - legacy wrapper fallback only when `data` is absent.
- `test/backend_ws_service_test.dart`
  - request contains `frame_data` and exact `timestamp_ms`;
  - request does not rely on `timestamp`;
  - in-flight acknowledgement uses `frame_timestamp_ms`.
- `test/pose_overlay_controller_test.dart`
  - backend connection list controls bone output;
  - low-confidence endpoints suppress their bone;
  - hysteresis prevents flicker;
  - explicit no-pose clears immediately;
  - stale data fades and clears.
- `test/pose_viewport_geometry_test.dart`
  - 640x480 into wide, tall, and same-aspect panels;
  - centered letterboxing for `BoxFit.contain`;
  - corner and shoulder anchors map through the same fitted rectangle;
  - optional mirrored transform maps both preview and keypoints equally.
- widget test
  - 100 overlay notifications repaint without rebuilding the parent exercise
    subtree.

Run:

```powershell
flutter analyze
flutter test
```

Then perform a Windows device check with the real backend. Unit tests cannot
prove webcam driver orientation, actual end-to-end latency, or visual alignment.

## 8. Manual acceptance checklist

- The complete 4:3 webcam image is visible inside the camera half with centered
  letterboxing where necessary.
- The image is not horizontally or vertically stretched.
- Nose, shoulders, elbows, wrists, hips, knees, and ankles sit on the person
  while stationary.
- Skeleton edges come from the response, and no bone connects through a missing
  joint.
- An undetected frame removes the previous skeleton immediately.
- Moving partially outside the image does not generate points at `(0, 0)`.
- `frame_timestamp_ms` in logs equals the timestamp sent with the matching JPEG.
- Older or duplicate results never replace a newer accepted overlay.
- The trainer video and surrounding layout do not rebuild for every keypoint
  sample.
- A 15-minute session has bounded memory and no growing JPEG/result queue.

## 9. Recommended migration order

1. Add typed captured-frame and pose models.
2. Correct `timestamp_ms`, `data`, and `pose` parsing with unit tests.
3. Add shared contain viewport and backend-driven skeleton painter.
4. Wire explicit no-pose clearing and staleness behavior.
5. Split overlay repaint state from `PairingState`.
6. Add newest-only backpressure and response ordering.
7. Add optional frame-locked diagnostics.
8. Profile and device-test on Windows before deleting compatibility parsing.

Do not optimize filtering or prediction until the exact request mapping,
response parsing, and shared viewport geometry pass the stationary anchor test.
