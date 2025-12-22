import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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

  void _onNext() {
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
      // Hoàn thành onboarding
      notifier.completeOnboarding();
      context.go(AppRoutes.profile);
    }
  }

  void _onBack() {
    final state = ref.read(onboardingProvider);
    if (state.currentStep > 1) {
      _animateStepChange();
      ref.read(onboardingProvider.notifier).previousStep();
      _navigateToStep(state.currentStep - 1);
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
          if (currentStep > 1)
            OnboardingBackButton(onPressed: _onBack)
          else
            const SizedBox(width: 40),
          const Spacer(),
          OnboardingProgressIndicator(
            currentStep: currentStep,
            totalSteps: OnboardingConfig.totalSteps,
          ),
          const Spacer(),
          const SizedBox(width: 40), // Balance với back button
        ],
      ),
    );
  }

  Widget _buildStepContent(OnboardingData state) {
    switch (state.currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2(state);
      case 3:
        return _buildStep3(state);
      case 4:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Introduction
  Widget _buildStep1() {
    final config = OnboardingConfig.getStep(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        _buildStepImage(config.imagePath!, 280),
        const SizedBox(height: 48),
        Text(
          config.title,
          style: AppTextStyles.headline1.copyWith(
            color: AppColors.textPrimary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Chào mừng bác đến với Memotion - ứng dụng hỗ trợ phục hồi chức năng dành riêng cho người cao tuổi.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Step 2: Choose rehabilitation type
  Widget _buildStep2(OnboardingData state) {
    final config = OnboardingConfig.getStep(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          config.title,
          style: AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 24),
        ...RehabilitationType.values.map((type) {
          final isSelected = state.selectedRehabTypes.contains(type);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OnboardingOptionCell(
              text: type.displayName,
              isSelected: isSelected,
              leadingIcon: _buildRehabIcon(type),
              onTap: () {
                ref.read(onboardingProvider.notifier).toggleRehabType(type);
              },
            ),
          );
        }),
        const SizedBox(height: 32),
        _buildStepImage(config.imagePath!, 240),
      ],
    );
  }

  // Step 3: Pain location
  Widget _buildStep3(OnboardingData state) {
    final config = OnboardingConfig.getStep(3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildStepImage(config.imagePath!, 240),
        const SizedBox(height: 32),
        Text(
          config.title,
          style: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 20),
        // Grid của các options
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: PainLocation.values.take(4).map((location) {
            final isSelected = state.selectedPainLocations.contains(location);
            return OnboardingOptionCell(
              text: location.displayName,
              isSelected: isSelected,
              onTap: () {
                ref
                    .read(onboardingProvider.notifier)
                    .togglePainLocation(location);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 4: Doctor's advice
  Widget _buildStep4() {
    final config = OnboardingConfig.getStep(4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildStepImage(config.imagePath!, 280),
        const SizedBox(height: 32),
        Text(
          config.title,
          style: AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Text(
          'Nếu bác có lời khuyên nào từ bác sĩ, xin hãy chia sẻ để chúng tôi có thể hỗ trợ tốt hơn.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        OnboardingTextInput(
          controller: _adviceController,
          focusNode: _adviceFocusNode,
          hintText: 'Nhập lời khuyên từ bác sĩ (không bắt buộc)...',
          onChanged: (value) {
            ref.read(onboardingProvider.notifier).setDoctorAdvice(value);
          },
        ),
      ],
    );
  }

  Widget _buildStepImage(String imagePath, double size) {
    return Center(
      child: Hero(
        tag: 'onboarding_image_${imagePath.hashCode}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.image_not_supported_outlined,
                size: size * 0.3,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRehabIcon(RehabilitationType type) {
    final IconData icon;
    switch (type) {
      case RehabilitationType.physicalTherapy:
        icon = Icons.accessibility_new;
        break;
      case RehabilitationType.neurology:
        icon = Icons.psychology;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: const Color(0xFF4E6AFF), size: 24),
    );
  }

  Widget _buildBottomNavigation(OnboardingData state, bool canProceed) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button (chỉ hiển thị ở step 2, 3)
          if (state.currentStep > 1 && state.currentStep < 4)
            TextButton(
              onPressed: () {
                _animateStepChange();
                ref.read(onboardingProvider.notifier).nextStep();
                _navigateToStep(state.currentStep + 1);
              },
              child: Text(
                'Bỏ qua',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            const SizedBox(width: 70),
          // Next button
          OnboardingNextButton(onPressed: _onNext, isEnabled: canProceed),
        ],
      ),
    );
  }
}
