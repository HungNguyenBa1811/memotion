import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Hero section with greeting, mood card, avatar, and action button (Caregiver version)
class GreetingHero extends StatelessWidget {
  final String userName;
  final String greeting;
  final String? avatarUrl;
  final String? moodMessage;
  final String actionButtonText;
  final VoidCallback? onActionPressed;

  const GreetingHero({
    super.key,
    required this.userName,
    this.greeting = 'Good morning',
    this.avatarUrl,
    this.moodMessage,
    this.actionButtonText = 'SITUATION HANDLING',
    this.onActionPressed,
  });

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final weekday = weekdays[now.weekday % 7];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
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
              // Avatar with caregiver image
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
                            'assets/images/caregiver_avatar.png',
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
                      '$greeting,',
                      style: AppTextStyles.headline2.copyWith(
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      userName,
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
                width: 320,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.primary),
                ),
                padding: const EdgeInsets.only(left: 20, top: 20, right: 160),
                child: Text(
                  moodMessage ?? "Please pay attention to the patient's mood today",
                  style: AppTextStyles.headline3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              // Elderly illustration positioned at right (Caregiver version)
              Positioned(
                right: -70,
                top: -50,
                child: Image.asset(
                  'assets/images/caregiver_elderly.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.tealGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.elderly,
                        size: 80,
                        color: AppColors.tealGreen,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // const SizedBox(height: 16),

          // Action Button (Situation Handling)
          GestureDetector(
            onTap: onActionPressed,
            child: Container(
              width: double.infinity,
              height: 75,
              decoration: BoxDecoration(
                color: AppColors.sosButton,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFC28F79)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    actionButtonText,
                    style: AppTextStyles.sectionHeading.copyWith(
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