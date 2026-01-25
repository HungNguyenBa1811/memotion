import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../providers/onboarding_provider.dart';
import '../models/onboarding_data.dart';
import '../widgets/widgets.dart';

/// Màn hình onboarding refactored với Riverpod và clean architecture
///
/// - Sử dụng ConsumerStatefulWidget để tích hợp Riverpod
/// - Tách logic thành Provider riêng
/// - Các widget con được tách thành file riêng
/// - Animation mượt mà giữa các step
/// - Lưu trữ dữ liệu người dùng chọn vào state
class OnboardingScreenNew extends ConsumerStatefulWidget {
  final int initialStep;

  const OnboardingScreenNew({super.key, this.initialStep = 1});

  @override
  ConsumerState<OnboardingScreenNew> createState() =>
      _OnboardingScreenNewState();
}

class _OnboardingScreenNewState extends ConsumerState<OnboardingScreenNew>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final TextEditingController _adviceController = TextEditingController();
  final FocusNode _adviceFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Sync với provider khi có step được truyền vào
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).goToStep(widget.initialStep);
      _animationController.forward();
    });
  }

  @override
  void didUpdateWidget(covariant OnboardingScreenNew oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStep != widget.initialStep) {
      _animateStepChange();
      ref.read(onboardingProvider.notifier).goToStep(widget.initialStep);
    }
  }

  void _animateStepChange() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _adviceController.dispose();
    _adviceFocusNode.dispose();
    super.dispose();
  }

  void _onNext() async {
    final notifier = ref.read(onboardingProvider.notifier);
    final state = ref.read(onboardingProvider);

    // Lưu lời khuyên bác sĩ nếu đang ở step 4
    if (state.currentStep == 4) {
      notifier.setDoctorAdvice(_adviceController.text);
    }

    if (state.currentStep < OnboardingConfig.totalSteps) {
      _animateStepChange();
      notifier.nextStep();
      _navigateToStep(state.currentStep + 1);
    } else {
      // Hoàn thành onboarding - navigate to loading screen để submit data
      context.go(AppRoutes.onboardingLoading);
    }
  }

  void _navigateToStep(int step) {
    switch (step) {
      case 1:
        context.go(AppRoutes.onboardingStep1);
        break;
      case 2:
        context.go(AppRoutes.onboardingStep2);
        break;
      case 3:
        context.go(AppRoutes.onboardingStep3);
        break;
      case 4:
        context.go(AppRoutes.onboardingStep4);
        break;
      case 5:
        context.go(AppRoutes.onboardingStep5);
        break;
      case 6:
        context.go(AppRoutes.onboardingStep6);
        break;
      case 7:
        context.go(AppRoutes.onboardingStep7);
        break;
      case 8:
        context.go(AppRoutes.onboardingStep8);
        break;
      case 9:
        context.go(AppRoutes.onboardingStep9);
        break;
      case 10:
        context.go(AppRoutes.onboardingStep10);
        break;
      case 11:
        context.go(AppRoutes.onboardingStep11);
        break;
      case 12:
        context.go(AppRoutes.onboardingStep12);
        break;
      case 13:
        context.go(AppRoutes.onboardingStep13);
        break;
      case 14:
        context.go(AppRoutes.onboardingStep14);
        break;
      case 15:
        context.go(AppRoutes.onboardingStep15);
        break;
      case 16:
        context.go(AppRoutes.onboardingStep16);
        break;
      case 17:
        context.go(AppRoutes.onboardingStep17);
        break;
      case 18:
        context.go(AppRoutes.onboardingStep18);
        break;
      default:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final canProceed = ref.watch(canProceedProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(onboardingState.currentStep),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildStepContent(onboardingState),
                      ),
                    ),
                  ),
                ),
              ),
              _buildBottomNavigation(onboardingState, canProceed),
            ],
          ),
        ),
      ),
    );
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
          const SizedBox(width: 40), // Balance với back button
        ],
      ),
    );
  }

  Widget _buildStepContent(OnboardingData state) {
    // Use the step builder factory for modular step rendering
    return StepBuilderFactory.buildStep(state.currentStep);
  }

  // Step 1: Introduction
  // (Step 1 rendered by `Step1Builder` now)

  // Step 2 handled by modular step builders (Step2Builder)

  // Step 3: Pain location
  // (Step 3 rendered by `Step3Builder` now)

  // Step 4: Doctor's advice
  // (Step 4 rendered by `Step4Builder` now)

  // Image helper removed — step builders render their own images now.

  // Rehab icons are provided inside step builders when needed

  Widget _buildBottomNavigation(OnboardingData state, bool canProceed) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(color: const Color.fromARGB(0, 0, 0, 0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 70),
          // Next button
          OnboardingNextButton(onPressed: _onNext, isEnabled: canProceed),
        ],
      ),
    );
  }
}
