// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_scan_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MedicationScanResponse _$MedicationScanResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MedicationScanResponse.fromJson(json);
}

/// @nodoc
mixin _$MedicationScanResponse {
  String get code => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  MedicationScanData? get data => throw _privateConstructorUsedError;

  /// Serializes this MedicationScanResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicationScanResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicationScanResponseCopyWith<MedicationScanResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationScanResponseCopyWith<$Res> {
  factory $MedicationScanResponseCopyWith(
    MedicationScanResponse value,
    $Res Function(MedicationScanResponse) then,
  ) = _$MedicationScanResponseCopyWithImpl<$Res, MedicationScanResponse>;
  @useResult
  $Res call({String code, String message, MedicationScanData? data});

  $MedicationScanDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$MedicationScanResponseCopyWithImpl<
  $Res,
  $Val extends MedicationScanResponse
>
    implements $MedicationScanResponseCopyWith<$Res> {
  _$MedicationScanResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicationScanResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? data = freezed,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as MedicationScanData?,
          )
          as $Val,
    );
  }

  /// Create a copy of MedicationScanResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicationScanDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $MedicationScanDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MedicationScanResponseImplCopyWith<$Res>
    implements $MedicationScanResponseCopyWith<$Res> {
  factory _$$MedicationScanResponseImplCopyWith(
    _$MedicationScanResponseImpl value,
    $Res Function(_$MedicationScanResponseImpl) then,
  ) = __$$MedicationScanResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String message, MedicationScanData? data});

  @override
  $MedicationScanDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$MedicationScanResponseImplCopyWithImpl<$Res>
    extends
        _$MedicationScanResponseCopyWithImpl<$Res, _$MedicationScanResponseImpl>
    implements _$$MedicationScanResponseImplCopyWith<$Res> {
  __$$MedicationScanResponseImplCopyWithImpl(
    _$MedicationScanResponseImpl _value,
    $Res Function(_$MedicationScanResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicationScanResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? data = freezed,
  }) {
    return _then(
      _$MedicationScanResponseImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as MedicationScanData?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationScanResponseImpl implements _MedicationScanResponse {
  const _$MedicationScanResponseImpl({
    required this.code,
    required this.message,
    required this.data,
  });

  factory _$MedicationScanResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationScanResponseImplFromJson(json);

  @override
  final String code;
  @override
  final String message;
  @override
  final MedicationScanData? data;

  @override
  String toString() {
    return 'MedicationScanResponse(code: $code, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationScanResponseImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, message, data);

  /// Create a copy of MedicationScanResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationScanResponseImplCopyWith<_$MedicationScanResponseImpl>
  get copyWith =>
      __$$MedicationScanResponseImplCopyWithImpl<_$MedicationScanResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationScanResponseImplToJson(this);
  }
}

abstract class _MedicationScanResponse implements MedicationScanResponse {
  const factory _MedicationScanResponse({
    required final String code,
    required final String message,
    required final MedicationScanData? data,
  }) = _$MedicationScanResponseImpl;

  factory _MedicationScanResponse.fromJson(Map<String, dynamic> json) =
      _$MedicationScanResponseImpl.fromJson;

  @override
  String get code;
  @override
  String get message;
  @override
  MedicationScanData? get data;

  /// Create a copy of MedicationScanResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicationScanResponseImplCopyWith<_$MedicationScanResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MedicationScanData _$MedicationScanDataFromJson(Map<String, dynamic> json) {
  return _MedicationScanData.fromJson(json);
}

/// @nodoc
mixin _$MedicationScanData {
  String get message => throw _privateConstructorUsedError;
  MedicationDto? get medication => throw _privateConstructorUsedError;
  String? get agentError => throw _privateConstructorUsedError;

  /// Serializes this MedicationScanData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicationScanData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicationScanDataCopyWith<MedicationScanData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationScanDataCopyWith<$Res> {
  factory $MedicationScanDataCopyWith(
    MedicationScanData value,
    $Res Function(MedicationScanData) then,
  ) = _$MedicationScanDataCopyWithImpl<$Res, MedicationScanData>;
  @useResult
  $Res call({String message, MedicationDto? medication, String? agentError});

  $MedicationDtoCopyWith<$Res>? get medication;
}

/// @nodoc
class _$MedicationScanDataCopyWithImpl<$Res, $Val extends MedicationScanData>
    implements $MedicationScanDataCopyWith<$Res> {
  _$MedicationScanDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicationScanData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? medication = freezed,
    Object? agentError = freezed,
  }) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            medication: freezed == medication
                ? _value.medication
                : medication // ignore: cast_nullable_to_non_nullable
                      as MedicationDto?,
            agentError: freezed == agentError
                ? _value.agentError
                : agentError // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of MedicationScanData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicationDtoCopyWith<$Res>? get medication {
    if (_value.medication == null) {
      return null;
    }

    return $MedicationDtoCopyWith<$Res>(_value.medication!, (value) {
      return _then(_value.copyWith(medication: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MedicationScanDataImplCopyWith<$Res>
    implements $MedicationScanDataCopyWith<$Res> {
  factory _$$MedicationScanDataImplCopyWith(
    _$MedicationScanDataImpl value,
    $Res Function(_$MedicationScanDataImpl) then,
  ) = __$$MedicationScanDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, MedicationDto? medication, String? agentError});

  @override
  $MedicationDtoCopyWith<$Res>? get medication;
}

/// @nodoc
class __$$MedicationScanDataImplCopyWithImpl<$Res>
    extends _$MedicationScanDataCopyWithImpl<$Res, _$MedicationScanDataImpl>
    implements _$$MedicationScanDataImplCopyWith<$Res> {
  __$$MedicationScanDataImplCopyWithImpl(
    _$MedicationScanDataImpl _value,
    $Res Function(_$MedicationScanDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicationScanData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? medication = freezed,
    Object? agentError = freezed,
  }) {
    return _then(
      _$MedicationScanDataImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        medication: freezed == medication
            ? _value.medication
            : medication // ignore: cast_nullable_to_non_nullable
                  as MedicationDto?,
        agentError: freezed == agentError
            ? _value.agentError
            : agentError // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationScanDataImpl implements _MedicationScanData {
  const _$MedicationScanDataImpl({
    required this.message,
    this.medication,
    this.agentError,
  });

  factory _$MedicationScanDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationScanDataImplFromJson(json);

  @override
  final String message;
  @override
  final MedicationDto? medication;
  @override
  final String? agentError;

  @override
  String toString() {
    return 'MedicationScanData(message: $message, medication: $medication, agentError: $agentError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationScanDataImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.medication, medication) ||
                other.medication == medication) &&
            (identical(other.agentError, agentError) ||
                other.agentError == agentError));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, medication, agentError);

  /// Create a copy of MedicationScanData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationScanDataImplCopyWith<_$MedicationScanDataImpl> get copyWith =>
      __$$MedicationScanDataImplCopyWithImpl<_$MedicationScanDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationScanDataImplToJson(this);
  }
}

abstract class _MedicationScanData implements MedicationScanData {
  const factory _MedicationScanData({
    required final String message,
    final MedicationDto? medication,
    final String? agentError,
  }) = _$MedicationScanDataImpl;

  factory _MedicationScanData.fromJson(Map<String, dynamic> json) =
      _$MedicationScanDataImpl.fromJson;

  @override
  String get message;
  @override
  MedicationDto? get medication;
  @override
  String? get agentError;

  /// Create a copy of MedicationScanData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicationScanDataImplCopyWith<_$MedicationScanDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MedicationDto _$MedicationDtoFromJson(Map<String, dynamic> json) {
  return _MedicationDto.fromJson(json);
}

/// @nodoc
mixin _$MedicationDto {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get dosage => throw _privateConstructorUsedError;
  int get frequencyPerDay => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;
  String get medicationId => throw _privateConstructorUsedError;

  /// Serializes this MedicationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicationDtoCopyWith<MedicationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationDtoCopyWith<$Res> {
  factory $MedicationDtoCopyWith(
    MedicationDto value,
    $Res Function(MedicationDto) then,
  ) = _$MedicationDtoCopyWithImpl<$Res, MedicationDto>;
  @useResult
  $Res call({
    String name,
    String description,
    String dosage,
    int frequencyPerDay,
    String notes,
    String imagePath,
    String medicationId,
  });
}

/// @nodoc
class _$MedicationDtoCopyWithImpl<$Res, $Val extends MedicationDto>
    implements $MedicationDtoCopyWith<$Res> {
  _$MedicationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? dosage = null,
    Object? frequencyPerDay = null,
    Object? notes = null,
    Object? imagePath = null,
    Object? medicationId = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            dosage: null == dosage
                ? _value.dosage
                : dosage // ignore: cast_nullable_to_non_nullable
                      as String,
            frequencyPerDay: null == frequencyPerDay
                ? _value.frequencyPerDay
                : frequencyPerDay // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            imagePath: null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            medicationId: null == medicationId
                ? _value.medicationId
                : medicationId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicationDtoImplCopyWith<$Res>
    implements $MedicationDtoCopyWith<$Res> {
  factory _$$MedicationDtoImplCopyWith(
    _$MedicationDtoImpl value,
    $Res Function(_$MedicationDtoImpl) then,
  ) = __$$MedicationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String description,
    String dosage,
    int frequencyPerDay,
    String notes,
    String imagePath,
    String medicationId,
  });
}

/// @nodoc
class __$$MedicationDtoImplCopyWithImpl<$Res>
    extends _$MedicationDtoCopyWithImpl<$Res, _$MedicationDtoImpl>
    implements _$$MedicationDtoImplCopyWith<$Res> {
  __$$MedicationDtoImplCopyWithImpl(
    _$MedicationDtoImpl _value,
    $Res Function(_$MedicationDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? dosage = null,
    Object? frequencyPerDay = null,
    Object? notes = null,
    Object? imagePath = null,
    Object? medicationId = null,
  }) {
    return _then(
      _$MedicationDtoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        dosage: null == dosage
            ? _value.dosage
            : dosage // ignore: cast_nullable_to_non_nullable
                  as String,
        frequencyPerDay: null == frequencyPerDay
            ? _value.frequencyPerDay
            : frequencyPerDay // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        imagePath: null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        medicationId: null == medicationId
            ? _value.medicationId
            : medicationId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationDtoImpl implements _MedicationDto {
  const _$MedicationDtoImpl({
    required this.name,
    required this.description,
    required this.dosage,
    required this.frequencyPerDay,
    required this.notes,
    required this.imagePath,
    required this.medicationId,
  });

  factory _$MedicationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationDtoImplFromJson(json);

  @override
  final String name;
  @override
  final String description;
  @override
  final String dosage;
  @override
  final int frequencyPerDay;
  @override
  final String notes;
  @override
  final String imagePath;
  @override
  final String medicationId;

  @override
  String toString() {
    return 'MedicationDto(name: $name, description: $description, dosage: $dosage, frequencyPerDay: $frequencyPerDay, notes: $notes, imagePath: $imagePath, medicationId: $medicationId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.frequencyPerDay, frequencyPerDay) ||
                other.frequencyPerDay == frequencyPerDay) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.medicationId, medicationId) ||
                other.medicationId == medicationId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    dosage,
    frequencyPerDay,
    notes,
    imagePath,
    medicationId,
  );

  /// Create a copy of MedicationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationDtoImplCopyWith<_$MedicationDtoImpl> get copyWith =>
      __$$MedicationDtoImplCopyWithImpl<_$MedicationDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationDtoImplToJson(this);
  }
}

abstract class _MedicationDto implements MedicationDto {
  const factory _MedicationDto({
    required final String name,
    required final String description,
    required final String dosage,
    required final int frequencyPerDay,
    required final String notes,
    required final String imagePath,
    required final String medicationId,
  }) = _$MedicationDtoImpl;

  factory _MedicationDto.fromJson(Map<String, dynamic> json) =
      _$MedicationDtoImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  String get dosage;
  @override
  int get frequencyPerDay;
  @override
  String get notes;
  @override
  String get imagePath;
  @override
  String get medicationId;

  /// Create a copy of MedicationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicationDtoImplCopyWith<_$MedicationDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
