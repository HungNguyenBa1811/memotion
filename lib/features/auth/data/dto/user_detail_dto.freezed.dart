// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserDetailDto _$UserDetailDtoFromJson(Map<String, dynamic> json) {
  return _UserDetailDto.fromJson(json);
}

/// @nodoc
mixin _$UserDetailDto {
  String get fullName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isFirstLogin => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  PatientDto? get patient => throw _privateConstructorUsedError;

  /// Serializes this UserDetailDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDetailDtoCopyWith<UserDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDetailDtoCopyWith<$Res> {
  factory $UserDetailDtoCopyWith(
    UserDetailDto value,
    $Res Function(UserDetailDto) then,
  ) = _$UserDetailDtoCopyWithImpl<$Res, UserDetailDto>;
  @useResult
  $Res call({
    String fullName,
    String email,
    bool isActive,
    bool isFirstLogin,
    String role,
    String userId,
    String phone,
    PatientDto? patient,
  });
}

/// @nodoc
class _$UserDetailDtoCopyWithImpl<$Res, $Val extends UserDetailDto>
    implements $UserDetailDtoCopyWith<$Res> {
  _$UserDetailDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? email = null,
    Object? isActive = null,
    Object? isFirstLogin = null,
    Object? role = null,
    Object? userId = null,
    Object? phone = null,
    Object? patient = freezed,
  }) {
    return _then(
      _value.copyWith(
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFirstLogin: null == isFirstLogin
                ? _value.isFirstLogin
                : isFirstLogin // ignore: cast_nullable_to_non_nullable
                      as bool,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            patient: freezed == patient
                ? _value.patient
                : patient // ignore: cast_nullable_to_non_nullable
                      as PatientDto?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserDetailDtoImplCopyWith<$Res>
    implements $UserDetailDtoCopyWith<$Res> {
  factory _$$UserDetailDtoImplCopyWith(
    _$UserDetailDtoImpl value,
    $Res Function(_$UserDetailDtoImpl) then,
  ) = __$$UserDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fullName,
    String email,
    bool isActive,
    bool isFirstLogin,
    String role,
    String userId,
    String phone,
    PatientDto? patient,
  });
}

/// @nodoc
class __$$UserDetailDtoImplCopyWithImpl<$Res>
    extends _$UserDetailDtoCopyWithImpl<$Res, _$UserDetailDtoImpl>
    implements _$$UserDetailDtoImplCopyWith<$Res> {
  __$$UserDetailDtoImplCopyWithImpl(
    _$UserDetailDtoImpl _value,
    $Res Function(_$UserDetailDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? email = null,
    Object? isActive = null,
    Object? isFirstLogin = null,
    Object? role = null,
    Object? userId = null,
    Object? phone = null,
    Object? patient = freezed,
  }) {
    return _then(
      _$UserDetailDtoImpl(
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFirstLogin: null == isFirstLogin
            ? _value.isFirstLogin
            : isFirstLogin // ignore: cast_nullable_to_non_nullable
                  as bool,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        patient: freezed == patient
            ? _value.patient
            : patient // ignore: cast_nullable_to_non_nullable
                  as PatientDto?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDetailDtoImpl implements _UserDetailDto {
  const _$UserDetailDtoImpl({
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.isFirstLogin,
    required this.role,
    required this.userId,
    required this.phone,
    this.patient,
  });

  factory _$UserDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDetailDtoImplFromJson(json);

  @override
  final String fullName;
  @override
  final String email;
  @override
  final bool isActive;
  @override
  final bool isFirstLogin;
  @override
  final String role;
  @override
  final String userId;
  @override
  final String phone;
  @override
  final PatientDto? patient;

  @override
  String toString() {
    return 'UserDetailDto(fullName: $fullName, email: $email, isActive: $isActive, isFirstLogin: $isFirstLogin, role: $role, userId: $userId, phone: $phone, patient: $patient)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDetailDtoImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isFirstLogin, isFirstLogin) ||
                other.isFirstLogin == isFirstLogin) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.patient, patient) || other.patient == patient));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    fullName,
    email,
    isActive,
    isFirstLogin,
    role,
    userId,
    phone,
    patient,
  );

  /// Create a copy of UserDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDetailDtoImplCopyWith<_$UserDetailDtoImpl> get copyWith =>
      __$$UserDetailDtoImplCopyWithImpl<_$UserDetailDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDetailDtoImplToJson(this);
  }
}

abstract class _UserDetailDto implements UserDetailDto {
  const factory _UserDetailDto({
    required final String fullName,
    required final String email,
    required final bool isActive,
    required final bool isFirstLogin,
    required final String role,
    required final String userId,
    required final String phone,
    final PatientDto? patient,
  }) = _$UserDetailDtoImpl;

  factory _UserDetailDto.fromJson(Map<String, dynamic> json) =
      _$UserDetailDtoImpl.fromJson;

  @override
  String get fullName;
  @override
  String get email;
  @override
  bool get isActive;
  @override
  bool get isFirstLogin;
  @override
  String get role;
  @override
  String get userId;
  @override
  String get phone;
  @override
  PatientDto? get patient;

  /// Create a copy of UserDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDetailDtoImplCopyWith<_$UserDetailDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
