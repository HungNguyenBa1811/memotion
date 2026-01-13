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
    try {
      final taskDtos = await _apiService.getNutritionTasksByDate(date);
      return NutritionTaskMapper.toNutritionTaskList(taskDtos);
    } catch (e) {
      print('Error fetching nutrition tasks: $e');
      rethrow;
    }
  }

  /// Mark a nutrition task as completed
  Future<NutritionTask> completeNutritionTask(String taskId) async {
    try {
      final taskDto = await _apiService.completeTask(taskId);
      return NutritionTaskMapper.toNutritionTask(taskDto);
    } catch (e) {
      print('Error completing nutrition task: $e');
      rethrow;
    }
  }

  /// Get nutrition task detail by ID
  Future<NutritionTask> getNutritionTaskDetail(String taskId) async {
    try {
      final taskDto = await _apiService.getTaskDetail(taskId);
      return NutritionTaskMapper.toNutritionTask(taskDto);
    } catch (e) {
      print('Error fetching nutrition task detail: $e');
      rethrow;
    }
  }
}
