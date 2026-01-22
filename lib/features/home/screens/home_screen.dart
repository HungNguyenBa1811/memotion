import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/providers/profile_provider.dart';
import 'caretaker/caretaker_home_screen.dart';
import 'patient/patient_home_screen.dart';

/// Homepage screen that routes to appropriate screen based on user role
/// - CARETAKER role: Shows CaretakerHomeScreen
/// - PATIENT role: Shows PatientHomeScreen (Elderly)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileViewModel = ref.watch(profileViewModelProvider);

    // Show loading while fetching user profile
    if (profileViewModel.isLoadingUserDetails) {
      return const Scaffold(
        backgroundColor: AppColors.lightGreen,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.tealGreen),
        ),
      );
    }

    // Get user role from profile
    final userRole =
        profileViewModel.userDetails?.role.toUpperCase() ?? 'PATIENT';

    // Route to appropriate screen based on role
    if (userRole == 'CARETAKER') {
      return const CaretakerHomeScreen();
    } else {
      // Default to Patient/Elderly screen
      return const PatientHomeScreen();
    }
  }
}
