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

  /// ========== Step 1.1 (Step 2): Username/Phone Number ==========

  /// Cập nhật username hoặc số điện thoại
  void setUsernameOrPhone(String value) {
    state = state.copyWith(usernameOrPhone: value.trim());
  }

  /// ========== Step 3 (old Step 2): Personal Information ==========

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
    double? bmi;
    final currentWeight = state.weight;
    if (currentWeight != null && height > 0) {
      final meters = height / 100.0;
      bmi = currentWeight / (meters * meters);
    }
    state = state.copyWith(height: height, bmi: bmi);
  }

  /// Cập nhật cân nặng (kg)
  void setWeight(double weight) {
    double? bmi;
    final currentHeight = state.height;
    if (currentHeight != null && currentHeight > 0) {
      final meters = currentHeight / 100.0;
      bmi = weight / (meters * meters);
    }
    state = state.copyWith(weight: weight, bmi: bmi);
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

  /// ========== Step 10: Living Arrangement ==========

  /// Set living arrangement (step 10)
  void setLivingArrangement(String arrangement) {
    state = state.copyWith(livingArrangement: arrangement);
  }

  /// ========== Step 11: Blood Pressure / MAP Score ==========

  /// Set MAP score / blood pressure (step 11)
  void setMapScore(double score) {
    state = state.copyWith(mapScore: score);
  }

  /// ========== Step 14: ADL Score ==========

  /// Set ADL score directly (step 14)
  void setAdlScore(int score) {
    state = state.copyWith(adlScore: score);
  }

  /// Set ADL score by option index (step 14)
  /// Options map to scores [2, 1, 0] in order
  void setAdlScoreByOptionIndex(int index) {
    const scores = [2, 1, 0];
    final score = (index >= 0 && index < scores.length) ? scores[index] : 0;
    state = state.copyWith(adlScore: score);
  }

  /// ========== Step 15: IADL Score ==========

  /// Set IADL score directly (step 15)
  void setIadlScore(int score) {
    state = state.copyWith(iadlScore: score);
  }

  /// Set IADL score by option index (step 15)
  /// Options map to scores [2, 1, 0] in order
  void setIadlScoreByOptionIndex(int index) {
    const scores = [2, 1, 0];
    final score = (index >= 0 && index < scores.length) ? scores[index] : 0;
    state = state.copyWith(iadlScore: score);
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
        // Step 2 (1.1): Username/Phone
        return true;

      case 3:
        // Step 3 (old Step 2) yêu cầu: tên, năm sinh, giới tính, chiều cao, cân nặng
        return state.fullName != null &&
            state.fullName!.isNotEmpty &&
            state.birthYear != null &&
            state.gender != null &&
            state.height != null &&
            state.height! > 0 &&
            state.weight != null &&
            state.weight! > 0;

      case 4:
        // Step 4 (old Step 3) yêu cầu chọn ít nhất 1 mục tiêu
        return state.selectedObjectives.isNotEmpty;

      case 5:
        // Step 5 (old Step 4) yêu cầu chọn ít nhất 1 vị trí đau (doctor advice là optional)
        return state.selectedPainLocations.isNotEmpty;

      case 6:
        // require pain level selected
        return state.painLevel != null;

      case 7:
        // require pain type
        return state.painType != null;

      case 8:
        // require weakness selection
        return state.weaknessType != null;

      case 9:
        // require stand ability selection
        return state.standAbility != null;

      default:
        return true; // Steps 10-18 are optional/info screens
    }
  }

  /// Lấy thông báo lỗi (nếu có) cho bước hiện tại
  String? getValidationError() {
    switch (state.currentStep) {
      case 2:
        // Step 2 (1.1): Username/Phone - optional
        return null;

      case 3:
        if (state.fullName == null || state.fullName!.isEmpty) {
          return 'Please enter name';
        }
        if (state.birthYear == null) {
          return 'Please select birth year';
        }
        if (state.gender == null) {
          return 'Please select gender';
        }
        if (state.height == null || state.height! <= 0) {
          return 'Please enter a valid height';
        }
        if (state.weight == null || state.weight! <= 0) {
          return 'Please enter a valid weight';
        }
        return null;

      case 4:
        if (state.selectedObjectives.isEmpty) {
          return 'Please select recovery goal';
        }
        return null;

      case 5:
        if (state.selectedPainLocations.isEmpty) {
          return 'Please select pain location';
        }
        return null;

      case 6:
        if (state.painLevel == null) {
          return 'Please provide pain level (0-10)';
        }
        return null;

      case 7:
        if (state.painType == null) {
          return 'Please select pain type';
        }
        return null;

      case 8:
        if (state.weaknessType == null) {
          return 'Please select weakness/stiffness';
        }
        return null;

      case 9:
        if (state.standAbility == null) {
          return 'Please select an answer';
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
/// All data is now stored in onboardingProvider (OnboardingData)
final canProceedProvider = Provider<bool>((ref) {
  final state = ref.watch(onboardingProvider);

  switch (state.currentStep) {
    case 1:
      return true; // Step 1 chỉ là giới thiệu

    case 2:
      // Step 2 (1.1): Username/Phone - bắt buộc nhập
      return state.usernameOrPhone != null && state.usernameOrPhone!.isNotEmpty;

    case 3:
      // Step 3: Personal info - yêu cầu tên, năm sinh, giới tính, chiều cao, cân nặng
      return state.fullName != null &&
          state.fullName!.isNotEmpty &&
          state.birthYear != null &&
          state.gender != null &&
          state.height != null &&
          state.height! > 0 &&
          state.weight != null &&
          state.weight! > 0;

    case 4:
      // Step 4: Health objectives - yêu cầu chọn ít nhất 1 mục tiêu
      return state.selectedObjectives.isNotEmpty;

    case 5:
      // Step 5: Pain locations - yêu cầu chọn ít nhất 1 vị trí đau
      return state.selectedPainLocations.isNotEmpty;

    case 6:
      // Step 6: Pain level - yêu cầu chọn mức đau
      return state.painLevel != null;

    case 7:
      // Step 7: Yếu/cứng - không bắt buộc
      return true;

    case 8:
      // Step 8: Weakness type - không bắt buộc
      return true;

    case 9:
      // Step 9: Vững chân/chóng mặt - không bắt buộc
      return true;

    case 10:
      // Step 10: (uses OnboardingStep9Config) - not required here
      return true;

    case 11:
      // Step 11: Living arrangement (OnboardingStep10Config) - optional
      return true;

    case 12:
      // Step 12: Blood pressure/MAP score - yêu cầu nhập
      return state.mapScore != null && state.mapScore! > 0;

    case 13:
      // Step 13: Heart rate - yêu cầu nhập
      return state.heartRate != null && state.heartRate! > 0;

    case 14:
      // Step 14: Blood glucose - yêu cầu nhập
      return state.bloodSugar != null && state.bloodSugar! > 0;

    case 15:
      // Step 15: ADL score - yêu cầu chọn
      return state.adlScore != null;

    case 16:
      // Step 16: IADL score - yêu cầu chọn
      return state.iadlScore != null;

    case 17:
      // Step 17: Document upload - optional
      return true;

    case 18:
      // Step 18: Final step - no input required
      return true;

    default:
      return true;
  }
});

/// Provider lấy thông báo lỗi validation
/// All data is now stored in onboardingProvider (OnboardingData)
final validationErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(onboardingProvider);

  switch (state.currentStep) {
    case 2:
      // Step 2 (1.1): Username/Phone - bắt buộc nhập
      if (state.usernameOrPhone == null || state.usernameOrPhone!.isEmpty) {
        return 'Please enter phone number or username';
      }
      return null;

    case 3:
      if (state.fullName == null || state.fullName!.isEmpty) {
        return 'Please enter name';
      }
      if (state.birthYear == null) {
        return 'Please select birth year';
      }
      if (state.gender == null) {
        return 'Please select gender';
      }
      if (state.height == null || state.height! <= 0) {
        return 'Please enter a valid height';
      }
      if (state.weight == null || state.weight! <= 0) {
        return 'Please enter a valid weight';
      }
      return null;

    case 4:
      if (state.selectedObjectives.isEmpty) {
        return 'Please select recovery goal';
      }
      return null;

    case 5:
      if (state.selectedPainLocations.isEmpty) {
        return 'Please select pain location';
      }
      return null;

    case 6:
      if (state.painLevel == null) {
        return 'Please provide pain level (0-10)';
      }
      return null;

    case 7:
      // Step 7: Yếu/cứng - không bắt buộc
      return null;

    case 8:
      // Step 8: Weakness type - không bắt buộc
      return null;

    case 9:
      // Step 9: Vững chân/chóng mặt - không bắt buộc
      return null;

    case 10:
      // Step 10: Living arrangement - không bắt buộc
      return null;

    case 11:
      if (state.mapScore == null || state.mapScore! <= 0) {
        return 'Please enter blood pressure';
      }
      return null;

    case 12:
      if (state.heartRate == null || state.heartRate! <= 0) {
        return 'Please enter heart rate';
      }
      return null;

    case 13:
      if (state.bloodSugar == null || state.bloodSugar! <= 0) {
        return 'Please enter blood sugar level';
      }
      return null;

    case 14:
      if (state.adlScore == null) {
        return 'Please select an answer';
      }
      return null;

    case 15:
      if (state.iadlScore == null) {
        return 'Please select an answer';
      }
      return null;

    default:
      return null;
  }
});