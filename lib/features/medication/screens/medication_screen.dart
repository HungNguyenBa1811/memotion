import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/providers/profile_provider.dart';
import 'medication_main_screen.dart';
import 'patient/patient_medication_screen.dart';

/// Role-aware medication screen entry point.
/// Routes to [MedicationMainScreenContent] for CARETAKER
/// or [PatientMedicationScreenContent] for PATIENT.
class MedicationScreen extends ConsumerWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileViewModel = ref.watch(profileViewModelProvider);

    if (profileViewModel.isLoadingUserDetails) {
      return const Scaffold(
        backgroundColor: AppColors.lightGreen,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.tealGreen),
        ),
      );
    }

    final role =
        profileViewModel.userDetails?.role.toUpperCase() ?? 'PATIENT';

    if (role == 'CARETAKER') {
      return const MedicationMainScreenContent();
    } else {
      return const PatientMedicationScreenContent();
    }
  }
}
