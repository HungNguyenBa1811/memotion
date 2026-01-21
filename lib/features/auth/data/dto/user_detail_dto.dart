import 'package:freezed_annotation/freezed_annotation.dart';

import 'register_response_dto.dart';

part 'user_detail_dto.freezed.dart';
part 'user_detail_dto.g.dart';

/// DTO for /api/users/me response
@freezed
class UserDetailDto with _$UserDetailDto {
  const factory UserDetailDto({
    required String fullName,
    required String email,
    required bool isActive,
    required bool isFirstLogin,
    required String role,
    required String userId,
    required String phone,
    PatientDto? patient,
  }) = _UserDetailDto;

  factory UserDetailDto.fromJson(Map<String, dynamic> json) =>
      _$UserDetailDtoFromJson(json);
}
