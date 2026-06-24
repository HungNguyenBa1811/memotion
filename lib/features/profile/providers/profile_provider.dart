import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../medication/providers/medication_provider.dart';
import '../../nutrition/providers/nutrition_provider.dart';
import '../../workout/providers/workout_provider.dart';
import '../../../core/network/result.dart';
import '../data/profile_repository.dart';
import '../models/user_detail_response_dto.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final profileViewModelProvider = ChangeNotifierProvider<ProfileViewModel>((
  ref,
) {
  return ProfileViewModel(ref);
});

class ProfileViewModel extends ChangeNotifier {
  final Ref ref;

  String heartRate = '';
  String energy = '';
  String weight = '';
  UserDetailResponseDto? userDetails;
  bool isLoadingUserDetails = false;
  String? userDetailsError;

  ProfileViewModel(this.ref) {
    _init();
  }

  void _init() async {
    await loadStats();
    await loadUserDetails();
    notifyListeners();

    // Re-load user details whenever the user authenticates (e.g. after re-login)
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated) {
        loadUserDetails();
      }
    });
  }

  Future<void> loadStats() async {
    final repo = ref.read(profileRepositoryProvider);
    final stats = await repo.fetchStats();
    heartRate = stats['heartRate'] ?? '';
    energy = stats['energy'] ?? '';
    weight = stats['weight'] ?? '';
    notifyListeners();
  }

  Future<void> loadUserDetails() async {
    isLoadingUserDetails = true;
    userDetailsError = null;
    notifyListeners();

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getCurrentUser();

    if (result.isSuccess) {
      userDetails = result.dataOrNull;
      debugPrint(
        'User details loaded successfully: ${result.dataOrNull!.fullName}',
      );
    } else {
      final failure = result as Failure<UserDetailResponseDto>;
      userDetailsError = failure.message;
      debugPrint('Failed to load user details: ${failure.message}');
    }

    isLoadingUserDetails = false;
    notifyListeners();
  }

  // Expose current user via auth provider
  dynamic get user => ref.read(authProvider).user;

  // Get display name from API response or fallback to auth provider
  String get displayName {
    if (userDetails?.fullName.isNotEmpty == true) {
      return userDetails!.fullName;
    }
    return user?.nickname ?? 'User';
  }

  // Get email from API response or fallback to auth provider
  String get displayEmail {
    if (userDetails?.email.isNotEmpty == true) {
      return userDetails!.email;
    }
    return user?.email ?? '';
  }

  Future<void> logout() async {
    await ref.read(authProvider.notifier).logout();

    // Clear local cached fields immediately so UI doesn't show stale data
    heartRate = '';
    energy = '';
    weight = '';
    userDetails = null;
    userDetailsError = null;
    isLoadingUserDetails = false;

    // Invalidate global providers so feature data is re-fetched for next user
    try {
      ref.invalidate(homeProvider);
    } catch (_) {}
    try {
      ref.invalidate(medicationsProvider);
    } catch (_) {}
    try {
      ref.invalidate(nutritionTasksProvider);
    } catch (_) {}
    try {
      ref.invalidate(workoutListProvider);
      ref.invalidate(workoutDetailProvider);
    } catch (_) {}

    notifyListeners();
  }
}
