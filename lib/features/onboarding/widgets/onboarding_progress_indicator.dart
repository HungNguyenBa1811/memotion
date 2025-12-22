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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) => _buildDot(index + 1)),
    );
  }

  Widget _buildDot(int step) {
    final bool isActive = step == currentStep;
    final bool isPast = step < currentStep;

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive || isPast
            ? AppColors.primary
            : AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
