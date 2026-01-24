import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/home_provider.dart';
import '../../widgets/greeting_hero.dart';
import '../../widgets/action_card.dart';
import '../../widgets/upcoming_medication_card.dart';
import '../../widgets/health_summary_card.dart';

/// Homepage screen for CARETAKER role (Figma design)
/// Displays greeting, situation handling button, medication reminder, quick actions, and health summary
class CaretakerHomeScreen extends ConsumerWidget {
  const CaretakerHomeScreen({super.key});

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
                // Greeting Hero with situation handling button (Caretaker version)
                GreetingHero(
                  userName: 'Anh/Chị',
                  greeting: _getGreeting(),
                  avatarUrl: dashboardData?.avatarUrl,
                  moodMessage: 'Hôm nay cần để ý đến tâm trạng của bác nhé',
                  actionButtonText: 'XỬ LÝ TÌNH HUỐNG',
                  onActionPressed: () {
                    homeNotifier.triggerSOS();
                    _showSituationHandlingDialog(context);
                  },
                ),

                const SizedBox(height: 24),

                // Upcoming Medication Card (Caregiver perspective)
                UpcomingMedicationCard(
                  title: 'Nhắc ông/bà uống thuốc',
                  time: dashboardData?.upcomingMedication?.time ?? '10:00 AM',
                  dosage:
                      dashboardData?.upcomingMedication?.dosage ??
                      'Uống 1 viên Vitamin C sau ăn',
                  imageUrl: dashboardData?.upcomingMedication?.imageUrl,
                  onTakenPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã đánh dấu uống thuốc!'),
                        backgroundColor: AppColors.tealGreen,
                      ),
                    );
                  },
                  onDetailsPressed: () {
                    context.go('/medication');
                  },
                ),

                const SizedBox(height: 24),

                // Section title: "Dành cho Caregiver"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'Dành cho Caregiver',
                    style: AppTextStyles.headline1.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

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
                              title: 'Kiểm tra\nsức khoẻ',
                              svgAsset: 'assets/images/icon_heart_beat.svg',
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
                              title: 'Nhắc uống\nthuốc',
                              svgAsset: 'assets/images/icon_medicine_file.svg',
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
                              title: 'Trò chuyện\ngia đình',
                              svgAsset: 'assets/images/icon_calls.svg',
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
                              title: 'Sổ sức\nkhoẻ',
                              svgAsset: 'assets/images/icon_health_check.svg',
                              icon: Icons.book,
                              iconColor: AppColors.primary,
                              onTap: () {
                                context.push(AppRoutes.caretakerHealthReport);
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
                  statusLabel: 'Rất tốt',
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
      return 'Chào buổi sáng';
    } else if (hour < 18) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }

  void _showSituationHandlingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xử lý tình huống'),
        content: const Text('Bạn có muốn gọi khẩn cấp hoặc liên hệ gia đình?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement emergency call
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Gọi khẩn cấp'),
          ),
        ],
      ),
    );
  }
}
