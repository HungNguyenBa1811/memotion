import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onRegisterPressed;
  final VoidCallback onLoginPressed;

  const OnboardingScreen({
    super.key,
    required this.onRegisterPressed,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.background),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Placeholder for onboarding image
                      Container(
                        width: 280,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Headline
                  Text(
                    'Hãy cùng bắt đầu nào',
                    style: AppTextStyles.headline1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Trải nghiệm Memotion ngay!',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Buttons
                  PrimaryButton(text: 'Đăng nhập', onPressed: onLoginPressed),
                  const SizedBox(height: 16),

                  SecondaryButton(
                    text: 'Đăng ký',
                    onPressed: onRegisterPressed,
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
