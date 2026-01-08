import 'package:json_annotation/json_annotation.dart';

part 'register_request_dto.g.dart';

/// User Role enum
enum UserRole {
  @JsonValue('PATIENT')
  patient,
  @JsonValue('CAREGIVER')
  caregiver,
}

/// Register Request DTO
///
/// Request body for POST /api/auth/register
@JsonSerializable()
class RegisterRequestDto {
  @JsonKey(name: 'full_name')
  final String fullName;

  final String email;
  final String password;
  final String phone;
  final UserRole role;

  @JsonKey(name: 'patient_full_name')
  final String? patientFullName;

  @JsonKey(name: 'patient_email')
  final String? patientEmail;

  @JsonKey(name: 'patient_phone')
  final String? patientPhone;

  const RegisterRequestDto({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phone,
    this.role = UserRole.patient,
    this.patientFullName,
    this.patientEmail,
    this.patientPhone,
  });

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}
