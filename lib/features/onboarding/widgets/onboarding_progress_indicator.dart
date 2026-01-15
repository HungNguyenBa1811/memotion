import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget hiển thị tiến độ onboarding với 4 chấm tròn
class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Duration animationDuration;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseActive = 24.0;
        final baseInactive = 8.0;
        final baseMargin = 4.0;
        final n = totalSteps.toDouble();

        final requiredWidth =
            baseActive + (n - 1) * baseInactive + n * (baseMargin * 2);
        final avail = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : requiredWidth;
        final scale = (requiredWidth <= avail)
            ? 1.0
            : (avail / requiredWidth).clamp(0.4, 1.0);

        final activeWidth = baseActive * scale;
        final inactiveWidth = baseInactive * scale;
        final margin = baseMargin * scale;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalSteps, (index) {
              final step = index + 1;
              final bool isActive = step == currentStep;
              final bool isPast = step < currentStep;
              final width = isActive ? activeWidth : inactiveWidth;
              final height = inactiveWidth;

              return AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(horizontal: margin),
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: isActive || isPast
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4 * scale),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
