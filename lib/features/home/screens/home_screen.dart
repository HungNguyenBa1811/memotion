import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/home_provider.dart';
import '../widgets/greeting_hero.dart';
import '../widgets/action_card.dart';
import '../widgets/upcoming_medication_card.dart';
import '../widgets/health_summary_card.dart';

/// Homepage screen for elderly users
/// Displays greeting, SOS button, quick actions, medication, and health summary
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const HomeScreenContent();
  }
}

class HomeScreenContent extends ConsumerWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    if (homeState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.lightGreen,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.tealGreen,
          ),
        ),
      );
    }

    final dashboardData = homeState.data;

    return Scaffold(
      backgroundColor: AppColors.lightGreen,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => homeNotifier.refresh(),
          color: AppColors.tealGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status bar spacing
                const SizedBox(height: 8),

                // Top navigation icons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {},
                        color: AppColors.primaryBlack,
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                        color: AppColors.primaryBlack,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Greeting Hero with SOS button
                GreetingHero(
                  userName: dashboardData?.userName ?? 'User',
                  greeting: dashboardData?.greeting ?? 'Hello',
                  avatarUrl: dashboardData?.avatarUrl,
                  onSOSPressed: () {
                    homeNotifier.triggerSOS();
                    _showSOSDialog(context);
                  },
                ),

                const SizedBox(height: 24),

                // Upcoming Medication Card
                if (dashboardData?.upcomingMedication != null)
                  UpcomingMedicationCard(
                    title: dashboardData!.upcomingMedication!.name,
                    time: dashboardData.upcomingMedication!.time,
                    dosage: dashboardData.upcomingMedication!.dosage,
                    imageUrl: dashboardData.upcomingMedication!.imageUrl,
                    onDetailsPressed: () {
                      context.go('/medication');
                    },
                  ),

                const SizedBox(height: 24),

                // Quick Actions Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: AppTextStyles.sectionHeading,
                      ),
                      const SizedBox(height: 16),
                      // 2x2 Grid of action cards
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          ActionCard(
                            title: 'Medication',
                            icon: Icons.medication,
                            iconColor: AppColors.accent,
                            onTap: () {
                              context.go('/medication');
                            },
                          ),
                          ActionCard(
                            title: 'Nutrition',
                            icon: Icons.restaurant,
                            iconColor: AppColors.tealGreen,
                            onTap: () {
                              context.go('/nutrition');
                            },
                          ),
                          ActionCard(
                            title: 'Workout',
                            icon: Icons.fitness_center,
                            iconColor: AppColors.warning,
                            onTap: () {
                              context.go('/workout');
                            },
                          ),
                          ActionCard(
                            title: 'Appointment',
                            icon: Icons.calendar_today,
                            iconColor: AppColors.error,
                            onTap: () {
                              // Navigate to appointments
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Health Summary Card
                HealthSummaryCard(
                  heartRate: dashboardData?.healthVitals?.heartRate ?? '72',
                  bloodPressure: dashboardData?.healthVitals?.bloodPressure ?? '120/80',
                  steps: dashboardData?.healthVitals?.steps ?? '0',
                ),

                const SizedBox(height: 32),

                // Bottom padding for navigation bar
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: const Text(
          'Are you sure you want to send an emergency alert to your caregivers?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Trigger SOS action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency alert sent!'),
                  backgroundColor: AppColors.sosButton,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sosButton,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }
}
