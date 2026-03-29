import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive_utils.dart';

/// Quick action card widget for homepage (Figma design)
/// Displays an icon image, title, and status badge.
/// Set [circular] to true for a perfect circle shape (width == height).
class ActionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? iconAsset;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? badge;
  final bool showStatusDot;
  final bool circular;

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
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    if (circular) return _buildCircular(context);

    final textScale = ResponsiveUtils.textScaleFactor(context);
    final iconSize = ResponsiveUtils.isLargeTablet(context) ? 210.0
        : ResponsiveUtils.isTablet(context) ? 170.0
        : 80.0;
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: iconSize,
                        height: iconSize * 0.875,
                        child: _buildIconWidget(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: (ResponsiveUtils.isTabletOrLarger(context) ? 20 : 16) * textScale,
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

  Widget _buildCircular(BuildContext context) {
    final textScale = ResponsiveUtils.textScaleFactor(context);
    final iconSize = ResponsiveUtils.isLargeTablet(context) ? 76.0
        : ResponsiveUtils.isTablet(context) ? 60.0
        : 32.0;
    final fontSize = (ResponsiveUtils.isTabletOrLarger(context) ? 14.0 : 12.0) * textScale;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.cardBackground,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircularIcon(iconSize),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      title,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCircularIcon(double size) {
    if (iconAsset != null) {
      return Image.asset(iconAsset!, width: size, height: size, fit: BoxFit.contain);
    }
    if (icon != null) {
      return Icon(icon, size: size, color: iconColor ?? AppColors.primary);
    }
    return const SizedBox.shrink();
  }

  Widget _buildIconWidget() {
    if (iconAsset != null) {
      return Image.asset(iconAsset!, fit: BoxFit.contain);
    }
    return const SizedBox.shrink();
  }
}
