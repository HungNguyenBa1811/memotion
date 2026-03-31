import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../features/medication/providers/medication_provider.dart';
import '../../../voice_command/screens/voice_command_sheet.dart';
import '../../providers/home_provider.dart';
import '../../widgets/patient_greeting_hero.dart';
import '../../widgets/upcoming_medication_card.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../voice_command/providers/voice_audio_playing_provider.dart';

/// Homepage screen for PATIENT (Elderly) role (Figma design - node 535:1851)
/// Displays greeting, SOS button, medication schedule, quick actions, and health summary
class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final firstMed = ref.watch(firstMedicationTodayProvider);

    if (homeState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.lightGreen,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.tealGreen),
        ),
      );
    }

    final dashboardData = homeState.data;

    final heroSection = PatientGreetingHero(
      userName: 'Grandpa/Grandma',
      greeting: _getGreeting(),
      avatarUrl: dashboardData?.avatarUrl,
      moodMessage: "You don't seem to be in a good mood today",
      actionButtonText: 'EMERGENCY CALL',
      onActionPressed: () {
        homeNotifier.triggerSOS();
        _showSOSDialog(context);
      },
    );

    final medicationSection = UpcomingMedicationCard(
      title: firstMed?.name ?? 'Upcoming Schedule',
      time:
          firstMed?.time ??
          dashboardData?.upcomingMedication?.time ??
          '10:00 AM',
      dosage:
          firstMed?.dosage ??
          dashboardData?.upcomingMedication?.dosage ??
          'Take 1 Vitamin C tablet after meal',
      imageUrl: firstMed?.imageUrl.isNotEmpty == true
          ? firstMed!.imageUrl
          : dashboardData?.upcomingMedication?.imageUrl,
      onTakenPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as taken!'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      onDetailsPressed: () {
        context.go('/medication');
      },
    );

    final titleSection = Text(
      'For Grandpa/Grandma',
      style: AppTextStyles.headline1.copyWith(
        fontSize: 22 * ResponsiveUtils.textScaleFactor(context),
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.lightGreen,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => homeNotifier.refresh(),
          color: AppColors.tealGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.contentMaxWidth(context),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.horizontalPadding(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heroSection,
                      const SizedBox(height: 24),
                      medicationSection,
                      const SizedBox(height: 24),
                      titleSection,
                      SizedBox(
                        height:
                            80 *
                            (ResponsiveUtils.isTabletOrLarger(context)
                                ? 1.5
                                : 1.0),
                      ),
                      Center(
                        child: VoiceRecordButton(
                          isEnabled: !ref.watch(voiceAudioPlayingProvider),
                          size: VoiceRecordButtonSize.custom,
                          customDiameter:
                              ResponsiveUtils.isTabletOrLarger(context)
                                  ? 160
                                  : 120,
                          onPressed: () => _onAskAiPressed(context),
                          label: 'Ask AI',
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveUtils.bottomNavPadding(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Future<void> _onAskAiPressed(BuildContext context) async {
    final permissionStatus = await Permission.microphone.request();

    if (permissionStatus.isGranted) {
      if (!context.mounted) {
        return;
      }
      _showVoiceCommandSheet(context);
      return;
    }

    if (!context.mounted) {
      return;
    }

    if (permissionStatus.isPermanentlyDenied || permissionStatus.isRestricted) {
      _showMicrophonePermissionDialog(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Microphone permission is required to use Ask AI.'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _showVoiceCommandSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceCommandSheet(),
    );
  }

  void _showMicrophonePermissionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enable microphone access'),
          content: const Text(
            'Please allow microphone permission in Settings so Ask AI can hear your command.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final scale = ResponsiveUtils.textScaleFactor(context);
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20 * scale),
          ),
          title: Row(
            children: [
              Container(
                width: 40 * scale,
                height: 40 * scale,
                decoration: const BoxDecoration(
                  color: Color(0xFFD77658),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.phone, color: Colors.white, size: 24 * scale),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  'EMERGENCY CALL',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD77658),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Do you want to make an emergency call to family or emergency services?',
            style: TextStyle(fontSize: 16 * scale),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14 * scale,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement emergency call to family
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calling family...'),
                    backgroundColor: AppColors.tealGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 8 * scale,
                ),
              ),
              child: Text(
                'Call Family',
                style: TextStyle(fontSize: 14 * scale),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement 115 emergency call
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calling 115...'),
                    backgroundColor: Color(0xFFD77658),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD77658),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 8 * scale,
                ),
              ),
              child: Text('Call 115', style: TextStyle(fontSize: 14 * scale)),
            ),
          ],
        );
      },
    );
  }
}
