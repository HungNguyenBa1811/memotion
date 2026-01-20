// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UpcomingMedication _$UpcomingMedicationFromJson(Map<String, dynamic> json) {
  return _UpcomingMedication.fromJson(json);
}

/// @nodoc
mixin _$UpcomingMedication {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get dosage => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this UpcomingMedication to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpcomingMedication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpcomingMedicationCopyWith<UpcomingMedication> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpcomingMedicationCopyWith<$Res> {
  factory $UpcomingMedicationCopyWith(
    UpcomingMedication value,
    $Res Function(UpcomingMedication) then,
  ) = _$UpcomingMedicationCopyWithImpl<$Res, UpcomingMedication>;
  @useResult
  $Res call({
    String id,
    String name,
    String dosage,
    String time,
    String? imageUrl,
  });
}

/// @nodoc
class _$UpcomingMedicationCopyWithImpl<$Res, $Val extends UpcomingMedication>
    implements $UpcomingMedicationCopyWith<$Res> {
  _$UpcomingMedicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpcomingMedication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dosage = null,
    Object? time = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            dosage: null == dosage
                ? _value.dosage
                : dosage // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpcomingMedicationImplCopyWith<$Res>
    implements $UpcomingMedicationCopyWith<$Res> {
  factory _$$UpcomingMedicationImplCopyWith(
    _$UpcomingMedicationImpl value,
    $Res Function(_$UpcomingMedicationImpl) then,
  ) = __$$UpcomingMedicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String dosage,
    String time,
    String? imageUrl,
  });
}

/// @nodoc
class __$$UpcomingMedicationImplCopyWithImpl<$Res>
    extends _$UpcomingMedicationCopyWithImpl<$Res, _$UpcomingMedicationImpl>
    implements _$$UpcomingMedicationImplCopyWith<$Res> {
  __$$UpcomingMedicationImplCopyWithImpl(
    _$UpcomingMedicationImpl _value,
    $Res Function(_$UpcomingMedicationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpcomingMedication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dosage = null,
    Object? time = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$UpcomingMedicationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        dosage: null == dosage
            ? _value.dosage
            : dosage // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpcomingMedicationImpl implements _UpcomingMedication {
  const _$UpcomingMedicationImpl({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.imageUrl,
  });

  factory _$UpcomingMedicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpcomingMedicationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String dosage;
  @override
  final String time;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'UpcomingMedication(id: $id, name: $name, dosage: $dosage, time: $time, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpcomingMedicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, dosage, time, imageUrl);

  /// Create a copy of UpcomingMedication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpcomingMedicationImplCopyWith<_$UpcomingMedicationImpl> get copyWith =>
      __$$UpcomingMedicationImplCopyWithImpl<_$UpcomingMedicationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpcomingMedicationImplToJson(this);
  }
}

abstract class _UpcomingMedication implements UpcomingMedication {
  const factory _UpcomingMedication({
    required final String id,
    required final String name,
    required final String dosage,
    required final String time,
    final String? imageUrl,
  }) = _$UpcomingMedicationImpl;

  factory _UpcomingMedication.fromJson(Map<String, dynamic> json) =
      _$UpcomingMedicationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get dosage;
  @override
  String get time;
  @override
  String? get imageUrl;

  /// Create a copy of UpcomingMedication
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpcomingMedicationImplCopyWith<_$UpcomingMedicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthVitals _$HealthVitalsFromJson(Map<String, dynamic> json) {
  return _HealthVitals.fromJson(json);
}

/// @nodoc
mixin _$HealthVitals {
  String get heartRate => throw _privateConstructorUsedError;
  String get bloodPressure => throw _privateConstructorUsedError;
  String get steps => throw _privateConstructorUsedError;
  String? get temperature => throw _privateConstructorUsedError;
  String? get bloodSugar => throw _privateConstructorUsedError;

  /// Serializes this HealthVitals to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthVitals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthVitalsCopyWith<HealthVitals> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthVitalsCopyWith<$Res> {
  factory $HealthVitalsCopyWith(
    HealthVitals value,
    $Res Function(HealthVitals) then,
  ) = _$HealthVitalsCopyWithImpl<$Res, HealthVitals>;
  @useResult
  $Res call({
    String heartRate,
    String bloodPressure,
    String steps,
    String? temperature,
    String? bloodSugar,
  });
}

/// @nodoc
class _$HealthVitalsCopyWithImpl<$Res, $Val extends HealthVitals>
    implements $HealthVitalsCopyWith<$Res> {
  _$HealthVitalsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthVitals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heartRate = null,
    Object? bloodPressure = null,
    Object? steps = null,
    Object? temperature = freezed,
    Object? bloodSugar = freezed,
  }) {
    return _then(
      _value.copyWith(
            heartRate: null == heartRate
                ? _value.heartRate
                : heartRate // ignore: cast_nullable_to_non_nullable
                      as String,
            bloodPressure: null == bloodPressure
                ? _value.bloodPressure
                : bloodPressure // ignore: cast_nullable_to_non_nullable
                      as String,
            steps: null == steps
                ? _value.steps
                : steps // ignore: cast_nullable_to_non_nullable
                      as String,
            temperature: freezed == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as String?,
            bloodSugar: freezed == bloodSugar
                ? _value.bloodSugar
                : bloodSugar // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HealthVitalsImplCopyWith<$Res>
    implements $HealthVitalsCopyWith<$Res> {
  factory _$$HealthVitalsImplCopyWith(
    _$HealthVitalsImpl value,
    $Res Function(_$HealthVitalsImpl) then,
  ) = __$$HealthVitalsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String heartRate,
    String bloodPressure,
    String steps,
    String? temperature,
    String? bloodSugar,
  });
}

/// @nodoc
class __$$HealthVitalsImplCopyWithImpl<$Res>
    extends _$HealthVitalsCopyWithImpl<$Res, _$HealthVitalsImpl>
    implements _$$HealthVitalsImplCopyWith<$Res> {
  __$$HealthVitalsImplCopyWithImpl(
    _$HealthVitalsImpl _value,
    $Res Function(_$HealthVitalsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HealthVitals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heartRate = null,
    Object? bloodPressure = null,
    Object? steps = null,
    Object? temperature = freezed,
    Object? bloodSugar = freezed,
  }) {
    return _then(
      _$HealthVitalsImpl(
        heartRate: null == heartRate
            ? _value.heartRate
            : heartRate // ignore: cast_nullable_to_non_nullable
                  as String,
        bloodPressure: null == bloodPressure
            ? _value.bloodPressure
            : bloodPressure // ignore: cast_nullable_to_non_nullable
                  as String,
        steps: null == steps
            ? _value.steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as String,
        temperature: freezed == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as String?,
        bloodSugar: freezed == bloodSugar
            ? _value.bloodSugar
            : bloodSugar // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthVitalsImpl implements _HealthVitals {
  const _$HealthVitalsImpl({
    required this.heartRate,
    required this.bloodPressure,
    required this.steps,
    this.temperature,
    this.bloodSugar,
  });

  factory _$HealthVitalsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthVitalsImplFromJson(json);

  @override
  final String heartRate;
  @override
  final String bloodPressure;
  @override
  final String steps;
  @override
  final String? temperature;
  @override
  final String? bloodSugar;

  @override
  String toString() {
    return 'HealthVitals(heartRate: $heartRate, bloodPressure: $bloodPressure, steps: $steps, temperature: $temperature, bloodSugar: $bloodSugar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthVitalsImpl &&
            (identical(other.heartRate, heartRate) ||
                other.heartRate == heartRate) &&
            (identical(other.bloodPressure, bloodPressure) ||
                other.bloodPressure == bloodPressure) &&
            (identical(other.steps, steps) || other.steps == steps) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.bloodSugar, bloodSugar) ||
                other.bloodSugar == bloodSugar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    heartRate,
    bloodPressure,
    steps,
    temperature,
    bloodSugar,
  );

  /// Create a copy of HealthVitals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthVitalsImplCopyWith<_$HealthVitalsImpl> get copyWith =>
      __$$HealthVitalsImplCopyWithImpl<_$HealthVitalsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthVitalsImplToJson(this);
  }
}

abstract class _HealthVitals implements HealthVitals {
  const factory _HealthVitals({
    required final String heartRate,
    required final String bloodPressure,
    required final String steps,
    final String? temperature,
    final String? bloodSugar,
  }) = _$HealthVitalsImpl;

  factory _HealthVitals.fromJson(Map<String, dynamic> json) =
      _$HealthVitalsImpl.fromJson;

  @override
  String get heartRate;
  @override
  String get bloodPressure;
  @override
  String get steps;
  @override
  String? get temperature;
  @override
  String? get bloodSugar;

  /// Create a copy of HealthVitals
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthVitalsImplCopyWith<_$HealthVitalsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomeDashboardData _$HomeDashboardDataFromJson(Map<String, dynamic> json) {
  return _HomeDashboardData.fromJson(json);
}

/// @nodoc
mixin _$HomeDashboardData {
  String get userName => throw _privateConstructorUsedError;
  String get greeting => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  UpcomingMedication? get upcomingMedication =>
      throw _privateConstructorUsedError;
  HealthVitals? get healthVitals => throw _privateConstructorUsedError;

  /// Serializes this HomeDashboardData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeDashboardDataCopyWith<HomeDashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeDashboardDataCopyWith<$Res> {
  factory $HomeDashboardDataCopyWith(
    HomeDashboardData value,
    $Res Function(HomeDashboardData) then,
  ) = _$HomeDashboardDataCopyWithImpl<$Res, HomeDashboardData>;
  @useResult
  $Res call({
    String userName,
    String greeting,
    String? avatarUrl,
    UpcomingMedication? upcomingMedication,
    HealthVitals? healthVitals,
  });

  $UpcomingMedicationCopyWith<$Res>? get upcomingMedication;
  $HealthVitalsCopyWith<$Res>? get healthVitals;
}

/// @nodoc
class _$HomeDashboardDataCopyWithImpl<$Res, $Val extends HomeDashboardData>
    implements $HomeDashboardDataCopyWith<$Res> {
  _$HomeDashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userName = null,
    Object? greeting = null,
    Object? avatarUrl = freezed,
    Object? upcomingMedication = freezed,
    Object? healthVitals = freezed,
  }) {
    return _then(
      _value.copyWith(
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            greeting: null == greeting
                ? _value.greeting
                : greeting // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            upcomingMedication: freezed == upcomingMedication
                ? _value.upcomingMedication
                : upcomingMedication // ignore: cast_nullable_to_non_nullable
                      as UpcomingMedication?,
            healthVitals: freezed == healthVitals
                ? _value.healthVitals
                : healthVitals // ignore: cast_nullable_to_non_nullable
                      as HealthVitals?,
          )
          as $Val,
    );
  }

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UpcomingMedicationCopyWith<$Res>? get upcomingMedication {
    if (_value.upcomingMedication == null) {
      return null;
    }

    return $UpcomingMedicationCopyWith<$Res>(_value.upcomingMedication!, (
      value,
    ) {
      return _then(_value.copyWith(upcomingMedication: value) as $Val);
    });
  }

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HealthVitalsCopyWith<$Res>? get healthVitals {
    if (_value.healthVitals == null) {
      return null;
    }

    return $HealthVitalsCopyWith<$Res>(_value.healthVitals!, (value) {
      return _then(_value.copyWith(healthVitals: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeDashboardDataImplCopyWith<$Res>
    implements $HomeDashboardDataCopyWith<$Res> {
  factory _$$HomeDashboardDataImplCopyWith(
    _$HomeDashboardDataImpl value,
    $Res Function(_$HomeDashboardDataImpl) then,
  ) = __$$HomeDashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userName,
    String greeting,
    String? avatarUrl,
    UpcomingMedication? upcomingMedication,
    HealthVitals? healthVitals,
  });

  @override
  $UpcomingMedicationCopyWith<$Res>? get upcomingMedication;
  @override
  $HealthVitalsCopyWith<$Res>? get healthVitals;
}

/// @nodoc
class __$$HomeDashboardDataImplCopyWithImpl<$Res>
    extends _$HomeDashboardDataCopyWithImpl<$Res, _$HomeDashboardDataImpl>
    implements _$$HomeDashboardDataImplCopyWith<$Res> {
  __$$HomeDashboardDataImplCopyWithImpl(
    _$HomeDashboardDataImpl _value,
    $Res Function(_$HomeDashboardDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userName = null,
    Object? greeting = null,
    Object? avatarUrl = freezed,
    Object? upcomingMedication = freezed,
    Object? healthVitals = freezed,
  }) {
    return _then(
      _$HomeDashboardDataImpl(
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        greeting: null == greeting
            ? _value.greeting
            : greeting // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        upcomingMedication: freezed == upcomingMedication
            ? _value.upcomingMedication
            : upcomingMedication // ignore: cast_nullable_to_non_nullable
                  as UpcomingMedication?,
        healthVitals: freezed == healthVitals
            ? _value.healthVitals
            : healthVitals // ignore: cast_nullable_to_non_nullable
                  as HealthVitals?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeDashboardDataImpl implements _HomeDashboardData {
  const _$HomeDashboardDataImpl({
    required this.userName,
    required this.greeting,
    this.avatarUrl,
    this.upcomingMedication,
    this.healthVitals,
  });

  factory _$HomeDashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeDashboardDataImplFromJson(json);

  @override
  final String userName;
  @override
  final String greeting;
  @override
  final String? avatarUrl;
  @override
  final UpcomingMedication? upcomingMedication;
  @override
  final HealthVitals? healthVitals;

  @override
  String toString() {
    return 'HomeDashboardData(userName: $userName, greeting: $greeting, avatarUrl: $avatarUrl, upcomingMedication: $upcomingMedication, healthVitals: $healthVitals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeDashboardDataImpl &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.greeting, greeting) ||
                other.greeting == greeting) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.upcomingMedication, upcomingMedication) ||
                other.upcomingMedication == upcomingMedication) &&
            (identical(other.healthVitals, healthVitals) ||
                other.healthVitals == healthVitals));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userName,
    greeting,
    avatarUrl,
    upcomingMedication,
    healthVitals,
  );

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeDashboardDataImplCopyWith<_$HomeDashboardDataImpl> get copyWith =>
      __$$HomeDashboardDataImplCopyWithImpl<_$HomeDashboardDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeDashboardDataImplToJson(this);
  }
}

abstract class _HomeDashboardData implements HomeDashboardData {
  const factory _HomeDashboardData({
    required final String userName,
    required final String greeting,
    final String? avatarUrl,
    final UpcomingMedication? upcomingMedication,
    final HealthVitals? healthVitals,
  }) = _$HomeDashboardDataImpl;

  factory _HomeDashboardData.fromJson(Map<String, dynamic> json) =
      _$HomeDashboardDataImpl.fromJson;

  @override
  String get userName;
  @override
  String get greeting;
  @override
  String? get avatarUrl;
  @override
  UpcomingMedication? get upcomingMedication;
  @override
  HealthVitals? get healthVitals;

  /// Create a copy of HomeDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeDashboardDataImplCopyWith<_$HomeDashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
