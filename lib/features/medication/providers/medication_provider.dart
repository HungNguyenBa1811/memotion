import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/connectivity_service.dart';
import '../data/alarm_schedule_engine.dart';
import '../data/medication_cache_store.dart';
import '../data/medication_repository.dart';
import '../data/medication_sync_service.dart';
import '../data/pending_actions_queue.dart';
import '../models/medication.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infrastructure providers
// ─────────────────────────────────────────────────────────────────────────────

final medicationCacheStoreProvider = Provider<MedicationCacheStore>((ref) {
  return MedicationCacheStore();
});

final alarmScheduleEngineProvider = Provider<AlarmScheduleEngine>((ref) {
  return AlarmScheduleEngine();
});

final pendingActionsQueueProvider = Provider<PendingActionsQueue>((ref) {
  return PendingActionsQueue();
});

final medicationSyncServiceProvider = Provider<MedicationSyncService>((ref) {
  return MedicationSyncService(
    cacheStore: ref.watch(medicationCacheStoreProvider),
    alarmEngine: ref.watch(alarmScheduleEngineProvider),
    pendingQueue: ref.watch(pendingActionsQueueProvider),
  );
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// True when the device has no network connectivity.
/// Emits the current state immediately, then updates on every change.
final isOfflineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = ref.watch(connectivityServiceProvider);
  // Emit current status first so there's no loading gap.
  final currentlyOnline = await connectivity.isOnline();
  yield !currentlyOnline;
  yield* connectivity.onConnectivityChanged.map((online) => !online);
});

/// Tracks the result of the last sync operation (set from main.dart initState).
final medicationSyncStatusProvider = StateProvider<SyncResult?>((ref) => null);

/// Number of pending offline actions waiting to be synced.
/// Refreshes when sync status changes (which clears pending actions).
final pendingActionsCountProvider = FutureProvider<int>((ref) async {
  // Watch sync status to refresh when sync completes
  ref.watch(medicationSyncStatusProvider);
  final queue = ref.watch(pendingActionsQueueProvider);
  return queue.pendingCount;
});

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the medication repository
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(
    syncService: ref.watch(medicationSyncServiceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
    pendingQueue: ref.watch(pendingActionsQueueProvider),
  );
});

/// Provider for the list of all medications (uses selected date)
final medicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final repository = ref.watch(medicationRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return repository.getMedicationsForDate(selectedDate);
});

/// Provider for medications filtered by status
final filteredMedicationsProvider =
    Provider.family<AsyncValue<List<Medication>>, MedicationFilter>((
      ref,
      filter,
    ) {
      final medicationsAsync = ref.watch(medicationsProvider);

      return medicationsAsync.when(
        data: (medications) {
          switch (filter) {
            case MedicationFilter.all:
              return AsyncData(medications);
            case MedicationFilter.taken:
              return AsyncData(
                medications
                    .where((m) => m.status == MedicationStatus.taken)
                    .toList(),
              );
            case MedicationFilter.missed:
              return AsyncData(
                medications
                    .where((m) => m.status == MedicationStatus.missed)
                    .toList(),
              );
          }
        },
        loading: () => const AsyncLoading(),
        error: (error, stack) => AsyncError(error, stack),
      );
    });

/// Current selected filter state
final selectedFilterProvider = StateProvider<MedicationFilter>((ref) {
  return MedicationFilter.all;
});

/// Current selected date for viewing medications
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// First pending medication for today — used by home screen card.
/// Returns null when the list is empty or still loading.
final firstMedicationTodayProvider = Provider<Medication?>((ref) {
  return ref.watch(medicationsProvider).valueOrNull?.firstOrNull;
});

/// Provider for scanned medication result
final scannedMedicationProvider = StateProvider<Medication?>((ref) {
  return null;
});

/// Notifier for medication actions
class MedicationNotifier extends StateNotifier<AsyncValue<void>> {
  final MedicationRepository _repository;
  final Ref _ref;

  MedicationNotifier(this._repository, this._ref)
    : super(const AsyncData(null));

  Future<void> takeMedication(
    String medicationId, {
    String? medicationName,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.updateMedicationStatus(
        medicationId,
        MedicationStatus.taken,
        medicationName: medicationName,
      );
      _ref.invalidate(medicationsProvider);
      _ref.invalidate(pendingActionsCountProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> skipMedication(
    String medicationId, {
    String? medicationName,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.updateMedicationStatus(
        medicationId,
        MedicationStatus.missed,
        medicationName: medicationName,
      );
      _ref.invalidate(medicationsProvider);
      _ref.invalidate(pendingActionsCountProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<Medication?> scanMedication(String imagePath) async {
    state = const AsyncLoading();
    try {
      final medication = await _repository.scanMedication(imagePath);
      _ref.read(scannedMedicationProvider.notifier).state = medication;
      state = const AsyncData(null);
      return medication;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

/// Provider for medication actions
final medicationNotifierProvider =
    StateNotifierProvider<MedicationNotifier, AsyncValue<void>>((ref) {
      return MedicationNotifier(ref.watch(medicationRepositoryProvider), ref);
    });

/// Filter options for medications
enum MedicationFilter { all, taken, missed }

extension MedicationFilterExtension on MedicationFilter {
  String get displayText {
    switch (this) {
      case MedicationFilter.all:
        return 'All';
      case MedicationFilter.taken:
        return 'Taken';
      case MedicationFilter.missed:
        return 'Missed';
    }
  }
}
