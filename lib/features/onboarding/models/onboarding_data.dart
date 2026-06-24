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
            'Monitoring and building a comprehensive rehabilitation journey app',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly_couple.png',
        extraImagePath: 'assets/images/onboarding/onboarding_logo.png',
        titleAlignment: TitleAlignment.left,
      );
}

/// Step 1.1 (becomes Step 2): Username/Phone Number input
/// Figma: Bxer3DnXLQcxg5HSArHa8w node 453:1691
class OnboardingStep1_1Config extends OnboardingStepConfig {
  const OnboardingStep1_1Config()
    : super(
        step: 2,
        title: 'Please enter your login information here',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly4.png',
        titleAlignment: TitleAlignment.center,
      );
}

class OnboardingStep2Config extends OnboardingStepConfig {
  const OnboardingStep2Config()
    : super(
        step: 3,
        title: 'Basic information of the care recipient',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly4.png',
        titleAlignment: TitleAlignment.center,
      );
}

class OnboardingStep3Config extends OnboardingStepConfig {
  const OnboardingStep3Config()
    : super(
        step: 3,
        title: 'What is the main recovery goal currently?',
        subtitle: 'Choose the most appropriate goal for the current condition.',
        imagePath: 'assets/images/onboarding/elderly1.png',
      );
}

class OnboardingStep4Config extends OnboardingStepConfig {
  const OnboardingStep4Config()
    : super(
        step: 4,
        title: 'Currently, where do you feel the most pain or discomfort?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep5Config extends OnboardingStepConfig {
  const OnboardingStep5Config()
    : super(
        step: 5,
        title:
            'If 0 is no pain and 10 is unbearable pain, what is your current pain level?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep6Config extends OnboardingStepConfig {
  const OnboardingStep6Config()
    : super(
        step: 6,
        title:
            'How would you describe this pain? Sharp for a while then gone, or a dull ache all day?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep7Config extends OnboardingStepConfig {
  const OnboardingStep7Config()
    : super(
        step: 7,
        title:
            'Do you feel any weakness in your limbs or any stiffness or difficulty moving?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep8Config extends OnboardingStepConfig {
  const OnboardingStep8Config()
    : super(
        step: 8,
        title:
            'Can you stand up from a chair without using your hands or needing support?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep9Config extends OnboardingStepConfig {
  const OnboardingStep9Config()
    : super(
        step: 9,
        title:
            'Do you feel steady when walking? Do you ever feel slightly dizzy or fear falling?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly3.png',
      );
}

class OnboardingStep10Config extends OnboardingStepConfig {
  const OnboardingStep10Config()
    : super(
        step: 10,
        title: 'Who are you currently living with?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly_couple2.png',
        options: const [
          'Living alone',
          'Living with spouse',
          'Living with children/grandchildren',
        ],
      );
}

class OnboardingStep11Config extends OnboardingStepConfig {
  const OnboardingStep11Config()
    : super(
        step: 11,
        title:
            'What is your typical blood pressure level? If you have a monitor, please provide the numbers.',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly5.png',
      );
}

class OnboardingStep12Config extends OnboardingStepConfig {
  const OnboardingStep12Config()
    : super(
        step: 12,
        title:
            'When resting, do you feel your heart beat regularly? What is your typical heart rate?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly5.png',
      );
}

class OnboardingStep13Config extends OnboardingStepConfig {
  const OnboardingStep13Config()
    : super(
        step: 13,
        title:
            'What was the most recent blood glucose level reported by your doctor?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly5.png',
      );
}

class OnboardingStep14Config extends OnboardingStepConfig {
  const OnboardingStep14Config()
    : super(
        step: 14,
        title:
            'Do you need any help with daily activities like personal hygiene, dressing, or eating?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly_couple3.png',
        options: const [
          'Completely independent',
          'Need a little support.',
          'Need full assistance.',
        ],
      );
}

class OnboardingStep15Config extends OnboardingStepConfig {
  const OnboardingStep15Config()
    : super(
        step: 15,
        title:
            'Can you go shopping, cook, or use the phone to call your children/grandchildren by yourself?',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly_couple3.png',
        options: const [
          'Completely independent',
          'Need a little support.',
          'Need full assistance.',
        ],
      );
}

class OnboardingStep16Config extends OnboardingStepConfig {
  const OnboardingStep16Config()
    : super(
        step: 16,
        title: 'Take a photo of discharge summary / prescription',
        subtitle: null,
        imagePath: null,
        titleAlignment: TitleAlignment.center,
      );
}

class OnboardingStep17Config extends OnboardingStepConfig {
  const OnboardingStep17Config()
    : super(
        step: 17,
        title: 'Completed',
        subtitle: null,
        imagePath: 'assets/images/onboarding/elderly2.png',
      );
}

class OnboardingConfig {
  static final Map<int, OnboardingStepConfig> _steps = {
    1: const OnboardingStep1Config(),
    2: const OnboardingStep1_1Config(), // New Step 1.1: Username/Phone
    3: const OnboardingStep2Config(),
    4: const OnboardingStep3Config(),
    5: const OnboardingStep4Config(),
    6: const OnboardingStep5Config(),
    7: const OnboardingStep6Config(),
    8: const OnboardingStep7Config(),
    9: const OnboardingStep8Config(),
    10: const OnboardingStep9Config(),
    11: const OnboardingStep10Config(),
    12: const OnboardingStep11Config(),
    13: const OnboardingStep12Config(),
    14: const OnboardingStep13Config(),
    15: const OnboardingStep14Config(),
    16: const OnboardingStep15Config(),
    17: const OnboardingStep16Config(),
    18: const OnboardingStep17Config(),
  };

  static OnboardingStepConfig getStep(int step) => _steps[step] ?? _steps[1]!;

  static const int totalSteps = 18;

  static List<OnboardingStepConfig> getAll() =>
      List.generate(totalSteps, (i) => getStep(i + 1));
}

/// --- Onboarding data model ---
class OnboardingData {
  final int currentStep;

  // Step 1.1 (Step 2) - Username/Phone
  final String? usernameOrPhone;

  // Step 3 - Personal info
  final String? fullName;
  final int? birthYear;
  final Gender? gender;
  final double? height;
  final double? weight;
  // Calculated BMI (kg/m^2)
  final double? bmi;

  // Step 3 - Health objectives
  final Set<HealthObjective> selectedObjectives;

  // Step 4 - Pain locations
  final Set<PainLocation> selectedPainLocations;

  // Step 5 - Pain level (0-10)
  final int? painLevel;

  // Step 14 - ADL score (0,1,2)
  final int? adlScore;

  // Step 15 - IADL score (0,1,2)
  final int? iadlScore;

  // Step 12 - Resting heart rate (beats per minute)
  final int? heartRate;

  // Step 13 - Blood glucose (e.g., mg/dL)
  final int? bloodSugar;

  // Step 11 - MAP score / blood pressure input
  final double? mapScore;

  // Step 6 - Pain type
  final PainType? painType;

  // Step 7 - Weakness/stiffness
  final WeaknessType? weaknessType;

  // Step 8 - Functional: stand from chair
  final StandAbility? standAbility;

  // Step 10 - Living arrangement (UI choices: 'Sống một mình', 'Sống cùng vợ/chồng', 'Sống cùng con cháu')
  final String? livingArrangement;

  // Optional doctor advice
  final String? doctorAdvice;

  // Completed flag
  final bool isCompleted;

  const OnboardingData({
    this.currentStep = 1,
    this.usernameOrPhone,
    this.fullName,
    this.birthYear,
    this.gender,
    this.height,
    this.weight,
    this.bmi,
    this.livingArrangement,
    this.mapScore,
    this.adlScore,
    this.iadlScore,
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
    String? usernameOrPhone,
    String? fullName,
    int? birthYear,
    Gender? gender,
    double? height,
    double? weight,
    double? bmi,
    String? livingArrangement,
    double? mapScore,
    int? adlScore,
    int? iadlScore,
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
      usernameOrPhone: usernameOrPhone ?? this.usernameOrPhone,
      fullName: fullName ?? this.fullName,
      birthYear: birthYear ?? this.birthYear,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      livingArrangement: livingArrangement ?? this.livingArrangement,
      mapScore: mapScore ?? this.mapScore,
      adlScore: adlScore ?? this.adlScore,
      iadlScore: iadlScore ?? this.iadlScore,
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
      'usernameOrPhone': usernameOrPhone,
      'fullName': fullName,
      'birthYear': birthYear,
      'gender': gender?.name,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'livingArrangement': livingArrangement,
      'mapScore': mapScore,
      'adlScore': adlScore,
      'iadlScore': iadlScore,
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
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
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
        return 'Shoulder Joint';
      case PainLocation.back:
        return 'Lower Back';
      case PainLocation.knee:
        return 'Knee Joint';
      case PainLocation.hip:
        return 'Hip';
      case PainLocation.neck:
        return 'Neck';
    }
  }
}

extension PainTypeDisplay on PainType {
  String get displayName {
    switch (this) {
      case PainType.sharp:
        return 'Sharp pain';
      case PainType.aching:
        return 'Dull ache';
      case PainType.burning:
        return 'Burning sensation';
      case PainType.other:
        return 'Other';
    }
  }
}

extension WeaknessTypeDisplay on WeaknessType {
  String get displayName {
    switch (this) {
      case WeaknessType.none:
        return 'None';
      case WeaknessType.weakness:
        return 'Weakness';
      case WeaknessType.stiffness:
        return 'Stiffness';
    }
  }
}

extension StandAbilityDisplay on StandAbility {
  String get displayName {
    switch (this) {
      case StandAbility.veryEasy:
        return 'Very easy';
      case StandAbility.normal:
        return 'Normal';
      case StandAbility.difficult:
        return 'Somewhat difficult';
    }
  }
}