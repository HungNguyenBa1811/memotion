import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:memotion/core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/patient_creation_payload.dart';
import '../models/onboarding_state.dart';
import '../models/onboarding_data.dart';
import '../repositories/onboarding_repository_dio.dart';
import './onboarding_provider.dart';
import '../../../core/storage/token_storage.dart';

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

class OnboardingNotifier extends Notifier<OnboardingState> {
  late final OnboardingRepositoryDio _repo;

  @override
  OnboardingState build() {
    _repo = OnboardingRepositoryDio();
    return const OnboardingState();
  }

  // --- Simple setters for steps ---
  void setPatientPhone(String phone) =>
      state = state.copyWith(patientPhone: phone);

  void setPatientName(String name) =>
      state = state.copyWith(patientFullName: name);

  void setEmail(String email) => state = state.copyWith(email: email);

  void setFullName(String name) => state = state.copyWith(fullName: name);

  void setPhone(String phone) => state = state.copyWith(phone: phone);

  void setToken(String token) => state = state.copyWith(token: token);

  void setPainLocation(String loc) => state = state.copyWith(painLocation: loc);

  void setPainScaleScore(int score) =>
      state = state.copyWith(painScaleScore: score);

  void setPainCharacter(String c) => state = state.copyWith(painCharacter: c);

  void setGender(String g) => state = state.copyWith(gender: g);

  void setBmiScore(double v) => state = state.copyWith(bmiScore: v);

  void setAdlScore(int v) => state = state.copyWith(adlScore: v);

  void setIadlScore(int v) => state = state.copyWith(iadlScore: v);

  void setNote(String n) => state = state.copyWith(note: n);

  // --- Assessment data setters ---
  void setPainAssessment(String v) => state = state.copyWith(painAssessment: v);

  void setMuscleTone(String v) => state = state.copyWith(muscleTone: v);

  void setMuscleStrength(String v) => state = state.copyWith(muscleStrength: v);

  void setBalancedValuation(String v) =>
      state = state.copyWith(balancedValuation: v);

  void setFallRisk(String v) => state = state.copyWith(fallRisk: v);

  void setSelfStandAbility(String v) =>
      state = state.copyWith(selfStandAbility: v);

  void setTugTime(int v) => state = state.copyWith(tugTime: v);

  void setPreviousIllness(String v) =>
      state = state.copyWith(previousIllness: v);

  void setPreviousTreatments(String v) =>
      state = state.copyWith(previousTreatments: v);

  void setDailyActivities(String v) =>
      state = state.copyWith(dailyActivities: v);

  void setDoctorRecommended(String v) =>
      state = state.copyWith(doctorRecommended: v);

  void setDoctorTreatmentPlan(String v) =>
      state = state.copyWith(doctorTreatmentPlan: v);

  void setLivingArrangement(String v) =>
      state = state.copyWith(livingArrangement: v);

  void setMapScore(int v) => state = state.copyWith(mapScore: v);

  void setRhrScore(int v) => state = state.copyWith(rhrScore: v);

  void setBloodGlucoseLevel(int v) =>
      state = state.copyWith(bloodGlucoseLevel: v);

  void setConditionNote(String v) => state = state.copyWith(conditionNote: v);

  /// Step 14: ADL scoring - options map to scores [2,1,0] in order
  void setAdlScoreByOptionIndex(int index) {
    const scores = [2, 1, 0];
    final score = (index >= 0 && index < scores.length) ? scores[index] : 0;
    state = state.copyWith(adlScore: score);
  }

  /// Step 15: IADL scoring - options map to scores [2,1,0] in order
  void setIadlScoreByOptionIndex(int index) {
    const scores = [2, 1, 0];
    final score = (index >= 0 && index < scores.length) ? scores[index] : 0;
    state = state.copyWith(iadlScore: score);
  }

  // Additional setters from onboarding_provider
  void setUsernameOrPhone(String value) =>
      state = state.copyWith(phone: value.trim());

  void setDoctorAdvice(String value) =>
      state = state.copyWith(doctorRecommended: value);

  // Navigation methods
  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 1) {
      state = state.copyWith(currentStep: step);
    }
  }

  void completeOnboarding() {
    // Mark as completed if needed
  }

  // --- API Calls ---
  Future<bool> scanMedicalRecord(List<File> files) async {
    state = state.copyWith(isLoading: true);
    try {
      debugPrint(
        '[NOTIFIER] scanMedicalRecord() sending ${files.length} files',
      );
      final data = await _repo.scanMedicalRecord(files: files);
      debugPrint('[NOTIFIER] scanMedicalRecord() response: $data');
      if (data != null) {
        final recommended = data['doctor_recommended']?.toString() ?? '';
        final plan = data['doctor_treatment_plan']?.toString() ?? '';
        state = state.copyWith(
          doctorRecommended: recommended,
          doctorTreatmentPlan: plan,
        );
        debugPrint(
          '[NOTIFIER] scanMedicalRecord() extracted: recommended=$recommended, plan=$plan',
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[NOTIFIER] scanMedicalRecord() error: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchUserProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      debugPrint('[NOTIFIER] fetchUserProfile() calling repository');
      final data = await _repo.fetchUserProfile();
      debugPrint('[NOTIFIER] fetchUserProfile() response: $data');
      if (data != null) {
        state = state.copyWith(
          userId: data['id']?.toString(),
          email: data['email']?.toString(),
          fullName: data['full_name']?.toString() ?? state.fullName,
        );
      }
    } catch (e) {
      debugPrint('[NOTIFIER] fetchUserProfile() error: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> createPatient(WidgetRef ref) async {
    state = state.copyWith(isLoading: true);
    try {
      // Read data from onboardingProvider (where step builders save data)
      final uiData = ref.read(onboardingProvider);
      final caretakerEmail = ref.read(authProvider).user?.email;

      // The endpoint requires a unique patient email. Derive a distinct alias
      // from the authenticated caretaker's email while keeping the phone in
      // phone-only fields.
      final body = PatientCreationPayload.fromCaretaker(
        patientFullName: uiData.fullName ?? '',
        patientPhone: uiData.usernameOrPhone ?? '',
        caretakerEmail: caretakerEmail ?? '',
      ).toJson();
      debugPrint('[NOTIFIER] createPatient() payload: $body');
      final resp = await _repo.createPatient(body: body);
      debugPrint('[NOTIFIER] createPatient() response: $resp');
      if (resp != null) {
        // Try to extract patient id from common shapes
        String? pid;
        if (resp['patient'] != null && resp['patient']['user_id'] != null) {
          pid = resp['patient']['user_id']?.toString();
        } else if (resp['id'] != null) {
          pid = resp['id']?.toString();
        } else if (resp['user_id'] != null) {
          pid = resp['user_id']?.toString();
        }
        if (pid != null) {
          state = state.copyWith(createdPatientId: pid);
          debugPrint('[NOTIFIER] createPatient() created patient id: $pid');
        } else {
          debugPrint(
            '[NOTIFIER] createPatient() created patient id not found in response',
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[NOTIFIER] createPatient() error: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Submit final profile sequentially and return whether every call succeeded.
  /// Reads data from onboardingProvider and converts to API format.
  Future<bool> submitFinalProfile(
    BuildContext context,
    WidgetRef ref, {
    ValueChanged<int>? onProgress,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      debugPrint('[NOTIFIER] submitFinalProfile() start');
      onProgress?.call(0);

      // Ensure patient exists: if not created yet, create now.
      if (state.createdPatientId == null) {
        debugPrint(
          '[NOTIFIER] submitFinalProfile() creating patient before final submit',
        );
        final created = await createPatient(ref);
        if (!created) {
          debugPrint(
            '[NOTIFIER] submitFinalProfile() failed to create patient',
          );
          if (context.mounted) _navigateToOnboardingStep1(context);
          return false;
        }
      }

      // Read data from onboardingProvider (where step builders save data)
      final uiData = ref.read(onboardingProvider);
      debugPrint(
        '[NOTIFIER] submitFinalProfile() uiData: fullName=${uiData.fullName}, painLevel=${uiData.painLevel}, painType=${uiData.painType}, gender=${uiData.gender}',
      );

      // Convert enums to API-compatible strings
      final painLocationStr = uiData.selectedPainLocations.isNotEmpty
          ? uiData.selectedPainLocations
                .map((e) => e.name.toUpperCase())
                .join(',')
          : null;
      final painCharacterStr = uiData.painType?.name.toUpperCase();
      final genderStr = uiData.gender?.name.toUpperCase() ?? 'MALE';
      final selfStandAbilityStr = uiData.standAbility?.name.toUpperCase();
      // Step 9 answer khi có; nếu chưa trả lời thì giữ hành vi cũ (weaknessType)
      final balancedValuationStr =
          uiData.balanceStatus?.name.toUpperCase() ??
          uiData.weaknessType?.name.toUpperCase();
      final muscleToneStr = uiData.weaknessType?.name.toUpperCase();

      // Với lựa chọn "Other", gửi phần mô tả người dùng tự nhập
      String? otherOr(String? custom, String? fallback) {
        final trimmed = custom?.trim();
        return (trimmed != null && trimmed.isNotEmpty) ? trimmed : fallback;
      }

      final painAssessmentStr = uiData.painType == PainType.other
          ? otherOr(uiData.painTypeOther, uiData.painType?.displayName)
          : uiData.painType?.displayName;
      final muscleDescriptionStr = uiData.weaknessType == WeaknessType.other
          ? otherOr(uiData.weaknessOther, muscleToneStr)
          : muscleToneStr;
      final balanceDescriptionStr = uiData.balanceStatus == BalanceStatus.other
          ? otherOr(uiData.balanceOther, balancedValuationStr)
          : balancedValuationStr;

      // Helper to apply defaults: strings -> 'none', numbers -> 0.1
      String strOrNone(dynamic v) {
        final s = v?.toString();
        if (s == null || s.isEmpty) return 'none';
        return s;
      }

      double numOrDefault(dynamic v) {
        if (v == null) return 0.1;
        try {
          return (v is num) ? v.toDouble() : double.parse(v.toString());
        } catch (_) {
          return 0.1;
        }
      }

      // Map UI livingArrangement (English options now) to API enum strings
      String mapLivingArrangement(String? v) {
        if (v == null) return 'ALONE';
        switch (v.trim()) {
          case 'Lives alone':
          case 'Living alone':
            return 'ALONE';
          case 'Lives with a spouse or partner':
          case 'Living with spouse':
            return 'WITH_SPOUSE';
          case 'Lives with family':
          case 'Living with children/grandchildren':
            return 'WITH_CHILDREN';
          default:
            return v.toUpperCase().replaceAll(' ', '_');
        }
      }

      final generalBody = {
        'gender': strOrNone(genderStr),
        'living_arrangement': strOrNone(
          mapLivingArrangement(uiData.livingArrangement),
        ),
        'bmi_score': numOrDefault(uiData.bmi ?? 0.0),
        'map_score': numOrDefault(uiData.mapScore ?? 0),
        'rhr_score': numOrDefault(uiData.heartRate ?? 0),
        'blood_glucose_level': numOrDefault(uiData.bloodSugar ?? 0),
        'adl_score': numOrDefault(uiData.adlScore ?? 0),
        'iadl_score': numOrDefault(uiData.iadlScore ?? 0),
        'disease_type': 'PHYSICAL_THERAPY',
        // Per spec: set conditionNote to "None"
        'condition_note': 'None',
      };

      debugPrint(
        '[NOTIFIER] submitFinalProfile() general payload: $generalBody',
      );
      final genOk = await _repo.postGeneralProfile(body: generalBody);
      debugPrint('[NOTIFIER] submitFinalProfile() general result: $genOk');
      if (!genOk) {
        debugPrint('[NOTIFIER] submitFinalProfile() general POST failed');
        // Navigate back to onboarding step 1
        if (context.mounted) _navigateToOnboardingStep1(context);
        return false;
      }
      debugPrint('[NOTIFIER] submitFinalProfile() general POST succeeded');

      onProgress?.call(1);
      final physBody = {
        'pain_location': strOrNone(painLocationStr),
        'pain_scale_score': numOrDefault(uiData.painLevel),
        'pain_character': strOrNone(painCharacterStr),
        'pain_assessment': strOrNone(painAssessmentStr),
        'muscle_tone': strOrNone(muscleDescriptionStr),
        'muscle_strength': strOrNone(muscleDescriptionStr),
        'balanced_valuation': strOrNone(balanceDescriptionStr),
        'fall_risk': strOrNone(uiData.standAbility?.name ?? 'Low'),
        'self_stand_ability': strOrNone(selfStandAbilityStr),
        // Per spec: use fixed defaults for these fields
        'tug_time': 0,
        'previous_illness': 'None',
        'previous_treatments': 'None',
        'daily_activities': 'None',
        'doctor_recommended': strOrNone(uiData.doctorAdvice),
        'doctor_treatment_plan': 'None',
        'note': 'None',
        'living_arrangement': strOrNone(
          mapLivingArrangement(uiData.livingArrangement),
        ),
      };
      debugPrint('[NOTIFIER] submitFinalProfile() physical payload: $physBody');
      final physOk = await _repo.postPhysicalTherapy(body: physBody);
      debugPrint('[NOTIFIER] submitFinalProfile() physical result: $physOk');
      if (!physOk) {
        debugPrint('[NOTIFIER] submitFinalProfile() physical POST failed');
        // Navigate back to onboarding step 1
        if (context.mounted) _navigateToOnboardingStep1(context);
        return false;
      }
      debugPrint('[NOTIFIER] submitFinalProfile() physical POST succeeded');

      // Step 3: Generate AI care plan
      onProgress?.call(2);
      debugPrint('[NOTIFIER] submitFinalProfile() generating care plan...');
      final carePlanResult = await _repo.generateCarePlan(
        planDurationDays: 7,
        regenerate: false,
      );
      if (carePlanResult == null) {
        debugPrint(
          '[NOTIFIER] submitFinalProfile() care plan generation failed',
        );
        // Navigate back to onboarding step 1
        if (context.mounted) _navigateToOnboardingStep1(context);
        return false;
      }
      debugPrint(
        '[NOTIFIER] submitFinalProfile() care plan generated: $carePlanResult',
      );

      debugPrint('[NOTIFIER] submitFinalProfile() completed successfully');
      return true;
    } catch (e, st) {
      // If the API returned 403, clear stored access token and redirect to landing
      var redirectedToRegistration = false;
      if (e is DioException) {
        final status = e.response?.statusCode;
        if (status == 403) {
          debugPrint(
            '[NOTIFIER] submitFinalProfile() received 403 — clearing access token',
          );
          try {
            await TokenStorage.instance.clearAccessToken();
            debugPrint('[NOTIFIER] Access token cleared successfully');
            // Navigate to landing page after token is cleared
            if (context.mounted) {
              GoRouter.of(context).go(AppRoutes.registration);
              redirectedToRegistration = true;
              debugPrint('[NOTIFIER] Redirected to / after 403');
            }
          } catch (err) {
            debugPrint('[NOTIFIER] failed clearing token: $err');
          }
        }
      }
      debugPrint('[NOTIFIER] submitFinalProfile() exception: $e');
      debugPrint(st.toString());
      // On any exception, navigate back to onboarding step 1
      if (!redirectedToRegistration) {
        if (context.mounted) _navigateToOnboardingStep1(context);
      }
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Navigate back to onboarding step 1 when any API fails
  void _navigateToOnboardingStep1(BuildContext context) {
    debugPrint('[NOTIFIER] Navigating back to onboarding step 1');
    state = state.copyWith(currentStep: 1);
    try {
      if (context.mounted) {
        GoRouter.of(context).go('/onboarding/1');
      }
    } catch (e) {
      debugPrint(
        '[NOTIFIER] _navigateToOnboardingStep1() navigation error: $e',
      );
    }
  }
}
