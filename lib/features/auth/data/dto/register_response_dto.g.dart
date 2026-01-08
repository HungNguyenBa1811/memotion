// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientDto _$PatientDtoFromJson(Map<String, dynamic> json) => PatientDto(
  userId: json['user_id'] as String,
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
);

Map<String, dynamic> _$PatientDtoToJson(PatientDto instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
    };

RegisterResponseDto _$RegisterResponseDtoFromJson(Map<String, dynamic> json) =>
    RegisterResponseDto(
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      isActive: json['is_active'] as bool,
      userId: json['user_id'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      patient: json['patient'] == null
          ? null
          : PatientDto.fromJson(json['patient'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisterResponseDtoToJson(
  RegisterResponseDto instance,
) => <String, dynamic>{
  'full_name': instance.fullName,
  'email': instance.email,
  'is_active': instance.isActive,
  'user_id': instance.userId,
  'phone': instance.phone,
  'role': instance.role,
  'patient': instance.patient,
};
