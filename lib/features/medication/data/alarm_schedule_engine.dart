import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/medication_task.dart';

/// Signature of the function used to schedule a native alarm.
/// Matches [Alarm.set] so the real implementation can be passed as default.
typedef AlarmSetter = Future<bool> Function({
  required AlarmSettings alarmSettings,
});

/// Summary of a scheduling operation.
class ScheduleResult {
  final int scheduled;
  final int skipped; // past tasks ignored
  final int failed;

  const ScheduleResult({
    required this.scheduled,
    required this.skipped,
    required this.failed,
  });

  @override
  String toString() =>
      'ScheduleResult(scheduled: $scheduled, skipped: $skipped, failed: $failed)';
}

/// Manages the full lifecycle of medication alarms.
///
/// Responsibilities:
/// - Schedule / reschedule native alarms (idempotent via Alarm.set override)
/// - Persist alarm-id → MedicationTask mapping so the alarm screen can load
///   task details even when the app is killed and relaunched by the alarm.
/// - Cancel / remove mappings when a task is dismissed.
///
/// [alarmSetter] defaults to [Alarm.set] in production and can be replaced
/// with a fake in tests to avoid platform-channel calls.
class AlarmScheduleEngine {
  static const _keyPrefix = 'medication_task_';

  final AlarmSetter _alarmSetter;

  AlarmScheduleEngine({AlarmSetter? alarmSetter})
      : _alarmSetter = alarmSetter ?? Alarm.set;

  /// Schedule alarms for all [tasks] that are still in the future.
  ///
  /// Idempotent: calling this multiple times with the same tasks is safe —
  /// the alarm package overwrites existing alarms with the same id.
  Future<ScheduleResult> rescheduleAll(List<MedicationTask> tasks) async {
    final now = DateTime.now();
    int scheduled = 0;
    int skipped = 0;
    int failed = 0;

    for (final task in tasks) {
      if (!task.taskDueDate.isAfter(now)) {
        skipped++;
        continue;
      }

      // Persist mapping before scheduling so that if the alarm fires
      // immediately (race condition), the data is already in prefs.
      await persistTaskMapping(task);

      final settings = AlarmSettings(
        id: task.alarmId,
        dateTime: task.taskDueDate,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        androidFullScreenIntent: true,
        volumeSettings: const VolumeSettings.fixed(volume: 0.8),
        notificationSettings: NotificationSettings(
          title: 'Time to take ${task.medicationDetail.name}',
          body:
              '${task.medicationDetail.dosage}'
              '${task.medicationDetail.notes.isNotEmpty ? ' · ${task.medicationDetail.notes}' : ''}',
          stopButton: 'Dismiss',
        ),
      );

      final success = await _alarmSetter(alarmSettings: settings);
      if (success) {
        scheduled++;
      } else {
        failed++;
      }
    }

    return ScheduleResult(
      scheduled: scheduled,
      skipped: skipped,
      failed: failed,
    );
  }

  /// Persist the alarmId → task mapping to SharedPreferences.
  Future<void> persistTaskMapping(MedicationTask task) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix${task.alarmId}', task.toJsonString());
  }

  /// Retrieve a task by its alarm id (called when alarm fires).
  Future<MedicationTask?> getTaskByAlarmId(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_keyPrefix$alarmId');
    if (json == null) return null;
    try {
      return MedicationTask.fromJsonString(json);
    } catch (_) {
      return null;
    }
  }

  /// Remove a task mapping after the user dismisses the alarm.
  Future<void> removeTaskMapping(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$alarmId');
  }
}
