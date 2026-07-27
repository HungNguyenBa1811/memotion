import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/onboarding_notifier.dart';
import '../providers/onboarding_provider.dart';

/// Loading screen shown while submitting onboarding data (3 API calls)
class OnboardingLoadingScreen extends ConsumerStatefulWidget {
  const OnboardingLoadingScreen({super.key});

  @override
  ConsumerState<OnboardingLoadingScreen> createState() =>
      _OnboardingLoadingScreenState();
}

class _OnboardingLoadingScreenState
    extends ConsumerState<OnboardingLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  int _currentStep = 0;
  final List<String> _loadingMessages = [
    'Creating the care profile...',
    'Reviewing mobility information...',
    'Preparing the care plan...',
    'Care plan ready',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start API submission after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submitOnboardingData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitOnboardingData() async {
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    try {
      final success = await notifier.submitFinalProfile(
        context,
        ref,
        onProgress: (step) {
          if (mounted) setState(() => _currentStep = step);
        },
      );

      if (!success) {
        // The notifier routes retryable failures back to the wizard and
        // authentication failures back to registration.
        return;
      }
      if (!mounted) return;

      setState(() => _currentStep = 3);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      ref.read(onboardingProvider.notifier).completeOnboarding();
      // Clear the client-side first-login flag only after every API succeeds.
      ref.read(authProvider.notifier).markOnboardingComplete();
      context.go(AppRoutes.profile);
    } catch (error, stackTrace) {
      debugPrint('[OnboardingLoadingScreen] Submission failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) context.go(AppRoutes.onboardingStep1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo/icon
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.health_and_safety,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Title
                Text(
                  'Preparing the care profile',
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'This may take a moment.',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 48),

                // Progress steps
                ...List.generate(_loadingMessages.length, (index) {
                  return _buildProgressStep(index);
                }),

                const SizedBox(height: 32),

                // Loading indicator
                if (_currentStep < 3)
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
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

  Widget _buildProgressStep(int index) {
    final isCompleted = _currentStep > index;
    final isCurrent = _currentStep == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Status icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.primary
                  : isCurrent
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : isCurrent
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Text(
                      '${index + 1}',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Step label
          Expanded(
            child: Text(
              _loadingMessages[index],
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCompleted || isCurrent
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
