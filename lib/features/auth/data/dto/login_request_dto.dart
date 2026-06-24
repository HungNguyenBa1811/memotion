import 'package:json_annotation/json_annotation.dart';

part 'login_request_dto.g.dart';

/// Login Request DTO
///
/// Request body for POST /api/auth/login
@JsonSerializable()
class LoginRequestDto {
  final String username;
  final String password;

  const LoginRequestDto({required this.username, required this.password});

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}
