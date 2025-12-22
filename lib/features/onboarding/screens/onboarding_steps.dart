import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/router/app_router.dart';

class OnboardingStepScreen extends StatelessWidget {
  final int step;
  const OnboardingStepScreen({super.key, required this.step});

  String get title {
    switch (step) {
      case 1:
        return 'Welcome to Memotion';
      case 2:
        return 'Track your progress';
      case 3:
        return 'Personalised plans';
      case 4:
        return 'Stay connected';
      default:
        return 'Onboarding';
    }
  }

  String get subtitle {
    switch (step) {
      case 1:
        return 'Let us guide you through the main features.';
      case 2:
        return 'Easily monitor activities and milestones.';
      case 3:
        return 'We tailor content to your needs.';
      case 4:
        return 'Receive reminders and stay in touch.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = step == 4;
    String nextRoute;
    switch (step) {
      case 1:
        nextRoute = AppRoutes.onboardingStep2;
        break;
      case 2:
        nextRoute = AppRoutes.onboardingStep3;
        break;
      case 3:
        nextRoute = AppRoutes.onboardingStep4;
        break;
      default:
        nextRoute = AppRoutes.profile;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Onboarding', style: AppTextStyles.headline2),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.profile),
            child: Text(
              'Skip',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Text(
                  title,
                  style: AppTextStyles.headline1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Placeholder illustration
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Illustration ${step}',
                      style: AppTextStyles.headline3,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: isLast ? 'Get Started' : 'Next',
                  onPressed: () {
                    if (isLast) {
                      context.go(AppRoutes.profile);
                    } else {
                      context.go(nextRoute);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Back',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
