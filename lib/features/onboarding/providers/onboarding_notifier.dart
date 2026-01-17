import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/onboarding_state.dart';
import '../repositories/onboarding_repository_dio.dart';

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

  // --- API Calls ---
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

  Future<bool> createPatient() async {
    state = state.copyWith(isLoading: true);
    try {
      final body = {
        'full_name': state.fullName,
        'email': state.email,
        'phone': state.phone,
        'role': 'PATIENT',
        'patient_full_name': state.patientFullName,
        'patient_email': state.email,
        'patient_phone': state.patientPhone,
      };
      debugPrint('[NOTIFIER] createPatient() payload: $body');
      final resp = await _repo.createPatient(body: body);
      debugPrint('[NOTIFIER] createPatient() response: $resp');
      if (resp != null) {
        final pid = resp['id']?.toString();
        debugPrint('[NOTIFIER] createPatient() created patient id: $pid');
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

  /// Submit final profile sequentially. Navigates to `/profile` on success.
  Future<bool> submitFinalProfile(BuildContext context) async {
    state = state.copyWith(isLoading: true);
    try {
      final generalBody = {
        'pain_location': state.painLocation,
        'pain_scale_score': state.painScaleScore,
        'pain_character': state.painCharacter,
        'pain_assessment': state.painAssessment,
        'muscle_tone': state.muscleTone,
        'muscle_strength': state.muscleStrength,
        'balanced_valuation': state.balancedValuation,
        'fall_risk': state.fallRisk,
        'self_stand_ability': state.selfStandAbility,
        'tug_time': state.tugTime,
        'previous_illness': state.previousIllness,
        'previous_treatments': state.previousTreatments,
        'daily_activities': state.dailyActivities,
        'doctor_recommended': state.doctorRecommended,
        'doctor_treatment_plan': state.doctorTreatmentPlan,
        'note': state.note,
      };

      debugPrint(
        '[NOTIFIER] submitFinalProfile() general payload: $generalBody',
      );
      final genOk = await _repo.postGeneralProfile(body: generalBody);
      debugPrint('[NOTIFIER] submitFinalProfile() general result: $genOk');
      if (!genOk) {
        debugPrint('[NOTIFIER] submitFinalProfile() general POST failed');
        return false;
      }

      final physBody = {
        'gender': state.gender,
        'living_arrangement': state.livingArrangement,
        'bmi_score': state.bmiScore,
        'map_score': state.mapScore,
        'rhr_score': state.rhrScore,
        'blood_glucose_level': state.bloodGlucoseLevel,
        'adl_score': state.adlScore,
        'iadl_score': state.iadlScore,
        'disease_type': state.diseaseType,
        'condition_note': state.conditionNote,
      };

      debugPrint('[NOTIFIER] submitFinalProfile() physical payload: $physBody');
      final physOk = await _repo.postPhysicalTherapy(body: physBody);
      debugPrint('[NOTIFIER] submitFinalProfile() physical result: $physOk');
      if (!physOk) {
        debugPrint('[NOTIFIER] submitFinalProfile() physical POST failed');
        return false;
      }

      // On success navigate to profile
      try {
        GoRouter.of(context).go('/profile');
      } catch (_) {}

      return true;
    } catch (e) {
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
