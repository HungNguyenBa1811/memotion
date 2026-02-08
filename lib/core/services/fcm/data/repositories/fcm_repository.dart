import 'package:firebase_messaging/firebase_messaging.dart';
import '../datasources/fcm_api_service.dart';
import '../datasources/fcm_local_datasource.dart';
import '../models/fcm_token_local_model.dart';
import '../../../storage/token_storage.dart';

/// FCM Repository
/// Coordinates between local storage and remote API
class FcmRepository {
  final FcmLocalDataSource _localDataSource;
  final FcmApiService _apiService;
  final TokenStorage _tokenStorage;

  FcmRepository({
    required FcmLocalDataSource localDataSource,
    required FcmApiService apiService,
    required TokenStorage tokenStorage,
  })  : _localDataSource = localDataSource,
        _apiService = apiService,
        _tokenStorage = tokenStorage;

  /// Get stored token from local storage
  Future<FcmTokenLocalModel?> getStoredToken() async {
    return await _localDataSource.getToken();
  }

  /// Save token locally
  Future<void> saveTokenLocally(String token) async {
    final model = FcmTokenLocalModel(
      token: token,
      lastUpdated: DateTime.now(),
      isSynced: false,
    );
    await _localDataSource.saveToken(model);
  }

  /// Sync token to backend server
  Future<bool> syncTokenToServer(String token) async {
    try {
      // Get access token
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null) {
        return false; // User not logged in
      }

      // Call API
      await _apiService.syncToken(
        fcmToken: token,
        accessToken: accessToken,
      );

      // Update local storage as synced
      final model = FcmTokenLocalModel(
        token: token,
        lastUpdated: DateTime.now(),
        isSynced: true,
      );
      await _localDataSource.saveToken(model);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if token needs sync
  Future<bool> needsSync() async {
    return await _localDataSource.needsSync();
  }

  /// Clear token (e.g., on logout)
  Future<void> clearToken() async {
    await _localDataSource.clearToken();
  }

  /// Request and save new FCM token
  Future<String?> requestNewToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await saveTokenLocally(token);
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Delete token and request new one (force refresh)
  Future<String?> refreshToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      return await requestNewToken();
    } catch (e) {
      return null;
    }
  }
}
