/// Workout task model representing a daily workout/task item
class WorkoutTask {
  final String id;
  final String title;
  final String time;
  final DateTime scheduledDate;
  final WorkoutType type;
  final bool isCompleted;
  final String? imageAsset;
  final String? videoPath;
  final String? description;
  final List<String>? steps;
  final int? durationMinutes;
  final int? caloriesBurn;

  const WorkoutTask({
    required this.id,
    required this.title,
    required this.time,
    required this.scheduledDate,
    required this.type,
    this.isCompleted = false,
    this.imageAsset,
    this.videoPath,
    this.description,
    this.steps,
    this.durationMinutes,
    this.caloriesBurn,
  });

  WorkoutTask copyWith({
    String? id,
    String? title,
    String? time,
    DateTime? scheduledDate,
    WorkoutType? type,
    bool? isCompleted,
    String? imageAsset,
    String? videoPath,
    String? description,
    List<String>? steps,
    int? durationMinutes,
    int? caloriesBurn,
  }) {
    return WorkoutTask(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      imageAsset: imageAsset ?? this.imageAsset,
      videoPath: videoPath ?? this.videoPath,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurn: caloriesBurn ?? this.caloriesBurn,
    );
  }

  /// Create from JSON (for API response)
  factory WorkoutTask.fromJson(Map<String, dynamic> json) {
    return WorkoutTask(
      id: json['id'] as String,
      title: json['title'] as String,
      time: json['time'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      type: WorkoutType.fromString(json['type'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
      imageAsset: json['image_asset'] as String?,
      videoPath: json['video_path'] as String?,
      description: json['description'] as String?,
      steps: (json['steps'] as List<dynamic>?)?.cast<String>(),
      durationMinutes: json['duration_minutes'] as int?,
      caloriesBurn: json['calories_burn'] as int?,
    );
  }

  /// Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'scheduled_date': scheduledDate.toIso8601String(),
      'type': type.name,
      'is_completed': isCompleted,
      'image_asset': imageAsset,
      'video_path': videoPath,
      'description': description,
      'steps': steps,
      'duration_minutes': durationMinutes,
      'calories_burn': caloriesBurn,
    };
  }
}

/// Enum for workout task types
enum WorkoutType {
  yoga,
  meal,
  medicine,
  exercise,
  rest,
  other;

  static WorkoutType fromString(String value) {
    return WorkoutType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => WorkoutType.other,
    );
  }

  String get displayName {
    switch (this) {
      case WorkoutType.yoga:
        return 'Yoga';
      case WorkoutType.meal:
        return 'Meal';
      case WorkoutType.medicine:
        return 'Medication';
      case WorkoutType.exercise:
        return 'Exercise';
      case WorkoutType.rest:
        return 'Rest';
      case WorkoutType.other:
        return 'Other';
    }
  }
}

/// Calendar day model for the date picker
class CalendarDay {
  final DateTime date;
  final String dayOfWeek;
  final String month;
  final bool isSelected;

  const CalendarDay({
    required this.date,
    required this.dayOfWeek,
    required this.month,
    this.isSelected = false,
  });

  CalendarDay copyWith({
    DateTime? date,
    String? dayOfWeek,
    String? month,
    bool? isSelected,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      month: month ?? this.month,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
