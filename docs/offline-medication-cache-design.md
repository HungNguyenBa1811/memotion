# Offline Medication Cache & Alarm Design

**Author**: Senior Flutter Review
**Date**: 2026-03-02
**Status**: Design Proposal

---

## 1. Vấn đề hiện tại

### 1.1 Flow hiện tại

```
[Online Only]

API Server (/api/tasks/medication-tasks?task_date=...)
    ↓ Dio + Auth interceptor
TaskApiService.getMedicationTasksByDate(date)
    ↓ List<TaskDto>
MedicationRepository.getMedicationsForDate(date)
    ↓ TaskDtoMapper → List<Medication>
Riverpod medicationsProvider (FutureProvider - cache trong RAM)
    ↓
UI: MedicationMainScreenContent

[Alarm Scheduling - thủ công]
MedicationReminderScreen → "Simulate API Sync" button
    ↓ raw Map<String, dynamic>
MedicationScheduler.syncTasks(apiResponse)
    ├─ Parse → List<MedicationTask>
    ├─ Filter future tasks
    └─ For each: SharedPreferences.set() + Alarm.set()
```

### 1.2 Các điểm yếu nghiêm trọng

| Vấn đề | Mức độ | Ảnh hưởng |
|--------|--------|-----------|
| Alarm scheduling hoàn toàn thủ công (qua nút UI demo) | Critical | Alarm không bao giờ được set trong production |
| Không có offline cache cho medication data | Critical | App vô dụng khi mất mạng |
| SharedPreferences chỉ lưu task riêng lẻ khi alarm được set | High | App restart → mất alarm context nếu chưa fire |
| Riverpod FutureProvider chỉ cache trong RAM | High | App restart → cache mất, phải fetch lại |
| Không có auto-reschedule khi app restart | High | Alarm đã schedule qua `alarm` package vẫn fire nhưng task data có thể không còn trong SharedPrefs |
| `/api/tasks/medication` (bulk endpoint) chưa được dùng | Medium | Đang gọi endpoint by-date thay vì fetch toàn bộ |
| syncTasks() nhận raw Map, không gọi API trực tiếp | High | Coupling kỳ lạ - scheduler không tự fetch |

### 1.3 Kịch bản nguy hiểm

```
Scenario: App restart sau khi alarm đã được schedule

1. User mở app (có mạng) → không có gì tự động schedule alarm
2. User vào MedicationReminderScreen → bấm "Simulate" → alarm được set
3. App bị kill / device restart
4. native alarm package (alarm) vẫn fire alarm vào đúng giờ
5. App được launch lại từ alarm → MedicationAlarmScreen(alarmId: X)
6. MedicationScheduler.getTaskByAlarmId(X) → SharedPreferences.get('medication_task_X')
   → Nếu SharedPrefs bị clear (device restart, system clear) → null
   → UI hiển thị trống hoặc crash
```

---

## 2. Mục tiêu thiết kế

1. **Offline-first**: Alarm hoạt động ngay cả khi hoàn toàn mất mạng
2. **Auto-sync**: Tự động fetch và schedule alarm khi app khởi động
3. **Persistent cache**: Dữ liệu thuốc tồn tại qua app restart, device reboot
4. **Idempotent scheduling**: Reschedule alarm an toàn, không duplicate
5. **Minimal API calls**: Dùng bulk endpoint `/api/tasks/medication` thay vì per-date

---

## 3. Đề xuất kiến trúc

### 3.1 Tổng quan

```
┌─────────────────────────────────────────────────────────────┐
│                      DATA SOURCES                           │
│                                                             │
│  ┌──────────────────┐    ┌──────────────────────────────┐  │
│  │   Remote Source  │    │      Local Cache             │  │
│  │                  │    │                              │  │
│  │ GET /api/tasks/  │    │  MedicationCacheStore        │  │
│  │   medication     │    │  (SharedPreferences/SQLite)  │  │
│  │                  │    │  - cachedAt timestamp        │  │
│  │                  │    │  - List<MedicationTask> JSON │  │
│  └────────┬─────────┘    └──────────────┬───────────────┘  │
│           │                             │                   │
└───────────┼─────────────────────────────┼───────────────────┘
            │                             │
            ▼                             ▼
┌───────────────────────────────────────────────────────────┐
│              MedicationSyncService (NEW)                   │
│                                                           │
│  syncOnAppLaunch()                                        │
│    1. Check connectivity                                  │
│    2. If online: fetch → validate → persist cache         │
│    3. If offline: read cache                              │
│    4. Schedule alarms from data (online or cached)        │
│    5. Return SyncResult                                   │
│                                                           │
│  refreshCache()  - force refresh khi có mạng trở lại     │
│  getCachedTasks() - đọc từ cache, dùng cho UI offline    │
└───────────────────────────────────┬───────────────────────┘
                                    │
            ┌───────────────────────┼───────────────────┐
            ▼                       ▼                   ▼
┌──────────────────┐   ┌─────────────────────┐  ┌──────────────────┐
│ MedicationCache  │   │  AlarmScheduleEngine │  │ ConnectivitySvc  │
│    Store (NEW)   │   │       (NEW)          │  │    (NEW)         │
│                  │   │                      │  │                  │
│ - persist()      │   │ - scheduleAll()      │  │ - isOnline()     │
│ - restore()      │   │ - rescheduleAll()    │  │ - onRestore      │
│ - isExpired()    │   │ - cancelOutdated()   │  │   stream         │
│ - clear()        │   │ - isSafeToSchedule() │  └──────────────────┘
│ TTL: 24h default │   │                      │
└──────────────────┘   └──────────────────────┘
```

### 3.2 Các class mới cần tạo

#### `MedicationCacheStore`
```
lib/features/medication/data/medication_cache_store.dart
```

Trách nhiệm: Lưu/đọc toàn bộ danh sách medication task vào local storage.

```dart
class MedicationCacheStore {
  static const _cacheKey = 'medication_all_tasks_cache';
  static const _cacheMetaKey = 'medication_cache_meta';
  static const _defaultTtl = Duration(hours: 24);

  // Persist toàn bộ list (thay raw JSON để giảm parse overhead)
  Future<void> persist(List<MedicationTask> tasks);

  // Restore từ storage, trả null nếu chưa có / expired
  Future<List<MedicationTask>?> restore({Duration? maxAge});

  // Kiểm tra xem cache có còn hợp lệ không
  Future<bool> isValid({Duration? maxAge});

  // Metadata: cachedAt, count, source (api/manual)
  Future<CacheMetadata?> getMetadata();

  // Xóa cache (logout, reset)
  Future<void> clear();
}

class CacheMetadata {
  final DateTime cachedAt;
  final int taskCount;
  final String source; // 'api' | 'manual'
}
```

**Storage strategy**: SharedPreferences với key duy nhất, lưu JSON array. Với dataset lớn hơn (>100 tasks), migrate sang SQLite (drift/sqflite).

#### `AlarmScheduleEngine`
```
lib/features/medication/data/alarm_schedule_engine.dart
```

Trách nhiệm: Quản lý lifecycle của alarms — schedule, reschedule, cancel. Tách khỏi `MedicationScheduler` hiện tại (đang bị coupling với raw API response).

```dart
class AlarmScheduleEngine {
  // Schedule tất cả tasks trong tương lai, bỏ qua tasks đã qua
  // Idempotent: set lại alarm đã tồn tại sẽ override (alarm package hỗ trợ)
  Future<ScheduleResult> scheduleAll(List<MedicationTask> tasks);

  // Hủy các alarm của tasks đã past hoặc completed
  Future<void> cancelOutdated(List<MedicationTask> tasks);

  // Kiểm tra alarm còn active không (dùng Alarm.getAlarms())
  Future<bool> isAlarmActive(int alarmId);

  // Reschedule toàn bộ (dùng khi app restart)
  Future<ScheduleResult> rescheduleAll(List<MedicationTask> tasks);

  // Persist mapping alarmId → MedicationTask (thay thế logic trong MedicationScheduler)
  Future<void> persistTaskMapping(MedicationTask task);
  Future<MedicationTask?> getTaskByAlarmId(int alarmId);
  Future<void> removeTaskMapping(int alarmId);
}

class ScheduleResult {
  final int scheduled;
  final int skipped;  // past tasks
  final int failed;
  final List<String> errors;
}
```

#### `MedicationSyncService`
```
lib/features/medication/data/medication_sync_service.dart
```

Trách nhiệm: Orchestrator chính. Gọi khi app launch, network restored, hoặc user pull-to-refresh.

```dart
class MedicationSyncService {
  final TaskApiService _apiService;
  final MedicationCacheStore _cacheStore;
  final AlarmScheduleEngine _alarmEngine;
  final ConnectivityService _connectivity;

  // Entry point từ main.dart hoặc app lifecycle
  Future<SyncResult> syncOnAppLaunch();

  // Gọi khi detect network restored (stream)
  Future<SyncResult> refreshCache();

  // Lấy tasks để hiển thị trong UI (cache-first)
  Future<List<MedicationTask>> getCachedTasks();

  // Filter theo ngày (dùng trong MedicationRepository thay vì gọi API)
  Future<List<MedicationTask>> getTasksForDate(DateTime date);
}

class SyncResult {
  final SyncSource source; // SyncSource.api | SyncSource.cache | SyncSource.none
  final int taskCount;
  final int alarmsScheduled;
  final DateTime? cachedAt;
  final String? error;
}

enum SyncSource { api, cache, none }
```

#### `ConnectivityService`
```
lib/core/services/connectivity_service.dart
```

Trách nhiệm: Wrapper cho `connectivity_plus`, cung cấp stream và one-shot check.

```dart
class ConnectivityService {
  // True nếu có kết nối internet thực (không chỉ WiFi connected)
  Future<bool> isOnline();

  // Stream emit true khi network restored từ offline
  Stream<bool> get onConnectivityRestored;

  // Stream emit false khi mất mạng
  Stream<bool> get onConnectivityLost;
}
```

---

### 3.3 Thay đổi trong code hiện tại

#### `main.dart` — App bootstrap

Hiện tại:
```dart
// Chỉ init alarm package và permission
await Alarm.init();
Alarm.ringing.listen(_onAlarmRing);
```

Đề xuất thêm:
```dart
// Sau Alarm.init():
final syncService = MedicationSyncService(...);
final result = await syncService.syncOnAppLaunch();
// result.source cho biết dùng API hay cache

// Listen network restored để auto-refresh
connectivityService.onConnectivityRestored.listen((_) async {
  await syncService.refreshCache();
});
```

#### `MedicationRepository` — Cache-first reads

Hiện tại: Luôn gọi `TaskApiService.getMedicationTasksByDate(date)`.

Đề xuất:
```dart
Future<List<Medication>> getMedicationsForDate(DateTime date) async {
  try {
    // Thử API trước
    final dtos = await _taskApiService.getMedicationTasksByDate(date);
    // Update cache
    await _syncService.updateCacheFromDtos(dtos, date);
    return TaskDtoMapper.toMedicationList(dtos);
  } on NetworkException {
    // Fallback sang cache
    final cachedTasks = await _syncService.getTasksForDate(date);
    if (cachedTasks.isEmpty) rethrow;
    return cachedTasks.map(_taskToMedication).toList();
  }
}
```

#### `MedicationScheduler` — Deprecate / Delegate

Giữ nguyên public API để không break alarm screen, nhưng bên trong delegate sang `AlarmScheduleEngine`:

```dart
class MedicationScheduler {
  // Deprecated: syncTasks() nhận raw Map — thay bằng MedicationSyncService.syncOnAppLaunch()
  @Deprecated('Use MedicationSyncService.syncOnAppLaunch()')
  static Future<int> syncTasks(Map<String, dynamic> apiResponse) async {
    // Giữ để không break MedicationReminderScreen hiện tại
  }

  // Delegate sang AlarmScheduleEngine
  static Future<MedicationTask?> getTaskByAlarmId(int alarmId) =>
      _engine.getTaskByAlarmId(alarmId);

  static Future<void> removeTask(int alarmId) =>
      _engine.removeTaskMapping(alarmId);
}
```

---

## 4. Luồng dữ liệu mới (Offline-First)

### 4.1 App Launch

```
App Launch (main.dart)
    │
    ├─ Alarm.init()
    ├─ Permission checks
    │
    └─ MedicationSyncService.syncOnAppLaunch()
            │
            ├─ ConnectivityService.isOnline()?
            │       │
            │  YES  ├─→ TaskApiService.getAllMedicationTasks()
            │       │         → GET /api/tasks/medication
            │       │         → List<MedicationTask>
            │       │   ↓
            │       ├─→ MedicationCacheStore.persist(tasks)
            │       │         → SharedPrefs: cachedAt = now
            │       │   ↓
            │       └─→ AlarmScheduleEngine.rescheduleAll(tasks)
            │                 → Filter: task.dueDate > now
            │                 → Alarm.set() for each
            │                 → AlarmEngine.persistTaskMapping()
            │
            │  NO   └─→ MedicationCacheStore.restore()
            │                 → isExpired? (> 24h) → SyncResult.source = none
            │                 → valid? → List<MedicationTask>
            │                   ↓
            │           AlarmScheduleEngine.rescheduleAll(cachedTasks)
            │                 → Reschedule từ cache
            │
            └─ SyncResult(source, taskCount, alarmsScheduled)
```

### 4.2 UI Fetch (Medication List Screen)

```
MedicationMainScreen mounted
    │
    └─ medicationsProvider.watch(date)
            │
            └─ MedicationRepository.getMedicationsForDate(date)
                    │
                    ├─ Online? → API call → cache update → return
                    │
                    └─ Offline?
                            │
                            └─ MedicationSyncService.getTasksForDate(date)
                                    │
                                    └─ MedicationCacheStore.restore()
                                            → filter by date
                                            → TaskDtoMapper → List<Medication>
                                            → [OFFLINE BANNER shown in UI]
```

### 4.3 Alarm Fires (Background)

```
Native alarm fires (app may be killed)
    │
    └─ App launched by alarm package
            │
            └─ main.dart:_onAlarmRing(AlarmSet)
                    │
                    ├─ AlarmScheduleEngine.getTaskByAlarmId(alarmId)
                    │         → SharedPrefs: 'alarm_task_{id}'
                    │         → Deserialize MedicationTask
                    │
                    └─ Push MedicationAlarmScreen(task: task)
                            │
                            ├─ Display: name, dosage, notes, image
                            │
                            └─ User: "Mark as Taken"
                                    ├─ Alarm.stop(alarmId)
                                    ├─ AlarmEngine.removeTaskMapping(alarmId)
                                    └─ [Optional] Queue API call: completeTask(task.taskId)
                                              → If offline: store in pending queue
                                              → Sync when online
```

### 4.4 Network Restored

```
ConnectivityService.onConnectivityRestored emits true
    │
    └─ MedicationSyncService.refreshCache()
            ├─ Fetch fresh data from API
            ├─ Merge với pending completion queue
            ├─ Update cache
            └─ Reschedule alarms (idempotent)
```

---

## 5. Pending Actions Queue (Offline Completion)

Khi user bấm "Mark as Taken" lúc offline, cần queue lại để sync sau:

```dart
class PendingActionsQueue {
  // Thêm action vào queue
  Future<void> enqueue(PendingAction action);

  // Drain queue khi online
  Future<void> drainWhenOnline();

  // Lấy tất cả pending actions
  Future<List<PendingAction>> getPending();
}

class PendingAction {
  final String taskId;
  final PendingActionType type; // complete, skip
  final DateTime queuedAt;
}
```

Đây là optional trong phase 1, nhưng critical cho UX hoàn chỉnh.

---

## 6. Cấu trúc file đề xuất

```
lib/
├── core/
│   └── services/
│       └── connectivity_service.dart          [NEW]
│
└── features/
    └── medication/
        ├── data/
        │   ├── medication_api_service.dart     [existing - deprecated]
        │   ├── medication_cache_store.dart     [NEW]
        │   ├── medication_repository.dart      [MODIFY - add cache fallback]
        │   ├── medication_scan_service.dart    [existing - no change]
        │   ├── medication_scheduler.dart       [MODIFY - delegate to engine]
        │   ├── medication_sync_service.dart    [NEW]
        │   ├── alarm_schedule_engine.dart      [NEW]
        │   └── pending_actions_queue.dart      [NEW - optional phase 2]
        │
        ├── models/
        │   ├── cache_metadata.dart             [NEW]
        │   ├── sync_result.dart                [NEW]
        │   └── ... (existing models unchanged)
        │
        └── providers/
            ├── medication_provider.dart        [MODIFY - offline banner state]
            └── medication_sync_provider.dart   [NEW - sync status]
```

---

## 7. Riverpod Providers mới

```dart
// Cung cấp MedicationCacheStore
final medicationCacheStoreProvider = Provider<MedicationCacheStore>((ref) {
  return MedicationCacheStore();
});

// Cung cấp AlarmScheduleEngine
final alarmScheduleEngineProvider = Provider<AlarmScheduleEngine>((ref) {
  return AlarmScheduleEngine();
});

// Cung cấp ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// Sync status (có thể watch từ UI)
final medicationSyncStatusProvider = StateProvider<SyncResult?>((ref) => null);

// Override medicationsProvider để hỗ trợ offline
// Thay vì chỉ throw khi NetworkException, fallback sang cache
final medicationsProvider = FutureProvider.family<List<Medication>, DateTime>((ref, date) async {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.getMedicationsForDate(date); // repo giờ tự handle offline
});

// Offline status để show banner trong UI
final isOfflineProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return connectivity.onConnectivityLost.map((_) => true)
      .mergeWith([connectivity.onConnectivityRestored.map((_) => false)]);
});
```

---

## 8. UI Changes

### Offline Banner
Hiển thị banner trong `MedicationMainScreen` khi offline:

```dart
// Trong MedicationMainScreenContent build():
final isOffline = ref.watch(isOfflineProvider).valueOrNull ?? false;

if (isOffline)
  Container(
    color: Colors.orange.shade100,
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        Icon(Icons.wifi_off, size: 16, color: Colors.orange),
        SizedBox(width: 8),
        Text('Hiển thị dữ liệu đã lưu', style: TextStyle(color: Colors.orange.shade800)),
      ],
    ),
  ),
```

### Cache Info (Debug / Settings)
Hiển thị thông tin cache trong Settings hoặc debug panel:
- "Dữ liệu thuốc: Cập nhật lúc 08:30 - 2026-03-02"
- "5 alarm đã được lập lịch"

---

## 9. Dependency cần thêm

```yaml
# pubspec.yaml
dependencies:
  connectivity_plus: ^6.0.3    # Network connectivity detection
  # SQLite (optional, nếu dataset lớn):
  # drift: ^2.18.0
  # drift_flutter: ^0.2.0
```

---

## 10. Kế hoạch triển khai (Phases)

### Phase 1 — Core Cache & Auto-Sync (Priority: Critical)
- [ ] `MedicationCacheStore` — persist/restore toàn bộ task list
- [ ] `AlarmScheduleEngine` — tách logic schedule khỏi `MedicationScheduler`
- [ ] `MedicationSyncService.syncOnAppLaunch()` — auto-sync khi mở app
- [ ] Tích hợp vào `main.dart`
- [ ] `MedicationRepository` — cache fallback khi offline

### Phase 2 — Connectivity & Refresh (Priority: High)
- [ ] `ConnectivityService` — detect online/offline
- [ ] `MedicationSyncService.refreshCache()` — refresh khi mạng restored
- [ ] Offline banner trong UI
- [ ] Provider cho sync status

### Phase 3 — Offline Completion Queue (Priority: Medium)
- [ ] `PendingActionsQueue` — queue "Mark as Taken" khi offline
- [ ] Drain queue khi network restored
- [ ] Merge với cache update

### Phase 4 — Polish (Priority: Low)
- [ ] SQLite migration nếu task count lớn
- [ ] Cache versioning (invalidate khi schema thay đổi)
- [ ] Unit tests cho cache store và sync service
- [ ] Analytics: track cache hit/miss ratio

---

## 11. Các rủi ro và trade-offs

| Rủi ro | Giải pháp |
|--------|-----------|
| Cache stale sau 24h | TTL có thể config; show timestamp trong UI |
| SharedPreferences không phù hợp cho dataset lớn | Migration path sang SQLite/drift |
| Alarm.set() limit (Android có giới hạn exact alarms) | Chỉ schedule alarm trong 7 ngày tới |
| Concurrent sync calls (network restored + manual refresh) | Mutex/flag để chỉ cho 1 sync chạy |
| Task được update trên server nhưng cache stale | Sync khi app foreground (AppLifecycleState.resumed) |
| alarmId collision (hashCode của String) | Đã là risk hiện tại; consider UUID-based ID |

---

## 12. Tóm tắt

Kiến trúc hiện tại có foundation tốt (clean separation, Riverpod) nhưng thiếu:
1. **Auto-sync**: Alarm không bao giờ tự được schedule trong production flow
2. **Offline cache**: Không có fallback khi mất mạng
3. **Persistence**: Riverpod cache mất khi app restart

Solution đề xuất thêm `MedicationSyncService` làm orchestrator trung tâm, `MedicationCacheStore` cho persistence, và `AlarmScheduleEngine` để tách biệt alarm lifecycle. Tất cả có thể được tích hợp dần mà không break existing code.

**Endpoint cần dùng từ context.json**:
- `GET /api/tasks/medication` — Fetch ALL tasks (không cần date param), lý tưởng để bulk cache và schedule alarm cho nhiều ngày
- Hiện tại đang dùng `GET /api/tasks/medication-tasks?task_date=...` — chỉ lấy theo ngày
