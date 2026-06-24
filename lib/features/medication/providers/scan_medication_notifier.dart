import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/medication_scan_service.dart';
import 'scan_medication_state.dart';

/// Provider for MedicationScanService
final medicationScanServiceProvider = Provider<MedicationScanService>((ref) {
  return MedicationScanService();
});

/// Notifier for medication scanning
class ScanMedicationNotifier extends Notifier<ScanMedicationState> {
  @override
  ScanMedicationState build() {
    return const ScanMedicationState();
  }

  /// Scan medication from image file
  Future<void> scanMedication(File imageFile) async {
    // Set scanning state
    state = state.copyWith(
      isScanning: true,
      isSuccess: false,
      errorMessage: null,
      imagePath: imageFile.path,
    );

    try {
      final service = ref.read(medicationScanServiceProvider);
      final response = await service.scanMedicationImage(imageFile);

      // Check if scan was successful
      if (response.data?.medication != null) {
        state = state.copyWith(
          isScanning: false,
          isSuccess: true,
          scannedMedication: response.data!.medication,
          errorMessage: null,
        );
      } else {
        // Medication not found or agent error
        final errorMsg = response.data?.agentError ??
            response.data?.message ??
            'Failed to identify medication';
        state = state.copyWith(
          isScanning: false,
          isSuccess: false,
          errorMessage: errorMsg,
          scannedMedication: null,
        );
      }
    } catch (e) {
      // Handle error
      state = state.copyWith(
        isScanning: false,
        isSuccess: false,
        errorMessage: 'Error scanning medication: ${e.toString()}',
        scannedMedication: null,
      );
    }
  }

  /// Reset state
  void reset() {
    state = const ScanMedicationState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for ScanMedicationNotifier
final scanMedicationNotifierProvider =
    NotifierProvider<ScanMedicationNotifier, ScanMedicationState>(
  ScanMedicationNotifier.new,
);
