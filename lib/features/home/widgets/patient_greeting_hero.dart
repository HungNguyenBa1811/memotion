import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Hero section with greeting, mood card, avatar, and SOS button (Patient/Elderly version)
/// Based on Figma design node 535:1851 - Homepage Elderly
class PatientGreetingHero extends StatelessWidget {
  final String userName;
  final String greeting;
  final String? avatarUrl;
  final String? moodMessage;
  final String actionButtonText;
  final VoidCallback? onActionPressed;

  const PatientGreetingHero({
    super.key,
    required this.userName,
    this.greeting = 'Chào buổi sáng',
    this.avatarUrl,
    this.moodMessage,
    this.actionButtonText = 'GỌI KHẨN CẤP (SOS)',
    this.onActionPressed,
  });

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = [
      'Chủ Nhật',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
    ];
    final weekday = weekdays[now.weekday % 7];
    return '$weekday, ngày ${now.day} tháng ${now.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Avatar + Greeting + Date + Notification
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with elderly image
              Container(
                width: 59,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tealGreen.withOpacity(0.2),
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage(
                            'assets/images/elderly_avatar.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $userName',
                      style: AppTextStyles.headline2.copyWith(
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFormattedDate(),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tealGreen,
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Mood Card with elderly illustration
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Green mood card
              Container(
                width: 240,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.primary),
                ),
                padding: const EdgeInsets.only(left: 24, top: 20, right: 20),
                child: Text(
                  moodMessage ?? 'Hôm nay tâm trạng của bác không tốt',
                  style: AppTextStyles.headline3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              // Elderly illustration positioned at right
              Positioned(
                right: -70,
                top: -20,
                child: Image.asset(
                  'assets/images/elderly_mood.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(width: 200, height: 200);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // SOS Button (Patient version - Orange/Red color)
          GestureDetector(
            onTap: onActionPressed,
            child: Container(
              width: 330,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFD77658), // Orange/coral color from Figma
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFC28F79)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Phone icon
                  Container(
                    width: 23,
                    height: 34,
                    margin: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // SOS text
                  Text(
                    actionButtonText,
                    style: AppTextStyles.headline2.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
