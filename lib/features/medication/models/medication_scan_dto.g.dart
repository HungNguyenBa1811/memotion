// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_scan_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicationScanResponseImpl _$$MedicationScanResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MedicationScanResponseImpl(
  code: json['code'] as String,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : MedicationScanData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$MedicationScanResponseImplToJson(
  _$MedicationScanResponseImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$MedicationScanDataImpl _$$MedicationScanDataImplFromJson(
  Map<String, dynamic> json,
) => _$MedicationScanDataImpl(
  message: json['message'] as String?,
  medication: json['medication'] == null
      ? null
      : MedicationDto.fromJson(json['medication'] as Map<String, dynamic>),
  agentError: json['agent_error'] as String?,
);

Map<String, dynamic> _$$MedicationScanDataImplToJson(
  _$MedicationScanDataImpl instance,
) => <String, dynamic>{
  'message': instance.message,
  'medication': instance.medication,
  'agent_error': instance.agentError,
};

_$MedicationDtoImpl _$$MedicationDtoImplFromJson(Map<String, dynamic> json) =>
    _$MedicationDtoImpl(
      name: json['name'] as String,
      description: json['description'] as String,
      dosage: json['dosage'] as String,
      frequencyPerDay: (json['frequency_per_day'] as num?)?.toInt(),
      notes: json['notes'] as String,
      imagePath: json['image_path'] as String,
      medicationId: json['medication_id'] as String,
    );

Map<String, dynamic> _$$MedicationDtoImplToJson(_$MedicationDtoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'dosage': instance.dosage,
      'frequency_per_day': instance.frequencyPerDay,
      'notes': instance.notes,
      'image_path': instance.imagePath,
      'medication_id': instance.medicationId,
    };
