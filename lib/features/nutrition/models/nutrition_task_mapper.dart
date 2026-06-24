import '../../../core/network/models/task_dto.dart';
import 'nutrition_task.dart';

/// Mapper to convert TaskDto to NutritionTask model
class NutritionTaskMapper {
  /// Convert TaskDto to NutritionTask
  static NutritionTask toNutritionTask(TaskDto dto) {
    final nutritionDetail = dto.nutritionDetail;

    if (nutritionDetail == null) {
      throw Exception('TaskDto does not contain nutrition_detail');
    }

    return NutritionTask(
      id: dto.taskId,
      name: nutritionDetail.name,
      description: nutritionDetail.description,
      calories: nutritionDetail.calories,
      mealType: nutritionDetail.mealType ?? 'meal',
      time: dto.formattedTime,
      scheduledDate: dto.taskDuedate,
      status: NutritionStatus.fromString(dto.status),
      imagePath: nutritionDetail.imagePath,
      remainingTime: _calculateRemainingTime(dto.taskDuedate),
    );
  }

  /// Convert list of TaskDto to list of NutritionTask
  static List<NutritionTask> toNutritionTaskList(List<TaskDto> dtos) {
    return dtos
        .where((dto) => dto.nutritionDetail != null)
        .map((dto) => toNutritionTask(dto))
        .toList();
  }

  /// Calculate remaining time until task due date
  static String? _calculateRemainingTime(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
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
