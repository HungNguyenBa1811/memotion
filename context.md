# ROLE: SENIOR FLUTTER ENGINEER (RIVERPOD SPECIALIST)
# TASK: IMPLEMENT A 17-STEP ONBOARDING FLOW WITH SEQUENTIAL API LOGIC.

## 1. TECH STACK & ARCHITECTURE (NON-NEGOTIABLE)
- **Framework**: Flutter (Latest).
- **State Management**: `flutter_riverpod` (v2.6.x) using `NotifierProvider`.
- **Data Class**: `freezed` & `json_serializable`.
- **Navigation**: `go_router`.
- **Networking**: `dio`.
- **Pattern**: MVVM.
    - **Model**: Freezed classes strictly matching JSON.
    - **ViewModel**: A SINGLE `OnboardingNotifier` that holds the state for ALL 17 screens.
    - **View**: `ConsumerWidget` screens that strictly `watch` the state.

## 2. THE STATE MODEL (COPY THIS STRUCTURE)
Create a file `onboarding_state.dart`. Use `@freezed`.
The state must hold ALL data for the 17 steps. Do not create separate states for separate screens.

```dart
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(false) bool isLoading,
    String? errorMsg,

    // --- PHASE 1: USER INFO (From GET /me) ---
    String? currentUserId,
    String? currentUserEmail,
    String? currentFullName,
    String? currentPhone,

    // --- PHASE 2: PATIENT CREATION (Screen 1-2) ---
    String? inputPatientPhone, // Onboarding1.1
    String? inputPatientName, // Onboarding2
    String? createdPatientId, // Result from API

    // --- PHASE 3: ASSESSMENT DATA (Screen 3-16) ---
    String? painLocation, // Onboarding4
    int? painScaleScore, // Onboarding5
    String? painCharacter, // Onboarding6
    String? painAssessment, // Onboarding7
    String? balancedValuation, // Onboarding8
    String? selfStandAbility, // Onboarding9
    String? livingArrangement, // Onboarding10
    int? mapScore, // Onboarding11
    int? rhrScore, // Onboarding12
    int? bloodGlucoseLevel, // Onboarding13
    int? adlScore, // Onboarding14 (0,1,2)
    int? iadlScore, // Onboarding15 (0,1,2)
    
    // --- HIDDEN/DEFAULT FIELDS FOR API ---
    @Default("MALE") String gender, 
    @Default(0) double bmiScore,
    @Default("PHYSICAL_THERAPY") String diseaseType,
    String? muscleTone,
    String? muscleStrength,
    String? fallRisk,
    int? tugTime,
    String? previousIllness,
    String? previousTreatments,
    String? dailyActivities,
    String? doctorRecommended,
    String? doctorTreatmentPlan,
    String? note,
    String? conditionNote,
    
  }) = _OnboardingState;
}
3. THE LOGIC (VIEWMODEL)
Create onboarding_notifier.dart. Implement these specific methods:

Method A: initUser()
Trigger: App Start / Login Success.

API: GET /api/users/me

Action: Update state.currentUserEmail, state.currentFullName, etc.

Method B: submitPatientCreation()
Trigger: End of Screen 2.

API: POST /api/users/patients/create-by-caretaker

Strict Payload Mapping:

JSON
{
  "full_name": state.currentFullName,
  "email": state.currentUserEmail,
  "phone": state.currentPhone,
  "role": "PATIENT",
  "patient_full_name": state.inputPatientName,
  "patient_email": state.currentUserEmail, 
  "patient_phone": state.inputPatientPhone
}
Action: On success, save data.patient.user_id to state.createdPatientId. Next Step.

Method C: submitFinalAssessment() (COMPLEX)
Trigger: Button "Finish" on Screen 16.

Logic: Execute two API calls SEQUENTIALLY. If the first fails, stop.

Step 1: General Profile

API: POST /api/patient-profiles/general

Payload:

JSON
{
  "pain_location": state.painLocation,
  "pain_scale_score": state.painScaleScore,
  "pain_character": state.painCharacter,
  "pain_assessment": state.painAssessment,
  "muscle_tone": state.muscleTone ?? "Normal",
  "muscle_strength": state.muscleStrength ?? "Normal",
  "balanced_valuation": state.balancedValuation,
  "fall_risk": state.fallRisk ?? "Low",
  "self_stand_ability": state.selfStandAbility,
  "tug_time": state.tugTime ?? 0,
  "previous_illness": state.previousIllness ?? "",
  "previous_treatments": state.previousTreatments ?? "",
  "daily_actities": state.dailyActivities ?? "",
  "doctor_recommended": state.doctorRecommended ?? "",
  "doctor_treatment_plan": state.doctorTreatmentPlan ?? "",
  "note": state.note ?? ""
}
Step 2: Physical Therapy (Only if Step 1 is 200 OK)

API: POST /api/patient-profiles/physical-therapy

Payload:

JSON
{
  "gender": state.gender,
  "living_arrangement": state.livingArrangement,
  "bmi_score": state.bmiScore,
  "map_score": state.mapScore,
  "rhr_score": state.rhrScore,
  "adl_score": state.adlScore,
  "iadl_score": state.iadlScore,
  "blood_glucose_level": state.bloodGlucoseLevel,
  "disease_type": "PHYSICAL_THERAPY",
  "condition_note": state.conditionNote ?? ""
}
Action: On success, Navigate to ProfileScreen.

4. INSTRUCTIONS FOR CODE GENERATION
Do not split Logic: Put all logic above into ONE OnboardingNotifier class.

Safety: Handle null values with ?? defaults or empty strings to prevent API crashes.

UI: Generate a Template Screen (e.g., BaseOnboardingScreen) that accepts a child (Input) and a onNext callback, to avoid repeating code for 17 screens.

Route: Create a GoRoute path /onboarding/:stepId.

WRITE THE CODE FOR: onboarding_state.dart, onboarding_notifier.dart, and the submitFinalAssessment method specifically.