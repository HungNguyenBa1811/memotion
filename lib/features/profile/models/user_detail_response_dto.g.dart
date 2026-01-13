// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_detail_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDetailResponseDto _$UserDetailResponseDtoFromJson(
  Map<String, dynamic> json,
) => UserDetailResponseDto(
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  isActive: json['is_active'] as bool,
  role: json['role'] as String,
  userId: json['user_id'] as String,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$UserDetailResponseDtoToJson(
  UserDetailResponseDto instance,
) => <String, dynamic>{
  'full_name': instance.fullName,
  'email': instance.email,
  'is_active': instance.isActive,
  'role': instance.role,
  'user_id': instance.userId,
  'phone': instance.phone,
};
