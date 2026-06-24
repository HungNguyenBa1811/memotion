import '../../../core/network/base_api_service.dart';
import '../models/task_response_dto.dart';

/// API Service for medication-related endpoints
class MedicationApiService extends BaseApiService {
  MedicationApiService({super.dio});

  /// Get medication tasks for a specific date
  /// GET /api/tasks/patient/medication-tasks?task_date=YYYY-MM-DD
  Future<List<TaskDto>> getMedicationTasksByDate(DateTime date) async {
    final dateString = _formatDate(date);

    return await get<List<TaskDto>>(
      '/api/tasks/medication-tasks',
      queryParameters: {'task_date': dateString},
      parser: (json) {
        // Parse base response
        final baseResponse = BaseResponse.fromJson(
          json as Map<String, dynamic>,
          (data) => data,
        );

        // Parse tasks array
        final tasksList = baseResponse.data as List<dynamic>;
        return tasksList
            .map(
              (taskJson) => TaskDto.fromJson(taskJson as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  /// Get task detail by ID
  /// GET /api/tasks/{task_id}
  Future<TaskDto> getTaskDetail(String taskId) async {
    return await get<TaskDto>(
      '/api/tasks/$taskId',
      parser: (json) {
        final baseResponse = BaseResponse.fromJson(
          json as Map<String, dynamic>,
          (data) => data,
        );
        return TaskDto.fromJson(baseResponse.data as Map<String, dynamic>);
      },
    );
  }

  /// Complete a task
  /// PUT /api/tasks/patient/{task_id}/complete
  Future<TaskDto> completeTask(String taskId) async {
    return await put<TaskDto>(
      '/api/tasks/$taskId/complete',
      parser: (json) {
        final baseResponse = BaseResponse.fromJson(
          json as Map<String, dynamic>,
          (data) => data,
        );
        return TaskDto.fromJson(baseResponse.data as Map<String, dynamic>);
      },
    );
  }

  /// Format date to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
