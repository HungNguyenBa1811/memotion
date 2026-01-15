import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_data.dart';

/// Provider quản lý trạng thái onboarding
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>((ref) {
      return OnboardingNotifier();
    });

/// StateNotifier quản lý logic onboarding
///
/// Cung cấp các method để:
/// - Điều hướng giữa các bước (next, previous, goToStep)
/// - Cập nhật dữ liệu từng bước
/// - Xác thực dữ liệu trước khi chuyển bước
/// - Hoàn thành onboarding
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

  /// ========== Step 2: Personal Information ==========

  /// Cập nhật tên người dùng
  void setFullName(String name) {
    state = state.copyWith(fullName: name.trim());
  }

  /// Cập nhật năm sinh
  void setBirthYear(int year) {
    state = state.copyWith(birthYear: year);
  }

  /// Cập nhật giới tính
  void setGender(Gender gender) {
    state = state.copyWith(gender: gender);
  }

  /// Cập nhật chiều cao (cm)
  void setHeight(double height) {
    state = state.copyWith(height: height);
  }

  /// Cập nhật cân nặng (kg)
  void setWeight(double weight) {
    state = state.copyWith(weight: weight);
  }

  /// ========== Step 3: Health Objectives ==========

  /// Toggle mục tiêu phục hồi (step 3)
  void toggleHealthObjective(HealthObjective objective) {
    final current = Set<HealthObjective>.from(state.selectedObjectives);
    if (current.contains(objective)) {
      current.remove(objective);
    } else {
      // Chỉ cho phép chọn 1 mục tiêu
      current.clear();
      current.add(objective);
    }
    state = state.copyWith(selectedObjectives: current);
  }

  /// ========== Step 4: Pain Locations ==========

  /// Toggle vị trí đau (step 4)
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
    state = state.copyWith(doctorAdvice: advice.trim());
  }

  /// ========== Step 5-8: Additional clinical questions ==========

  /// Set pain level (0-10)
  void setPainLevel(int level) {
    final clamped = level.clamp(0, 10);
    state = state.copyWith(painLevel: clamped);
  }

  /// Set resting heart rate (step 12)
  void setHeartRate(int? bpm) {
    state = state.copyWith(heartRate: bpm);
  }

  /// Set blood glucose (step 13)
  void setBloodSugar(int? mgDl) {
    state = state.copyWith(bloodSugar: mgDl);
  }

  /// Set pain type (step 6)
  void setPainType(PainType type) {
    state = state.copyWith(painType: type);
  }

  /// Set weakness/stiffness selection (step 7)
  void setWeaknessType(WeaknessType type) {
    state = state.copyWith(weaknessType: type);
  }

  /// Set ability to stand from chair (step 8)
  void setStandAbility(StandAbility ability) {
    state = state.copyWith(standAbility: ability);
  }

  /// ========== Validation & Completion ==========

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
        // Step 2 yêu cầu: tên, năm sinh, giới tính, chiều cao, cân nặng
        return state.fullName != null &&
            state.fullName!.isNotEmpty &&
            state.birthYear != null &&
            state.gender != null &&
            state.height != null &&
            state.height! > 0 &&
            state.weight != null &&
            state.weight! > 0;

      case 3:
        // Step 3 yêu cầu chọn ít nhất 1 mục tiêu
        return state.selectedObjectives.isNotEmpty;

      case 4:
        // Step 4 yêu cầu chọn ít nhất 1 vị trí đau (doctor advice là optional)
        return state.selectedPainLocations.isNotEmpty;

      case 5:
        // require pain level selected
        return state.painLevel != null;

      case 6:
        // require pain type
        return state.painType != null;

      case 7:
        // require weakness selection
        return state.weaknessType != null;

      case 8:
        // require stand ability selection
        return state.standAbility != null;

      default:
        return false;
    }
  }

  /// Lấy thông báo lỗi (nếu có) cho bước hiện tại
  String? getValidationError() {
    switch (state.currentStep) {
      case 2:
        if (state.fullName == null || state.fullName!.isEmpty) {
          return 'Vui lòng nhập tên';
        }
        if (state.birthYear == null) {
          return 'Vui lòng chọn năm sinh';
        }
        if (state.gender == null) {
          return 'Vui lòng chọn giới tính';
        }
        if (state.height == null || state.height! <= 0) {
          return 'Vui lòng nhập chiều cao hợp lệ';
        }
        if (state.weight == null || state.weight! <= 0) {
          return 'Vui lòng nhập cân nặng hợp lệ';
        }
        return null;

      case 3:
        if (state.selectedObjectives.isEmpty) {
          return 'Vui lòng chọn mục tiêu phục hồi';
        }
        return null;

      case 4:
        if (state.selectedPainLocations.isEmpty) {
          return 'Vui lòng chọn vị trí đau';
        }
        return null;

      case 5:
        if (state.painLevel == null) {
          return 'Vui lòng cho biết mức đau (0-10)';
        }
        return null;

      case 6:
        if (state.painType == null) {
          return 'Vui lòng chọn đặc tính cơn đau';
        }
        return null;

      case 7:
        if (state.weaknessType == null) {
          return 'Vui lòng chọn tình trạng yếu/cứng';
        }
        return null;

      case 8:
        if (state.standAbility == null) {
          return 'Vui lòng chọn một đáp án';
        }
        return null;

      default:
        return null;
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

/// Provider lấy thông báo lỗi validation
final validationErrorProvider = Provider<String?>((ref) {
  return ref.watch(onboardingProvider.notifier).getValidationError();
});
