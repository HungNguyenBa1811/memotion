import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Hero section with greeting, avatar, and SOS button
class GreetingHero extends StatelessWidget {
  final String userName;
  final String greeting;
  final String? avatarUrl;
  final VoidCallback? onSOSPressed;

  const GreetingHero({
    super.key,
    required this.userName,
    this.greeting = 'Good Morning',
    this.avatarUrl,
    this.onSOSPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // Background avatar illustration (top section)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Avatar placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.tealGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.tealGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Greeting text
                  Text(
                    greeting,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: AppTextStyles.headline1,
                  ),
                ],
              ),
            ),
          ),
          // SOS Button (overlapping bottom)
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: GestureDetector(
              onTap: onSOSPressed,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.sosButton,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SOS Emergency',
                      style: AppTextStyles.sectionHeading.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
