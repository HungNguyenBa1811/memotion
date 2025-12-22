import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_data.dart';

/// Provider quản lý trạng thái onboarding
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>((ref) {
      return OnboardingNotifier();
    });

/// StateNotifier quản lý logic onboarding
class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(const OnboardingData());

  /// Chuyển sang bước tiếp theo
  void nextStep() {
    if (state.currentStep < OnboardingConfig.totalSteps) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Quay lại bước trước
  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Đi đến bước cụ thể
  void goToStep(int step) {
    if (step >= 1 && step <= OnboardingConfig.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  /// Toggle loại phục hồi (step 2)
  void toggleRehabType(RehabilitationType type) {
    final current = Set<RehabilitationType>.from(state.selectedRehabTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    state = state.copyWith(selectedRehabTypes: current);
  }

  /// Toggle vị trí đau (step 3)
  void togglePainLocation(PainLocation location) {
    final current = Set<PainLocation>.from(state.selectedPainLocations);
    if (current.contains(location)) {
      current.remove(location);
    } else {
      current.add(location);
    }
    state = state.copyWith(selectedPainLocations: current);
  }

  /// Cập nhật lời khuyên bác sĩ (step 4)
  void setDoctorAdvice(String advice) {
    state = state.copyWith(doctorAdvice: advice);
  }

  /// Hoàn thành onboarding
  void completeOnboarding() {
    state = state.copyWith(isCompleted: true);
  }

  /// Reset toàn bộ trạng thái
  void reset() {
    state = const OnboardingData();
  }

  /// Kiểm tra có thể tiến hành bước tiếp theo không
  bool canProceed() {
    switch (state.currentStep) {
      case 1:
        return true; // Step 1 chỉ là giới thiệu
      case 2:
        return state.selectedRehabTypes.isNotEmpty;
      case 3:
        return state.selectedPainLocations.isNotEmpty;
      case 4:
        return true; // Doctor advice là optional
      default:
        return false;
    }
  }

  /// Lấy tiến độ hiện tại (0.0 - 1.0)
  double get progress => state.currentStep / OnboardingConfig.totalSteps;
}

/// Provider cho cấu hình bước hiện tại
final currentStepConfigProvider = Provider<OnboardingStepConfig>((ref) {
  final currentStep = ref.watch(onboardingProvider).currentStep;
  return OnboardingConfig.getStep(currentStep);
});

/// Provider kiểm tra có thể tiến hành không
final canProceedProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider.notifier).canProceed();
});
