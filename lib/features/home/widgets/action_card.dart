import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Quick action card widget for homepage
/// Displays an icon, title, and optional badge
class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? badge;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 162,
        height: 171,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.cardBackground,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              offset: const Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icon badge in top-right
            if (badge != null)
              Positioned(
                top: 16,
                right: 16,
                child: badge!,
              )
            else
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: iconColor ?? AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Title at bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: iconColor ?? AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: AppTextStyles.cardTitle,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
