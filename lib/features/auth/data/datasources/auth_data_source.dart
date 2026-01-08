import '../dto/dto.dart';
import 'auth_api_service.dart';

/// Auth Data Source Interface
///
/// Abstract interface for authentication operations
abstract class AuthDataSource {
  /// Login with username (email) and password
  Future<LoginResponseDto> login(LoginRequestDto request);

  /// Register a new user
  Future<RegisterResponseDto> register(RegisterRequestDto request);
}

/// Implementation of AuthDataSource
///
/// Delegates to AuthApiService which handles API calls and logging
class AuthDataSourceImpl implements AuthDataSource {
  final AuthApiService _apiService;

  AuthDataSourceImpl({AuthApiService? apiService})
    : _apiService = apiService ?? AuthApiService();

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) {
    return _apiService.login(request);
  }

  @override
  Future<RegisterResponseDto> register(RegisterRequestDto request) {
    return _apiService.register(request);
  }
}
