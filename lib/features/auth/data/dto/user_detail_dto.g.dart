// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDetailDtoImpl _$$UserDetailDtoImplFromJson(Map<String, dynamic> json) =>
    _$UserDetailDtoImpl(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      isActive: json['isActive'] as bool,
      isFirstLogin: json['isFirstLogin'] as bool,
      role: json['role'] as String,
      userId: json['userId'] as String,
      phone: json['phone'] as String,
      patient: json['patient'] == null
          ? null
          : PatientDto.fromJson(json['patient'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserDetailDtoImplToJson(_$UserDetailDtoImpl instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'email': instance.email,
      'isActive': instance.isActive,
      'isFirstLogin': instance.isFirstLogin,
      'role': instance.role,
      'userId': instance.userId,
      'phone': instance.phone,
      'patient': instance.patient,
    };
