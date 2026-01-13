import 'package:json_annotation/json_annotation.dart';

part 'register_response_dto.g.dart';

/// Patient Info DTO
///
/// Nested patient information in register response
@JsonSerializable()
class PatientDto {
  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'full_name')
  final String fullName;

  final String email;
  final String phone;

  const PatientDto({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory PatientDto.fromJson(Map<String, dynamic> json) =>
      _$PatientDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PatientDtoToJson(this);
}

/// Register Response DTO
///
/// Response data for POST /api/auth/register/v2
/// ```json
/// {
///   "full_name": "string",
///   "email": "user@example.com",
///   "is_active": true,
///   "user_id": "uuid-string",
///   "phone": "string",
///   "role": "string",
///   "patient": { ... }
/// }
/// ```
@JsonSerializable()
class RegisterResponseDto {
  @JsonKey(name: 'full_name')
  final String fullName;

  final String email;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'user_id')
  final String userId;

  final String phone;
  final String role;
  final PatientDto? patient;

  const RegisterResponseDto({
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.userId,
    required this.phone,
    required this.role,
    this.patient,
  });

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseDtoToJson(this);
}
