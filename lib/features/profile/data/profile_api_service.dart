import 'package:flutter/foundation.dart';

import '../../../../core/network/network.dart';
import '../models/user_detail_response_dto.dart';

/// Profile API Service
///
/// Handles all profile API calls with logging
class ProfileApiService extends BaseApiService {
  ProfileApiService({super.dio});

  /// Get current user details
  ///
  /// GET /api/users/me
  Future<UserDetailResponseDto> getCurrentUser() async {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 👤 PROFILE: Fetching current user details');
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );

    final response = await get(
      '/api/users/me',
      parser: (json) => BaseResponse<UserDetailResponseDto>.fromJson(
        json as Map<String, dynamic>,
        (data) => UserDetailResponseDto.fromJson(data as Map<String, dynamic>),
      ),
    );

    if (response.isSuccess && response.data != null) {
      debugPrint(
        '┌─────────────────────────────────────────────────────────────',
      );
      debugPrint('│ ✅ PROFILE: User details fetched successfully');
      debugPrint('│ User ID: ${response.data!.userId}');
      debugPrint('│ Name: ${response.data!.fullName}');
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
    debugPrint('│ ❌ PROFILE: Failed to fetch user details');
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
