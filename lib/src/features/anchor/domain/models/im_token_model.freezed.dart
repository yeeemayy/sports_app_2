// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'im_token_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ImTokenModel _$ImTokenModelFromJson(Map<String, dynamic> json) {
  return _ImTokenModel.fromJson(json);
}

/// @nodoc
mixin _$ImTokenModel {
  String get token => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;
  String get appKey => throw _privateConstructorUsedError;

  /// Serializes this ImTokenModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImTokenModelCopyWith<ImTokenModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImTokenModelCopyWith<$Res> {
  factory $ImTokenModelCopyWith(
    ImTokenModel value,
    $Res Function(ImTokenModel) then,
  ) = _$ImTokenModelCopyWithImpl<$Res, ImTokenModel>;
  @useResult
  $Res call({String token, String id, String name, String cid, String appKey});
}

/// @nodoc
class _$ImTokenModelCopyWithImpl<$Res, $Val extends ImTokenModel>
    implements $ImTokenModelCopyWith<$Res> {
  _$ImTokenModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? id = null,
    Object? name = null,
    Object? cid = null,
    Object? appKey = null,
  }) {
    return _then(
      _value.copyWith(
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            cid: null == cid
                ? _value.cid
                : cid // ignore: cast_nullable_to_non_nullable
                      as String,
            appKey: null == appKey
                ? _value.appKey
                : appKey // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ImTokenModelImplCopyWith<$Res>
    implements $ImTokenModelCopyWith<$Res> {
  factory _$$ImTokenModelImplCopyWith(
    _$ImTokenModelImpl value,
    $Res Function(_$ImTokenModelImpl) then,
  ) = __$$ImTokenModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, String id, String name, String cid, String appKey});
}

/// @nodoc
class __$$ImTokenModelImplCopyWithImpl<$Res>
    extends _$ImTokenModelCopyWithImpl<$Res, _$ImTokenModelImpl>
    implements _$$ImTokenModelImplCopyWith<$Res> {
  __$$ImTokenModelImplCopyWithImpl(
    _$ImTokenModelImpl _value,
    $Res Function(_$ImTokenModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ImTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? id = null,
    Object? name = null,
    Object? cid = null,
    Object? appKey = null,
  }) {
    return _then(
      _$ImTokenModelImpl(
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        cid: null == cid
            ? _value.cid
            : cid // ignore: cast_nullable_to_non_nullable
                  as String,
        appKey: null == appKey
            ? _value.appKey
            : appKey // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ImTokenModelImpl implements _ImTokenModel {
  const _$ImTokenModelImpl({
    required this.token,
    required this.id,
    required this.name,
    required this.cid,
    required this.appKey,
  });

  factory _$ImTokenModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImTokenModelImplFromJson(json);

  @override
  final String token;
  @override
  final String id;
  @override
  final String name;
  @override
  final String cid;
  @override
  final String appKey;

  @override
  String toString() {
    return 'ImTokenModel(token: $token, id: $id, name: $name, cid: $cid, appKey: $appKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImTokenModelImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.appKey, appKey) || other.appKey == appKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, id, name, cid, appKey);

  /// Create a copy of ImTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImTokenModelImplCopyWith<_$ImTokenModelImpl> get copyWith =>
      __$$ImTokenModelImplCopyWithImpl<_$ImTokenModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImTokenModelImplToJson(this);
  }
}

abstract class _ImTokenModel implements ImTokenModel {
  const factory _ImTokenModel({
    required final String token,
    required final String id,
    required final String name,
    required final String cid,
    required final String appKey,
  }) = _$ImTokenModelImpl;

  factory _ImTokenModel.fromJson(Map<String, dynamic> json) =
      _$ImTokenModelImpl.fromJson;

  @override
  String get token;
  @override
  String get id;
  @override
  String get name;
  @override
  String get cid;
  @override
  String get appKey;

  /// Create a copy of ImTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImTokenModelImplCopyWith<_$ImTokenModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
