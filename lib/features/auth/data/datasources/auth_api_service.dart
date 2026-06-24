import 'package:flutter/foundation.dart';

import '../../../../core/network/network.dart';
import '../dto/dto.dart';

/// Auth API Service
///
/// Handles all authentication API calls with logging
class AuthApiService extends BaseApiService {
  AuthApiService({super.dio});

  /// Login with username (email) and password
  ///
  /// POST /api/auth/login
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 🔐 AUTH: Attempting login for ${request.username}');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    final response = await post(
      ApiConstants.login,
      data: request.toJson(),
      parser: (json) => BaseResponse<LoginResponseDto>.fromJson(
        json as Map<String, dynamic>,
        (data) => LoginResponseDto.fromJson(data as Map<String, dynamic>),
      ),
    );

    if (response.isSuccess && response.data != null) {
      debugPrint(
        '┌─────────────────────────────────────────────────────────────',
      );
      debugPrint('│ ✅ AUTH: Login successful for ${request.username}');
      debugPrint('│ Token type: ${response.data!.tokenType}');
      debugPrint(
        '│ Access token: ${response.data!.accessToken.substring(0, 20)}...',
      );
      debugPrint(
        '└─────────────────────────────────────────────────────────────',
      );
      return response.data!;
    }

    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ ❌ AUTH: Login failed');
    debugPrint('│ Code: ${response.code}');
    debugPrint('│ Message: ${response.message}');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    throw BadRequestException(
      message: response.message.isNotEmpty ? response.message : 'Login failed',
    );
  }

  /// Register a new user
  ///
  /// POST /api/auth/register/v2
  Future<RegisterResponseDto> register(RegisterRequestDto request) async {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 📝 AUTH: Attempting registration for ${request.email}');
    debugPrint('│ Full name: ${request.fullName}');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    final response = await post(
      ApiConstants.register,
      data: request.toJson(),
      parser: (json) => BaseResponse<RegisterResponseDto>.fromJson(
        json as Map<String, dynamic>,
        (data) => RegisterResponseDto.fromJson(data as Map<String, dynamic>),
      ),
    );

    if (response.isSuccess && response.data != null) {
      debugPrint(
        '┌─────────────────────────────────────────────────────────────',
      );
      debugPrint('│ ✅ AUTH: Registration successful');
      debugPrint('│ User ID: ${response.data!.userId}');
      debugPrint('│ Email: ${response.data!.email}');
      debugPrint('│ Role: ${response.data!.role}');
      debugPrint('│ Active: ${response.data!.isActive}');
      debugPrint(
        '└─────────────────────────────────────────────────────────────',
      );
      return response.data!;
    }

    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ ❌ AUTH: Registration failed');
    debugPrint('│ Code: ${response.code}');
    debugPrint('│ Message: ${response.message}');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    throw BadRequestException(
      message: response.message.isNotEmpty
          ? response.message
          : 'Registration failed',
    );
  }

  /// Get current user details
  ///
  /// GET /api/users/me
  Future<UserDetailDto> getUserDetails() async {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 👤 AUTH: Fetching user details');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    final response = await get(
      ApiConstants.userMe,
      parser: (json) => BaseResponse<UserDetailDto>.fromJson(
        json as Map<String, dynamic>,
        (data) => UserDetailDto.fromJson(data as Map<String, dynamic>),
      ),
    );

    if (response.isSuccess && response.data != null) {
      debugPrint(
        '┌─────────────────────────────────────────────────────────────',
      );
      debugPrint('│ ✅ AUTH: User details fetched successfully');
      debugPrint('│ User ID: ${response.data!.userId}');
      debugPrint('│ Email: ${response.data!.email}');
      debugPrint('│ Role: ${response.data!.role}');
      debugPrint(
        '└─────────────────────────────────────────────────────────────',
      );
      return response.data!;
    }

    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ ❌ AUTH: Failed to fetch user details');
    debugPrint('│ Code: ${response.code}');
    debugPrint('│ Message: ${response.message}');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    throw BadRequestException(
      message: response.message.isNotEmpty
          ? response.message
          : 'Failed to fetch user details',
    );
  }
}
