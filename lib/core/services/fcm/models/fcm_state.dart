import 'package:freezed_annotation/freezed_annotation.dart';

part 'fcm_state.freezed.dart';

/// FCM Service State
@freezed
class FcmState with _$FcmState {
  const factory FcmState({
    @Default(false) bool isInitialized,
    @Default(false) bool permissionGranted,
    String? currentToken,
    @Default(false) bool isSyncing,
    @Default(0) int syncRetryCount,
    String? error,
  }) = _FcmState;
}
