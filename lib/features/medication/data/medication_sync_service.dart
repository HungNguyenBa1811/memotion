import 'dart:developer' as developer;

import '../../../core/network/api_exceptions.dart';
import '../../../core/network/models/task_dto.dart';
import '../../../core/network/services/task_api_service.dart';
import '../models/medication_task.dart';
import '../models/pending_action.dart';
import 'alarm_schedule_engine.dart';
import 'medication_cache_store.dart';
import 'pending_actions_queue.dart';

/// Where the synced data came from.
enum SyncSource { api, cache, none }

/// Result returned by sync operations on [MedicationSyncService].
class SyncResult {
  final SyncSource source;
  final int taskCount;
  final int alarmsScheduled;
  final DateTime? cachedAt;
  final String? error;

  /// Number of pending offline actions that were successfully synced.
  final int pendingActionsSynced;

  /// Number of pending actions that failed to sync.
  final int pendingActionsFailed;

  const SyncResult({
    required this.source,
    required this.taskCount,
    required this.alarmsScheduled,
    this.cachedAt,
    this.error,
    this.pendingActionsSynced = 0,
    this.pendingActionsFailed = 0,
  });

  @override
  String toString() =>
      'SyncResult(source: $source, tasks: $taskCount, alarms: $alarmsScheduled'
      ', pendingSynced: $pendingActionsSynced, pendingFailed: $pendingActionsFailed'
      '${error != null ? ', error: $error' : ''})';
}

/// Orchestrates offline-capable medication data sync and alarm scheduling.
///
/// Two entry points:
/// - [syncOnAppLaunch]: called once on boot. Falls back to cache if offline.
/// - [refreshCache]: called when network is restored. Fails silently if still offline.
///
/// Both are guarded by [_isSyncing] so concurrent calls are no-ops.
class MedicationSyncService {
  final TaskApiService _apiService;
  final MedicationCacheStore _cacheStore;
  final AlarmScheduleEngine _alarmEngine;
  final PendingActionsQueue _pendingQueue;

  bool _isSyncing = false;

  MedicationSyncService({
    TaskApiService? apiService,
    MedicationCacheStore? cacheStore,
    AlarmScheduleEngine? alarmEngine,
    PendingActionsQueue? pendingQueue,
  }) : _apiService = apiService ?? TaskApiService(),
       _cacheStore = cacheStore ?? MedicationCacheStore(),
       _alarmEngine = alarmEngine ?? AlarmScheduleEngine(),
       _pendingQueue = pendingQueue ?? PendingActionsQueue();

  /// Call once when the app starts.
  ///
  /// Priority:
  ///   Online + auth  → fetch API → cache → schedule   → SyncSource.api
  ///   Offline/error  → read cache → reschedule         → SyncSource.cache
  ///   Not logged in  → skip silently                   → SyncSource.none
  Future<SyncResult> syncOnAppLaunch() async {
    if (_isSyncing) {
      return const SyncResult(
        source: SyncSource.none,
        taskCount: 0,
        alarmsScheduled: 0,
      );
    }
    _isSyncing = true;
    try {
      return await _fetchAndSync();
    } on UnauthorizedException {
      return const SyncResult(
        source: SyncSource.none,
        taskCount: 0,
        alarmsScheduled: 0,
      );
    } on PatientProfileNotFoundException {
      return const SyncResult(
        source: SyncSource.none,
        taskCount: 0,
        alarmsScheduled: 0,
      );
    } catch (e) {
      return _syncFromCache(e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// Force-fetch fresh data from the API and reschedule alarms.
  ///
  /// Call this when network connectivity is restored. Unlike [syncOnAppLaunch],
  /// this does NOT fall back to cache on failure — it simply returns an error
  /// result so the caller can decide how to handle it.
  ///
  /// Also drains the [PendingActionsQueue] before fetching fresh data.
  Future<SyncResult> refreshCache() async {
    if (_isSyncing) {
      return const SyncResult(
        source: SyncSource.none,
        taskCount: 0,
        alarmsScheduled: 0,
      );
    }
    _isSyncing = true;
    try {
      // First, drain any pending offline actions
      final drainResult = await _drainPendingActions();

      // Then fetch fresh data
      final syncResult = await _fetchAndSync();

      // Merge results
      return SyncResult(
        source: syncResult.source,
        taskCount: syncResult.taskCount,
        alarmsScheduled: syncResult.alarmsScheduled,
        cachedAt: syncResult.cachedAt,
        error: syncResult.error,
        pendingActionsSynced: drainResult.succeeded,
        pendingActionsFailed: drainResult.failed,
      );
    } catch (e) {
      return SyncResult(
        source: SyncSource.none,
        taskCount: 0,
        alarmsScheduled: 0,
        error: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Drains pending actions without full cache refresh.
  ///
  /// Useful for manual "sync now" button or periodic background sync.
  Future<DrainResult> drainPendingActions() => _drainPendingActions();

  /// Returns true if there are pending actions waiting to sync.
  Future<bool> get hasPendingActions => _pendingQueue.hasPending;

  /// Returns the count of pending actions.
  Future<int> get pendingActionsCount => _pendingQueue.pendingCount;

  /// Returns all tasks from the local cache regardless of age.
  Future<List<MedicationTask>> getCachedTasks() async {
    return await _cacheStore.restore(maxAge: const Duration(days: 365)) ?? [];
  }

  /// Returns cached tasks for a specific [date] — used by repository as offline fallback.
  Future<List<MedicationTask>> getTasksForDate(DateTime date) async {
    final all = await getCachedTasks();
    return all.where((t) {
      final d = t.taskDueDate;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  /// Returns metadata about the current cache snapshot.
  Future<CacheMetadata?> getCacheMetadata() => _cacheStore.getMetadata();

  // ---------------------------------------------------------------------------

  /// Processes all pending offline actions by sending them to the API.
  ///
  /// For each action:
  ///   - [PendingActionType.complete] → calls [TaskApiService.completeTask]
  ///   - [PendingActionType.skip] → skipped for now (API not implemented)
  ///
  /// Successfully synced actions are removed from the queue; failed ones remain.
  Future<DrainResult> _drainPendingActions() async {
    final pending = await _pendingQueue.getPending();
    if (pending.isEmpty) {
      return const DrainResult(succeeded: 0, failed: 0);
    }

    developer.log(
      'Draining ${pending.length} pending actions',
      name: 'MedicationSyncService',
    );

    int succeeded = 0;
    int failed = 0;
    final errors = <String>[];

    for (final action in pending) {
      try {
        switch (action.type) {
          case PendingActionType.complete:
            await _apiService.completeTask(action.taskId);
            developer.log(
              'Synced complete action for task ${action.taskId}',
              name: 'MedicationSyncService',
            );
          case PendingActionType.skip:
            // TODO: Backend API for skip/missed not implemented yet.
            // For now, just remove from queue (best-effort).
            developer.log(
              'Skipping skip action for task ${action.taskId} (API not implemented)',
              name: 'MedicationSyncService',
            );
        }
        await _pendingQueue.remove(action);
        succeeded++;
      } catch (e) {
        developer.log(
          'Failed to sync action for task ${action.taskId}: $e',
          name: 'MedicationSyncService',
          level: 900,
        );
        failed++;
        errors.add('Task ${action.taskId}: $e');
      }
    }

    developer.log(
      'Drain complete: $succeeded succeeded, $failed failed',
      name: 'MedicationSyncService',
    );

    return DrainResult(succeeded: succeeded, failed: failed, errors: errors);
  }

  /// Fetch from API, persist to cache, and reschedule all alarms.
  Future<SyncResult> _fetchAndSync() async {
    final dtos = await _apiService.getAllMedicationTasks();
    final tasks = _toMedicationTasks(dtos);
    await _cacheStore.persist(tasks);
    final scheduleResult = await _alarmEngine.rescheduleAll(tasks);
    return SyncResult(
      source: SyncSource.api,
      taskCount: tasks.length,
      alarmsScheduled: scheduleResult.scheduled,
      cachedAt: DateTime.now(),
    );
  }

  /// Read from cache and reschedule alarms from stale data.
  Future<SyncResult> _syncFromCache(String? errorMessage) async {
    final tasks = await _cacheStore.restore(maxAge: const Duration(days: 365));
    if (tasks == null || tasks.isEmpty) {
      return SyncResult(
        source: SyncSource.none,
        taskCount: 0,
        alarmsScheduled: 0,
        error: errorMessage,
      );
    }
    final scheduleResult = await _alarmEngine.rescheduleAll(tasks);
    final meta = await _cacheStore.getMetadata();
    return SyncResult(
      source: SyncSource.cache,
      taskCount: tasks.length,
      alarmsScheduled: scheduleResult.scheduled,
      cachedAt: meta?.cachedAt,
      error: errorMessage,
    );
  }

  /// Maps [TaskDto] list → [MedicationTask] list, skipping non-medication tasks.
  List<MedicationTask> _toMedicationTasks(List<TaskDto> dtos) {
    final result = <MedicationTask>[];
    for (final dto in dtos) {
      final detail = dto.medicationDetail;
      if (detail == null) continue;
      result.add(
        MedicationTask(
          taskId: dto.taskId,
          taskDueDate: dto.taskDuedate,
          medicationDetail: MedicationDetail(
            name: detail.name,
            dosage: detail.dosage ?? '',
            notes: detail.notes ?? '',
            imagePath: detail.imagePath,
          ),
        ),
      );
    }
    return result;
  }
}
