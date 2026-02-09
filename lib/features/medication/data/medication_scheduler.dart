import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_task.dart';

/// Parses the medication reminder API response, persists each task
/// to SharedPreferences, and schedules native alarms.
class MedicationScheduler {
  MedicationScheduler._();

  static const String _keyPrefix = 'medication_task_';

  /// Main entry point: parse, filter, persist, and schedule.
  static Future<int> syncTasks(Map<String, dynamic> apiResponse) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = _parseTasks(apiResponse);
    final futureTasks = _filterFutureTasks(tasks);

    int scheduled = 0;
    for (final task in futureTasks) {
      final alarmId = task.alarmId;

      // Persist task JSON so we can retrieve details when the alarm fires.
      await prefs.setString('$_keyPrefix$alarmId', task.toJsonString());

      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: task.taskDueDate,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        androidFullScreenIntent: true,
        volumeSettings: const VolumeSettings.fixed(volume: 0.8),
        notificationSettings: NotificationSettings(
          title: 'Time to take ${task.medicationDetail.name}',
          body: '${task.medicationDetail.dosage} - ${task.medicationDetail.notes}',
          stopButton: 'Dismiss',
        ),
      );

      final success = await Alarm.set(alarmSettings: alarmSettings);
      if (success) scheduled++;
    }

    return scheduled;
  }

  /// Retrieve a persisted [MedicationTask] by its alarm ID.
  static Future<MedicationTask?> getTaskByAlarmId(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_keyPrefix$alarmId');
    if (json == null) return null;
    return MedicationTask.fromJsonString(json);
  }

  /// Clean up persisted task after the user acknowledges the alarm.
  static Future<void> removeTask(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$alarmId');
  }

  // -- private helpers -------------------------------------------------------

  static List<MedicationTask> _parseTasks(Map<String, dynamic> response) {
    final dataList = response['data'] as List<dynamic>?;
    if (dataList == null) return [];
    return dataList
        .map((e) => MedicationTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<MedicationTask> _filterFutureTasks(List<MedicationTask> tasks) {
    final now = DateTime.now();
    return tasks.where((t) => t.taskDueDate.isAfter(now)).toList();
  }
}
