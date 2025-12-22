/// Model chứa dữ liệu người dùng thu thập trong quá trình onboarding
class OnboardingData {
  /// Bước hiện tại (1-4)
  final int currentStep;

  /// Chức năng phục hồi được chọn (step 2)
  final Set<RehabilitationType> selectedRehabTypes;

  /// Vị trí đau được chọn (step 3)
  final Set<PainLocation> selectedPainLocations;

  /// Lời khuyên từ bác sĩ (step 4)
  final String? doctorAdvice;

  /// Đã hoàn thành onboarding chưa
  final bool isCompleted;

  const OnboardingData({
    this.currentStep = 1,
    this.selectedRehabTypes = const {},
    this.selectedPainLocations = const {},
    this.doctorAdvice,
    this.isCompleted = false,
  });

  OnboardingData copyWith({
    int? currentStep,
    Set<RehabilitationType>? selectedRehabTypes,
    Set<PainLocation>? selectedPainLocations,
    String? doctorAdvice,
    bool? isCompleted,
  }) {
    return OnboardingData(
      currentStep: currentStep ?? this.currentStep,
      selectedRehabTypes: selectedRehabTypes ?? this.selectedRehabTypes,
      selectedPainLocations:
          selectedPainLocations ?? this.selectedPainLocations,
      doctorAdvice: doctorAdvice ?? this.doctorAdvice,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Chuyển đổi sang Map để lưu trữ/gửi API
  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'selectedRehabTypes': selectedRehabTypes.map((e) => e.name).toList(),
      'selectedPainLocations': selectedPainLocations
          .map((e) => e.name)
          .toList(),
      'doctorAdvice': doctorAdvice,
      'isCompleted': isCompleted,
    };
  }
}

/// Loại phục hồi chức năng
enum RehabilitationType {
  physicalTherapy('Vật lý trị liệu', 'assets/icons/physical_therapy.svg'),
  neurology('Thần kinh', 'assets/icons/neurology.svg');

  final String displayName;
  final String iconPath;

  const RehabilitationType(this.displayName, this.iconPath);
}

/// Vị trí đau trên cơ thể
enum PainLocation {
  knee('Khớp gối', 'assets/icons/knee.svg'),
  shoulder('Khớp vai', 'assets/icons/shoulder.svg'),
  back('Lưng', 'assets/icons/back.svg'),
  neck('Cổ', 'assets/icons/neck.svg'),
  hip('Hông', 'assets/icons/hip.svg'),
  ankle('Mắt cá chân', 'assets/icons/ankle.svg');

  final String displayName;
  final String iconPath;

  const PainLocation(this.displayName, this.iconPath);
}

/// Cấu hình cho mỗi bước onboarding
class OnboardingStepConfig {
  final int step;
  final String title;
  final String? imagePath;
  final List<String>? options;

  const OnboardingStepConfig({
    required this.step,
    required this.title,
    this.imagePath,
    this.options,
  });
}

/// Tất cả cấu hình bước onboarding
class OnboardingConfig {
  static const List<OnboardingStepConfig> steps = [
    OnboardingStepConfig(
      step: 1,
      title:
          'Ứng dụng giám sát, xây dựng lộ trình phục hồi chức năng toàn diện',
      imagePath: 'assets/images/onboarding/elderly2.png',
    ),
    OnboardingStepConfig(
      step: 2,
      title: 'Bác muốn phục hồi chức năng về?',
      imagePath: 'assets/images/onboarding/confused_person.png',
    ),
    OnboardingStepConfig(
      step: 3,
      title: 'Hiện tại, cơ thể bác đang cảm thấy đau hay khó chịu ở đâu nhất?',
      imagePath: 'assets/images/onboarding/body_image.png',
    ),
    OnboardingStepConfig(
      step: 4,
      title: 'Lời khuyên từ bác sĩ?',
      imagePath: 'assets/images/onboarding/elderly1.png',
    ),
  ];

  static OnboardingStepConfig getStep(int step) {
    return steps.firstWhere((s) => s.step == step, orElse: () => steps.first);
  }

  static const int totalSteps = 4;
}
