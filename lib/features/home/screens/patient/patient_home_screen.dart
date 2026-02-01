import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/home_provider.dart';
import '../../widgets/patient_greeting_hero.dart';
import '../../widgets/action_card.dart';
import '../../widgets/upcoming_medication_card.dart';
import '../../widgets/health_summary_card.dart';

/// Homepage screen for PATIENT (Elderly) role (Figma design - node 535:1851)
/// Displays greeting, SOS button, medication schedule, quick actions, and health summary
class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    if (homeState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.lightGreen,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.tealGreen),
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
                // Greeting Hero with SOS button (Patient/Elderly version)
                PatientGreetingHero(
                  userName: 'Grandpa/Grandma',
                  greeting: _getGreeting(),
                  avatarUrl: dashboardData?.avatarUrl,
                  moodMessage: "You don't seem to be in a good mood today",
                  actionButtonText: 'EMERGENCY CALL (SOS)',
                  onActionPressed: () {
                    homeNotifier.triggerSOS();
                    _showSOSDialog(context);
                  },
                ),

                const SizedBox(height: 24),

                // Section title: "For Grandpa/Grandma"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'For Grandpa/Grandma',
                    style: AppTextStyles.headline1.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Upcoming Medication Card (Patient perspective)
                UpcomingMedicationCard(
                  title: 'Upcoming Medication Schedule',
                  time: dashboardData?.upcomingMedication?.time ?? '10:00 AM',
                  dosage:
                      dashboardData?.upcomingMedication?.dosage ??
                      'Take 1 Vitamin C tablet after meal',
                  imageUrl: dashboardData?.upcomingMedication?.imageUrl,
                  onTakenPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Marked as taken!'),
                        backgroundColor: AppColors.tealGreen,
                      ),
                    );
                  },
                  onDetailsPressed: () {
                    context.go('/medication');
                  },
                ),

                const SizedBox(height: 24),

                // Quick Actions Grid (2x2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      // First row
                      Row(
                        children: [
                          Expanded(
                            child: ActionCard(
                              title: 'Health\nCheck',
                              iconAsset: 'assets/images/icon_heart_beat.png',
                              icon: Icons.health_and_safety,
                              iconColor: AppColors.primary,
                              onTap: () {
                                // Navigate to health check
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ActionCard(
                              title: 'Medication\nReminder',
                              iconAsset: 'assets/images/icon_medicine_file.png',
                              icon: Icons.medication,
                              iconColor: AppColors.primary,
                              onTap: () {
                                context.go('/medication');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Second row
                      Row(
                        children: [
                          Expanded(
                            child: ActionCard(
                              title: 'Family\nChat',
                              iconAsset: 'assets/images/icon_calls.png',
                              icon: Icons.chat_bubble,
                              iconColor: AppColors.primary,
                              onTap: () {
                                // Navigate to family chat
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ActionCard(
                              title: 'Health\nRecord',
                              iconAsset: 'assets/images/icon_health_check.png',
                              icon: Icons.book,
                              iconColor: AppColors.primary,
                              onTap: () {
                                context.go('/profile');
                              },
                            ),
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
                  bloodPressure:
                      dashboardData?.healthVitals?.bloodPressure ?? '120/80',
                  steps: dashboardData?.healthVitals?.steps ?? '0',
                  statusLabel: 'Very Good',
                ),

                // Bottom padding for navigation bar
                const SizedBox(height: 120),
              ],
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

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD77658),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'EMERGENCY CALL',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD77658),
              ),
            ),
          ],
        ),
        content: const Text(
          'Do you want to make an emergency call to family or emergency services?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Call Family'),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Call 115'),
          ),
        ],
      ),
    );
  }
}