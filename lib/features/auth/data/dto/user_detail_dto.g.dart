// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDetailDtoImpl _$$UserDetailDtoImplFromJson(Map<String, dynamic> json) =>
    _$UserDetailDtoImpl(
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      isActive: json['is_active'] as bool,
      isFirstLogin: json['is_first_login'] as bool,
      role: json['role'] as String,
      userId: json['user_id'] as String,
      phone: json['phone'] as String,
      patient: json['patient'] == null
          ? null
          : PatientDto.fromJson(json['patient'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserDetailDtoImplToJson(_$UserDetailDtoImpl instance) =>
    <String, dynamic>{
      'full_name': instance.fullName,
      'email': instance.email,
      'is_active': instance.isActive,
      'is_first_login': instance.isFirstLogin,
      'role': instance.role,
      'user_id': instance.userId,
      'phone': instance.phone,
      'patient': instance.patient,
    };
