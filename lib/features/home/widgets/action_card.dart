import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_utils.dart';

/// Quick action card widget for homepage (Figma design)
/// Displays an icon image, title, and status badge
class ActionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? iconAsset;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? badge;
  final bool showStatusDot;

  const ActionCard({
    super.key,
    required this.title,
    this.icon,
    this.iconAsset,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
    this.badge,
    this.showStatusDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = ResponsiveUtils.isTabletOrLarger(context) ? 90.0 : 80.0;
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 162 / 171,
        child: Container(
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
              // Status dot in top-right
              if (showStatusDot)
                Positioned(
                  top: 14,
                  right: 14,
                  child: badge ??
                      Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                ),
              // Icon + title grouped and centered together
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: iconSize,
                        height: iconSize * 0.875,
                        child: _buildIcon(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: ResponsiveUtils.isTabletOrLarger(context) ? 16 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (iconAsset != null) {
      return Image.asset(iconAsset!, fit: BoxFit.contain);
    }
    return const SizedBox.shrink();
  }
}
