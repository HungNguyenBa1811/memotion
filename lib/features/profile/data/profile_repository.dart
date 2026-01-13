import 'dart:async';
import '../../../../core/network/network.dart';
import 'profile_api_service.dart';
import '../models/user_detail_response_dto.dart';

class ProfileRepository {
  final ProfileApiService _apiService = ProfileApiService();

  Future<Map<String, String>> fetchStats() async {
    // Simulate network / local DB delay
    await Future.delayed(const Duration(milliseconds: 300));
    return {'heartRate': '72bpm', 'energy': '756cal', 'weight': '103lbs'};
  }

  /// Get current user details from API
  Future<Result<UserDetailResponseDto>> getCurrentUser() async {
    return Result.guard(() async {
      return await _apiService.getCurrentUser();
    });
  }
}

// Provider is declared next to where it's used (Provider file).
