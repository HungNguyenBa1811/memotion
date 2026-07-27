import 'package:freezed_annotation/freezed_annotation.dart';

import 'register_response_dto.dart';

part 'user_detail_dto.freezed.dart';
part 'user_detail_dto.g.dart';

/// DTO for /api/users/me response
@freezed
class UserDetailDto with _$UserDetailDto {
  const factory UserDetailDto({
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    @JsonKey(name: 'is_active') required bool isActive,
    required String role,
    @JsonKey(name: 'user_id') required String userId,
    required String phone,
    @JsonKey(name: 'is_first_login') bool? isFirstLogin,
    PatientDto? patient,
  }) = _UserDetailDto;

  factory UserDetailDto.fromJson(Map<String, dynamic> json) =>
      _$UserDetailDtoFromJson(json);
}
