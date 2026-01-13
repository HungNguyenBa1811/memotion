import 'package:json_annotation/json_annotation.dart';

part 'register_request_dto.g.dart';

/// Register Request DTO
///
/// Request body for POST /api/auth/register/v2
@JsonSerializable()
class RegisterRequestDto {
  @JsonKey(name: 'full_name')
  final String fullName;

  final String email;
  final String password;
  final String? phone;

  const RegisterRequestDto({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
  });

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}
