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
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              // reduce vertical padding so the image and content are closer
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
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

                      // Use the image's original size. Do not force width/height.
                      // Wrap with Center and constrain max width so it doesn't overflow on small screens.
                      return SizedBox(
                        width: boxWidth,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/logo.png',
                              // no width/height: original image size will be used
                              fit: BoxFit.none,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Content below image (all inside the same centered box)
                  Text(
                    "Let's get started",
                    style: AppTextStyles.headline1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Experience Memotion today!',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(text: 'Login', onPressed: onLoginPressed),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    text: 'Register',
                    onPressed: onRegisterPressed,
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
