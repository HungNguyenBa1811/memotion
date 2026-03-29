import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_utils.dart';

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
    final isTablet = ResponsiveUtils.isTabletOrLarger(context);
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final avatarSize = ResponsiveUtils.isLargeTablet(context) ? 170.0
        : ResponsiveUtils.isTablet(context) ? 150.0
        : 59.0;
    final notifIconSize = ResponsiveUtils.isLargeTablet(context) ? 64.0
        : ResponsiveUtils.isTablet(context) ? 56.0
        : 24.0;
    final notifBoxSize = ResponsiveUtils.isLargeTablet(context) ? 96.0
        : ResponsiveUtils.isTablet(context) ? 84.0
        : 48.0;
    final phoneIconSize = ResponsiveUtils.isLargeTablet(context) ? 68.0
        : ResponsiveUtils.isTablet(context) ? 56.0
        : 28.0;

    // No outer Padding here — the parent screen owns horizontal padding.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Header row: Avatar + Greeting + Date + Notification
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with caregiver image
            Container(
              width: avatarSize,
              height: avatarSize,
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
                      fontSize: 20 * textScale,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getFormattedDate(),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 14 * textScale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Notification icon with touch target
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(notifBoxSize / 2),
              child: Container(
                width: notifBoxSize,
                height: notifBoxSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tealGreen,
                ),
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: notifIconSize,
                ),
              ),
            ),
          ],
        ),

        // Mood section: Row fills full available width.
        // Left = fixed-width green card, Right = Expanded image area.
        // No Stack/Positioned — the image scales naturally with the remaining space.
        LayoutBuilder(
          builder: (_, constraints) {
            final useWide = constraints.maxWidth >= 480;
            final cardWidth = useWide ? 380.0 : 240.0;
            final cardHeight = useWide ? 220.0 : 160.0;
            // Image is taller than the card so it peeks above the card top.
            final imageHeight = cardHeight + (useWide ? 40.0 : 20.0);

            // Stack: card on bottom layer (left), image on top layer (right).
            // SizedBox gives the Stack a full-width × imageHeight canvas.
            // StackFit.expand lets Align children use the full canvas for positioning.
            return SizedBox(
              width: double.infinity,
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Layer 1 — Panel Left (transparent outer, primary bg pushed down 20px)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: Column(
                        children: [
                          // 20px transparent gap — image peeks through here
                          const SizedBox(height: 20),
                          // Primary bg colored Panel (fills remaining space)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(26),
                                  topRight: Radius.circular(26),
                                ),
                                border: Border.all(color: AppColors.primary),
                              ),
                              padding: EdgeInsets.only(
                                  left: 24, top: 16, right: (isTablet ? 0 : 24)),
                              child: Text(
                                widget.moodMessage ??
                                    "Please pay attention to the patient's mood today",
                                style: AppTextStyles.headline3.copyWith(
                                  fontSize: (isTablet ? 20 : 16) * textScale,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Layer 2 — couple illustration, bottom-right, ON TOP of card
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Transform.translate(
                      offset: const Offset(0, 10),
                      child: Image.asset(
                        'assets/images/caregiver_elderly.png',
                        height: imageHeight,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                        errorBuilder: (context, error, stack) =>
                            SizedBox(height: imageHeight),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Action Button (Situation Handling)
        Transform.translate(
          offset: const Offset(0, -10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onActionPressed,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: double.infinity,
                height: ResponsiveUtils.isLargeTablet(context) ? 128 : isTablet ? 114 : 75,
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
                        margin: const EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: phoneIconSize,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.actionButtonText,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headline2.copyWith(
                          fontSize: (isTablet ? 24 : 18) * textScale,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
