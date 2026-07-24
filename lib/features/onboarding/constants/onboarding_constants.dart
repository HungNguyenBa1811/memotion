/// Constants cho Onboarding Feature
/// Tập trung quản lý tất cả string, value cố định tại một nơi
class OnboardingConstants {
  // Prevent instantiation
  OnboardingConstants._();

  // Animation durations
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 400);
  static const Duration optionSelectDuration = Duration(milliseconds: 200);

  // Sizing
  static const double progressDotSize = 8.0;
  static const double progressDotExpandedWidth = 24.0;
  static const double nextButtonSize = 64.0;
  static const double backButtonSize = 40.0;
  static const double imageSize = 280.0;
  static const double imageSizeLarge = 340.0;
  static const double imageSizeSmall = 240.0;

  // Padding
  static const double horizontalPadding = 24.0;
  static const double verticalSpacingSmall = 16.0;
  static const double verticalSpacingMedium = 24.0;
  static const double verticalSpacingLarge = 40.0;

  // Border radius
  static const double cardBorderRadius = 12.0;
  static const double imageBorderRadius = 20.0;
  static const double inputBorderRadius = 16.0;

  // Text
  static const String skipButtonText = 'Skip for now';
}
