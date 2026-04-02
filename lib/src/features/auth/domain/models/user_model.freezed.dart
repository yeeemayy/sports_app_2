// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  int get uid => throw _privateConstructorUsedError;
  String get telephone => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatarUrl')
  String? get avatarUrl => throw _privateConstructorUsedError;
  int get gender => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 0)
  int get profit => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 0)
  int get balance => throw _privateConstructorUsedError;
  @JsonKey(name: 'isAnchor', defaultValue: -1)
  int get isAnchor => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    int uid,
    String telephone,
    String nickname,
    @JsonKey(name: 'avatarUrl') String? avatarUrl,
    int gender,
    @JsonKey(defaultValue: 0) int profit,
    @JsonKey(defaultValue: 0) int balance,
    @JsonKey(name: 'isAnchor', defaultValue: -1) int isAnchor,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? telephone = null,
    Object? nickname = null,
    Object? avatarUrl = freezed,
    Object? gender = null,
    Object? profit = null,
    Object? balance = null,
    Object? isAnchor = null,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as int,
            telephone: null == telephone
                ? _value.telephone
                : telephone // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as int,
            profit: null == profit
                ? _value.profit
                : profit // ignore: cast_nullable_to_non_nullable
                      as int,
            balance: null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as int,
            isAnchor: null == isAnchor
                ? _value.isAnchor
                : isAnchor // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int uid,
    String telephone,
    String nickname,
    @JsonKey(name: 'avatarUrl') String? avatarUrl,
    int gender,
    @JsonKey(defaultValue: 0) int profit,
    @JsonKey(defaultValue: 0) int balance,
    @JsonKey(name: 'isAnchor', defaultValue: -1) int isAnchor,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? telephone = null,
    Object? nickname = null,
    Object? avatarUrl = freezed,
    Object? gender = null,
    Object? profit = null,
    Object? balance = null,
    Object? isAnchor = null,
  }) {
    return _then(
      _$UserModelImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as int,
        telephone: null == telephone
            ? _value.telephone
            : telephone // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as int,
        profit: null == profit
            ? _value.profit
            : profit // ignore: cast_nullable_to_non_nullable
                  as int,
        balance: null == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as int,
        isAnchor: null == isAnchor
            ? _value.isAnchor
            : isAnchor // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.uid,
    required this.telephone,
    required this.nickname,
    @JsonKey(name: 'avatarUrl') required this.avatarUrl,
    required this.gender,
    @JsonKey(defaultValue: 0) required this.profit,
    @JsonKey(defaultValue: 0) required this.balance,
    @JsonKey(name: 'isAnchor', defaultValue: -1) required this.isAnchor,
  });

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final int uid;
  @override
  final String telephone;
  @override
  final String nickname;
  @override
  @JsonKey(name: 'avatarUrl')
  final String? avatarUrl;
  @override
  final int gender;
  @override
  @JsonKey(defaultValue: 0)
  final int profit;
  @override
  @JsonKey(defaultValue: 0)
  final int balance;
  @override
  @JsonKey(name: 'isAnchor', defaultValue: -1)
  final int isAnchor;

  @override
  String toString() {
    return 'UserModel(uid: $uid, telephone: $telephone, nickname: $nickname, avatarUrl: $avatarUrl, gender: $gender, profit: $profit, balance: $balance, isAnchor: $isAnchor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.profit, profit) || other.profit == profit) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.isAnchor, isAnchor) ||
                other.isAnchor == isAnchor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uid,
    telephone,
    nickname,
    avatarUrl,
    gender,
    profit,
    balance,
    isAnchor,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final int uid,
    required final String telephone,
    required final String nickname,
    @JsonKey(name: 'avatarUrl') required final String? avatarUrl,
    required final int gender,
    @JsonKey(defaultValue: 0) required final int profit,
    @JsonKey(defaultValue: 0) required final int balance,
    @JsonKey(name: 'isAnchor', defaultValue: -1) required final int isAnchor,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  int get uid;
  @override
  String get telephone;
  @override
  String get nickname;
  @override
  @JsonKey(name: 'avatarUrl')
  String? get avatarUrl;
  @override
  int get gender;
  @override
  @JsonKey(defaultValue: 0)
  int get profit;
  @override
  @JsonKey(defaultValue: 0)
  int get balance;
  @override
  @JsonKey(name: 'isAnchor', defaultValue: -1)
  int get isAnchor;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
