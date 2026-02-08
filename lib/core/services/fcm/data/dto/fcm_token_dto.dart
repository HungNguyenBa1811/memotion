import 'package:freezed_annotation/freezed_annotation.dart';

part 'fcm_token_dto.freezed.dart';
part 'fcm_token_dto.g.dart';

/// Request DTO for saving FCM token to backend
@freezed
class SaveFcmTokenRequest with _$SaveFcmTokenRequest {
  const factory SaveFcmTokenRequest({
    @JsonKey(name: 'fcm_token') required String fcmToken,
  }) = _SaveFcmTokenRequest;

  factory SaveFcmTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveFcmTokenRequestFromJson(json);
}

/// Response DTO after saving FCM token
@freezed
class SaveFcmTokenResponse with _$SaveFcmTokenResponse {
  const factory SaveFcmTokenResponse({
    required int code,
    required String message,
    UserDataDto? data,
  }) = _SaveFcmTokenResponse;

  factory SaveFcmTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$SaveFcmTokenResponseFromJson(json);
}

/// User data DTO from response
@freezed
class UserDataDto with _$UserDataDto {
  const factory UserDataDto({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'register_fcm_token') String? registerFcmToken,
    @JsonKey(name: 'update_fcm_time') String? updateFcmTime,
  }) = _UserDataDto;

  factory UserDataDto.fromJson(Map<String, dynamic> json) =>
      _$UserDataDtoFromJson(json);
}
