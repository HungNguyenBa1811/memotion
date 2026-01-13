import '../../../core/network/services/task_api_service.dart';
import '../models/medication.dart';
import '../models/mappers/task_dto_mapper.dart';

/// Repository for medication data
/// Uses shared TaskApiService for real API calls
class MedicationRepository {
  final TaskApiService _apiService;

  MedicationRepository({TaskApiService? apiService})
    : _apiService = apiService ?? TaskApiService();

  /// Fetches all medications for the current user
  /// Returns medications for today's date
  Future<List<Medication>> getMedications() async {
    final today = DateTime.now();
    return getMedicationsForDate(today);
  }

  /// Fetches medications for a specific date
  Future<List<Medication>> getMedicationsForDate(DateTime date) async {
    try {
      final taskDtos = await _apiService.getMedicationTasksByDate(date);
      return TaskDtoMapper.toMedicationList(taskDtos);
    } catch (e) {
      // Log error and return empty list or rethrow
      print('Error fetching medications: $e');
      rethrow;
    }
  }

  /// Updates the status of a medication by completing the task
  Future<Medication> updateMedicationStatus(
    String medicationId,
    MedicationStatus status,
  ) async {
    try {
      // For now, we only support marking as completed via the API
      if (status == MedicationStatus.taken) {
        final taskDto = await _apiService.completeTask(medicationId);
        return TaskDtoMapper.toMedication(taskDto);
      } else {
        // TODO: Backend might need API for marking as missed
        throw Exception('Only "taken" status is supported via API');
      }
    } catch (e) {
      print('Error updating medication status: $e');
      rethrow;
    }
  }

  /// Scans a medication barcode/image and returns medication info
  /// TODO: Implement actual image recognition/barcode scanning API
  Future<Medication?> scanMedication(String imagePath) async {
    await Future.delayed(const Duration(seconds: 1));

    // Placeholder: Return a fake scanned medication
    // This should be replaced with actual API call when available
    return const Medication(
      id: 'scanned_1',
      name: 'Vitamin C',
      dosage: '500mg',
      frequency: 'Daily',
      time: '08:00',
      status: MedicationStatus.pending,
      remainingTime: '1h 30m',
    );
  }

  /// Adds a new medication
  /// TODO: Implement API endpoint for adding medications
  Future<Medication> addMedication(Medication medication) async {
    // Placeholder: Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    throw UnimplementedError('Add medication API not yet implemented');
  }

  /// Deletes a medication
  /// TODO: Implement API endpoint for deleting medications
  Future<void> deleteMedication(String medicationId) async {
    // Placeholder: Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    throw UnimplementedError('Delete medication API not yet implemented');
  }
}
