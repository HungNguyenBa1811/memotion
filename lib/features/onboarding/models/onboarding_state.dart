import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';
part 'onboarding_state.g.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    // User Info
    String? userId,
    String? email,
    String? fullName,
    String? phone,
    String? token,

    // Patient Info (Onboarding 1-2)
    String? patientFullName,
    String? patientPhone,
    // ID returned after creating patient via caretaker API
    String? createdPatientId,

    // Assessment Data (Onboarding 3-16)
    String? painLocation,
    int? painScaleScore,
    String? painCharacter,
    String? painAssessment,
    String? muscleTone,
    String? muscleStrength,
    String? balancedValuation,
    String? fallRisk,
    String? selfStandAbility,
    int? tugTime,
    String? previousIllness,
    String? previousTreatments,
    String? dailyActivities,
    String? doctorRecommended,
    String? doctorTreatmentPlan,
    String? note,

    // Physical Therapy Data
    String? gender,
    String? livingArrangement,
    double? bmiScore,
    int? mapScore,
    int? rhrScore,
    int? bloodGlucoseLevel,
    int? adlScore,
    int? iadlScore,
    @Default('PHYSICAL_THERAPY') String diseaseType,
    String? conditionNote,

    @Default(false) bool isLoading,
    @Default(1) int currentStep,
  }) = _OnboardingState;

  factory OnboardingState.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStateFromJson(json);
}
