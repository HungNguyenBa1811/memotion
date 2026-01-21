import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_scan_dto.freezed.dart';
part 'medication_scan_dto.g.dart';

/// Response DTO for medication scan API
@freezed
class MedicationScanResponse with _$MedicationScanResponse {
  const factory MedicationScanResponse({
    required String code,
    required String message,
    required MedicationScanData? data,
  }) = _MedicationScanResponse;

  factory MedicationScanResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicationScanResponseFromJson(json);
}

/// Medication scan data containing the scanned medication info
@freezed
class MedicationScanData with _$MedicationScanData {
  const factory MedicationScanData({
    required String message,
    MedicationDto? medication,
    String? agentError,
  }) = _MedicationScanData;

  factory MedicationScanData.fromJson(Map<String, dynamic> json) =>
      _$MedicationScanDataFromJson(json);
}

/// Medication DTO from scan result
@freezed
class MedicationDto with _$MedicationDto {
  const factory MedicationDto({
    required String name,
    required String description,
    required String dosage,
    required int frequencyPerDay,
    required String notes,
    required String imagePath,
    required String medicationId,
  }) = _MedicationDto;

  factory MedicationDto.fromJson(Map<String, dynamic> json) =>
      _$MedicationDtoFromJson(json);
}
