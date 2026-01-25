import 'package:flutter/foundation.dart';

import '../../../core/network/services/task_api_service.dart';
import '../models/nutrition_task.dart';
import '../models/nutrition_task_mapper.dart';

/// Repository for nutrition data
class NutritionRepository {
  final TaskApiService _apiService;

  NutritionRepository({TaskApiService? apiService})
    : _apiService = apiService ?? TaskApiService();

  /// Fetches all nutrition tasks for today
  Future<List<NutritionTask>> getNutritionTasks() async {
    final today = DateTime.now();
    return getNutritionTasksForDate(today);
  }

  /// Fetches nutrition tasks for a specific date
  Future<List<NutritionTask>> getNutritionTasksForDate(DateTime date) async {
    debugPrint('┌─────────────────────────────────────────────────────────────');
    debugPrint('│ 🍽️ NUTRITION: Fetching tasks for date: $date');
    debugPrint('└─────────────────────────────────────────────────────────────');
    try {
      final taskDtos = await _apiService.getNutritionTasksByDate(date);
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ ✅ NUTRITION: Fetched ${taskDtos.length} tasks');
      for (final task in taskDtos) {
        final name = task.nutritionDetail?.name ?? task.title ?? 'Unknown';
        final mealType = task.nutritionDetail?.mealType ?? 'N/A';
        debugPrint('│   - $name ($mealType) - ${task.status}');
      }
      debugPrint('└─────────────────────────────────────────────────────────────');
      return NutritionTaskMapper.toNutritionTaskList(taskDtos);
    } catch (e) {
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ ❌ NUTRITION ERROR: Fetching tasks failed');
      debugPrint('│ Error: $e');
      debugPrint('└─────────────────────────────────────────────────────────────');
      rethrow;
    }
  }

  /// Mark a nutrition task as completed
  Future<NutritionTask> completeNutritionTask(String taskId) async {
    debugPrint('┌─────────────────────────────────────────────────────────────');
    debugPrint('│ 🍽️ NUTRITION: Completing task: $taskId');
    debugPrint('└─────────────────────────────────────────────────────────────');
    try {
      final taskDto = await _apiService.completeTask(taskId);
      final name = taskDto.nutritionDetail?.name ?? taskDto.title ?? 'Unknown';
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ ✅ NUTRITION: Task completed successfully');
      debugPrint('│   - Name: $name');
      debugPrint('│   - Status: ${taskDto.status}');
      debugPrint('└─────────────────────────────────────────────────────────────');
      return NutritionTaskMapper.toNutritionTask(taskDto);
    } catch (e) {
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ ❌ NUTRITION ERROR: Completing task failed');
      debugPrint('│ TaskId: $taskId');
      debugPrint('│ Error: $e');
      debugPrint('└─────────────────────────────────────────────────────────────');
      rethrow;
    }
  }

  /// Get nutrition task detail by ID
  Future<NutritionTask> getNutritionTaskDetail(String taskId) async {
    debugPrint('┌─────────────────────────────────────────────────────────────');
    debugPrint('│ 🍽️ NUTRITION: Fetching task detail: $taskId');
    debugPrint('└─────────────────────────────────────────────────────────────');
    try {
      final taskDto = await _apiService.getTaskDetail(taskId);
      final name = taskDto.nutritionDetail?.name ?? taskDto.title ?? 'Unknown';
      final mealType = taskDto.nutritionDetail?.mealType ?? 'N/A';
      final calories = taskDto.nutritionDetail?.calories;
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ ✅ NUTRITION: Task detail fetched');
      debugPrint('│   - Name: $name');
      debugPrint('│   - Meal Type: $mealType');
      debugPrint('│   - Calories: ${calories ?? 'N/A'}');
      debugPrint('│   - Status: ${taskDto.status}');
      debugPrint('└─────────────────────────────────────────────────────────────');
      return NutritionTaskMapper.toNutritionTask(taskDto);
    } catch (e) {
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ ❌ NUTRITION ERROR: Fetching task detail failed');
      debugPrint('│ TaskId: $taskId');
      debugPrint('│ Error: $e');
      debugPrint('└─────────────────────────────────────────────────────────────');
      rethrow;
    }
  }
}
