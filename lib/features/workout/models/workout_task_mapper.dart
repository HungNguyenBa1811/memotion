import '../../../core/network/models/task_dto.dart';
import 'workout_model.dart';

/// Mapper to convert TaskDto to WorkoutTask model
class WorkoutTaskMapper {
  /// Convert TaskDto to WorkoutTask
  static WorkoutTask toWorkoutTask(TaskDto dto) {
    final exerciseDetail = dto.exerciseDetail;

    if (exerciseDetail == null) {
      throw Exception('TaskDto does not contain exercise_detail');
    }

    // Determine workout type from target body region or name
    final workoutType = _determineWorkoutType(exerciseDetail);

    return WorkoutTask(
      id: dto.taskId,
      title: exerciseDetail.name,
      time: dto.formattedTime,
      scheduledDate: dto.taskDuedate,
      type: workoutType,
      isCompleted: dto.isCompleted,
      imageAsset: exerciseDetail.videoPath,
      description: exerciseDetail.description,
      steps: null, // API doesn't provide steps yet
      durationMinutes: exerciseDetail.durationMinutes,
      caloriesBurn: _estimateCaloriesBurn(
        exerciseDetail.durationMinutes,
        exerciseDetail.difficultyLevel,
      ),
    );
  }

  /// Convert list of TaskDto to list of WorkoutTask
  static List<WorkoutTask> toWorkoutTaskList(List<TaskDto> dtos) {
    return dtos
        .where((dto) => dto.exerciseDetail != null)
        .map((dto) => toWorkoutTask(dto))
        .toList();
  }

  /// Determine workout type from exercise details
  static WorkoutType _determineWorkoutType(ExerciseDetailDto detail) {
    final name = detail.name.toLowerCase();
    final bodyRegion = detail.targetBodyRegion?.toLowerCase() ?? '';

    if (name.contains('yoga') || bodyRegion.contains('yoga')) {
      return WorkoutType.yoga;
    }
    if (name.contains('rest') || name.contains('nghỉ')) {
      return WorkoutType.rest;
    }
    return WorkoutType.exercise;
  }

  /// Estimate calories burn based on duration and difficulty
  static int? _estimateCaloriesBurn(int? duration, int? difficulty) {
    if (duration == null) return null;

    // Base rate: 5 calories per minute, modified by difficulty
    final difficultyMultiplier = switch (difficulty) {
      1 => 0.8,
      2 => 1.0,
      3 => 1.2,
      4 => 1.5,
      5 => 2.0,
      _ => 1.0,
    };

    return (duration * 5 * difficultyMultiplier).round();
  }
}
