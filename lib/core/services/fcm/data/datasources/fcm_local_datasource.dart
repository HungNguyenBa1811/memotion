import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fcm_token_local_model.dart';

/// Local storage for FCM token
/// Uses SharedPreferences as storage backend
class FcmLocalDataSource {
  static const String _tokenKey = 'fcm_token_v1';

  final SharedPreferences _prefs;

  FcmLocalDataSource({required SharedPreferences prefs}) : _prefs = prefs;

  /// Get stored FCM token
  Future<FcmTokenLocalModel?> getToken() async {
    try {
      final jsonString = _prefs.getString(_tokenKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FcmTokenLocalModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Save FCM token locally
  Future<void> saveToken(FcmTokenLocalModel token) async {
    final jsonString = jsonEncode(token.toJson());
    await _prefs.setString(_tokenKey, jsonString);
  }

  /// Clear stored token
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  /// Check if token needs sync
  Future<bool> needsSync() async {
    final token = await getToken();
    if (token == null) return false;
    return !token.isSynced;
  }
}
