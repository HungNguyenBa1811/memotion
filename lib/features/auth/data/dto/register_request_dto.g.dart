// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequestDto _$RegisterRequestDtoFromJson(Map<String, dynamic> json) =>
    RegisterRequestDto(
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
      role:
          $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.patient,
      patientFullName: json['patient_full_name'] as String?,
      patientEmail: json['patient_email'] as String?,
      patientPhone: json['patient_phone'] as String?,
    );

Map<String, dynamic> _$RegisterRequestDtoToJson(RegisterRequestDto instance) =>
    <String, dynamic>{
      'full_name': instance.fullName,
      'email': instance.email,
      'password': instance.password,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'patient_full_name': instance.patientFullName,
      'patient_email': instance.patientEmail,
      'patient_phone': instance.patientPhone,
    };

const _$UserRoleEnumMap = {
  UserRole.patient: 'PATIENT',
  UserRole.caregiver: 'CAREGIVER',
};
