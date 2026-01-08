import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service quản lý lưu trữ token một cách bảo mật
///
/// Sử dụng flutter_secure_storage để mã hóa token trên device
class TokenStorage {
  static TokenStorage? _instance;
  late final FlutterSecureStorage _storage;

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';

  TokenStorage._() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  static TokenStorage get instance {
    _instance ??= TokenStorage._();
    return _instance!;
  }

  /// Lưu access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
    debugPrint('🔐 TokenStorage: Access token saved');
  }

  /// Lưu refresh token (nếu API hỗ trợ)
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
    debugPrint('🔐 TokenStorage: Refresh token saved');
  }

  /// Lưu token type (bearer, etc.)
  Future<void> saveTokenType(String type) async {
    await _storage.write(key: _tokenTypeKey, value: type);
  }

  /// Lấy access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Lấy refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Lấy token type
  Future<String?> getTokenType() async {
    return await _storage.read(key: _tokenTypeKey);
  }

  /// Kiểm tra có token hay không
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Xóa tất cả tokens (dùng khi logout hoặc 401)
  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenTypeKey);
    debugPrint('🔐 TokenStorage: All tokens cleared');
  }

  /// Xóa chỉ access token
  Future<void> clearAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
    debugPrint('🔐 TokenStorage: Access token cleared');
  }
}
