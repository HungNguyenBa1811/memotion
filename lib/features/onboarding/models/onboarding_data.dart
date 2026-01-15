// Onboarding models and configurations (clean, single-source)
// Supports onboarding steps and the gathered user data model.

import 'package:flutter/material.dart';

/// Căn chỉnh title trong onboarding step
enum TitleAlignment { left, center }

extension TitleAlignmentX on TitleAlignment {
  CrossAxisAlignment get crossAxisAlignment => switch (this) {
    TitleAlignment.left => CrossAxisAlignment.start,
    TitleAlignment.center => CrossAxisAlignment.center,
  };

  TextAlign get textAlign => switch (this) {
    TitleAlignment.left => TextAlign.left,
    TitleAlignment.center => TextAlign.center,
  };
}

abstract class OnboardingStepConfig {
  final int step;
  final String title;
  final String? subtitle;
  final String? imagePath;
  final String? extraImagePath;
  final List<String>? options;
  final TitleAlignment titleAlignment;

  const OnboardingStepConfig({
    required this.step,
    required this.title,
    this.subtitle,
    this.imagePath,
    this.extraImagePath,
    this.options,
    this.titleAlignment = TitleAlignment.left,
  });
}

class OnboardingStep1Config extends OnboardingStepConfig {
  const OnboardingStep1Config()
    : super(
        step: 1,
        title:
            'Ứng dụng giám sát, xây dựng lộ trình phục hồi chức năng toàn diện',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly_couple.png',
        extraImagePath: 'assets/images/onboarding/onboarding_logo.png',
        titleAlignment: TitleAlignment.left,
      );
}

class OnboardingStep2Config extends OnboardingStepConfig {
  const OnboardingStep2Config()
    : super(
        step: 2,
        title: 'Thông tin cơ bản của người được chăm sóc',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly4.png',
        titleAlignment: TitleAlignment.center,
      );
}

class OnboardingStep3Config extends OnboardingStepConfig {
  const OnboardingStep3Config()
    : super(
        step: 3,
        title: 'Mục tiêu phục hồi chính hiện nay là gì?',
        subtitle: 'Chọn mục tiêu phù hợp nhất với tình trạng hiện tại.',
        imagePath: 'assets/images/onboarding/elderly1.png',
      );
}

class OnboardingStep4Config extends OnboardingStepConfig {
  const OnboardingStep4Config()
    : super(
        step: 4,
        title: 'Hiện tại, bác thấy đau hoặc khó chịu nhiều nhất ở đâu?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep5Config extends OnboardingStepConfig {
  const OnboardingStep5Config()
    : super(
        step: 5,
        title:
            'Nếu coi 0 là không đau và 10 là đau không chịu nổi, thì mức đau của ông/bà đang là mấy ạ?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep6Config extends OnboardingStepConfig {
  const OnboardingStep6Config()
    : super(
        step: 6,
        title:
            'Cái đau này nó như thế nào ông/bà nhỉ? Đau nhói một lúc rồi hết, hay cứ đau âm ỉ cả ngày?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep7Config extends OnboardingStepConfig {
  const OnboardingStep7Config()
    : super(
        step: 7,
        title:
            'Ông/bà có thấy tay chân mình bị yếu đi hay có chỗ nào bị cứng, khó cử động không',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep8Config extends OnboardingStepConfig {
  const OnboardingStep8Config()
    : super(
        step: 8,
        title:
            'Từ ghế ngồi, ông/bà có thể tự đứng lên mà không cần vịn tay hay ai đỡ không ạ?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep9Config extends OnboardingStepConfig {
  const OnboardingStep9Config()
    : super(
        step: 9,
        title:
            'Khi đi lại, ông/bà có thấy vững chân không? Có bao giờ cảm thấy hơi chóng mặt hay lo sợ mình bị ngã không?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep10Config extends OnboardingStepConfig {
  const OnboardingStep10Config()
    : super(
        step: 10,
        title: 'Hiện tại ông/bà đang sống cùng với ai cho vui vầy ạ?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly_couple2.png',
        options: const ['Sống một mình', 'Sống cùng vợ/chồng', 'Sống cùng con cháu'],
      );
}
 
class OnboardingStep11Config extends OnboardingStepConfig {
  const OnboardingStep11Config()
    : super(
        step: 11,
        title:
            'Huyết áp của ông/bà thường ở mức nào ạ? Nếu có máy đo ở đó, ông/bà cho con xin con số nhé.',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly5.png',
      );
}

class OnboardingStep12Config extends OnboardingStepConfig {
  const OnboardingStep12Config()
    : super(
        step: 12,
        title:
            'Lúc ngồi nghỉ ngơi thong thả, ông/bà thấy tim mình đập có đều không? Nhịp tim thường là bao nhiêu ạ?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly5.png',
      );
}

class OnboardingStep13Config extends OnboardingStepConfig {
  const OnboardingStep13Config()
    : super(
        step: 13,
        title:
            'Chỉ số đường huyết gần nhất mà bác sĩ báo cho ông/bà là bao nhiêu ạ',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly5.png',
      );
}

class OnboardingStep14Config extends OnboardingStepConfig {
  const OnboardingStep14Config()
    : super(
        step: 14,
        title:
            'Trong các việc hằng ngày như vệ sinh cá nhân, mặc quần áo hay ăn uống, ông/bà có cần ai giúp đỡ không?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly_couple3.png',
        options: const [
          'Hoàn toàn tự làm được',
          'Cần hỗ trợ một chút.',
          'Cần người làm giúp hoàn toàn.',
        ], 
      );
}

class OnboardingStep15Config extends OnboardingStepConfig {
  const OnboardingStep15Config()
    : super(
        step: 15,
        title:
            'Ông/bà có thể tự đi chợ, nấu cơm hay dùng điện thoại gọi cho con cháu một mình được không ạ',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly_couple3.png',
        options: const [
          'Hoàn toàn tự làm được',
          'Cần hỗ trợ một chút.',
          'Cần người làm giúp hoàn toàn.',
        ],
      );
}

class OnboardingStep16Config extends OnboardingStepConfig {
  const OnboardingStep16Config()
    : super(
        step: 16,
        title: 'Chụp giấy ra viện / đơn thuốc',
        subtitle: null,
        imagePath: null,
        titleAlignment: TitleAlignment.center,
      );
}

class OnboardingStep17Config extends OnboardingStepConfig {
  const OnboardingStep17Config()
    : super(
        step: 17,
        title: 'Hoàn tất',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly2.png',
      );
}

class OnboardingConfig {
  static final Map<int, OnboardingStepConfig> _steps = {
    1: const OnboardingStep1Config(),
    2: const OnboardingStep2Config(),
    3: const OnboardingStep3Config(),
    4: const OnboardingStep4Config(),
    5: const OnboardingStep5Config(),
    6: const OnboardingStep6Config(),
    7: const OnboardingStep7Config(),
    8: const OnboardingStep8Config(),
    9: const OnboardingStep9Config(),
    10: const OnboardingStep10Config(),
    11: const OnboardingStep11Config(),
    12: const OnboardingStep12Config(),
    13: const OnboardingStep13Config(),
    14: const OnboardingStep14Config(),
    15: const OnboardingStep15Config(),
    16: const OnboardingStep16Config(),
    17: const OnboardingStep17Config(),
  };

  static OnboardingStepConfig getStep(int step) => _steps[step] ?? _steps[1]!;

  static const int totalSteps = 17;

  static List<OnboardingStepConfig> getAll() =>
      List.generate(totalSteps, (i) => getStep(i + 1));
}

/// --- Onboarding data model ---
class OnboardingData {
  final int currentStep;

  // Step 2 - Personal info
  final String? fullName;
  final int? birthYear;
  final Gender? gender;
  final double? height;
  final double? weight;

  // Step 3 - Health objectives
  final Set<HealthObjective> selectedObjectives;

  // Step 4 - Pain locations
  final Set<PainLocation> selectedPainLocations;

  // Step 5 - Pain level (0-10)
  final int? painLevel;

  // Step 12 - Resting heart rate (beats per minute)
  final int? heartRate;

  // Step 13 - Blood glucose (e.g., mg/dL)
  final int? bloodSugar;

  // Step 6 - Pain type
  final PainType? painType;

  // Step 7 - Weakness/stiffness
  final WeaknessType? weaknessType;

  // Step 8 - Functional: stand from chair
  final StandAbility? standAbility;

  // Optional doctor advice
  final String? doctorAdvice;

  // Completed flag
  final bool isCompleted;

  const OnboardingData({
    this.currentStep = 1,
    this.fullName,
    this.birthYear,
    this.gender,
    this.height,
    this.weight,
    this.selectedObjectives = const <HealthObjective>{},
    this.selectedPainLocations = const <PainLocation>{},
    this.painLevel,
    this.heartRate,
    this.bloodSugar,
    this.painType,
    this.weaknessType,
    this.standAbility,
    this.doctorAdvice,
    this.isCompleted = false,
  });

  OnboardingData copyWith({
    int? currentStep,
    String? fullName,
    int? birthYear,
    Gender? gender,
    double? height,
    double? weight,
    Set<HealthObjective>? selectedObjectives,
    Set<PainLocation>? selectedPainLocations,
    int? painLevel,
    int? heartRate,
    int? bloodSugar,
    PainType? painType,
    WeaknessType? weaknessType,
    StandAbility? standAbility,
    String? doctorAdvice,
    bool? isCompleted,
  }) {
    return OnboardingData(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      birthYear: birthYear ?? this.birthYear,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      selectedObjectives: selectedObjectives ?? this.selectedObjectives,
      selectedPainLocations:
          selectedPainLocations ?? this.selectedPainLocations,
      painLevel: painLevel ?? this.painLevel,
      heartRate: heartRate ?? this.heartRate,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      painType: painType ?? this.painType,
      weaknessType: weaknessType ?? this.weaknessType,
      standAbility: standAbility ?? this.standAbility,
      doctorAdvice: doctorAdvice ?? this.doctorAdvice,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'fullName': fullName,
      'birthYear': birthYear,
      'gender': gender?.name,
      'height': height,
      'weight': weight,
      'selectedObjectives': selectedObjectives.map((e) => e.name).toList(),
      'selectedPainLocations': selectedPainLocations
          .map((e) => e.name)
          .toList(),
      'painLevel': painLevel,
      'heartRate': heartRate,
      'bloodSugar': bloodSugar,
      'painType': painType?.name,
      'weaknessType': weaknessType?.name,
      'standAbility': standAbility?.name,
      'doctorAdvice': doctorAdvice,
      'isCompleted': isCompleted,
    };
  }
}

// --- Enums ---
enum Gender { male, female, other }

enum HealthObjective { movement, lifeActivities, pain }

enum PainLocation { shoulder, back, knee, hip, neck }

enum PainType { sharp, aching, burning, other }

enum WeaknessType { none, weakness, stiffness }

enum StandAbility { veryEasy, normal, difficult }

// --- Display extensions used by UI builders ---
extension GenderDisplay on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Nam';
      case Gender.female:
        return 'Nữ';
      case Gender.other:
        return 'Khác';
    }
  }
}

extension HealthObjectiveDisplay on HealthObjective {
  String get displayNameVi {
    switch (this) {
      case HealthObjective.movement:
        return 'Vận động - đi lại';
      case HealthObjective.lifeActivities:
        return 'Sinh hoạt hàng ngày';
      case HealthObjective.pain:
        return 'Giảm đau - cải thiện thể lực';
    }
  }

  String get displayNameEn {
    switch (this) {
      case HealthObjective.movement:
        return 'Improve daily movement';
      case HealthObjective.lifeActivities:
        return 'Support daily activities';
      case HealthObjective.pain:
        return 'Reduce pain and improve fitness';
    }
  }
}

extension PainLocationDisplay on PainLocation {
  String get displayName {
    switch (this) {
      case PainLocation.shoulder:
        return 'Khớp vai';
      case PainLocation.back:
        return 'Thắt lưng';
      case PainLocation.knee:
        return 'Khớp gối';
      case PainLocation.hip:
        return 'Hông';
      case PainLocation.neck:
        return 'Cổ';
    }
  }
}

extension PainTypeDisplay on PainType {
  String get displayName {
    switch (this) {
      case PainType.sharp:
        return 'Đau nhói';
      case PainType.aching:
        return 'Đau âm ỉ';
      case PainType.burning:
        return 'Rát, nóng';
      case PainType.other:
        return 'Khác';
    }
  }
}

extension WeaknessTypeDisplay on WeaknessType {
  String get displayName {
    switch (this) {
      case WeaknessType.none:
        return 'Không';
      case WeaknessType.weakness:
        return 'Yếu';
      case WeaknessType.stiffness:
        return 'Cứng';
    }
  }
}

extension StandAbilityDisplay on StandAbility {
  String get displayName {
    switch (this) {
      case StandAbility.veryEasy:
        return 'Rất dễ dàng';
      case StandAbility.normal:
        return 'Bình thường';
      case StandAbility.difficult:
        return 'Hơi khó khăn';
    }
  }
}
