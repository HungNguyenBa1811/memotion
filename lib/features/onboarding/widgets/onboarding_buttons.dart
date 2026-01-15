import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Nút tròn để chuyển bước tiếp theo
class OnboardingNextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final double size;
  final Duration animationDuration;

  const OnboardingNextButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
    this.size = 64,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: animationDuration,
      opacity: isEnabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: AnimatedContainer(
          duration: animationDuration,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.5),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
}

/// Nút back với icon mũi tên
