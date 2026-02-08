import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/fcm_state.dart';
import '../data/data.dart';

/// FCM Service Notifier
/// Manages FCM token lifecycle and state
class FcmNotifier extends StateNotifier<FcmState> {
  final FcmRepository _repository;

  FcmNotifier(this._repository) : super(const FcmState());

  /// Initialize FCM service
  Future<void> initialize() async {
    if (state.isInitialized) return;

    try {
      debugPrint('[FCM] Initializing...');

      // Request permission
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      state = state.copyWith(permissionGranted: permissionGranted);

      if (!permissionGranted) {
        debugPrint('[FCM] Permission denied');
        return;
      }

      // Get initial token
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _handleNewToken(token);
      }

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen(_handleNewToken);

      state = state.copyWith(isInitialized: true);
      debugPrint('[FCM] Initialized successfully');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      debugPrint('[FCM] Initialization error: $e');
    }
  }

  /// Handle new or refreshed token
  Future<void> _handleNewToken(String token) async {
    debugPrint('[FCM] New token: ${token.substring(0, 20)}...');

    state = state.copyWith(currentToken: token);

    // Save locally
    await _repository.saveTokenLocally(token);

    // Try to sync
    await _syncToken(token);
  }

  /// Sync token to server
  Future<void> _syncToken(String token) async {
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true);

    final success = await _repository.syncTokenToServer(token);

    if (success) {
      debugPrint('[FCM] Token synced successfully');
      state = state.copyWith(isSyncing: false, syncRetryCount: 0);
    } else {
      debugPrint('[FCM] Token sync failed');
      state = state.copyWith(isSyncing: false);
      _scheduleRetry(token);
    }
  }

  /// Schedule retry with exponential backoff
  void _scheduleRetry(String token) {
    if (state.syncRetryCount >= 3) {
      debugPrint('[FCM] Max retries reached');
      return;
    }

    final retryCount = state.syncRetryCount + 1;
    state = state.copyWith(syncRetryCount: retryCount);

    final delay = Duration(seconds: 30 * retryCount);
    debugPrint('[FCM] Retry $retryCount after ${delay.inSeconds}s');

    Future.delayed(delay, () => _syncToken(token));
  }

  /// Sync token after login
  Future<void> syncAfterLogin() async {
    debugPrint('[FCM] Syncing token after login');

    final needsSync = await _repository.needsSync();
    if (!needsSync) {
      debugPrint('[FCM] Token already synced');
      return;
    }

    final storedToken = await _repository.getStoredToken();
    if (storedToken != null) {
      await _syncToken(storedToken.token);
    }
  }

  /// Check token freshness and refresh if needed
  Future<void> checkTokenFreshness() async {
    final storedToken = await _repository.getStoredToken();
    if (storedToken == null) return;

    if (storedToken.isExpiringSoon()) {
      debugPrint('[FCM] Token expiring soon, refreshing...');
      final newToken = await _repository.refreshToken();
      if (newToken != null) {
        await _handleNewToken(newToken);
      }
    }
  }

  /// Clear token on logout
  Future<void> onLogout() async {
    debugPrint('[FCM] Clearing token on logout');
    await _repository.clearToken();
    state = state.copyWith(currentToken: null, syncRetryCount: 0);
  }
}

/// FCM Service Provider
final fcmServiceProvider =
    StateNotifierProvider<FcmNotifier, FcmState>((ref) {
  final repository = ref.watch(fcmRepositoryProvider);
  return FcmNotifier(repository);
});
