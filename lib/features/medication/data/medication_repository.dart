import '../models/medication.dart';

/// Repository for medication data
/// TODO: Replace fake data with real API calls when backend is ready
class MedicationRepository {
  /// Fetches all medications for the current user
  /// This is a placeholder that returns fake data
  Future<List<Medication>> getMedications() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return fake medication data
    return _fakeMedications;
  }

  /// Fetches medications for a specific date
  Future<List<Medication>> getMedicationsForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Filter medications for the date (placeholder logic)
    return _fakeMedications;
  }

  /// Updates the status of a medication
  Future<Medication> updateMedicationStatus(
    String medicationId,
    MedicationStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _fakeMedications.indexWhere((m) => m.id == medicationId);
    if (index != -1) {
      _fakeMedications[index] = _fakeMedications[index].copyWith(
        status: status,
      );
      return _fakeMedications[index];
    }
    throw Exception('Medication not found');
  }

  /// Scans a medication barcode/image and returns medication info
  /// TODO: Implement actual image recognition/barcode scanning API
  Future<Medication?> scanMedication(String imagePath) async {
    await Future.delayed(const Duration(seconds: 1));

    // Return a fake scanned medication
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
  Future<Medication> addMedication(Medication medication) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fakeMedications.add(medication);
    return medication;
  }

  /// Deletes a medication
  Future<void> deleteMedication(String medicationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fakeMedications.removeWhere((m) => m.id == medicationId);
  }
}

/// Fake medication data for development
List<Medication> _fakeMedications = [
  Medication(
    id: '1',
    name: 'Metformin',
    dosage: '250mg',
    frequency: 'Daily',
    time: '09:00',
    status: MedicationStatus.pending,
    remainingTime: '2h 23m',
    scheduledDate: DateTime.now(),
  ),
  Medication(
    id: '2',
    name: 'Vitamin D',
    dosage: '1000 IU',
    frequency: 'Daily',
    time: '09:00',
    status: MedicationStatus.taken,
    scheduledDate: DateTime.now(),
  ),
  Medication(
    id: '3',
    name: 'Aspirin',
    dosage: '100mg',
    frequency: 'Daily',
    time: '14:00',
    status: MedicationStatus.missed,
    scheduledDate: DateTime.now(),
  ),
  Medication(
    id: '4',
    name: 'Omega-3',
    dosage: '1000mg',
    frequency: 'Daily',
    time: '18:00',
    status: MedicationStatus.pending,
    remainingTime: '6h 10m',
    scheduledDate: DateTime.now(),
  ),
  Medication(
    id: '5',
    name: 'Calcium',
    dosage: '500mg',
    frequency: 'Daily',
    time: '21:00',
    status: MedicationStatus.pending,
    remainingTime: '9h 30m',
    scheduledDate: DateTime.now(),
  ),
];
