/// API Constants and Endpoints
class ApiConstants {
  ApiConstants._();

  // Base URL - Change this according to your environment
  static const String baseUrl = 'http://14.225.218.83:8005';

  // Auth Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
