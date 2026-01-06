import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/medication_repository.dart';
import '../models/medication.dart';

/// Provider for the medication repository
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository();
});

/// Provider for the list of all medications
final medicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.getMedications();
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

  Future<void> takeMedication(String medicationId) async {
    state = const AsyncLoading();
    try {
      await _repository.updateMedicationStatus(
        medicationId,
        MedicationStatus.taken,
      );
      _ref.invalidate(medicationsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> skipMedication(String medicationId) async {
    state = const AsyncLoading();
    try {
      await _repository.updateMedicationStatus(
        medicationId,
        MedicationStatus.missed,
      );
      _ref.invalidate(medicationsProvider);
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
