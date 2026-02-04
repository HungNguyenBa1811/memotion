import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_scan_dto.freezed.dart';
part 'medication_scan_dto.g.dart';

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

@freezed
class MedicationScanData with _$MedicationScanData {
  const factory MedicationScanData({
    String? message,
    MedicationDto? medication,
    @JsonKey(name: 'agent_error') String? agentError,
  }) = _MedicationScanData;

  factory MedicationScanData.fromJson(Map<String, dynamic> json) =>
      _$MedicationScanDataFromJson(json);
}

@freezed
class MedicationDto with _$MedicationDto {
  const factory MedicationDto({
    required String name,
    required String description,
    required String dosage,
    @JsonKey(name: 'frequency_per_day') int? frequencyPerDay,
    required String notes,
    @JsonKey(name: 'image_path') required String imagePath,
    @JsonKey(name: 'medication_id') required String medicationId,
  }) = _MedicationDto;

  factory MedicationDto.fromJson(Map<String, dynamic> json) =>
      _$MedicationDtoFromJson(json);
}
