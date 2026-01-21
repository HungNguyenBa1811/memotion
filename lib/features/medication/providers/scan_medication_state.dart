import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/medication_scan_dto.dart';

part 'scan_medication_state.freezed.dart';

/// State for medication scanning feature
@freezed
class ScanMedicationState with _$ScanMedicationState {
  const factory ScanMedicationState({
    @Default(false) bool isScanning,
    @Default(false) bool isSuccess,
    MedicationDto? scannedMedication,
    String? errorMessage,
    String? imagePath,
  }) = _ScanMedicationState;
}
