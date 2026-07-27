# Camera keypoint overlay: implementation plan

Status: proposed

Scope: `D:/Code/Mobile/memotion`, Android first

Last reviewed: 2026-07-27

Verified toolchain: Flutter 3.41.5, Dart 3.11.3, `camera` 0.11.3, `camera_android_camerax` 0.6.27, `web_socket_channel` 3.0.3

## 1. Executive decision

Stop treating this as a drawing-library problem.

Flutter's `CameraPreview` plus `CustomPaint` is already the correct rendering stack for 33 pose landmarks. No third-party keypoint renderer is needed. A painter driven by a `Listenable` can repaint without running widget build or layout, and 33 points plus a few dozen bones is trivial paint work on a normal phone.

The real latency and accuracy problems are earlier in the pipeline:

1. Camera frames are copied from three planes.
2. Dart loops over every pixel to convert YUV to RGB.
3. Dart encodes the RGB image as JPEG.
4. The JPEG is expanded again by base64 and wrapped in JSON.
5. The frame crosses the network.
6. The server runs inference.
7. A response returns without a reliable client frame identity.
8. Normalized points are multiplied by the widget width and height even when preview rotation, mirroring, fitting, and cropping differ from the encoded frame.
9. The complete Riverpod session state rebuilds the training screen for every result.

There is also a physical constraint that must be made explicit:

- A remote result belongs to an older camera frame.
- The local `CameraPreview` texture is showing a newer camera frame.
- Smoothing can reduce jitter.
- Prediction can reduce perceived lag.
- Neither can make an old result become frame-accurate against a newer image.

The product therefore needs two named modes:

| Mode | User sees | Guarantee | Use |
|---|---|---|---|
| `livePredictive` | Current camera preview plus filtered and conservatively predicted landmarks | Fresh and visually smooth, but approximate during fast motion | Normal exercise guidance |
| `frameLocked` | The exact submitted/processed frame plus its returned landmarks | Spatially exact, but delayed by encoding, network, and inference | Diagnostics, QA, calibration, screenshots |

The default product mode is `livePredictive`. If the business requirement is literally both current-frame accuracy and near-zero latency, pose inference must eventually move on-device. That is a later architecture track, not something a faster `Canvas` call can solve.

## 2. Outcomes and measurable budgets

“No lag” and “accurate” must be testable, not adjectives.

### 2.1 Initial service-level objectives

These are starting budgets for Android profile builds on the team's lowest supported device. Baseline them before implementation and adjust only with recorded evidence.

| Signal | Target | Hard failure |
|---|---:|---:|
| Camera preview | Stable hardware preview, normally 30 FPS or better | Visible freeze over 200 ms |
| Flutter UI frame time | p95 build under 4 ms; p95 raster under 8 ms on a 60 Hz display | More than 1% frames over 16.7 ms during a 3-minute run |
| Pose result rate | p50 at least 12 results/s; target 15 results/s | Under 8 results/s for 5 seconds on a healthy connection |
| Capture-to-result age | p50 under 120 ms; p95 under 220 ms | p95 over 350 ms |
| Result-to-paint delay | p95 under one display frame | Over 33 ms |
| Static reprojection error | median at most 4 px; p95 at most 10 px in the camera viewport | Systematic offset, wrong axis, or mirrored result |
| Overlay staleness | Drop results older than 250 ms by default | Paint a result older than 400 ms |
| Memory | No unbounded frame or result queues; stable after warm-up | Growth caused by retained image buffers |
| Thermal soak | 15 minutes without runaway throttling or camera failure | Session becomes unusable before 15 minutes |

Remote capture-to-result targets are hypotheses until measured against the real backend and network. The plan must record actual p50, p90, and p95 values rather than hiding an impossible budget.

### 2.2 Visual acceptance criteria

- Nose, shoulders, elbows, wrists, hips, knees, and ankles stay on the same anatomical locations for a stationary user.
- Front-camera behavior is intentionally mirrored or intentionally unmirrored; it is never an accidental platform side effect.
- Portrait and both landscape orientations pass the same anchor-point test.
- Cover-cropped previews keep landmarks aligned at the edges.
- Low-confidence joints fade instead of teleporting to `(0, 0)`.
- Skeleton bones are never drawn to missing joints.
- A stale skeleton disappears gracefully; it does not freeze indefinitely over a moving user.
- Score, repetition count, and instructions can update without rebuilding the camera/overlay subtree.

## 3. What exists today

### 3.1 Current data path

    CameraX texture -------------------------------> CameraPreview
          |
          +-> CameraImage YUV planes
              -> copy three Uint8List planes
              -> persistent Dart isolate
              -> per-pixel YUV to RGB
              -> JPEG quality 80
              -> base64
              -> JSON
              -> WebSocket
              -> backend pose inference
              -> JSON result
              -> PoseFrameResult with List<dynamic>
              -> PoseSessionState.lastResult
              -> rebuild PoseTrainingScreen
              -> CustomPaint

The preview lane and inference lane start from the same camera but are not temporally locked after capture.

### 3.2 Current files in the hot path

| File | Current responsibility |
|---|---|
| `lib/features/workout/data/camera_service.dart` | Camera ownership, image stream, plane copies, isolate, YUV conversion, JPEG encoding |
| `lib/features/workout/data/pose_detection_service.dart` | HTTP session lifecycle, WebSocket transport, JSON parsing, result streams |
| `lib/features/workout/models/pose_detection_model.dart` | Session/result models and phase-specific convenience getters |
| `lib/features/workout/providers/pose_detection_provider.dart` | Session state, stream subscriptions, phase navigation callback, every-frame state updates |
| `lib/features/workout/screens/pose_detection_screen.dart` | Camera/session startup and phase 1/2 UI |
| `lib/features/workout/screens/pose_training_screen.dart` | Camera handoff, trainer video, timer, phase 3 UI, current painter |

### 3.3 Problems to correct before micro-optimizing paint

| Severity | Finding | Consequence |
|---|---|---|
| Critical | Capture timestamp is created after JPEG encoding, not when `CameraImage` arrives | Latency metrics and video synchronization exclude camera/encoding delay |
| Critical | Results do not have a required echoed `client_frame_id` | Cannot match, order, age, or reject results reliably |
| Critical | Mapping is only `x * canvasWidth`, `y * canvasHeight` | Wrong under rotation, mirroring, aspect fit, and crop |
| Critical | The integration document describes phase-specific response keys while current parsing reads only `data` | Landmarks may silently parse as empty depending on the live backend contract |
| High | Front-camera metadata is captured but `isFrontCamera` is unused during encoding/mapping | Preview and inference image may have opposite handedness |
| High | The full session state stores `lastResult`; both screens watch the full provider | A pose result can rebuild the whole screen |
| High | No application-level WebSocket in-flight limit or result-age policy exists | Network/server slowdown can create stale work and buffered messages |
| High | YUV conversion is a Dart nested pixel loop | CPU, battery, heat, and result-age cost dominate the overlay |
| High | Three plane lists and the encoded JPEG are copied | Allocation and memory-bandwidth pressure |
| Medium | `targetFps = 30` is declarative only; it does not sample by time | Actual inference rate is controlled by encoder speed and camera callbacks |
| Medium | `List<dynamic>` and `Map` parsing continue into the painter | Runtime type work, unclear schema, weak tests |
| Medium | `Paint` objects are allocated inside every `paint` call | Avoidable allocations in the hottest UI method |
| Medium | The current line paint is unused and skeleton connections are TODO | Incomplete overlay |
| Medium | Camera lifecycle is not handled with `WidgetsBindingObserver` | Background/resume behavior can leak or fail; current camera docs assign lifecycle ownership to the app |
| Medium | Training catches initialization failure and still sets initialized in `finally` | UI can look ready after a failed camera/stream setup |
| Low | Per-frame logging and temporary emoji `print` calls remain | Noise and measurable debug overhead |

The existing `_syncOffset` compares training-video position with a post-encode wall-clock timestamp. It is not camera-to-keypoint alignment and must not be used as proof that the overlay is synchronized.

## 4. Architecture decisions

### 4.1 Keep Flutter's native rendering primitives

Use:

- `CameraPreview` for the camera texture.
- One viewport widget that applies preview size, rotation, mirroring, fit, and clipping to both preview and overlay.
- `CustomPainter(repaint: overlayController)` for the skeleton.
- `RepaintBoundary` around the overlay only if profile evidence confirms it reduces collateral repaints.
- `IgnorePointer` around the overlay.

Do not add a pose-drawing dependency. A package cannot repair frame identity, coordinate transforms, or network age.

Do not claim that `drawRawPoints` “puts data directly on the GPU.” It is a lower-allocation Canvas API taking `Float32List`; the engine still decides rendering details. For 33 landmarks, correctness and allocation discipline matter more than replacing every `drawCircle`.

### 4.2 Split the hot visual lane from semantic app state

There must be two result consumers:

1. **Overlay lane**
   - Receives every accepted typed pose sample.
   - Matches frame identity.
   - Rejects stale/out-of-order samples.
   - Filters and optionally predicts display coordinates.
   - Notifies only the painter.
   - Never writes every display tick into Riverpod state.

2. **Semantic lane**
   - Updates phase, connection, repetitions, score, fatigue, warnings, and instructions.
   - Uses distinct values and small consumers/selectors.
   - Repetition changes are immediate.
   - Score is visually rate-limited to about 5 Hz unless product research requires more.
   - Identical text/connection values do not notify UI.

This is more important than choosing `drawCircle` versus `drawRawPoints`.

### 4.3 Use typed immutable hot-path models

No `dynamic`, `Map`, or raw JSON is allowed past the transport parser.

Use plain immutable Dart models for the hot path. Do not import `dart:ui` into transport/domain models. Keep normalized coordinates as doubles and construct Canvas data in the overlay controller.

Required types:

    enum PoseLandmarkSchema { blazePose33V1 }

    final class NormalizedPoseLandmark {
      final int index;
      final double x;
      final double y;
      final double? z;
      final double visibility;
      final double? presence;
    }

    final class CapturedPoseFrame {
      final int clientFrameId;
      final int capturedElapsedUs;
      final int width;
      final int height;
      final int rotationDegrees;
      final bool mirroredInPayload;
      final Uint8List jpegBytes;
    }

    final class PoseInferenceSample {
      final int clientFrameId;
      final int capturedElapsedUs;
      final int receivedElapsedUs;
      final Size2D inferenceImageSize;
      final PoseLandmarkSchema schema;
      final List<NormalizedPoseLandmark> landmarks;
    }

    final class PoseOverlaySnapshot {
      final int sourceFrameId;
      final int sourceAgeUs;
      final Float32List highConfidencePoints;
      final Float32List mediumConfidencePoints;
      final Float32List visibleBoneSegments;
      final double opacity;
    }

Use unit suffixes in names: `elapsedUs`, `ageMs`, `widthPx`. Never use an unqualified field named only `timestamp` in new hot-path code.

### 4.4 One owner for runtime resources

Create a session-scoped runtime/controller that owns:

- `CameraController`
- capture sampler
- encoder worker
- WebSocket transport
- stream subscriptions
- overlay controller
- lifecycle state
- cancellation/generation token

Screens should request actions and display state; they should not independently decide which singleton to dispose during route replacement.

The camera must survive phase 1/2 to phase 3 handoff because the runtime survives, not because two screens race an unawaited singleton `dispose`.

## 5. Target runtime

    CameraController / CameraPreview texture
                 |
                 +-> PoseCaptureSampler
                       |
                       | newest eligible CameraImage only
                       v
                 PoseFrameEncoderWorker
                       |
                       | CapturedPoseFrame + frame identity
                       v
                 PoseWebSocketTransport
                       |
                       | max two unacknowledged frames, no queue
                       v
                 backend inference
                       |
                       | echoed frame identity + typed landmarks
                       v
                 PoseResultDecoder
                       |
             +---------+----------------+
             |                          |
             v                          v
      PoseOverlayController       PoseSessionNotifier
      stale/order gate            phase/reps/score/text
      One Euro filter             distinct/rate-limited state
      bounded prediction
             |
             | ChangeNotifier / Listenable
             v
      PoseLandmarkPainter
      repaint only; no build/layout

## 6. Exact file plan

Keep the repository's existing feature folders. Do not create a second architecture hierarchy under workout.

### 6.1 Add

| File | Contents |
|---|---|
| `lib/features/workout/models/pose_landmark_model.dart` | `PoseLandmarkSchema`, `NormalizedPoseLandmark`, skeleton edge registry |
| `lib/features/workout/models/pose_frame_model.dart` | `Size2D`, `CapturedPoseFrame`, `PoseInferenceSample`, protocol metadata |
| `lib/features/workout/models/pose_overlay_model.dart` | Immutable overlay configuration and snapshot types |
| `lib/features/workout/data/pose_frame_encoder_worker.dart` | Long-lived isolate protocol, frame request/result IDs, shutdown/error handling |
| `lib/features/workout/data/pose_result_decoder.dart` | Strict JSON-to-typed parsing and legacy response compatibility |
| `lib/features/workout/data/pose_overlay_controller.dart` | Frame ordering, age gate, filtering, prediction, prepared Canvas buffers |
| `lib/features/workout/widgets/pose_camera_viewport.dart` | Shared preview/overlay sizing, fit, crop, mirroring, clipping |
| `lib/features/workout/widgets/pose_landmark_overlay.dart` | Ticker lifecycle and `CustomPaint` wiring |
| `lib/features/workout/widgets/pose_landmark_painter.dart` | Paint-only skeleton renderer |
| `lib/features/workout/utils/one_euro_filter.dart` | Deterministic scalar/point filters independent of Flutter widgets |
| `lib/features/workout/utils/pose_viewport_geometry.dart` | Pure coordinate/orientation/mirroring calculations |
| `lib/features/workout/providers/pose_runtime_provider.dart` | Session-scoped ownership and disposal |

### 6.2 Modify

| File | Change |
|---|---|
| `camera_service.dart` | Reduce to camera/capture responsibilities or fold into runtime; capture IDs/times at callback entry; expose typed metadata; remove UI callback tuples |
| `pose_detection_service.dart` | Separate transport from session API; add protocol v2; explicit in-flight accounting; parser delegation |
| `pose_detection_model.dart` | Remove raw landmark getter after migration; keep semantic result models |
| `pose_detection_provider.dart` | Stop publishing raw per-frame landmarks through full session state; use selectors/distinct semantic state |
| `pose_detection_screen.dart` | Use shared runtime and `PoseCameraViewport`; no direct singleton lifecycle |
| `pose_training_screen.dart` | Remove embedded painter; use small consumers; do not mark failed initialization successful |

### 6.3 Add tests

| File | Responsibility |
|---|---|
| `test/unit/workout/models/pose_result_decoder_test.dart` | Strict and legacy protocol fixtures |
| `test/unit/workout/utils/pose_viewport_geometry_test.dart` | Rotation, crop, fit, mirroring, anchors |
| `test/unit/workout/utils/one_euro_filter_test.dart` | Step response, jitter, gaps, reset |
| `test/unit/workout/data/pose_overlay_controller_test.dart` | Ordering, stale rejection, confidence hysteresis, prediction cap |
| `test/unit/workout/data/pose_capture_backpressure_test.dart` | Encoder/transport capacity and latest-frame policy |
| `test/widgets/workout/pose_camera_viewport_test.dart` | Shared layout and repaint isolation |
| `test/widgets/workout/pose_landmark_overlay_golden_test.dart` | Skeleton, confidence states, crop edges |
| `integration_test/pose_overlay_performance_test.dart` | On-device timing and soak instrumentation |

Do not update the legacy root `test/widget_test.dart` as part of this feature unless the test harness is separately modernized; it is unrelated debt.

## 7. Wire protocol: make the result traceable

### 7.1 Protocol v2 request

The backend must echo `client_frame_id` and `captured_elapsed_us` unchanged.

    {
      "type": "pose_frame",
      "protocol_version": 2,
      "session_id": "session-id",
      "client_frame_id": 1842,
      "captured_elapsed_us": 51234567,
      "image": {
        "encoding": "jpeg",
        "width": 480,
        "height": 640,
        "rotation_degrees": 90,
        "mirrored": false
      },
      "frame_data": "<base64 during compatibility phase>"
    }

`captured_elapsed_us` comes from one session `Stopwatch` at the beginning of the camera callback. It is client-monotonic and is only meaningful when echoed back to the same client. It must not be compared with server wall-clock time.

Wall-clock time may be added separately for logs, named `captured_wall_clock_ms`, but it must never drive ordering or latency inside the client.

### 7.2 Protocol v2 response

    {
      "type": "pose_result",
      "protocol_version": 2,
      "session_id": "session-id",
      "client_frame_id": 1842,
      "captured_elapsed_us": 51234567,
      "server": {
        "queue_ms": 4.2,
        "decode_ms": 3.1,
        "inference_ms": 22.8,
        "postprocess_ms": 1.7
      },
      "model": {
        "landmark_schema": "blazepose_33_v1",
        "input_width": 480,
        "input_height": 640,
        "coordinates": "normalized_upright_payload"
      },
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
      "phase": 3,
      "phase_name": "sync",
      "message": "Keep your shoulders level",
      "sync": {
        "current_score": 84.2,
        "rep_count": 6,
        "fatigue_level": "MILD"
      }
    }

The response contract must specify:

- landmark order/schema;
- whether x/y are relative to the exact upright encoded payload;
- whether coordinates may go outside 0–1;
- whether the inference image was letterboxed or cropped internally;
- whether returned coordinates were unletterboxed back to payload space;
- whether the payload was mirrored;
- which confidence fields exist and their ranges.

If the model letterboxes internally, the backend is responsible for returning coordinates in original payload space. Do not leak model tensor padding into mobile UI mapping.

### 7.3 Legacy compatibility

The current repository contains conflicting assumptions:

- code reads one common `data` object;
- `WORKOUT_INTEGRATION.md` describes `detection`, `calibration`, `sync`, and `final_report` wrappers.

`PoseResultDecoder` must temporarily accept both, with deterministic precedence:

1. protocol v2 typed top-level fields;
2. phase-specific wrapper;
3. legacy `data` fallback.

Malformed landmarks reject that frame and increment a metric. They do not convert missing values to an apparently valid point at the top-left corner.

Remove compatibility only after captured production fixtures and backend contract tests prove it unused.

### 7.4 Binary transport phase

Base64 increases image payload size by roughly one third and adds encode/decode allocations. After v2 JSON identity is stable:

- send metadata plus JPEG as a binary WebSocket envelope;
- keep one small versioned header;
- preserve the same typed client model;
- feature-flag binary mode so old backend deployments still work;
- compare p50/p95 encode, send, receive, and allocation metrics before making it default.

Do not switch protocol format and overlay mapping in the same rollout gate.

## 8. Capture scheduling and backpressure

Every stage must have a bounded capacity.

### 8.1 Frame identity and clocks

At camera callback entry:

1. Read session `Stopwatch.elapsedMicroseconds`.
2. Allocate the next strictly increasing `clientFrameId`.
3. Capture orientation, lens direction, buffer width/height, and expected payload transform.
4. Decide whether the sampler has capacity.
5. If no capacity, increment `captureDroppedBusy` and return without copying planes.

The ID and capture time travel through encoder request, encoded frame, WebSocket request, server response, filter, paint snapshot, and metrics. Never create a replacement timestamp after encoding.

### 8.2 Default capacity

- Encoder: maximum one active frame.
- WebSocket/server: maximum two unacknowledged frames.
- Pending camera images: zero.
- Pending encoded frames waiting for transport: zero or one latest frame, only if age is under 50 ms.
- Result reorder buffer: zero; discard older IDs.

This is a low-latency system, not a throughput queue. When overloaded, drop work and return to the newest camera frame.

Two unacknowledged frames is an initial setting, not dogma. A limit of one minimizes age but caps throughput near the round-trip rate. A limit of two can keep the server busy without allowing a stale backlog. Tune using the age histogram.

### 8.3 Time-based sampling

Replace the unused “30 FPS” intention with a sampler:

- default inference target: 15 FPS;
- minimum interval: 66,667 microseconds;
- allow a new frame only when interval and capacity both pass;
- camera preview remains native and unsampled;
- expose remote configuration only after safe local defaults exist.

Sending 30 JPEG frames per second is not a success if 20 are stale before inference.

### 8.4 Isolate policy

Keep one long-lived encoder worker because the operation repeats. Do not call `Isolate.run` or Flutter `compute` per camera frame.

For camera planes:

- plugin plane memory cannot be assumed valid after the callback;
- the data therefore needs owned memory before leaving the callback;
- use `TransferableTypedData` for isolate handoff where it reduces an additional receiver copy;
- measure construction cost because creating owned transferable data can still require a copy from plugin buffers;
- correlate every worker response with frame ID;
- use a generation ID so a response from a stopped session is ignored;
- return structured worker errors rather than silently returning null;
- shut down with a command/ack and timeout before force-killing.

Do not move 33-landmark JSON parsing into a new isolate by default. That payload is small, and isolate messaging can cost more than strict typed parsing. Measure first. A persistent decoder isolate is justified only if responses become materially larger, such as hands plus face mesh.

### 8.5 Encoder path

The current Dart per-pixel YUV conversion is the first performance candidate, not the painter.

Implementation order:

1. Instrument its p50/p95 time, output bytes, allocations, and effective FPS.
2. Confirm Y, U, and V row/pixel stride correctness on supported CameraX devices.
3. Reduce inference resolution only if pose accuracy validation passes.
4. Prototype native Android YUV-to-JPEG compression or direct backend-supported YUV/NV21 transport.
5. Prefer sending YUV directly if the backend decoder/model can consume it efficiently.
6. Keep the Dart encoder as a flagged fallback until device coverage passes.

JPEG quality 80 and `ResolutionPreset.medium` are not sacred. Treat resolution, quality, inference rate, and accuracy as a measured configuration matrix.

## 9. Spatial correctness

### 9.1 Define coordinate spaces

Never pass an unlabelled “x/y”.

| Space | Meaning |
|---|---|
| Sensor buffer | Raw `CameraImage.width/height` and plane orientation |
| Encoded payload | Image after the client's explicit rotation/mirror policy |
| Model input | Backend tensor, possibly resized/letterboxed |
| Result normalized | Coordinates returned in encoded-payload space, normalized to 0–1 |
| Preview source | Upright source size used by the preview/overlay pair |
| Viewport | On-screen clipped camera rectangle |
| Canvas | Painter coordinates inside the shared preview source |

The target contract is that results are normalized in **encoded payload space**, after the backend removes any tensor letterbox/crop.

### 9.2 One shared preview/overlay transform

`PoseCameraViewport` owns both the preview and overlay. The overlay is passed as `CameraPreview.child` or placed in the exact same source-sized box. The entire pair is then fitted and clipped together.

Conceptual structure:

    LayoutBuilder
      ClipRect
        FittedBox(fit: BoxFit.cover)
          SizedBox(size: orientedPreviewSize)
            CameraPreview(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: PoseLandmarkOverlay
                )
              )
            )

Benefits:

- normalized coordinates paint in source space;
- `FittedBox` applies the same scale/crop to preview and overlay;
- one mirror transform affects both when desired;
- no duplicated “guess the content rectangle” math in screens;
- detection and training use the same widget.

The exact widget composition must be proven with the installed `camera` plugin because `CameraPreview` already uses an orientation-dependent `AspectRatio` and Android `RotatedBox`.

### 9.3 Reference transform math

If explicit viewport math is required, for source size `sw × sh` and viewport `vw × vh`:

For `BoxFit.cover`:

    scale = max(vw / sw, vh / sh)
    renderedWidth = sw * scale
    renderedHeight = sh * scale
    offsetX = (vw - renderedWidth) / 2
    offsetY = (vh - renderedHeight) / 2
    screenX = offsetX + sourceX * scale
    screenY = offsetY + sourceY * scale

For `BoxFit.contain`, use `min` instead of `max`.

For a horizontal handedness change:

    normalizedX = 1 - normalizedX

Apply mirroring exactly once and record whether it occurs in payload space or display space. Never infer it from “front camera usually mirrors.”

### 9.4 Orientation policy

- Freeze the capture/display orientation for an active workout unless product requires rotation.
- If orientation changes are supported, treat them as a geometry generation change.
- Stop accepting old results.
- clear filter/prediction state;
- update oriented source dimensions;
- restart capture with new metadata;
- do not blend points across orientation generations.

The current encoder rotates by sensor orientation while `CameraPreview` responds to device/locked orientation. These are not automatically the same operation. A device matrix test must decide the final transform.

### 9.5 Coordinate validation harness

Add a debug-only overlay mode with:

- source bounds;
- center crosshair;
- 3×3 normalized anchors;
- payload width/height;
- rotation;
- payload mirror flag;
- display mirror flag;
- current frame ID and age.

Test with a person or printed markers at all nine anchors in:

- portrait front;
- landscape-left front;
- landscape-right front;
- portrait back;
- cover crop;
- contain fit, if used anywhere.

A screenshot that “looks about right in the center” is not a mapping test.

## 10. Temporal correctness, filtering, and prediction

### 10.1 Ordering and age gate

When a result arrives:

1. Reject a different session/generation.
2. Reject an unknown landmark schema.
3. Reject `clientFrameId <= lastAcceptedFrameId`.
4. Compute `ageUs = nowElapsedUs - capturedElapsedUs`.
5. Reject negative age outside a tiny tolerance.
6. Reject age over `maxAcceptedResultAgeUs`, initially 250,000.
7. Parse/validate finite normalized coordinates.
8. Feed accepted raw landmarks to the display filter.

Maintain counters for every reject reason.

### 10.2 Filtering does not alter scoring

Raw backend pose data drives exercise correctness, angle calculation, repetition logic, and audit/debug data.

Filtered/predicted points are presentation-only. Never feed display points back into scoring.

### 10.3 One Euro filter

Start with a One Euro filter per landmark axis because it explicitly balances low-speed jitter against high-speed responsiveness.

For each axis:

    derivative = (value - previousValue) / dt
    filteredDerivative = lowPass(derivative, derivativeCutoff)
    cutoff = minCutoff + beta * abs(filteredDerivative)
    filteredValue = lowPass(value, cutoff)

The low-pass coefficient is derived from real capture-time `dt`, not an assumed FPS and not uneven receive-time intervals.

Initial tuning candidates:

- `minCutoffHz = 1.5`
- `beta = 0.05`
- `derivativeCutoffHz = 1.0`

These are experiment seeds, not universal constants. Record step-response lag and stationary jitter for shoulders, wrists, hips, and ankles. Wrists/ankles may need different parameters from torso joints, but do not add per-joint tuning until a shared setting is measured.

Reset a joint filter when:

- no accepted sample exists for 250 ms;
- confidence was absent long enough to drop the joint;
- session, lens, orientation, schema, or camera generation changes;
- coordinates are non-finite or implausibly discontinuous.

### 10.4 Confidence hysteresis

Avoid visibility flicker:

- hidden -> visible only at visibility at least 0.65;
- visible remains visible until visibility falls below 0.45;
- hold last position for at most 100 ms;
- fade between 100 and 250 ms;
- remove after 250 ms;
- draw a bone only when both endpoints are currently drawable.

Tune thresholds using real model output. Presence and visibility should be combined only if the selected model defines both semantics clearly.

### 10.5 Conservative prediction

For `livePredictive` mode:

- estimate velocity from capture-time-filtered points;
- predict toward current render time;
- cap prediction horizon, initially 80 ms;
- cap per-axis displacement, initially 0.04 normalized units;
- reduce or disable prediction when confidence is low, result intervals are irregular, or velocity changes direction;
- never extrapolate a joint outside a small permitted margin around the frame;
- expose prediction on/off in the debug panel.

Prediction is evaluated by motion reprojection error, not by whether the animation “feels smoother.”

### 10.6 Frame-locked diagnostic mode

Keep a bounded debug-only cache of the last one or two submitted encoded frames keyed by frame ID. When the result returns:

- decode and display its exact source frame;
- draw raw returned points without prediction;
- show capture-to-result age;
- compare against live mode side by side.

Do not retain a long image queue. This mode is for truth-testing geometry and latency, not normal exercise UI.

## 11. Painter and display loop

### 11.1 Overlay controller

`PoseOverlayController` extends `ChangeNotifier` and owns:

- last accepted source frame;
- per-joint filters;
- last display positions/velocities;
- confidence state;
- preallocated or reused `Float32List` buffers;
- current `PoseOverlaySnapshot`;
- debug metrics.

It exposes read-only buffers to the painter. Network/result ingestion mutates controller internals and schedules one paint notification. If interpolation/prediction runs at display rate, `PoseLandmarkOverlay` owns a `Ticker` and ticks only while mounted, visible, and holding a fresh pose.

No Riverpod state change occurs per display tick.

### 11.2 Painter rules

`PoseLandmarkPainter`:

- receives the controller as `repaint` in `super`;
- stores `Paint` instances as final fields;
- draws bones before joints;
- uses round line caps and joins;
- uses at most two or three confidence style buckets;
- uses prepared numeric buffers;
- does not parse maps;
- does not allocate `Paint`, gradients, paths, or text on every frame;
- does not call `saveLayer`, blur filters, or shadows in the live path;
- clips to source bounds;
- returns false from `shouldRepaint` when the same controller/config instance is reused;
- compares immutable visual configuration when the painter instance changes.

`drawRawPoints(PointMode.points, ...)` is useful when all points in a buffer share diameter/color. With round `strokeCap`, stroke width becomes point diameter. For a 33-point skeleton, regular circles may still be clearer and fast enough. Select after profile evidence.

Bones can be built as paired coordinates and drawn with `PointMode.lines`, or as a reused `Path`. Do not use `PointMode.polygon` because the human skeleton is not one continuous polyline.

### 11.3 Skeleton schema

Do not hard-code edges beside UI code. Use a schema registry:

    final class PoseSkeletonDefinition {
      final PoseLandmarkSchema schema;
      final int landmarkCount;
      final List<(int, int)> edges;
    }

Validate indices once. A result with the wrong count or unknown schema is rejected or rendered as points-only in debug mode.

### 11.4 Repaint boundaries

A `CustomPainter` repaint listener already avoids build/layout. A `RepaintBoundary` additionally isolates paint damage, but it can create another composited layer. Use it around the overlay, not blindly around the entire camera surface, and confirm with:

- DevTools repaint rainbow;
- paint timeline profiling;
- layer count;
- raster time before/after.

## 12. Riverpod and screen rebuild discipline

The top of `PoseTrainingScreen.build` currently watches the entire `poseSessionProvider`. Replace that pattern with small consumers:

- connection badge selects `isConnected`;
- score label selects a display-rate-limited score;
- rep label selects `repCount`;
- fatigue label selects `fatigueLevel`;
- instruction selects a distinct string;
- phase/navigation uses `ref.listen`, not a mutable callback field owned by the screen;
- overlay listens to `PoseOverlayController`, not session state;
- the one-second duration display uses a small notifier/consumer, not `setState` on the whole screen.

Do not store `lastResult.landmarks` in `PoseSessionState` after migration. If a last raw result is needed for diagnostics, put it in a debug repository/controller that does not drive the screen widget tree.

Prefer dependency injection through providers over `.instance` access in new code. Match the repository's current `StateNotifier` style for semantic session state during this feature; do not combine a Riverpod major-style migration with the overlay work.

## 13. Lifecycle, cancellation, and errors

### 13.1 App lifecycle

The runtime host implements `WidgetsBindingObserver`.

On inactive/paused:

- stop image stream;
- stop sampler/ticker;
- clear in-flight capacity;
- invalidate the camera generation;
- dispose camera controller according to plugin guidance;
- notify backend of pause if protocol supports it;
- keep or close WebSocket based on measured resume behavior and backend timeout.

On resumed:

- verify session is still valid;
- re-enumerate/reinitialize the selected camera;
- rebuild geometry from the new controller value;
- reset overlay/filter state;
- reconnect transport if required;
- resume capture only after camera and transport are ready.

### 13.2 Route/phase transitions

- Replace mutable `onPhaseChange` assignment with `ref.listen`.
- Await stream stop before navigation.
- Runtime, not either screen, decides whether camera resources survive.
- Use one idempotent `stop`/`dispose` future so repeated back/end/lifecycle actions do not race.
- Every asynchronous callback checks mounted state or runtime generation as appropriate.
- A late encoder/result callback from a previous generation is ignored.

### 13.3 Error model

Use typed failures:

    sealed class PoseRuntimeFailure
      CameraPermissionFailure
      CameraInitializationFailure
      EncoderFailure
      TransportConnectionFailure
      ProtocolFailure
      BackendFailure
      SessionExpiredFailure

User copy stays respectful and actionable. Logs include technical reason, session-safe correlation IDs, and metrics, but never raw JWTs or full image data.

Do not catch initialization errors and unconditionally mark the screen initialized.

## 14. Observability

### 14.1 Per-stage timing

For each sampled frame:

- capture callback elapsed time;
- plane-copy duration;
- encoder queue/compute duration;
- JPEG size;
- base64/serialization duration;
- send elapsed time;
- server queue/decode/inference/postprocess durations when supplied;
- receive elapsed time;
- parse duration;
- accepted/rejected reason;
- capture-to-result age;
- result-to-notify duration;
- result-to-first-paint duration where measurable.

Aggregate and log every 5 seconds or session end. Never log every frame in release.

### 14.2 Counters

- `cameraFramesObserved`
- `captureDroppedSampler`
- `captureDroppedEncoderBusy`
- `encodedFrames`
- `encodedDroppedTransportBusy`
- `framesSent`
- `resultsReceived`
- `resultsAccepted`
- `resultsDroppedOutOfOrder`
- `resultsDroppedStale`
- `resultsDroppedProtocol`
- `overlayPaints`
- `overlayHiddenStale`
- reconnects and lifecycle restarts

The debug UI should show rates and percentile ages, not a misleading green “synced” label derived from unrelated clocks.

## 15. Test strategy

### 15.1 Protocol tests

Fixtures must cover:

- v2 detection, calibration, sync, scoring, completed;
- legacy common `data`;
- phase-specific wrappers;
- completion event;
- backend error;
- string/number coercion policy;
- missing frame ID;
- wrong session ID;
- unknown schema;
- too few/many landmarks;
- null, NaN-like invalid input, infinities, and out-of-range coordinates;
- duplicate and out-of-order results.

Captured production messages must be scrubbed of user data before committing as fixtures.

### 15.2 Geometry tests

Use nine normalized anchors: corners, edge centers, and center.

For every orientation/lens/fit case assert exact expected viewport coordinates. Include:

- portrait 480×640 into portrait viewport;
- landscape 640×480;
- `BoxFit.cover` horizontal crop;
- `BoxFit.cover` vertical crop;
- `BoxFit.contain` letterbox;
- front mirror;
- payload mirrored but display unmirrored;
- 90/180/270-degree rotations;
- resize while result is in flight;
- stale geometry generation rejection.

### 15.3 Filter tests

Use a fake monotonic clock.

- stationary noisy point reduces RMS jitter;
- step movement reaches an agreed percentage within the latency budget;
- steady velocity prediction reduces mean error;
- direction reversal does not overshoot beyond cap;
- variable result intervals remain stable;
- confidence hysteresis avoids flicker;
- 250 ms gap removes the joint;
- reset prevents blending across sessions/orientations.

### 15.4 Backpressure tests

With fake camera, encoder, and transport:

- one active encoder request only;
- no camera-image queue;
- no more than configured unacknowledged frames;
- slow encoder drops early before plane copies;
- slow server does not grow memory;
- newest eligible frame wins;
- stopping invalidates late worker responses;
- reconnect resets in-flight accounting;
- all resources dispose exactly once.

### 15.5 Widget and painter tests

- 100 overlay updates do not rebuild a sentinel parent widget.
- Score change rebuilds only score subtree.
- Rep change is immediate.
- Overlay is non-interactive.
- Golden images cover full/partial/hidden confidence and edge crop.
- Skeleton never connects through an invisible endpoint.
- Stale overlay fades and disappears.
- Debug metadata is absent in release configuration.

### 15.6 On-device performance protocol

Run in profile mode on:

1. lowest supported Android device;
2. representative mid-tier device;
3. one high-tier device.

Scenarios:

- stationary user for 60 seconds;
- normal exercise for 3 minutes;
- fast arm movement for 60 seconds;
- poor network latency/jitter/loss;
- backend slowed intentionally;
- background/resume three times;
- orientation change if supported;
- 15-minute thermal soak.

Record DevTools timeline, CPU, memory, raster/build frames, frame-age histogram, send/result rate, battery/thermal notes, and a screen recording with frame IDs visible.

Do not profile “no lag” in debug mode.

## 16. Delivery phases

Each phase is separately reviewable and has a rollback flag.

### Phase 0 — truth and baseline

Work:

- capture scrubbed backend fixtures;
- reconcile `data` versus phase-specific wrappers;
- add frame/stage metrics around the existing pipeline;
- build coordinate debug overlay;
- measure existing encoder, transport, screen rebuild, and paint costs;
- document current front-camera behavior per target device.

Done when:

- baseline report contains percentiles, not anecdotes;
- one exact backend contract is agreed;
- current mapping error is reproducible;
- target device list is explicit.

### Phase 1 — typed and spatially correct overlay

Work:

- add typed landmark/schema models and decoder;
- add shared `PoseCameraViewport`;
- move painter to its own file;
- implement skeleton registry;
- add confidence thresholds/fade;
- drive painter with `Listenable`;
- separate overlay updates from the whole session state;
- add geometry, decoder, widget, and golden tests.

Done when:

- all anchor/orientation/mirror tests pass;
- parent rebuild sentinel stays unchanged during overlay updates;
- static reprojection budget passes;
- feature can fall back to old dots behind a flag.

### Phase 2 — frame identity and freshness

Work:

- introduce session `Stopwatch`, frame ID, and geometry generation;
- implement protocol v2 echo;
- add max-in-flight and stale/out-of-order rejection;
- replace misleading sync indicator with real frame-age state;
- add server stage metrics.

Done when:

- every accepted result traces to a submitted frame;
- no queue grows under a deliberately slow backend;
- stale/out-of-order test suite passes;
- capture-to-result percentiles are visible.

Backend v2 support is a dependency for full completion of this phase.

### Phase 3 — visual stabilization

Work:

- add One Euro filter;
- add confidence hysteresis and stale fade;
- add conservative prediction in `livePredictive`;
- add `frameLocked` diagnostic comparison;
- tune with recorded motion rather than hand-picked demos.

Done when:

- stationary jitter improves without violating step-response budget;
- prediction improves mean fast-motion error and does not worsen p95 beyond the agreed bound;
- scoring remains based on raw backend data.

### Phase 4 — capture/transport optimization

Work:

- prototype native YUV/JPEG or direct YUV transport;
- introduce binary WebSocket envelope;
- tune resolution, JPEG quality, result rate, and in-flight limit;
- remove per-frame debug prints and old encoder only after fallback soak passes.

Done when:

- p95 age, CPU, memory, and thermal results improve materially;
- pose accuracy does not regress;
- compatibility flag and rollback have been exercised.

### Phase 5 — on-device inference decision

Run a time-boxed spike if remote mode still cannot meet the product budget.

Compare:

- platform-native/on-device pose model latency;
- camera-frame to landmark transform simplicity;
- accuracy against backend;
- APK size and device coverage;
- battery/thermal cost;
- sending landmarks instead of user camera images;
- offline behavior and privacy.

Decision:

- keep remote inference if measured budgets pass;
- use on-device landmarks for live overlay and send compact landmarks/server summaries if backend scoring allows;
- retain remote frame-locked analysis only where server quality is materially better.

## 17. Coding conventions for this feature

### Types and names

- One public type per file unless two tiny types are inseparable.
- Use `final class` for concrete non-extendable runtime/model types.
- Use `sealed class` for exhaustive failures/states.
- Prefer const immutable values.
- No `dynamic` outside the JSON boundary.
- No `Map<String, dynamic>` outside decoder/service boundaries.
- Include units in time, size, and rate names.
- Use `clientFrameId`, not generic `frameNumber`, for client identity.
- Use `capturedElapsedUs`, not generic `timestamp`.
- Use `normalizedX/Y` or typed landmark fields; do not mix pixels and normalized values.
- Document coordinate space on every public x/y-bearing type.

### Ownership and async

- Inject services through providers in new code.
- One runtime owner disposes camera, worker, transport, ticker, and subscriptions.
- Stop/dispose methods are idempotent.
- Await lifecycle transitions.
- Track generation IDs to reject late async work.
- Never use an unbounded `StreamController`/list as a frame queue.
- Do not use a per-frame isolate spawn.
- Do not ignore worker errors.

### Rendering

- No `setState` or Riverpod state write per pose point/result solely to paint.
- No parsing, filtering, list construction, or `Paint` construction in `paint`.
- No `saveLayer`, blur, shader, or shadow without profile evidence.
- Keep visual constants in an immutable `PoseOverlayStyle`.
- Use `withValues(alpha: ...)` for new Flutter color code; do not add new deprecated opacity calls.
- Keep debug overlay behind compile-time/runtime debug configuration.

### Logging

- Use the existing structured logger direction, not emoji `print`.
- Throttle periodic metrics.
- Log IDs and durations, not frames, tokens, or personal data.
- User errors are friendly; technical causes remain in logs.

### Documentation

- Every protocol field has unit, coordinate space, and nullability.
- Every performance claim names device, build mode, scenario, and percentile.
- Any magic threshold includes a tuning source or TODO owner.
- Update this plan when an architecture decision changes; do not let screen comments become the protocol source of truth.

## 18. Pull request boundaries

Avoid one giant “performance” PR.

1. **PR: baseline and fixtures**
   - metrics, debug geometry, protocol fixtures; no production behavior change.
2. **PR: typed overlay and shared viewport**
   - models, decoder, overlay controller/painter, geometry tests, feature flag.
3. **PR: Riverpod rebuild isolation**
   - small selectors/consumers, duration notifier, phase listener.
4. **PR: protocol v2 freshness**
   - frame ID, monotonic capture time, server echo, capacity/age gate.
5. **PR: filter and prediction**
   - deterministic tests and before/after recordings.
6. **PR: encoder/transport optimization**
   - native/binary changes with fallback.

Each PR includes:

- targeted `dart format`;
- targeted `flutter analyze`;
- relevant unit/widget tests;
- `git diff --check`;
- performance evidence when touching the hot path;
- explicit note of unrelated existing analyzer/test debt;
- no unrelated working-tree files.

## 19. Release and rollback

Feature flags:

- `poseOverlayV2Enabled`
- `poseProtocolV2Enabled`
- `posePredictionEnabled`
- `poseBinaryTransportEnabled`
- `poseNativeEncoderEnabled`

Rollout:

1. internal debug devices;
2. staff/beta cohort with metrics;
3. small production cohort;
4. expand only if crash-free sessions, latency, mapping error, and thermal results pass.

Fallback order:

1. disable prediction;
2. disable v2 overlay but keep protocol identity/metrics;
3. disable binary transport;
4. disable native encoder;
5. hide overlay while preserving camera/session, rather than showing knowingly wrong points.

## 20. Definition of done

The feature is done only when all are true:

- backend contract and landmark schema are versioned;
- every accepted result is tied to a client capture ID;
- capture time is recorded before encoding with a monotonic session clock;
- camera/result coordinate spaces are documented;
- front/back, rotation, fit, crop, and mirror tests pass;
- overlay repaints without rebuilding/layout of the screen;
- no frame/result stage has an unbounded queue;
- stale/out-of-order results are rejected;
- smoothing/prediction are presentation-only and deterministic under tests;
- lifecycle pause/resume and route handoff are reliable;
- profile-mode device results meet the agreed budgets;
- 15-minute soak passes;
- metrics can explain where time is spent;
- old implementation and compatibility paths have an owned removal ticket/date;
- unrelated repository changes remain untouched.

## 21. Required contract answers before Phase 2

These do not block Phase 0/1, but implementation must not guess them:

1. Does the live backend return landmarks under `data`, phase-specific wrappers, or both?
2. What exact landmark schema/order is returned?
3. Are x/y relative to the pre-letterbox payload or the model tensor?
4. Does the backend currently preserve the client's `timestamp_ms`, and can it echo frame ID?
5. Are responses guaranteed in request order?
6. What are real server queue and inference percentiles?
7. Is front-camera payload expected mirrored or unmirrored?
8. Which Android devices and minimum OS are release targets?
9. Is 15 FPS pose inference sufficient for exercise scoring?
10. Can the backend accept binary JPEG or YUV/NV21?
11. Is on-device pose inference acceptable for privacy/offline/product architecture?

## 22. Documentation references

- Flutter `CustomPainter`: the repaint `Listenable` path avoids build and layout.
  <https://api.flutter.dev/flutter/rendering/CustomPainter-class.html>
- Flutter `RepaintBoundary`: isolates repaint work and should be profile-validated.
  <https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html>
- Flutter `Canvas.drawRawPoints`: typed-point Canvas API, not a synchronization solution.
  <https://api.flutter.dev/flutter/dart-ui/Canvas/drawRawPoints.html>
- Flutter camera package: initialization, image streaming, preview, and application-owned lifecycle behavior.
  <https://pub.dev/packages/camera>
- Dart isolate guidance: short-lived `Isolate.run` versus long-lived worker isolates and message passing.
  <https://dart.dev/language/isolates>

The implementation must continue to be checked against the versions locked in this repository and the supported physical devices; external API guidance does not replace device-level camera validation.
