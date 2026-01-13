/// Shared DTOs for Task API responses
/// Used by medication, nutrition, and workout features

/// Base response wrapper from API
class ApiResponse<T> {
  final String code;
  final String message;
  final T data;

  ApiResponse({required this.code, required this.message, required this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) dataParser,
  ) {
    return ApiResponse(
      code: json['code'] as String? ?? '200',
      message: json['message'] as String? ?? '',
      data: dataParser(json['data']),
    );
  }

  bool get isSuccess => code == '200';
}

/// Medication detail from API
class MedicationDetailDto {
  final String medicationId;
  final String name;
  final String? description;
  final String? dosage;
  final int? frequencyPerDay;
  final String? notes;
  final String? imagePath;

  MedicationDetailDto({
    required this.medicationId,
    required this.name,
    this.description,
    this.dosage,
    this.frequencyPerDay,
    this.notes,
    this.imagePath,
  });

  factory MedicationDetailDto.fromJson(Map<String, dynamic> json) {
    return MedicationDetailDto(
      medicationId: json['medication_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      dosage: json['dosage'] as String?,
      frequencyPerDay: json['frequency_per_day'] as int?,
      notes: json['notes'] as String?,
      imagePath: json['image_path'] as String?,
    );
  }
}

/// Nutrition detail from API
class NutritionDetailDto {
  final String nutritionId;
  final String name;
  final int? calories;
  final String? description;
  final String? mealType;
  final String? imagePath;

  NutritionDetailDto({
    required this.nutritionId,
    required this.name,
    this.calories,
    this.description,
    this.mealType,
    this.imagePath,
  });

  factory NutritionDetailDto.fromJson(Map<String, dynamic> json) {
    return NutritionDetailDto(
      nutritionId: json['nutrition_id'] as String,
      name: json['name'] as String,
      calories: json['calories'] as int?,
      description: json['description'] as String?,
      mealType: json['meal_type'] as String?,
      imagePath: json['image_path'] as String?,
    );
  }
}

/// Exercise detail from API
class ExerciseDetailDto {
  final String exerciseId;
  final String name;
  final String? targetBodyRegion;
  final String? description;
  final int? durationMinutes;
  final int? difficultyLevel;
  final String? videoPath;

  ExerciseDetailDto({
    required this.exerciseId,
    required this.name,
    this.targetBodyRegion,
    this.description,
    this.durationMinutes,
    this.difficultyLevel,
    this.videoPath,
  });

  factory ExerciseDetailDto.fromJson(Map<String, dynamic> json) {
    return ExerciseDetailDto(
      exerciseId: json['exercise_id'] as String,
      name: json['name'] as String,
      targetBodyRegion: json['target_body_region'] as String?,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      difficultyLevel: json['difficulty_level'] as int?,
      videoPath: json['video_path'] as String?,
    );
  }
}

/// Task DTO from API - shared across all task types
class TaskDto {
  final String taskId;
  final String? title;
  final String? description;
  final DateTime taskDuedate;
  final String? taskType;
  final String status;
  final String? ownerType;
  final String? carePlanId;
  final String? medicationId;
  final String? nutritionId;
  final String? exerciseId;
  final String? linkedTaskId;
  final MedicationDetailDto? medicationDetail;
  final NutritionDetailDto? nutritionDetail;
  final ExerciseDetailDto? exerciseDetail;

  TaskDto({
    required this.taskId,
    this.title,
    this.description,
    required this.taskDuedate,
    this.taskType,
    required this.status,
    this.ownerType,
    this.carePlanId,
    this.medicationId,
    this.nutritionId,
    this.exerciseId,
    this.linkedTaskId,
    this.medicationDetail,
    this.nutritionDetail,
    this.exerciseDetail,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      taskId: json['task_id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      taskDuedate: DateTime.parse(json['task_duedate'] as String),
      taskType: json['task_type'] as String?,
      status: json['status'] as String,
      ownerType: json['owner_type'] as String?,
      carePlanId: json['care_plan_id'] as String?,
      medicationId: json['medication_id'] as String?,
      nutritionId: json['nutrition_id'] as String?,
      exerciseId: json['exercise_id'] as String?,
      linkedTaskId: json['linked_task_id'] as String?,
      medicationDetail: json['medication_detail'] != null
          ? MedicationDetailDto.fromJson(
              json['medication_detail'] as Map<String, dynamic>,
            )
          : null,
      nutritionDetail: json['nutrition_detail'] != null
          ? NutritionDetailDto.fromJson(
              json['nutrition_detail'] as Map<String, dynamic>,
            )
          : null,
      exerciseDetail: json['exercise_detail'] != null
          ? ExerciseDetailDto.fromJson(
              json['exercise_detail'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Check if this is a medication task
  bool get isMedicationTask => medicationId != null || medicationDetail != null;

  /// Check if this is a nutrition task
  bool get isNutritionTask => nutritionId != null || nutritionDetail != null;

  /// Check if this is an exercise task
  bool get isExerciseTask => exerciseId != null || exerciseDetail != null;

  /// Get formatted time from duedate
  String get formattedTime {
    final hour = taskDuedate.hour.toString().padLeft(2, '0');
    final minute = taskDuedate.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Check if task is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Check if task is pending
  bool get isPending => status.toLowerCase() == 'pending';
}

/// Task status enum
enum TaskStatus {
  pending,
  completed,
  missed;

  static TaskStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return TaskStatus.completed;
      case 'missed':
        return TaskStatus.missed;
      default:
        return TaskStatus.pending;
    }
  }
}
