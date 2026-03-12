import 'package:alarm/alarm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memotion/features/medication/data/alarm_schedule_engine.dart';
import 'package:memotion/features/medication/models/medication_task.dart';
import '../../helpers/test_data.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Fake alarm setter that captures calls and always succeeds.
  final alarmCalls = <AlarmSettings>[];
  Future<bool> successfulAlarmSetter({required AlarmSettings alarmSettings}) async {
    alarmCalls.add(alarmSettings);
    return true;
  }

  Future<bool> failingAlarmSetter({required AlarmSettings alarmSettings}) async {
    alarmCalls.add(alarmSettings);
    return false;
  }

  late AlarmScheduleEngine engine;

  setUp(() {
    alarmCalls.clear();
    engine = AlarmScheduleEngine(alarmSetter: successfulAlarmSetter);
  });

  // ─── persistTaskMapping / getTaskByAlarmId / removeTaskMapping ───────────

  group('task mapping persistence', () {
    test('stores and retrieves a task by alarmId', () async {
      final task = makeTask();
      await engine.persistTaskMapping(task);

      final retrieved = await engine.getTaskByAlarmId(task.alarmId);
      expect(retrieved, isNotNull);
      expect(retrieved!.taskId, task.taskId);
      expect(retrieved.medicationDetail.name, task.medicationDetail.name);
      expect(retrieved.medicationDetail.dosage, task.medicationDetail.dosage);
    });

    test('returns null for an unknown alarmId', () async {
      expect(await engine.getTaskByAlarmId(99999), isNull);
    });

    test('removeTaskMapping deletes the entry', () async {
      final task = makeTask();
      await engine.persistTaskMapping(task);
      await engine.removeTaskMapping(task.alarmId);
      expect(await engine.getTaskByAlarmId(task.alarmId), isNull);
    });

    test('overwriting same alarmId updates stored task', () async {
      final original = makeTask();
      final updated = MedicationTask(
        taskId: original.taskId, // same alarmId (taskId.hashCode)
        taskDueDate: original.taskDueDate.add(const Duration(hours: 1)),
        medicationDetail: original.medicationDetail,
      );

      await engine.persistTaskMapping(original);
      await engine.persistTaskMapping(updated);

      final retrieved = await engine.getTaskByAlarmId(original.alarmId);
      expect(retrieved!.taskDueDate, updated.taskDueDate);
    });

    test('multiple distinct tasks can be stored simultaneously', () async {
      final t1 = makeTask(taskId: 'aaa');
      final t2 = makeTask(taskId: 'bbb');
      await engine.persistTaskMapping(t1);
      await engine.persistTaskMapping(t2);

      expect((await engine.getTaskByAlarmId(t1.alarmId))!.taskId, 'aaa');
      expect((await engine.getTaskByAlarmId(t2.alarmId))!.taskId, 'bbb');
    });
  });

  // ─── rescheduleAll ───────────────────────────────────────────────────────

  group('rescheduleAll', () {
    test('schedules future tasks and skips past tasks', () async {
      final future = makeTask(taskId: 'future', dueDate: kFutureDate);
      final past = makeTask(taskId: 'past', dueDate: kPastDate);

      final result = await engine.rescheduleAll([future, past]);

      expect(result.scheduled, 1);
      expect(result.skipped, 1);
      expect(result.failed, 0);
    });

    test('does not call alarm setter for past tasks', () async {
      await engine.rescheduleAll([
        makeTask(taskId: 'p1', dueDate: kPastDate),
        makeTask(taskId: 'p2', dueDate: kPastDate),
      ]);

      expect(alarmCalls, isEmpty);
    });

    test('all skipped when every task is past', () async {
      final result = await engine.rescheduleAll([
        makeTask(taskId: 'p1', dueDate: kPastDate),
        makeTask(taskId: 'p2', dueDate: kPastDate),
      ]);
      expect(result.scheduled, 0);
      expect(result.skipped, 2);
    });

    test('returns zero counts for empty list', () async {
      final result = await engine.rescheduleAll([]);
      expect(result.scheduled, 0);
      expect(result.skipped, 0);
      expect(result.failed, 0);
      expect(alarmCalls, isEmpty);
    });

    test('alarm is set with matching id and dateTime', () async {
      final task = makeTask(dueDate: kFutureDate);
      await engine.rescheduleAll([task]);

      expect(alarmCalls.length, 1);
      expect(alarmCalls.first.id, task.alarmId);
      expect(alarmCalls.first.dateTime, task.taskDueDate);
    });

    test('task mapping is persisted before alarm setter is called', () async {
      final task = makeTask(dueDate: kFutureDate);
      await engine.rescheduleAll([task]);

      final stored = await engine.getTaskByAlarmId(task.alarmId);
      expect(stored, isNotNull);
    });

    test('counts as failed when alarm setter returns false', () async {
      final failEngine = AlarmScheduleEngine(alarmSetter: failingAlarmSetter);
      final result = await failEngine.rescheduleAll([makeTask(dueDate: kFutureDate)]);

      expect(result.failed, 1);
      expect(result.scheduled, 0);
    });

    test('schedules multiple future tasks independently', () async {
      final result = await engine.rescheduleAll([
        makeTask(taskId: 'f1', dueDate: kFutureDate),
        makeTask(taskId: 'f2', dueDate: kFutureDate),
        makeTask(taskId: 'f3', dueDate: kFutureDate),
      ]);

      expect(result.scheduled, 3);
      expect(alarmCalls.length, 3);
    });

    test('notification title contains medication name', () async {
      final task = makeTask(dueDate: kFutureDate, medicationName: 'Vitamin C 1000mg');
      await engine.rescheduleAll([task]);

      expect(alarmCalls.first.notificationSettings.title, contains('Vitamin C 1000mg'));
    });
  });
}
