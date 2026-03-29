import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../features/medication/providers/medication_provider.dart';
import '../../providers/home_provider.dart';
import '../../widgets/greeting_hero.dart';
import '../../widgets/action_card.dart';
import '../../widgets/upcoming_medication_card.dart';

/// Homepage screen for CARETAKER role (Figma design)
/// Displays greeting, situation handling button, medication reminder, quick actions, and health summary
class CaretakerHomeScreen extends ConsumerWidget {
  const CaretakerHomeScreen({super.key});

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

    // Hero + medication widgets
    final heroSection = GreetingHero(
      userName: 'Sir/Madam',
      greeting: _getGreeting(),
      avatarUrl: dashboardData?.avatarUrl,
      moodMessage: "Please pay attention to patient's mood",
      actionButtonText: 'SITUATION HANDLING',
      onActionPressed: () {
        homeNotifier.triggerSOS();
        _showSituationHandlingDialog(context);
      },
    );

    final medicationSection = UpcomingMedicationCard(
      title: firstMed?.name ?? 'Remind to take medicine',
      time: firstMed?.time ?? dashboardData?.upcomingMedication?.time ?? '10:00 AM',
      dosage: firstMed?.dosage ?? dashboardData?.upcomingMedication?.dosage ?? 'Take 1 Vitamin C tablet after meal',
      imageUrl: firstMed?.imageUrl.isNotEmpty == true ? firstMed!.imageUrl : dashboardData?.upcomingMedication?.imageUrl,
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
      'For Caregiver',
      style: AppTextStyles.headline1.copyWith(
        fontSize: 22 * ResponsiveUtils.textScaleFactor(context),
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );

    final actionsGrid = GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 162 / 171,
      children: [
        ActionCard(
          title: 'Health\nCheck',
          iconAsset: 'assets/images/icon_heart_beat.png',
          icon: Icons.health_and_safety,
          iconColor: AppColors.primary,
          onTap: () {},
        ),
        ActionCard(
          title: 'Medication\nReminder',
          iconAsset: 'assets/images/icon_medicine_file.png',
          icon: Icons.medication,
          iconColor: AppColors.primary,
          onTap: () => context.go('/medication'),
        ),
        ActionCard(
          title: 'Family\nChat',
          iconAsset: 'assets/images/icon_calls.png',
          icon: Icons.chat_bubble,
          iconColor: AppColors.primary,
          onTap: () {},
        ),
        ActionCard(
          title: 'Health\nRecord',
          iconAsset: 'assets/images/icon_health_check.png',
          icon: Icons.book,
          iconColor: AppColors.primary,
          onTap: () => context.push(AppRoutes.caretakerHealthReport),
        ),
      ],
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
                      const SizedBox(height: 16),
                      actionsGrid,
                      const SizedBox(height: 24),
                      SizedBox(height: ResponsiveUtils.bottomNavPadding(context)),
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

  void _showSituationHandlingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Situation Handling'),
        content: const Text('Do you want to make an emergency call or contact family?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'), // TODO: REVIEW_LAYOUT_RISK
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement emergency call
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Emergency Call'),
          ),
        ],
      ),
    );
  }
}