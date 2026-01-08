import '../../../../core/network/network.dart';
import '../datasources/auth_data_source.dart';
import '../dto/dto.dart';

/// Auth Repository
///
/// Provides authentication operations with proper error handling
/// and result wrapping for the presentation layer
abstract class AuthRepository {
  /// Login with email and password
  ///
  /// Returns [Success] with [LoginResponseDto] on success
  /// Returns [Failure] with [ApiException] on failure
  Future<Result<LoginResponseDto>> login({
    required String email,
    required String password,
  });

  /// Register a new user
  ///
  /// Returns [Success] with [RegisterResponseDto] on success
  /// Returns [Failure] with [ApiException] on failure
  Future<Result<RegisterResponseDto>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    UserRole role = UserRole.patient,
    String? patientFullName,
    String? patientEmail,
    String? patientPhone,
  });
}

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl({AuthDataSource? dataSource})
    : _dataSource = dataSource ?? AuthDataSourceImpl();

  @override
  Future<Result<LoginResponseDto>> login({
    required String email,
    required String password,
  }) async {
    return Result.guard(() async {
      final request = LoginRequestDto(username: email, password: password);
      final response = await _dataSource.login(request);

      // Store token in ApiClient for subsequent requests
      ApiClient.instance.setAuthToken(response.accessToken);

      return response;
    });
  }

  @override
  Future<Result<RegisterResponseDto>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    UserRole role = UserRole.patient,
    String? patientFullName,
    String? patientEmail,
    String? patientPhone,
  }) async {
    return Result.guard(() async {
      final request = RegisterRequestDto(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        role: role,
        patientFullName: patientFullName,
        patientEmail: patientEmail,
        patientPhone: patientPhone,
      );

      return await _dataSource.register(request);
    });
  }
}
