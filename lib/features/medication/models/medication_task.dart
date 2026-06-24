import 'dart:convert';

const String _imageBaseUrl = 'http://14.225.218.83:8005';

/// Represents a single medication task from the reminder API.
/// Separate from [Medication] because the alarm JSON schema differs
/// from the task-list DTO returned by the care-plan endpoints.
class MedicationTask {
  final String taskId;
  final DateTime taskDueDate;
  final MedicationDetail medicationDetail;

  const MedicationTask({
    required this.taskId,
    required this.taskDueDate,
    required this.medicationDetail,
  });

  /// Deterministic int ID derived from [taskId] for the alarm package.
  int get alarmId => taskId.hashCode;

  factory MedicationTask.fromJson(Map<String, dynamic> json) {
    return MedicationTask(
      taskId: json['task_id'] as String,
      taskDueDate: DateTime.parse(json['task_duedate'] as String),
      medicationDetail: MedicationDetail.fromJson(
        json['medication_detail'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'task_duedate': taskDueDate.toIso8601String(),
      'medication_detail': medicationDetail.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory MedicationTask.fromJsonString(String source) {
    return MedicationTask.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }
}

class MedicationDetail {
  final String name;
  final String dosage;
  final String notes;
  final String? imagePath;

  const MedicationDetail({
    required this.name,
    required this.dosage,
    required this.notes,
    this.imagePath,
  });

  /// Full URL for the medication image, or null when [imagePath] is absent.
  String? get fullImageUrl =>
      imagePath != null ? '$_imageBaseUrl$imagePath' : null;

  factory MedicationDetail.fromJson(Map<String, dynamic> json) {
    return MedicationDetail(
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      notes: json['notes'] as String,
      imagePath: json['image_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'notes': notes,
      'image_path': imagePath,
    };
  }
}
