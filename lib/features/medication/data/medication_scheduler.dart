import '../models/medication_task.dart';
import 'alarm_schedule_engine.dart';

/// Legacy static façade for alarm scheduling.
///
/// The manual sync method is deprecated — use [MedicationSyncService.syncOnAppLaunch]
/// which fetches data from the API automatically.
///
/// [getTaskByAlarmId] and [removeTask] delegate to [AlarmScheduleEngine] and
/// remain the live path used by [MedicationAlarmScreen].
class MedicationScheduler {
  MedicationScheduler._();

  static final _engine = AlarmScheduleEngine();

  /// Deprecated. Pass the raw API response map to schedule alarms manually.
  /// Prefer [MedicationSyncService.syncOnAppLaunch] for production use.
  @Deprecated('Use MedicationSyncService.syncOnAppLaunch() instead.')
  static Future<int> syncTasks(Map<String, dynamic> apiResponse) async {
    final tasks = _parseTasks(apiResponse);
    final result = await _engine.rescheduleAll(tasks);
    return result.scheduled;
  }

  /// Retrieve the persisted [MedicationTask] for [alarmId] when an alarm fires.
  static Future<MedicationTask?> getTaskByAlarmId(int alarmId) =>
      _engine.getTaskByAlarmId(alarmId);

  /// Remove the task mapping after the user dismisses the alarm.
  static Future<void> removeTask(int alarmId) =>
      _engine.removeTaskMapping(alarmId);

  // ---------------------------------------------------------------------------

  static List<MedicationTask> _parseTasks(Map<String, dynamic> response) {
    final dataList = response['data'] as List<dynamic>?;
    if (dataList == null) return [];
    return dataList
        .map((e) => MedicationTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
