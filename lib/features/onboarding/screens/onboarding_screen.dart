import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive_utils.dart';
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
    final scale = ResponsiveUtils.textScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30 * scale, vertical: 28 * scale),
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Onboarding image (responsive)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenW = MediaQuery.of(context).size.width;
                      final boxWidth = (screenW < 400)
                          ? screenW * 0.95
                          : screenW * 0.9;

                      return SizedBox(
                        width: boxWidth,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12 * scale),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: boxWidth * 0.5,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Content below image
                  Text(
                    "Let's get started",
                    style: AppTextStyles.headline1.copyWith(fontSize: 22 * scale * scale),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Experience Memotion today!',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 16 * scale * scale,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40 * scale),
                PrimaryButton(
                  text: 'Login',
                  onPressed: onLoginPressed,
                  fontSize: ResponsiveUtils.isTabletOrLarger(context) ? 20 : null,
                ),
                SizedBox(height: 16 * scale),
                SecondaryButton(
                  text: 'Register',
                  onPressed: onRegisterPressed,
                  fontSize: ResponsiveUtils.isTabletOrLarger(context) ? 20 : null,
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
