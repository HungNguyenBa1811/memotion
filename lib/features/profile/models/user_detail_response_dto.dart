import 'package:json_annotation/json_annotation.dart';

part 'user_detail_response_dto.g.dart';

/// User Detail Response DTO
///
/// Response body for GET /api/users/me
@JsonSerializable()
class UserDetailResponseDto {
  @JsonKey(name: 'full_name')
  final String fullName;

  final String email;

  @JsonKey(name: 'is_active')
  final bool isActive;

  final String role;

  @JsonKey(name: 'user_id')
  final String userId;

  final String? phone;

  const UserDetailResponseDto({
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.role,
    required this.userId,
    this.phone,
  });

  factory UserDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserDetailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailResponseDtoToJson(this);
}
