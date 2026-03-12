import '../../../core/network/api_exceptions.dart';
import '../../../core/network/services/task_api_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../models/medication.dart';
import '../models/mappers/task_dto_mapper.dart';
import '../models/medication_task.dart';
import '../models/pending_action.dart';
import 'medication_sync_service.dart';
import 'pending_actions_queue.dart';

/// Repository for medication data.
/// Tries the network first; falls back to the local cache on [NetworkException].
/// When offline, status update actions are queued for later sync.
class MedicationRepository {
  final TaskApiService _apiService;
  final MedicationSyncService _syncService;
  final ConnectivityService _connectivityService;
  final PendingActionsQueue _pendingQueue;

  MedicationRepository({
    TaskApiService? apiService,
    MedicationSyncService? syncService,
    ConnectivityService? connectivityService,
    PendingActionsQueue? pendingQueue,
  }) : _apiService = apiService ?? TaskApiService(),
       _syncService = syncService ?? MedicationSyncService(),
       _connectivityService = connectivityService ?? ConnectivityService(),
       _pendingQueue = pendingQueue ?? PendingActionsQueue();

  /// Fetches all medications for the current user (today's date).
  Future<List<Medication>> getMedications() async {
    return getMedicationsForDate(DateTime.now());
  }

  /// Fetches medications for [date].
  ///
  /// Strategy:
  ///   1. Try API (network-first).
  ///   2. On [NetworkException], fall back to the local cache filtered by date.
  ///   3. Any other error is rethrown so the UI can display it.
  Future<List<Medication>> getMedicationsForDate(DateTime date) async {
    try {
      final taskDtos = await _apiService.getMedicationTasksByDate(date);
      return TaskDtoMapper.toMedicationList(taskDtos);
    } on NetworkException {
      final cached = await _syncService.getTasksForDate(date);
      if (cached.isNotEmpty) {
        return cached.map(_taskToMedication).toList();
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the status of a medication by completing the task.
  ///
  /// If the device is offline, the action is queued in [PendingActionsQueue]
  /// and a local-only success response is returned. The action will be synced
  /// when connectivity is restored.
  ///
  /// Returns [Medication] with updated status (either from API or local).
  Future<Medication> updateMedicationStatus(
    String medicationId,
    MedicationStatus status, {
    String? medicationName,
  }) async {
    final isOnline = await _connectivityService.isOnline();

    if (!isOnline) {
      // Queue the action for later sync
      await _pendingQueue.enqueue(
        PendingAction(
          taskId: medicationId,
          type: status == MedicationStatus.taken
              ? PendingActionType.complete
              : PendingActionType.skip,
          queuedAt: DateTime.now(),
          medicationName: medicationName,
        ),
      );
      // Return a local-only medication with the requested status
      return Medication(
        id: medicationId,
        name: medicationName ?? 'Medication',
        dosage: '',
        frequency: '',
        time: '',
        status: status,
      );
    }

    // Online: proceed with API call
    if (status == MedicationStatus.taken) {
      try {
        final taskDto = await _apiService.completeTask(medicationId);
        return TaskDtoMapper.toMedication(taskDto);
      } on NetworkException {
        // Network failed mid-request; queue for retry
        await _pendingQueue.enqueue(
          PendingAction(
            taskId: medicationId,
            type: PendingActionType.complete,
            queuedAt: DateTime.now(),
            medicationName: medicationName,
          ),
        );
        return Medication(
          id: medicationId,
          name: medicationName ?? 'Medication',
          dosage: '',
          frequency: '',
          time: '',
          status: status,
        );
      }
    } else {
      // Skip/missed: queue for backend (API not implemented yet)
      await _pendingQueue.enqueue(
        PendingAction(
          taskId: medicationId,
          type: PendingActionType.skip,
          queuedAt: DateTime.now(),
          medicationName: medicationName,
        ),
      );
      return Medication(
        id: medicationId,
        name: medicationName ?? 'Medication',
        dosage: '',
        frequency: '',
        time: '',
        status: status,
      );
    }
  }

  /// Checks if there are pending actions waiting to sync.
  Future<bool> get hasPendingActions => _pendingQueue.hasPending;

  /// Returns the count of pending actions.
  Future<int> get pendingActionsCount => _pendingQueue.pendingCount;

  /// Scans a medication barcode/image and returns medication info.
  /// TODO: Implement actual image recognition/barcode scanning API
  Future<Medication?> scanMedication(String imagePath) async {
    await Future.delayed(const Duration(seconds: 1));
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

  /// Adds a new medication — not yet implemented.
  Future<Medication> addMedication(Medication medication) async {
    await Future.delayed(const Duration(milliseconds: 300));
    throw UnimplementedError('Add medication API not yet implemented');
  }

  /// Deletes a medication — not yet implemented.
  Future<void> deleteMedication(String medicationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    throw UnimplementedError('Delete medication API not yet implemented');
  }

  // ---------------------------------------------------------------------------

  /// Convert a cached [MedicationTask] to the UI [Medication] model.
  Medication _taskToMedication(MedicationTask task) {
    return Medication(
      id: task.taskId,
      name: task.medicationDetail.name,
      dosage: task.medicationDetail.dosage,
      frequency: '',
      time: _formatTime(task.taskDueDate),
      imageUrl: task.medicationDetail.fullImageUrl ?? '',
      status: MedicationStatus.pending,
      remainingTime: _calcRemainingTime(task.taskDueDate),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String? _calcRemainingTime(DateTime due) {
    final diff = due.difference(DateTime.now());
    if (diff.isNegative) return null;
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
