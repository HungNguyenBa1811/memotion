import '../../../core/network/services/task_api_service.dart';
import '../models/workout_model.dart';
import '../models/workout_task_mapper.dart';
import 'workout_repository.dart';

/// Real API implementation of WorkoutRepository
class ApiWorkoutRepository implements WorkoutRepository {
  final TaskApiService _apiService;

  ApiWorkoutRepository({TaskApiService? apiService})
    : _apiService = apiService ?? TaskApiService();

  @override
  Future<List<WorkoutTask>> getWorkoutsByDate(DateTime date) async {
    try {
      final taskDtos = await _apiService.getExerciseTasksByDate(date);
      return WorkoutTaskMapper.toWorkoutTaskList(taskDtos);
    } catch (e) {
      print('Error fetching workout tasks: $e');
      rethrow;
    }
  }

  @override
  Future<WorkoutTask?> getWorkoutById(String id) async {
    try {
      final taskDto = await _apiService.getTaskDetail(id);
      return WorkoutTaskMapper.toWorkoutTask(taskDto);
    } catch (e) {
      print('Error fetching workout detail: $e');
      return null;
    }
  }

  @override
  Future<List<WorkoutTask>> getWorkoutsForUser(String userId) async {
    // API doesn't support filtering by user - use today's date
    return getWorkoutsByDate(DateTime.now());
  }

  @override
  Future<bool> markWorkoutCompleted(String workoutId) async {
    try {
      await _apiService.completeTask(workoutId);
      return true;
    } catch (e) {
      print('Error completing workout: $e');
      return false;
    }
  }

  @override
  Future<WorkoutTask> createWorkout(WorkoutTask workout) async {
    // TODO: Implement when API endpoint is available
    throw UnimplementedError('Create workout API not yet implemented');
  }

  @override
  Future<WorkoutTask> updateWorkout(WorkoutTask workout) async {
    // TODO: Implement when API endpoint is available
    throw UnimplementedError('Update workout API not yet implemented');
  }

  @override
  Future<bool> deleteWorkout(String workoutId) async {
    // TODO: Implement when API endpoint is available
    throw UnimplementedError('Delete workout API not yet implemented');
  }
}
