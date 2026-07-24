import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../providers/onboarding_provider.dart';
import '../models/onboarding_data.dart';
import '../widgets/widgets.dart';

/// Onboarding wizard with split layout:
/// - Top half: PageView that slides content on 'Next'
/// - Bottom half: Static image with crossfade (only animates when image changes)
class OnboardingWizardScreen extends ConsumerStatefulWidget {
  final int initialStep;

  const OnboardingWizardScreen({super.key, this.initialStep = 1});

  @override
  ConsumerState<OnboardingWizardScreen> createState() =>
      _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialStep - 1;
    _pageController = PageController(initialPage: _currentPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).goToStep(widget.initialStep);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _goToNextPage() {
    if (_currentPage < OnboardingConfig.totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onNext() {
    final notifier = ref.read(onboardingProvider.notifier);
    final state = ref.read(onboardingProvider);

    if (state.currentStep < OnboardingConfig.totalSteps) {
      notifier.nextStep();
      _goToNextPage();
    } else {
      context.go(AppRoutes.onboardingLoading);
    }
  }

  String? get _currentImagePath {
    return OnboardingConfig.getStep(_currentPage + 1).imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final canProceed = ref.watch(canProceedProvider);
    final imagePath = _currentImagePath;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(_currentPage + 1),

              // Top: PageView — only this section slides on 'Next'
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  itemCount: OnboardingConfig.totalSteps,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: StepBuilderFactory.buildStep(
                        index + 1,
                        onNext: _goToNextPage,
                      ),
                    );
                  },
                ),
              ),

              // Bottom: Static image — crossfades only when imagePath changes
              _buildBottomImage(imagePath),

              _buildBottomNavigation(onboardingState, canProceed),
            ],
          ),
        ),
      ),
    );
  }

  void _onSkip() {
    context.go(AppRoutes.profile);
  }

  Widget _buildHeader(int currentStep) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          const SizedBox(width: 40),
          const Spacer(),
          Expanded(
            child: Center(
              child: OnboardingProgressIndicator(
                currentStep: currentStep,
                totalSteps: OnboardingConfig.totalSteps,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _onSkip,
            child: Text(
              'Skip',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom image section.
  /// Uses AnimatedSwitcher keyed by imagePath so it only crossfades
  /// when the actual image changes between steps.
  /// AnimatedContainer handles smooth height transition when imagePath
  /// becomes null (e.g., the camera capture step).
  Widget _buildBottomImage(String? imagePath) {
    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: imagePath != null ? 200.0 : 0.0,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: imagePath != null
              ? Padding(
                  key: ValueKey(imagePath),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Image.asset(
                    imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(height: 200),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-image')),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(OnboardingData state, bool canProceed) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 70),
          OnboardingNextButton(onPressed: _onNext, isEnabled: canProceed),
        ],
      ),
    );
  }
}
