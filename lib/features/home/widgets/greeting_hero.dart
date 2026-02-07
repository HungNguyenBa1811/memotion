import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Hero section with greeting, mood card, avatar, and action button (Caregiver version)
class GreetingHero extends StatefulWidget {
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

  @override
  State<GreetingHero> createState() => _GreetingHeroState();
}

class _GreetingHeroState extends State<GreetingHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

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
                  image: widget.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.avatarUrl!),
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
                      '${widget.greeting}, ${widget.userName}',
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
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                  border: Border.all(color: AppColors.primary),
                ),
                padding: const EdgeInsets.only(left: 24, top: 20, right: 20),
                child: Text(
                  widget.moodMessage ??
                      "Please pay attention to the patient's mood today",
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
                right: -130,
                top: -20,
                child: Image.asset(
                  'assets/images/caregiver_elderly.png',
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

          // Action Button (Situation Handling)
          Transform.translate(
            offset: const Offset(0, -10),
            child: GestureDetector(
              onTap: widget.onActionPressed,
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
                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle:
                              math.sin(_shakeController.value * 2 * math.pi) *
                              0.3,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        margin: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    Text(
                      widget.actionButtonText,
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
          ),
        ],
      ),
    );
  }
}
