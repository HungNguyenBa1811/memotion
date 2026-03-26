import 'package:json_annotation/json_annotation.dart';

part 'login_response_dto.g.dart';

/// Login Response DTO
///
/// Response data for POST /api/auth/login
/// ```json
/// {
///   "access_token": "string",
///   "token_type": "bearer"
/// }
/// ```
@JsonSerializable()
class LoginResponseDto {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'token_type')
  final String tokenType;

  const LoginResponseDto({
    required this.accessToken,
    required this.tokenType,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}
