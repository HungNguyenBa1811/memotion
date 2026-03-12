import '../api_exceptions.dart';
import '../base_api_service.dart';
import '../models/task_dto.dart';

/// Shared API Service for all task-related endpoints
/// Handles medication, nutrition, and exercise tasks
class TaskApiService extends BaseApiService {
  TaskApiService({super.dio});

  // ─────────────────────────────────────────────────────────────────
  // MEDICATION TASKS
  // ─────────────────────────────────────────────────────────────────

  /// Get medication tasks for a specific date
  /// GET /api/tasks/patient/medication-tasks?task_date=YYYY-MM-DD
  Future<List<TaskDto>> getMedicationTasksByDate(DateTime date) async {
    return _getTasksByDate('/api/tasks/medication-tasks', date);
  }

  // ─────────────────────────────────────────────────────────────────
  // NUTRITION TASKS
  // ─────────────────────────────────────────────────────────────────

  /// Get nutrition tasks for a specific date
  /// GET /api/tasks/patient/nutrition-tasks?task_date=YYYY-MM-DD
  Future<List<TaskDto>> getNutritionTasksByDate(DateTime date) async {
    return _getTasksByDate('/api/tasks/nutrition-tasks', date);
  }

  // ─────────────────────────────────────────────────────────────────
  // EXERCISE TASKS
  // ─────────────────────────────────────────────────────────────────

  /// Get exercise tasks for a specific date
  /// GET /api/tasks/patient/exercise-tasks?task_date=YYYY-MM-DD
  Future<List<TaskDto>> getExerciseTasksByDate(DateTime date) async {
    return _getTasksByDate('/api/tasks/exercise-tasks', date);
  }

  // ─────────────────────────────────────────────────────────────────
  // ALL MEDICATION TASKS (bulk, no date filter)
  // ─────────────────────────────────────────────────────────────────

  /// Fetch ALL medication tasks for the current user (no date filter).
  /// Used for bulk caching and alarm scheduling on app launch.
  /// GET /api/tasks/medication
  Future<List<TaskDto>> getAllMedicationTasks() async {
    try {
      return await get<List<TaskDto>>(
        '/api/tasks/medication',
        parser: (json) {
          final response = ApiResponse.fromJson(
            json as Map<String, dynamic>,
            (data) => data,
          );
          final tasksList = response.data as List<dynamic>;
          return tasksList
              .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    } on BadRequestException {
      throw const PatientProfileNotFoundException();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // SHARED TASK OPERATIONS
  // ─────────────────────────────────────────────────────────────────

  /// Complete a task (works for any task type)
  /// PUT /api/tasks/patient/{task_id}/complete
  Future<TaskDto> completeTask(String taskId) async {
    return await put<TaskDto>(
      '/api/tasks/$taskId/complete',
      parser: (json) {
        final response = ApiResponse.fromJson(
          json as Map<String, dynamic>,
          (data) => data,
        );
        return TaskDto.fromJson(response.data as Map<String, dynamic>);
      },
    );
  }

  /// Get task detail by ID
  /// GET /api/tasks/{task_id}
  Future<TaskDto> getTaskDetail(String taskId) async {
    return await get<TaskDto>(
      '/api/tasks/$taskId',
      parser: (json) {
        final response = ApiResponse.fromJson(
          json as Map<String, dynamic>,
          (data) => data,
        );
        return TaskDto.fromJson(response.data as Map<String, dynamic>);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────────────────────────

  /// Generic method to get tasks by date from any endpoint
  /// Handles 400 error as "patient profile not found" - returns empty list
  Future<List<TaskDto>> _getTasksByDate(String endpoint, DateTime date) async {
    final dateString = _formatDate(date);

    try {
      return await get<List<TaskDto>>(
        endpoint,
        queryParameters: {'task_date': dateString},
        parser: (json) {
          final response = ApiResponse.fromJson(
            json as Map<String, dynamic>,
            (data) => data,
          );
          final tasksList = response.data as List<dynamic>;
          return tasksList
              .map(
                (taskJson) =>
                    TaskDto.fromJson(taskJson as Map<String, dynamic>),
              )
              .toList();
        },
      );
    } on BadRequestException {
      // 400 error means patient profile not found
      // Throw specific exception for UI to handle gracefully
      throw const PatientProfileNotFoundException();
    }
  }

  /// Format date to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
