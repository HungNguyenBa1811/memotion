import 'package:dio/dio.dart';
import '../dto/dto.dart';

/// FCM API Service
/// Handles HTTP requests for FCM token sync
class FcmApiService {
  final Dio _dio;
  final String _baseUrl;

  FcmApiService({
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? 'http://your-backend.com';

  /// Sync FCM token to backend
  /// POST /api/v1/users/fcm-token
  Future<SaveFcmTokenResponse> syncToken({
    required String fcmToken,
    required String accessToken,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/v1/users/fcm-token',
        data: SaveFcmTokenRequest(fcmToken: fcmToken).toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return SaveFcmTokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.response != null) {
      return Exception(
        'API Error: ${error.response?.statusCode} - ${error.response?.data}',
      );
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return Exception('Connection timeout');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return Exception('Receive timeout');
    }
    return Exception('Network error: ${error.message}');
  }
}
