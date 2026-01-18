// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OnboardingState _$OnboardingStateFromJson(Map<String, dynamic> json) {
  return _OnboardingState.fromJson(json);
}

/// @nodoc
mixin _$OnboardingState {
  // User Info
  String? get userId => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get token =>
      throw _privateConstructorUsedError; // Patient Info (Onboarding 1-2)
  String? get patientFullName => throw _privateConstructorUsedError;
  String? get patientPhone =>
      throw _privateConstructorUsedError; // ID returned after creating patient via caretaker API
  String? get createdPatientId =>
      throw _privateConstructorUsedError; // Assessment Data (Onboarding 3-16)
  String? get painLocation => throw _privateConstructorUsedError;
  int? get painScaleScore => throw _privateConstructorUsedError;
  String? get painCharacter => throw _privateConstructorUsedError;
  String? get painAssessment => throw _privateConstructorUsedError;
  String? get muscleTone => throw _privateConstructorUsedError;
  String? get muscleStrength => throw _privateConstructorUsedError;
  String? get balancedValuation => throw _privateConstructorUsedError;
  String? get fallRisk => throw _privateConstructorUsedError;
  String? get selfStandAbility => throw _privateConstructorUsedError;
  int? get tugTime => throw _privateConstructorUsedError;
  String? get previousIllness => throw _privateConstructorUsedError;
  String? get previousTreatments => throw _privateConstructorUsedError;
  String? get dailyActivities => throw _privateConstructorUsedError;
  String? get doctorRecommended => throw _privateConstructorUsedError;
  String? get doctorTreatmentPlan => throw _privateConstructorUsedError;
  String? get note =>
      throw _privateConstructorUsedError; // Physical Therapy Data
  String? get gender => throw _privateConstructorUsedError;
  String? get livingArrangement => throw _privateConstructorUsedError;
  double? get bmiScore => throw _privateConstructorUsedError;
  int? get mapScore => throw _privateConstructorUsedError;
  int? get rhrScore => throw _privateConstructorUsedError;
  int? get bloodGlucoseLevel => throw _privateConstructorUsedError;
  int? get adlScore => throw _privateConstructorUsedError;
  int? get iadlScore => throw _privateConstructorUsedError;
  String get diseaseType => throw _privateConstructorUsedError;
  String? get conditionNote => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  int get currentStep => throw _privateConstructorUsedError;

  /// Serializes this OnboardingState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingStateCopyWith<OnboardingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
    OnboardingState value,
    $Res Function(OnboardingState) then,
  ) = _$OnboardingStateCopyWithImpl<$Res, OnboardingState>;
  @useResult
  $Res call({
    String? userId,
    String? email,
    String? fullName,
    String? phone,
    String? token,
    String? patientFullName,
    String? patientPhone,
    String? createdPatientId,
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
    String? gender,
    String? livingArrangement,
    double? bmiScore,
    int? mapScore,
    int? rhrScore,
    int? bloodGlucoseLevel,
    int? adlScore,
    int? iadlScore,
    String diseaseType,
    String? conditionNote,
    bool isLoading,
    int currentStep,
  });
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res, $Val extends OnboardingState>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? email = freezed,
    Object? fullName = freezed,
    Object? phone = freezed,
    Object? token = freezed,
    Object? patientFullName = freezed,
    Object? patientPhone = freezed,
    Object? createdPatientId = freezed,
    Object? painLocation = freezed,
    Object? painScaleScore = freezed,
    Object? painCharacter = freezed,
    Object? painAssessment = freezed,
    Object? muscleTone = freezed,
    Object? muscleStrength = freezed,
    Object? balancedValuation = freezed,
    Object? fallRisk = freezed,
    Object? selfStandAbility = freezed,
    Object? tugTime = freezed,
    Object? previousIllness = freezed,
    Object? previousTreatments = freezed,
    Object? dailyActivities = freezed,
    Object? doctorRecommended = freezed,
    Object? doctorTreatmentPlan = freezed,
    Object? note = freezed,
    Object? gender = freezed,
    Object? livingArrangement = freezed,
    Object? bmiScore = freezed,
    Object? mapScore = freezed,
    Object? rhrScore = freezed,
    Object? bloodGlucoseLevel = freezed,
    Object? adlScore = freezed,
    Object? iadlScore = freezed,
    Object? diseaseType = null,
    Object? conditionNote = freezed,
    Object? isLoading = null,
    Object? currentStep = null,
  }) {
    return _then(
      _value.copyWith(
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            fullName: freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            token: freezed == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String?,
            patientFullName: freezed == patientFullName
                ? _value.patientFullName
                : patientFullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            patientPhone: freezed == patientPhone
                ? _value.patientPhone
                : patientPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdPatientId: freezed == createdPatientId
                ? _value.createdPatientId
                : createdPatientId // ignore: cast_nullable_to_non_nullable
                      as String?,
            painLocation: freezed == painLocation
                ? _value.painLocation
                : painLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            painScaleScore: freezed == painScaleScore
                ? _value.painScaleScore
                : painScaleScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            painCharacter: freezed == painCharacter
                ? _value.painCharacter
                : painCharacter // ignore: cast_nullable_to_non_nullable
                      as String?,
            painAssessment: freezed == painAssessment
                ? _value.painAssessment
                : painAssessment // ignore: cast_nullable_to_non_nullable
                      as String?,
            muscleTone: freezed == muscleTone
                ? _value.muscleTone
                : muscleTone // ignore: cast_nullable_to_non_nullable
                      as String?,
            muscleStrength: freezed == muscleStrength
                ? _value.muscleStrength
                : muscleStrength // ignore: cast_nullable_to_non_nullable
                      as String?,
            balancedValuation: freezed == balancedValuation
                ? _value.balancedValuation
                : balancedValuation // ignore: cast_nullable_to_non_nullable
                      as String?,
            fallRisk: freezed == fallRisk
                ? _value.fallRisk
                : fallRisk // ignore: cast_nullable_to_non_nullable
                      as String?,
            selfStandAbility: freezed == selfStandAbility
                ? _value.selfStandAbility
                : selfStandAbility // ignore: cast_nullable_to_non_nullable
                      as String?,
            tugTime: freezed == tugTime
                ? _value.tugTime
                : tugTime // ignore: cast_nullable_to_non_nullable
                      as int?,
            previousIllness: freezed == previousIllness
                ? _value.previousIllness
                : previousIllness // ignore: cast_nullable_to_non_nullable
                      as String?,
            previousTreatments: freezed == previousTreatments
                ? _value.previousTreatments
                : previousTreatments // ignore: cast_nullable_to_non_nullable
                      as String?,
            dailyActivities: freezed == dailyActivities
                ? _value.dailyActivities
                : dailyActivities // ignore: cast_nullable_to_non_nullable
                      as String?,
            doctorRecommended: freezed == doctorRecommended
                ? _value.doctorRecommended
                : doctorRecommended // ignore: cast_nullable_to_non_nullable
                      as String?,
            doctorTreatmentPlan: freezed == doctorTreatmentPlan
                ? _value.doctorTreatmentPlan
                : doctorTreatmentPlan // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            livingArrangement: freezed == livingArrangement
                ? _value.livingArrangement
                : livingArrangement // ignore: cast_nullable_to_non_nullable
                      as String?,
            bmiScore: freezed == bmiScore
                ? _value.bmiScore
                : bmiScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            mapScore: freezed == mapScore
                ? _value.mapScore
                : mapScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            rhrScore: freezed == rhrScore
                ? _value.rhrScore
                : rhrScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            bloodGlucoseLevel: freezed == bloodGlucoseLevel
                ? _value.bloodGlucoseLevel
                : bloodGlucoseLevel // ignore: cast_nullable_to_non_nullable
                      as int?,
            adlScore: freezed == adlScore
                ? _value.adlScore
                : adlScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            iadlScore: freezed == iadlScore
                ? _value.iadlScore
                : iadlScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            diseaseType: null == diseaseType
                ? _value.diseaseType
                : diseaseType // ignore: cast_nullable_to_non_nullable
                      as String,
            conditionNote: freezed == conditionNote
                ? _value.conditionNote
                : conditionNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentStep: null == currentStep
                ? _value.currentStep
                : currentStep // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnboardingStateImplCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory _$$OnboardingStateImplCopyWith(
    _$OnboardingStateImpl value,
    $Res Function(_$OnboardingStateImpl) then,
  ) = __$$OnboardingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? userId,
    String? email,
    String? fullName,
    String? phone,
    String? token,
    String? patientFullName,
    String? patientPhone,
    String? createdPatientId,
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
    String? gender,
    String? livingArrangement,
    double? bmiScore,
    int? mapScore,
    int? rhrScore,
    int? bloodGlucoseLevel,
    int? adlScore,
    int? iadlScore,
    String diseaseType,
    String? conditionNote,
    bool isLoading,
    int currentStep,
  });
}

/// @nodoc
class __$$OnboardingStateImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingStateImpl>
    implements _$$OnboardingStateImplCopyWith<$Res> {
  __$$OnboardingStateImplCopyWithImpl(
    _$OnboardingStateImpl _value,
    $Res Function(_$OnboardingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? email = freezed,
    Object? fullName = freezed,
    Object? phone = freezed,
    Object? token = freezed,
    Object? patientFullName = freezed,
    Object? patientPhone = freezed,
    Object? createdPatientId = freezed,
    Object? painLocation = freezed,
    Object? painScaleScore = freezed,
    Object? painCharacter = freezed,
    Object? painAssessment = freezed,
    Object? muscleTone = freezed,
    Object? muscleStrength = freezed,
    Object? balancedValuation = freezed,
    Object? fallRisk = freezed,
    Object? selfStandAbility = freezed,
    Object? tugTime = freezed,
    Object? previousIllness = freezed,
    Object? previousTreatments = freezed,
    Object? dailyActivities = freezed,
    Object? doctorRecommended = freezed,
    Object? doctorTreatmentPlan = freezed,
    Object? note = freezed,
    Object? gender = freezed,
    Object? livingArrangement = freezed,
    Object? bmiScore = freezed,
    Object? mapScore = freezed,
    Object? rhrScore = freezed,
    Object? bloodGlucoseLevel = freezed,
    Object? adlScore = freezed,
    Object? iadlScore = freezed,
    Object? diseaseType = null,
    Object? conditionNote = freezed,
    Object? isLoading = null,
    Object? currentStep = null,
  }) {
    return _then(
      _$OnboardingStateImpl(
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        token: freezed == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String?,
        patientFullName: freezed == patientFullName
            ? _value.patientFullName
            : patientFullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        patientPhone: freezed == patientPhone
            ? _value.patientPhone
            : patientPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdPatientId: freezed == createdPatientId
            ? _value.createdPatientId
            : createdPatientId // ignore: cast_nullable_to_non_nullable
                  as String?,
        painLocation: freezed == painLocation
            ? _value.painLocation
            : painLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        painScaleScore: freezed == painScaleScore
            ? _value.painScaleScore
            : painScaleScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        painCharacter: freezed == painCharacter
            ? _value.painCharacter
            : painCharacter // ignore: cast_nullable_to_non_nullable
                  as String?,
        painAssessment: freezed == painAssessment
            ? _value.painAssessment
            : painAssessment // ignore: cast_nullable_to_non_nullable
                  as String?,
        muscleTone: freezed == muscleTone
            ? _value.muscleTone
            : muscleTone // ignore: cast_nullable_to_non_nullable
                  as String?,
        muscleStrength: freezed == muscleStrength
            ? _value.muscleStrength
            : muscleStrength // ignore: cast_nullable_to_non_nullable
                  as String?,
        balancedValuation: freezed == balancedValuation
            ? _value.balancedValuation
            : balancedValuation // ignore: cast_nullable_to_non_nullable
                  as String?,
        fallRisk: freezed == fallRisk
            ? _value.fallRisk
            : fallRisk // ignore: cast_nullable_to_non_nullable
                  as String?,
        selfStandAbility: freezed == selfStandAbility
            ? _value.selfStandAbility
            : selfStandAbility // ignore: cast_nullable_to_non_nullable
                  as String?,
        tugTime: freezed == tugTime
            ? _value.tugTime
            : tugTime // ignore: cast_nullable_to_non_nullable
                  as int?,
        previousIllness: freezed == previousIllness
            ? _value.previousIllness
            : previousIllness // ignore: cast_nullable_to_non_nullable
                  as String?,
        previousTreatments: freezed == previousTreatments
            ? _value.previousTreatments
            : previousTreatments // ignore: cast_nullable_to_non_nullable
                  as String?,
        dailyActivities: freezed == dailyActivities
            ? _value.dailyActivities
            : dailyActivities // ignore: cast_nullable_to_non_nullable
                  as String?,
        doctorRecommended: freezed == doctorRecommended
            ? _value.doctorRecommended
            : doctorRecommended // ignore: cast_nullable_to_non_nullable
                  as String?,
        doctorTreatmentPlan: freezed == doctorTreatmentPlan
            ? _value.doctorTreatmentPlan
            : doctorTreatmentPlan // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        livingArrangement: freezed == livingArrangement
            ? _value.livingArrangement
            : livingArrangement // ignore: cast_nullable_to_non_nullable
                  as String?,
        bmiScore: freezed == bmiScore
            ? _value.bmiScore
            : bmiScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        mapScore: freezed == mapScore
            ? _value.mapScore
            : mapScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        rhrScore: freezed == rhrScore
            ? _value.rhrScore
            : rhrScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        bloodGlucoseLevel: freezed == bloodGlucoseLevel
            ? _value.bloodGlucoseLevel
            : bloodGlucoseLevel // ignore: cast_nullable_to_non_nullable
                  as int?,
        adlScore: freezed == adlScore
            ? _value.adlScore
            : adlScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        iadlScore: freezed == iadlScore
            ? _value.iadlScore
            : iadlScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        diseaseType: null == diseaseType
            ? _value.diseaseType
            : diseaseType // ignore: cast_nullable_to_non_nullable
                  as String,
        conditionNote: freezed == conditionNote
            ? _value.conditionNote
            : conditionNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentStep: null == currentStep
            ? _value.currentStep
            : currentStep // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OnboardingStateImpl implements _OnboardingState {
  const _$OnboardingStateImpl({
    this.userId,
    this.email,
    this.fullName,
    this.phone,
    this.token,
    this.patientFullName,
    this.patientPhone,
    this.createdPatientId,
    this.painLocation,
    this.painScaleScore,
    this.painCharacter,
    this.painAssessment,
    this.muscleTone,
    this.muscleStrength,
    this.balancedValuation,
    this.fallRisk,
    this.selfStandAbility,
    this.tugTime,
    this.previousIllness,
    this.previousTreatments,
    this.dailyActivities,
    this.doctorRecommended,
    this.doctorTreatmentPlan,
    this.note,
    this.gender,
    this.livingArrangement,
    this.bmiScore,
    this.mapScore,
    this.rhrScore,
    this.bloodGlucoseLevel,
    this.adlScore,
    this.iadlScore,
    this.diseaseType = 'PHYSICAL_THERAPY',
    this.conditionNote,
    this.isLoading = false,
    this.currentStep = 1,
  });

  factory _$OnboardingStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnboardingStateImplFromJson(json);

  // User Info
  @override
  final String? userId;
  @override
  final String? email;
  @override
  final String? fullName;
  @override
  final String? phone;
  @override
  final String? token;
  // Patient Info (Onboarding 1-2)
  @override
  final String? patientFullName;
  @override
  final String? patientPhone;
  // ID returned after creating patient via caretaker API
  @override
  final String? createdPatientId;
  // Assessment Data (Onboarding 3-16)
  @override
  final String? painLocation;
  @override
  final int? painScaleScore;
  @override
  final String? painCharacter;
  @override
  final String? painAssessment;
  @override
  final String? muscleTone;
  @override
  final String? muscleStrength;
  @override
  final String? balancedValuation;
  @override
  final String? fallRisk;
  @override
  final String? selfStandAbility;
  @override
  final int? tugTime;
  @override
  final String? previousIllness;
  @override
  final String? previousTreatments;
  @override
  final String? dailyActivities;
  @override
  final String? doctorRecommended;
  @override
  final String? doctorTreatmentPlan;
  @override
  final String? note;
  // Physical Therapy Data
  @override
  final String? gender;
  @override
  final String? livingArrangement;
  @override
  final double? bmiScore;
  @override
  final int? mapScore;
  @override
  final int? rhrScore;
  @override
  final int? bloodGlucoseLevel;
  @override
  final int? adlScore;
  @override
  final int? iadlScore;
  @override
  @JsonKey()
  final String diseaseType;
  @override
  final String? conditionNote;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final int currentStep;

  @override
  String toString() {
    return 'OnboardingState(userId: $userId, email: $email, fullName: $fullName, phone: $phone, token: $token, patientFullName: $patientFullName, patientPhone: $patientPhone, createdPatientId: $createdPatientId, painLocation: $painLocation, painScaleScore: $painScaleScore, painCharacter: $painCharacter, painAssessment: $painAssessment, muscleTone: $muscleTone, muscleStrength: $muscleStrength, balancedValuation: $balancedValuation, fallRisk: $fallRisk, selfStandAbility: $selfStandAbility, tugTime: $tugTime, previousIllness: $previousIllness, previousTreatments: $previousTreatments, dailyActivities: $dailyActivities, doctorRecommended: $doctorRecommended, doctorTreatmentPlan: $doctorTreatmentPlan, note: $note, gender: $gender, livingArrangement: $livingArrangement, bmiScore: $bmiScore, mapScore: $mapScore, rhrScore: $rhrScore, bloodGlucoseLevel: $bloodGlucoseLevel, adlScore: $adlScore, iadlScore: $iadlScore, diseaseType: $diseaseType, conditionNote: $conditionNote, isLoading: $isLoading, currentStep: $currentStep)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStateImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.patientFullName, patientFullName) ||
                other.patientFullName == patientFullName) &&
            (identical(other.patientPhone, patientPhone) ||
                other.patientPhone == patientPhone) &&
            (identical(other.createdPatientId, createdPatientId) ||
                other.createdPatientId == createdPatientId) &&
            (identical(other.painLocation, painLocation) ||
                other.painLocation == painLocation) &&
            (identical(other.painScaleScore, painScaleScore) ||
                other.painScaleScore == painScaleScore) &&
            (identical(other.painCharacter, painCharacter) ||
                other.painCharacter == painCharacter) &&
            (identical(other.painAssessment, painAssessment) ||
                other.painAssessment == painAssessment) &&
            (identical(other.muscleTone, muscleTone) ||
                other.muscleTone == muscleTone) &&
            (identical(other.muscleStrength, muscleStrength) ||
                other.muscleStrength == muscleStrength) &&
            (identical(other.balancedValuation, balancedValuation) ||
                other.balancedValuation == balancedValuation) &&
            (identical(other.fallRisk, fallRisk) ||
                other.fallRisk == fallRisk) &&
            (identical(other.selfStandAbility, selfStandAbility) ||
                other.selfStandAbility == selfStandAbility) &&
            (identical(other.tugTime, tugTime) || other.tugTime == tugTime) &&
            (identical(other.previousIllness, previousIllness) ||
                other.previousIllness == previousIllness) &&
            (identical(other.previousTreatments, previousTreatments) ||
                other.previousTreatments == previousTreatments) &&
            (identical(other.dailyActivities, dailyActivities) ||
                other.dailyActivities == dailyActivities) &&
            (identical(other.doctorRecommended, doctorRecommended) ||
                other.doctorRecommended == doctorRecommended) &&
            (identical(other.doctorTreatmentPlan, doctorTreatmentPlan) ||
                other.doctorTreatmentPlan == doctorTreatmentPlan) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.livingArrangement, livingArrangement) ||
                other.livingArrangement == livingArrangement) &&
            (identical(other.bmiScore, bmiScore) ||
                other.bmiScore == bmiScore) &&
            (identical(other.mapScore, mapScore) ||
                other.mapScore == mapScore) &&
            (identical(other.rhrScore, rhrScore) ||
                other.rhrScore == rhrScore) &&
            (identical(other.bloodGlucoseLevel, bloodGlucoseLevel) ||
                other.bloodGlucoseLevel == bloodGlucoseLevel) &&
            (identical(other.adlScore, adlScore) ||
                other.adlScore == adlScore) &&
            (identical(other.iadlScore, iadlScore) ||
                other.iadlScore == iadlScore) &&
            (identical(other.diseaseType, diseaseType) ||
                other.diseaseType == diseaseType) &&
            (identical(other.conditionNote, conditionNote) ||
                other.conditionNote == conditionNote) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    userId,
    email,
    fullName,
    phone,
    token,
    patientFullName,
    patientPhone,
    createdPatientId,
    painLocation,
    painScaleScore,
    painCharacter,
    painAssessment,
    muscleTone,
    muscleStrength,
    balancedValuation,
    fallRisk,
    selfStandAbility,
    tugTime,
    previousIllness,
    previousTreatments,
    dailyActivities,
    doctorRecommended,
    doctorTreatmentPlan,
    note,
    gender,
    livingArrangement,
    bmiScore,
    mapScore,
    rhrScore,
    bloodGlucoseLevel,
    adlScore,
    iadlScore,
    diseaseType,
    conditionNote,
    isLoading,
    currentStep,
  ]);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      __$$OnboardingStateImplCopyWithImpl<_$OnboardingStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OnboardingStateImplToJson(this);
  }
}

abstract class _OnboardingState implements OnboardingState {
  const factory _OnboardingState({
    final String? userId,
    final String? email,
    final String? fullName,
    final String? phone,
    final String? token,
    final String? patientFullName,
    final String? patientPhone,
    final String? createdPatientId,
    final String? painLocation,
    final int? painScaleScore,
    final String? painCharacter,
    final String? painAssessment,
    final String? muscleTone,
    final String? muscleStrength,
    final String? balancedValuation,
    final String? fallRisk,
    final String? selfStandAbility,
    final int? tugTime,
    final String? previousIllness,
    final String? previousTreatments,
    final String? dailyActivities,
    final String? doctorRecommended,
    final String? doctorTreatmentPlan,
    final String? note,
    final String? gender,
    final String? livingArrangement,
    final double? bmiScore,
    final int? mapScore,
    final int? rhrScore,
    final int? bloodGlucoseLevel,
    final int? adlScore,
    final int? iadlScore,
    final String diseaseType,
    final String? conditionNote,
    final bool isLoading,
    final int currentStep,
  }) = _$OnboardingStateImpl;

  factory _OnboardingState.fromJson(Map<String, dynamic> json) =
      _$OnboardingStateImpl.fromJson;

  // User Info
  @override
  String? get userId;
  @override
  String? get email;
  @override
  String? get fullName;
  @override
  String? get phone;
  @override
  String? get token; // Patient Info (Onboarding 1-2)
  @override
  String? get patientFullName;
  @override
  String? get patientPhone; // ID returned after creating patient via caretaker API
  @override
  String? get createdPatientId; // Assessment Data (Onboarding 3-16)
  @override
  String? get painLocation;
  @override
  int? get painScaleScore;
  @override
  String? get painCharacter;
  @override
  String? get painAssessment;
  @override
  String? get muscleTone;
  @override
  String? get muscleStrength;
  @override
  String? get balancedValuation;
  @override
  String? get fallRisk;
  @override
  String? get selfStandAbility;
  @override
  int? get tugTime;
  @override
  String? get previousIllness;
  @override
  String? get previousTreatments;
  @override
  String? get dailyActivities;
  @override
  String? get doctorRecommended;
  @override
  String? get doctorTreatmentPlan;
  @override
  String? get note; // Physical Therapy Data
  @override
  String? get gender;
  @override
  String? get livingArrangement;
  @override
  double? get bmiScore;
  @override
  int? get mapScore;
  @override
  int? get rhrScore;
  @override
  int? get bloodGlucoseLevel;
  @override
  int? get adlScore;
  @override
  int? get iadlScore;
  @override
  String get diseaseType;
  @override
  String? get conditionNote;
  @override
  bool get isLoading;
  @override
  int get currentStep;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
