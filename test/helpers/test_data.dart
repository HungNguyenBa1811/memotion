import 'package:memotion/core/network/models/task_dto.dart';
import 'package:memotion/features/medication/models/medication_task.dart';

/// A date 2 hours in the future — always a valid future task.
DateTime get kFutureDate => DateTime.now().add(const Duration(hours: 2));

/// A date 1 hour in the past — always an expired task.
DateTime get kPastDate => DateTime.now().subtract(const Duration(hours: 1));

/// Creates a [MedicationTask] with sensible defaults for tests.
MedicationTask makeTask({
  String taskId = 'task-001',
  DateTime? dueDate,
  String medicationName = 'Paracetamol 500mg',
  String dosage = '1 viên',
  String notes = 'Uống sau ăn',
  String? imagePath,
}) {
  return MedicationTask(
    taskId: taskId,
    taskDueDate: dueDate ?? kFutureDate,
    medicationDetail: MedicationDetail(
      name: medicationName,
      dosage: dosage,
      notes: notes,
      imagePath: imagePath,
    ),
  );
}

/// Creates a [TaskDto] representing a medication task, matching the API schema.
TaskDto makeTaskDto({
  String taskId = 'task-001',
  DateTime? dueDate,
  String medicationName = 'Paracetamol 500mg',
  String dosage = '1 viên',
  String notes = 'Uống sau ăn',
}) {
  return TaskDto(
    taskId: taskId,
    taskDuedate: dueDate ?? kFutureDate,
    status: 'pending',
    medicationDetail: MedicationDetailDto(
      medicationId: 'med-$taskId',
      name: medicationName,
      dosage: dosage,
      notes: notes,
    ),
  );
}
