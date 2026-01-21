// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_medication_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ScanMedicationState {
  bool get isScanning => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;
  MedicationDto? get scannedMedication => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;

  /// Create a copy of ScanMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScanMedicationStateCopyWith<ScanMedicationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanMedicationStateCopyWith<$Res> {
  factory $ScanMedicationStateCopyWith(
    ScanMedicationState value,
    $Res Function(ScanMedicationState) then,
  ) = _$ScanMedicationStateCopyWithImpl<$Res, ScanMedicationState>;
  @useResult
  $Res call({
    bool isScanning,
    bool isSuccess,
    MedicationDto? scannedMedication,
    String? errorMessage,
    String? imagePath,
  });

  $MedicationDtoCopyWith<$Res>? get scannedMedication;
}

/// @nodoc
class _$ScanMedicationStateCopyWithImpl<$Res, $Val extends ScanMedicationState>
    implements $ScanMedicationStateCopyWith<$Res> {
  _$ScanMedicationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScanMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isScanning = null,
    Object? isSuccess = null,
    Object? scannedMedication = freezed,
    Object? errorMessage = freezed,
    Object? imagePath = freezed,
  }) {
    return _then(
      _value.copyWith(
            isScanning: null == isScanning
                ? _value.isScanning
                : isScanning // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSuccess: null == isSuccess
                ? _value.isSuccess
                : isSuccess // ignore: cast_nullable_to_non_nullable
                      as bool,
            scannedMedication: freezed == scannedMedication
                ? _value.scannedMedication
                : scannedMedication // ignore: cast_nullable_to_non_nullable
                      as MedicationDto?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            imagePath: freezed == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ScanMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicationDtoCopyWith<$Res>? get scannedMedication {
    if (_value.scannedMedication == null) {
      return null;
    }

    return $MedicationDtoCopyWith<$Res>(_value.scannedMedication!, (value) {
      return _then(_value.copyWith(scannedMedication: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScanMedicationStateImplCopyWith<$Res>
    implements $ScanMedicationStateCopyWith<$Res> {
  factory _$$ScanMedicationStateImplCopyWith(
    _$ScanMedicationStateImpl value,
    $Res Function(_$ScanMedicationStateImpl) then,
  ) = __$$ScanMedicationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isScanning,
    bool isSuccess,
    MedicationDto? scannedMedication,
    String? errorMessage,
    String? imagePath,
  });

  @override
  $MedicationDtoCopyWith<$Res>? get scannedMedication;
}

/// @nodoc
class __$$ScanMedicationStateImplCopyWithImpl<$Res>
    extends _$ScanMedicationStateCopyWithImpl<$Res, _$ScanMedicationStateImpl>
    implements _$$ScanMedicationStateImplCopyWith<$Res> {
  __$$ScanMedicationStateImplCopyWithImpl(
    _$ScanMedicationStateImpl _value,
    $Res Function(_$ScanMedicationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScanMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isScanning = null,
    Object? isSuccess = null,
    Object? scannedMedication = freezed,
    Object? errorMessage = freezed,
    Object? imagePath = freezed,
  }) {
    return _then(
      _$ScanMedicationStateImpl(
        isScanning: null == isScanning
            ? _value.isScanning
            : isScanning // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSuccess: null == isSuccess
            ? _value.isSuccess
            : isSuccess // ignore: cast_nullable_to_non_nullable
                  as bool,
        scannedMedication: freezed == scannedMedication
            ? _value.scannedMedication
            : scannedMedication // ignore: cast_nullable_to_non_nullable
                  as MedicationDto?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        imagePath: freezed == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ScanMedicationStateImpl implements _ScanMedicationState {
  const _$ScanMedicationStateImpl({
    this.isScanning = false,
    this.isSuccess = false,
    this.scannedMedication,
    this.errorMessage,
    this.imagePath,
  });

  @override
  @JsonKey()
  final bool isScanning;
  @override
  @JsonKey()
  final bool isSuccess;
  @override
  final MedicationDto? scannedMedication;
  @override
  final String? errorMessage;
  @override
  final String? imagePath;

  @override
  String toString() {
    return 'ScanMedicationState(isScanning: $isScanning, isSuccess: $isSuccess, scannedMedication: $scannedMedication, errorMessage: $errorMessage, imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanMedicationStateImpl &&
            (identical(other.isScanning, isScanning) ||
                other.isScanning == isScanning) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            (identical(other.scannedMedication, scannedMedication) ||
                other.scannedMedication == scannedMedication) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isScanning,
    isSuccess,
    scannedMedication,
    errorMessage,
    imagePath,
  );

  /// Create a copy of ScanMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanMedicationStateImplCopyWith<_$ScanMedicationStateImpl> get copyWith =>
      __$$ScanMedicationStateImplCopyWithImpl<_$ScanMedicationStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ScanMedicationState implements ScanMedicationState {
  const factory _ScanMedicationState({
    final bool isScanning,
    final bool isSuccess,
    final MedicationDto? scannedMedication,
    final String? errorMessage,
    final String? imagePath,
  }) = _$ScanMedicationStateImpl;

  @override
  bool get isScanning;
  @override
  bool get isSuccess;
  @override
  MedicationDto? get scannedMedication;
  @override
  String? get errorMessage;
  @override
  String? get imagePath;

  /// Create a copy of ScanMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScanMedicationStateImplCopyWith<_$ScanMedicationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
