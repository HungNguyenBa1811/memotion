import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Quick action card widget for homepage (Figma design)
/// Displays an icon image, title, and status badge
class ActionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? iconAsset;
  final String? svgAsset;
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
    this.svgAsset,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
    this.badge,
    this.showStatusDot = true,
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
            // Status dot in top-right
            if (showStatusDot)
              Positioned(
                top: 14,
                right: 14,
                child:
                    badge ??
                    Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: AppColors.tealGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
              ),
            // Icon centered
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(width: 80, height: 70, child: _buildIcon()),
              ),
            ),
            // Title at bottom center
            Positioned(
              left: 10,
              right: 10,
              bottom: 20,
              child: Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    // SVG asset
    if (svgAsset != null) {
      return SvgPicture.asset(
        svgAsset!,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Icon(
          icon ?? Icons.category,
          size: 60,
          color: iconColor ?? AppColors.tealGreen,
        ),
      );
    }
    // PNG/image asset
    if (iconAsset != null) {
      return Image.asset(
        iconAsset!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            icon ?? Icons.category,
            size: 60,
            color: iconColor ?? AppColors.tealGreen,
          );
        },
      );
    }
    // Fallback icon
    return Icon(
      icon ?? Icons.category,
      size: 60,
      color: iconColor ?? AppColors.tealGreen,
    );
  }
}
