import '../../../../core/network/models/task_dto.dart';
import '../medication.dart';

/// Mapper to convert TaskDto to Medication model
class TaskDtoMapper {
  /// Convert TaskDto to Medication
  static Medication toMedication(TaskDto dto) {
    // Extract medication detail
    final medicationDetail = dto.medicationDetail;

    if (medicationDetail == null) {
      throw Exception('TaskDto does not contain medication_detail');
    }

    // Parse status
    final status = _parseStatus(dto.status);

    // Calculate remaining time
    final remainingTime = _calculateRemainingTime(dto.taskDuedate);

    // Extract time from task_duedate
    final time = dto.formattedTime;

    return Medication(
      id: dto.taskId,
      name: medicationDetail.name,
      dosage: medicationDetail.dosage ?? '',
      frequency: _formatFrequency(medicationDetail.frequencyPerDay ?? 1),
      time: time,
      imageUrl: medicationDetail.imagePath ?? '',
      status: status,
      scheduledDate: dto.taskDuedate,
      remainingTime: remainingTime,
    );
  }

  /// Convert list of TaskDto to list of Medication
  static List<Medication> toMedicationList(List<TaskDto> dtos) {
    return dtos
        .where((dto) => dto.medicationDetail != null)
        .map((dto) => toMedication(dto))
        .toList();
  }

  /// Parse status string to MedicationStatus enum
  static MedicationStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'taken':
        return MedicationStatus.taken;
      case 'missed':
        return MedicationStatus.missed;
      case 'pending':
      default:
        return MedicationStatus.pending;
    }
  }

  /// Format frequency per day to readable string
  static String _formatFrequency(int frequencyPerDay) {
    if (frequencyPerDay == 1) {
      return 'Once daily';
    } else if (frequencyPerDay == 2) {
      return 'Twice daily';
    } else if (frequencyPerDay == 3) {
      return '3 times daily';
    } else {
      return '$frequencyPerDay times daily';
    }
  }

  /// Format DateTime to time string (HH:MM)
  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Calculate remaining time until task due date
  static String? _calculateRemainingTime(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      // Task is overdue
      return null;
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return 'Now';
    }
  }
}
