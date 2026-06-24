# Workout WebSocket Integration — Mobile Team Answers

> Trả lời các câu hỏi từ PC team về protocol WebSocket workout session.
> Last updated: 2026-03-28

---

## 1. Giá trị `phase` là gì trong message?

**Phase là INT**, không phải string.

```json
{ "phase": 1, "phase_name": "detection" }
```

Tuy nhiên **có 5 phase**, không phải 3 như PC app đang giả định:

| phase (int) | phase_name (string) | Mô tả |
|-------------|---------------------|-------|
| 1 | `"detection"` | Phát hiện tư thế người dùng |
| 2 | `"calibration"` | Hiệu chỉnh góc khớp |
| 3 | `"sync"` | Đồng bộ với video (chính là training) |
| 4 | `"scoring"` | Tính điểm (real-time trong lúc tập) |
| 5 | `"completed"` | Hoàn thành toàn bộ session |

**Kết luận cho PC team:**
- Parse `phase` dưới dạng `int` — đúng.
- Nhưng mapping `3 → training` sai. Phase 3 là `sync` (camera + video), còn scoring xảy ra ở phase 4.
- Nên dùng cả hai field: `phase` (int để switch) + `phase_name` (string để debug/display).

Mobile model có `PosePhase.fromValue(int)` và `PosePhase.fromName(String)` để parse cả hai chiều.

---

## 2. Field names có đúng không?

**Không hoàn toàn đúng.** Dưới đây là field names chính xác từ mobile model:

### Phase 1 — Detection

| PC expect | Mobile gửi thực tế | Kiểu |
|-----------|-------------------|------|
| `pose_detected` | `pose_detected` | bool ✅ |
| `stable_count` | `stable_count` | int ✅ |
| `progress` | `progress` | double ✅ |
| _(không có)_ | `landmarks` | List ➕ extra |

### Phase 2 — Calibration

| PC expect | Mobile gửi thực tế | Kiểu |
|-----------|-------------------|------|
| `current_joint` | `current_joint` | String ✅ |
| `current_angle` | `current_angle` | double ✅ |
| `user_max_angle` | `user_max_angle` | double ✅ |
| `calibration_progress` | `progress` | double ⚠️ **tên khác** |
| `queue_index` | `queue_index` | int ✅ |
| `total_joints` | `total_joints` | int ✅ |
| _(không có)_ | `current_joint_name` | String ➕ |
| _(không có)_ | `overall_progress` | double ➕ |
| _(không có)_ | `status` | String ➕ |
| _(không có)_ | `countdown_remaining` | double ➕ |
| _(không có)_ | `position_instruction` | String ➕ |

> **Lỗi:** PC đọc `calibration_progress` — nhưng backend gửi là `progress`. Đây có thể là nguyên nhân UI không update phase 2.

### Phase 3 — Sync/Training (PC gọi là "training")

| PC expect | Mobile gửi thực tế | Kiểu |
|-----------|-------------------|------|
| `reps` | `rep_count` | int ⚠️ **tên khác** |
| `score` | `current_score` | double ⚠️ **tên khác** |
| `feedback` | _(không có field này)_ | ❌ **không tồn tại** |
| `stage` | _(không có field này)_ | ❌ **không tồn tại** |
| _(không có)_ | `video_frame` | String (base64) ➕ |
| _(không có)_ | `fatigue_level` | String ➕ |

> **Lỗi nghiêm trọng:** `reps` → thực tế là `rep_count`. `score` → thực tế là `current_score`. `feedback` và `stage` không tồn tại trong protocol này.

### Phase 4 — Scoring (PC không có case này)

```json
{
  "phase": 4,
  "phase_name": "scoring",
  "data": {
    "total_score": 85.5,
    "rom_score": 80.0,
    "stability_score": 90.0,
    "flow_score": 86.5,
    "grade": "B+"
  }
}
```

PC app nên xử lý phase 4 — hoặc ít nhất không crash khi nhận phase 4.

---

## 3. Phase transition xảy ra như thế nào?

**Phase transition nằm TRONG chính `frame_result` message** — không có message riêng kiểu `phase_change`.

Mỗi frame message đều có field `phase` (int). Khi backend chuyển phase, giá trị `phase` trong frame tiếp theo sẽ tăng lên. Mobile app detect transition bằng cách so sánh `phase` của frame hiện tại vs frame trước.

```json
// Frame n (phase 1)
{ "phase": 1, "phase_name": "detection", "data": { ... } }

// Frame n+1 (phase 2 — backend tự chuyển, không có message riêng)
{ "phase": 2, "phase_name": "calibration", "data": { ... } }
```

**Ngoài ra**, mobile service có một `Stream<PosePhase> phaseChanges` riêng được emit khi detect phase thay đổi — nhưng đây là logic phía mobile client, không phải message từ server.

**Kết luận cho PC team:**
- Không có message type `phase_change` riêng — đúng là PC app đang bỏ qua nếu có.
- Chỉ cần đọc field `phase` trong mỗi `frame_result` và xử lý khi thay đổi.
- Đề xuất: track `lastPhase`, nếu `currentPhase != lastPhase` thì trigger UI transition.

---

## 4. Cấu trúc đầy đủ của một WebSocket frame message

```json
{
  "phase": 2,
  "phase_name": "calibration",
  "timestamp": 1711612800.123,
  "frame_number": 342,
  "fps": 28.5,
  "message": "Hold the position",
  "warning": null,
  "data": {
    "current_joint": "left_shoulder",
    "current_joint_name": "Vai trái",
    "current_angle": 145.3,
    "user_max_angle": 170.0,
    "progress": 0.62,
    "queue_index": 1,
    "total_joints": 4,
    "overall_progress": 0.25,
    "status": "measuring",
    "countdown_remaining": 2.1,
    "position_instruction": "Giơ tay lên cao hơn"
  }
}
```

---

## 5. PC → Mobile pairing protocol (tham khảo thêm)

Luồng này dùng WebSocket **riêng** (kết nối tới PC local server), khác với WebSocket pose detection (kết nối tới backend server).

```
Mobile → PC:  { "type": "pair_request", "jwt": "...", "session_config": { "workout_id": "...", "exercise_type": "arm_raise" } }
PC → Mobile:  { "type": "pair_confirmed" }
Mobile → PC:  { "type": "heartbeat_ping" }  (mỗi 5 giây)
PC → Mobile:  { "type": "heartbeat_pong" }
PC → Mobile:  { "type": "session_started", "session_id": "..." }
PC → Mobile:  { "type": "session_complete" }
PC → Mobile:  { "type": "session_failed", "reason": "..." }
```

Timeout heartbeat: 15 giây (3 lần bỏ lỡ).

---

## Tóm tắt lỗi cần fix ở PC app

| # | Vấn đề | Fix |
|---|--------|-----|
| 1 | Chỉ có 3 phase cases, thiếu phase 4 và 5 | Thêm `case 4` (scoring) và `case 5` (completed) |
| 2 | Phase 2: đọc `calibration_progress` | Đổi thành `progress` |
| 3 | Phase 3: đọc `reps` | Đổi thành `rep_count` |
| 4 | Phase 3: đọc `score` | Đổi thành `current_score` |
| 5 | Phase 3: đọc `feedback`, `stage` | Xóa — field không tồn tại |
| 6 | Có thể bỏ qua message type không rõ | Không liên quan vì không có `phase_change` message riêng |

---

## 6. Cấu trúc message thực tế từ backend — CRITICAL

> Đây là phần quan trọng nhất. Mobile parse như thế nào thì PC phải làm y chang.

### Các loại message WebSocket nhận được

#### A. Frame result (message chính, liên tục)

```json
{
  "phase": 1,
  "phase_name": "detection",
  "timestamp": 1711612800.123,
  "frame_number": 342,
  "fps": 28.5,
  "message": "Stand in the frame",
  "warning": null,
  "detection": { ... }   ← Phase 1: data nằm ở đây
}
```

```json
{
  "phase": 2,
  "phase_name": "calibration",
  "calibration": { ... }  ← Phase 2: data nằm ở đây (có thể là "data" nếu không có "calibration")
}
```

```json
{
  "phase": 3,
  "phase_name": "sync",
  "sync": { ... }          ← Phase 3: data nằm ở đây
}
```

```json
{
  "phase": 4,
  "phase_name": "scoring",
  "final_report": { ... }  ← Phase 4: data nằm ở đây
}
```

> **⚠️ BUG NGHIÊM TRỌNG NHẤT:** Backend KHÔNG gửi data trong key `"data"` chung.
> Mỗi phase có key riêng: `detection` / `calibration` / `sync` / `final_report`.
> PC app đang đọc `message['data']` → luôn trả về null/empty → UI không update.

#### B. Session completed event (đặc biệt, gửi 1 lần)

```json
{
  "event": "session_completed"
}
```

Không có data. Chỉ là signal báo session kết thúc. Cần handle riêng, không parse như frame result.

#### C. Error message

```json
{
  "error": "Frame processing failed",
  "code": "500"
}
```

---

### Logic parse đúng (dịch từ Dart sang pseudocode)

```
function parseMessage(rawString):
  json = JSON.parse(rawString)

  // 1. Session completed event
  if json['event'] == 'session_completed':
    handleSessionCompleted()
    return

  // 2. Error
  if json.hasKey('error'):
    handleError(json['error'], json['code'])
    return

  // 3. Frame result — lấy data theo phase
  phase = json['phase']  // int: 1, 2, 3, 4, 5

  phaseData = {}
  if phase == 1:
    phaseData = json['detection'] ?? {}
  elif phase == 2:
    phaseData = json['calibration'] ?? json['data'] ?? {}  // fallback
  elif phase == 3:
    phaseData = json['sync'] ?? {}
  elif phase == 4:
    phaseData = json['final_report'] ?? {}
  else:
    phaseData = json['data'] ?? {}

  // 4. Extract top-level fields
  message  = json['message']       // String? — instruction text
  warning  = json['warning']       // String? — warning text
  fps      = json['fps']           // double
  frameNum = json['frame_number']  // int
  timestamp= json['timestamp']     // double (Unix seconds)

  // 5. Route to correct UI update
  switch phase:
    case 1: updateDetectionUI(phaseData, message)
    case 2: updateCalibrationUI(phaseData, message)
    case 3: updateSyncUI(phaseData, message)
    case 4: updateScoringUI(phaseData)
    case 5: handleCompleted()

  // 6. Check phase change (so sánh với phase trước)
  if phase != lastPhase:
    triggerPhaseTransition(lastPhase, phase)
    lastPhase = phase
```

---

### Toàn bộ fields theo phase (sau khi đã lấy đúng phaseData)

#### Phase 1 — `phaseData = json['detection']`

```
phaseData['pose_detected']  → bool
phaseData['stable_count']   → int
phaseData['progress']       → double (0.0 – 1.0)
phaseData['landmarks']      → List<{x, y, visibility}> (x,y là 0–1 relative)
```

#### Phase 2 — `phaseData = json['calibration']`

```
phaseData['current_joint']         → String  (e.g. "left_shoulder")
phaseData['current_joint_name']    → String  (tên hiển thị, tiếng Anh/Việt)
phaseData['current_angle']         → double  (góc hiện tại, độ)
phaseData['user_max_angle']        → double  (góc max đã đo được)
phaseData['progress']              → double  (0.0 – 1.0, tiến độ joint hiện tại)
phaseData['queue_index']           → int     (0-based, joint thứ mấy đang đo)
phaseData['total_joints']          → int     (tổng số joint cần calibrate)
phaseData['overall_progress']      → double  (tiến độ tổng, 0.0 – 1.0)
phaseData['status']                → String  ("measuring", "hold", "done")
phaseData['countdown_remaining']   → double  (giây còn lại, max 3.0)
phaseData['position_instruction']  → String  (hướng dẫn cho user)
```

#### Phase 3 — `phaseData = json['sync']`

```
phaseData['current_score']   → double  (điểm real-time, 0–100)
phaseData['rep_count']       → int     (số rep đã làm)
phaseData['fatigue_level']   → String  ("FRESH" | "MILD" | "MODERATE" | "HIGH")
phaseData['video_frame']     → String? (base64 frame ảnh trainer nếu có)
```

#### Phase 4 — `phaseData = json['final_report']`

```
phaseData['total_score']      → double
phaseData['rom_score']        → double  (Range of Motion score)
phaseData['stability_score']  → double
phaseData['flow_score']       → double
phaseData['grade']            → String  (e.g. "B+", "A")
```

#### Phase 5 — Completed

Không có phaseData đáng kể. Chỉ cần nhận phase=5 để navigate đến kết quả.

---

### REST API — End session (lấy kết quả cuối)

```
DELETE /api/pose/sessions/{session_id}

Response JSON:
{
  "data": {
    "session_id": "abc123",
    "exercise_name": "Arm Raise",
    "duration_seconds": 450,
    "total_score": 85.5,
    "rom_score": 80.0,
    "stability_score": 90.0,
    "flow_score": 86.5,
    "grade": "B+",
    "grade_color": "green",
    "total_reps": 12,
    "fatigue_level": "MILD",
    "calibrated_joints": [
      { "joint": "left_shoulder", "max_angle": 170.5 },
      { "joint": "right_shoulder", "max_angle": 165.2 }
    ],
    "rep_scores": [
      { "rep": 1, "score": 88.0 },
      { "rep": 2, "score": 82.5 }
    ],
    "recommendations": [
      "Lower your shoulders during extension",
      "Good knee alignment - keep it up"
    ]
  }
}
```

Note: `data` wrapper ở REST API là bình thường — chỉ WebSocket frame mới dùng named keys theo phase.

---

## 7. UI spec theo từng phase — PC team làm tương tự

> Màu chủ đạo: primary green `#00695C`, bg `#F1F7E8` / `#F1F8E9`, coral `#D67052`

---

### Phase 1 — Detection (`PoseDetectionScreen`)

```
┌──────────────────────────────────────┐  ← rounded bottom corners, bg #F1F8E9
│  [●1]──────[○2]                      │  ← phase indicator circles (1=green, 2=gray)
│  USER DETECTION                      │  ← title, bold
│  67%   [✓ Detected]                  │  ← % từ progress*100 | badge xanh/cam
└──────────────────────────────────────┘
│                                      │
│          CAMERA PREVIEW              │  ← front camera, full width
│          (front-facing)              │
│                              [LIVE]  │  ← top-right, green pill nếu connected
│                                      │
└──────────────────────────────────────┘
┌──────────────────────────────────────┐  ← rounded top corners, bg #F1F8E9, h=160
│         Detecting...                 │  ← title bold
│   Please stand in the frame to start │  ← subtitle gray, từ message backend
│                                      │
│          [■ End Session]             │  ← button 200px, bg #00695C
└──────────────────────────────────────┘
```

**Data fields cần đọc:**
| UI element | Field | Ghi chú |
|---|---|---|
| Progress % | `data.progress * 100` | 0.0–1.0 |
| Detected badge | `data.pose_detected` | bool → text + màu |
| Instruction text | `message` (top-level) | fallback: "Please stand in the frame to start" |
| LIVE/OFFLINE | `isConnected` (WebSocket state) | client-side |

---

### Phase 2 — Calibration (cùng screen, UI thay đổi)

```
┌──────────────────────────────────────┐  ← bg #F1F8E9
│  [●1]━━━━━━[●2]                      │  ← cả 2 indicator đều xanh
│  COLLECTING MEASUREMENTS             │
│  [⟳ left_shoulder]  [2/6]           │  ← joint badge (#00695C) + queue badge (blue)
│  145°  current angle   [Max: 170°]  │  ← angle lớn 24px + max badge coral
└──────────────────────────────────────┘
│          CAMERA PREVIEW              │
└──────────────────────────────────────┘
┌──────────────────────────────────────┐  ← h=160
│ [HOLD]    Calibrating...             │  ← circular timer trái, title giữa
│ [ 2s ]  Collecting measurements...  │  ← countdown + subtitle từ backend
│                                      │
│          [■ End Session]             │
└──────────────────────────────────────┘
```

**Data fields cần đọc:**
| UI element | Field | Ghi chú |
|---|---|---|
| Joint name badge | `data.current_joint` | e.g. "left_shoulder" |
| Queue counter | `data.queue_index + 1` / `data.total_joints` | 0-based → display 1-based |
| Current angle (lớn) | `data.current_angle` | double, format `145°` |
| Max angle badge | `data.user_max_angle` | coral badge "Max: 170°" |
| Circular timer | `data.countdown_remaining` | max=3.0s, progress = remaining/3.0 |
| Instruction | `message` (top-level) | fallback: "Collecting angle measurements..." |

**Circular timer spec:**
- Size: 63×63px, stroke width 6
- Green arc từ top, progress = `countdown_remaining / 3.0`
- Center text: "HOLD" + "{n}s"

---

### Calibration Complete (transition screen giữa phase 2→3)

```
[←]                              [🔔]
          Session Complete
          Knee Extension             ← tên bài tập (từ API)
    ┌─────────────────────┐
    │    120              │         ← circular arc xanh, center = rangeAngle (max-min)
    │    Range            │         ← label "Range"
    └─────────────────────┘
              [Target]              ← badge cam #D77658
          Great Effort!
  "You're making excellent progress..."

  ┌──────────┐  ┌──────────┐  ┌──────────┐
  │   20     │  │   140    │  │   Good   │
  │ Min Angle│  │ Max Angle│  │Amplitude │
  └──────────┘  └──────────┘  └──────────┘

       [          Done          ]   ← coral/orange, 301px
       [        Next Step       ]   ← teal, 301px → navigate to training
```

**Data từ phase 2 cần lưu lại để hiển thị:**
- `min_angle` — góc nhỏ nhất đo được (không có trong frame message — backend tổng hợp cuối phase 2)
- `max_angle` / `user_max_angle` — góc lớn nhất
- `rangeAngle` = `max_angle - min_angle` — hiển thị ở center vòng tròn

---

### Phase 3 — Sync/Training (`PoseTrainingScreen`)

```
┌──────────────────────────────────────┐
│[←]                                   │  ← back button, white circle, top-left
│                                      │
│  ┌── USER CAMERA (top 50%) ──────┐  │
│  │ [wifi]              [Score   ]│  │  ← wifi icon top-left | score top-right
│  │                     [  85.3  ]│  │  ← score màu: ≥80=green, ≥60=orange, <60=red
│  │   [pose landmark dots/lines]  │  │  ← green dots on body joints
│  │                               │  │
│  │[● LIVE ANALYSIS]  [⟳ SYNCED] │  │  ← bottom of camera area
│  └───────────────────────────────┘  │
│                                      │
│  ┌── TRAINER VIDEO (bottom 50%) ─┐  │
│  │ [▶ Trainer View]              │  │  ← badge top-left
│  │   (looping video, muted)      │  │
│  └───────────────────────────────┘  │
│                                      │
│┌────────────────────────────────────┐│  ← bottom panel h=110, rounded top, #F1F8E9
││ [00:45 ] [3    ] Analyzing...      ││  ← Duration | Reps | message từ backend
││ Duration  Reps   Fatigue: FRESH    ││  ← fatigue màu: FRESH=green, MODERATE=orange
││                                    ││
││           [■ End]                  ││  ← button 160px, #00695C
│└────────────────────────────────────┘│
└──────────────────────────────────────┘
```

**Data fields cần đọc:**
| UI element | Field | Ghi chú |
|---|---|---|
| Score (top-right camera) | `data.current_score` | ≥80=green, ≥60=orange, <60=red |
| Rep count | `data.rep_count` | int, update real-time |
| Duration | client timer (tick mỗi giây) | không từ backend |
| Message | `message` (top-level) | fallback: "Analyzing..." |
| Fatigue level | `data.fatigue_level` | FRESH/MILD/MODERATE/HIGH |
| Pose landmarks | `data.landmarks` | array `[{x, y, visibility}]` — vẽ dot nếu visibility>0.5 |
| LIVE/OFFLINE badge | WebSocket connection state | client-side |
| SYNCED/SYNCING badge | abs(syncOffset) < 100ms | so sánh user timestamp vs video position |

**Pose landmark overlay:**
- Mỗi landmark: `{x: 0-1, y: 0-1, visibility: 0-1}`
- x,y là tỉ lệ relative to frame size → nhân với widget width/height để ra pixel
- Chỉ vẽ nếu `visibility > 0.5`
- Màu dot: green, radius 5px

---

### Training Complete (kết quả cuối session)

```
[←]                              [🔔]
          Session Complete
          Knee Extension
    ┌─────────────────────┐
    │    85               │         ← circular arc xanh, center = total_score
    │    Score            │
    └─────────────────────┘
          Great Effort!
  "You're making excellent progress..."

  ┌──────────┐  ┌──────────┐  ┌──────────┐
  │  12:30   │  │   92%    │  │   45     │
  │   Min    │  │ Accuracy │  │  Kcal    │
  └──────────┘  └──────────┘  └──────────┘

  ─── What to improve ───

  ┌────────────────────────────────────┐
  │ (↓)  Lower shoulders              │  ← red circle icon = warning
  │      Relax your upper back...     │
  └────────────────────────────────────┘
  ┌────────────────────────────────────┐
  │ (✓)  Good Knee alignment          │  ← green circle icon = good
  │      Perfect stability...         │
  └────────────────────────────────────┘

       [           Done           ]  ← coral/orange
       [       To Homepage        ]  ← teal
```

**Data từ API kết thúc session (DELETE /api/pose/sessions/{id}):**
| UI element | Field từ API |
|---|---|
| Score (center vòng tròn) | `total_score` |
| Arc progress | `total_score / 100` |
| Duration | `duration_seconds` (format MM:SS) |
| Accuracy | tính từ `flow_score` hoặc `rom_score` |
| Calories | `calories_burned` (nếu có) |
| Improvement cards | `recommendations` (array) |
| Good/Warning | mỗi item trong `recommendations` có type/isWarning |

---

### Tóm tắt luồng màn hình PC cần làm

```
[Pairing QR scan]
       ↓
[Phase 1: Detection screen]  → progress bar + pose detected badge
       ↓ (auto khi backend gửi phase=2)
[Phase 2: Calibration screen]  → joint name, angle, countdown timer
       ↓ (auto khi backend gửi phase=3)
[Calibration Complete interstitial]  → range angle, min/max stats
       ↓ (user nhấn Next Step)
[Phase 3: Training screen]  → dual view (user cam + trainer video) + score + reps
       ↓ (user nhấn End hoặc backend gửi phase=5)
[Training Complete screen]  → final score, improvement cards
```

---

## 8. Video link bài tập — cách gửi và cách PC dùng

### Video URL đến từ đâu?

Khi user mở bài tập trên mobile, app lấy `video_path` từ API workout detail:

```json
// GET /api/workouts/{id} → WorkoutModel
{
  "id": "abc123",
  "exercise_type": "arm_raise",
  "video_path": "/media/exercises/arm_raise_demo.mp4"
}
```

Full video URL = `baseUrl + video_path` = `http://100.27.167.208:8005/media/exercises/arm_raise_demo.mp4`

Đây là URL public (không cần JWT), PC fetch trực tiếp được.

---

### Vấn đề hiện tại — video_url CHƯA được gửi sang PC

`buildPairRequest` hiện tại chỉ gửi:

```json
{
  "type": "pair_request",
  "jwt": "...",
  "session_config": {
    "workout_id": "abc123",
    "exercise_type": "arm_raise"
  }
}
```

**`video_url` không có trong message này** — PC không biết link video để play ở phase 3.

---

### Fix: Mobile team cần thêm `video_url` vào `pair_request`

Sửa `buildPairRequest` trong [pc_session_model.dart](lib/features/workout/models/pc_session_model.dart:75) để gửi thêm full video URL:

```json
{
  "type": "pair_request",
  "jwt": "...",
  "session_config": {
    "workout_id": "abc123",
    "exercise_type": "arm_raise",
    "video_url": "http://100.27.167.208:8005/media/exercises/arm_raise_demo.mp4"
  }
}
```

Phía mobile, URL được build như sau (xem [pose_training_screen.dart](lib/features/workout/screens/pose_training_screen.dart:116)):

```dart
// video_path là relative path từ API (e.g. "/media/exercises/arm_raise.mp4")
// baseUrl = "http://100.27.167.208:8005"
final fullVideoUrl = '${ApiConstants.baseUrl}${videoPath}';
```

Nếu `videoPath` là null/empty → không có video, PC hiển thị placeholder "Reference Video".

---

### PC team: xử lý video_url như thế nào?

#### 1. Lưu khi nhận `pair_request`

```
onMessage(pair_request):
  sessionConfig = msg['session_config']
  workoutId    = sessionConfig['workout_id']
  exerciseType = sessionConfig['exercise_type']
  videoUrl     = sessionConfig['video_url']  // có thể null

  storeVideoUrl(videoUrl)  // dùng ở phase 3
  send({ "type": "pair_confirmed" })
```

#### 2. Load video khi phase 3 bắt đầu

```
onPhaseChange(newPhase):
  if newPhase == 3 (sync):
    if storedVideoUrl != null:
      initVideoPlayer(storedVideoUrl)
      videoPlayer.setLooping(true)
      videoPlayer.setVolume(0)   // muted
      videoPlayer.play()
    else:
      showPlaceholder("Reference Video")
```

#### 3. SYNCED / SYNCING badge

Mobile tính sync offset = `|userTimestamp - videoPosition|` theo ms:

```
syncOffset = abs(userFrameTimestamp - videoPlayer.currentPosition_ms)
label = syncOffset < 100 ? "SYNCED" : "SYNCING"
color = syncOffset < 100 ? green : orange
```

`userFrameTimestamp` = thời gian user bắt đầu phase 3 tính từ đầu session (ms).

#### 4. Fallback nếu không có video

- Hiển thị icon person + text "Reference Video" (màu xám)
- App vẫn hoạt động bình thường — video chỉ là reference, không ảnh hưởng scoring

---

### Toàn bộ data nhận được khi pairing (sau khi fix)

```
Mobile → PC:  pair_request
{
  "type": "pair_request",
  "jwt": "<access_token>",
  "session_config": {
    "workout_id": "abc123",
    "exercise_type": "arm_raise",
    "video_url": "http://100.27.167.208:8005/media/exercises/arm_raise_demo.mp4"
  }
}

PC → Mobile:  pair_confirmed
{ "type": "pair_confirmed" }
```

Sau đó mobile bắt đầu stream camera frame lên backend WebSocket (không liên quan đến kết nối PC). PC chỉ cần lưu `video_url` và chờ phase 3.

---

## 9. Endpoint lấy workout detail — xác nhận cho PC team

### Endpoint đúng

**Không có `/api/workouts/{id}`** trong hệ thống. Backend dùng task-based API:

```
GET /api/tasks/{task_id}
Authorization: Bearer {jwt}

Response:
{
  "data": {
    "task_id": "abc123",
    "title": "Knee Extension",
    "exercise_detail": {
      "exercise_id": "ex001",
      "exercise_name": "Knee Extension",
      "description": "...",
      "duration_minutes": 15,
      "difficulty_level": 2,
      "video_path": "/media/exercises/knee_extension.mp4"   ← đây
    }
  }
}
```

`video_path` nằm trong `exercise_detail`, không phải top-level. Full URL = `baseUrl + video_path`.

---

### PC team: KHÔNG cần tự fetch — mobile đã gửi luôn trong `pair_request`

Sau fix ở section 8, PC nhận `video_url` đã là full URL sẵn trong `session_config`:

```json
{
  "type": "pair_request",
  "session_config": {
    "workout_id": "abc123",
    "exercise_type": "arm_raise",
    "video_url": "http://100.27.167.208:8005/media/exercises/arm_raise.mp4"
  }
}
```

**PC chỉ cần dùng `video_url` này — không cần gọi thêm API nào.**

---

### Nếu PC vẫn muốn tự fetch (fallback khi `video_url` absent)

Dùng endpoint:
```
GET http://100.27.167.208:8005/api/tasks/{workout_id}
Authorization: Bearer {jwt}   ← lấy từ jwt field trong pair_request
```

Extract:
```
videoPath = response['data']['exercise_detail']['video_path']
fullUrl   = "http://100.27.167.208:8005" + videoPath
```

**Không dùng `/api/workouts/{id}` — endpoint đó không tồn tại.**

---

### Tóm tắt quyết định

| Tình huống | Làm gì |
|---|---|
| `session_config.video_url` có giá trị | Dùng thẳng, không fetch thêm |
| `session_config.video_url` là null/absent | Fetch `GET /api/tasks/{workout_id}` với JWT từ pair_request, lấy `exercise_detail.video_path` |
| Cả hai đều null | Show placeholder "Reference Video", không ảnh hưởng scoring |
