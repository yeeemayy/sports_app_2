// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RefAppModel _$RefAppModelFromJson(Map<String, dynamic> json) {
  return _RefAppModel.fromJson(json);
}

/// @nodoc
mixin _$RefAppModel {
  String get icon => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;

  /// Serializes this RefAppModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RefAppModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RefAppModelCopyWith<RefAppModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefAppModelCopyWith<$Res> {
  factory $RefAppModelCopyWith(
    RefAppModel value,
    $Res Function(RefAppModel) then,
  ) = _$RefAppModelCopyWithImpl<$Res, RefAppModel>;
  @useResult
  $Res call({String icon, String? name, String description, String url});
}

/// @nodoc
class _$RefAppModelCopyWithImpl<$Res, $Val extends RefAppModel>
    implements $RefAppModelCopyWith<$Res> {
  _$RefAppModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RefAppModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? name = freezed,
    Object? description = null,
    Object? url = null,
  }) {
    return _then(
      _value.copyWith(
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RefAppModelImplCopyWith<$Res>
    implements $RefAppModelCopyWith<$Res> {
  factory _$$RefAppModelImplCopyWith(
    _$RefAppModelImpl value,
    $Res Function(_$RefAppModelImpl) then,
  ) = __$$RefAppModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String icon, String? name, String description, String url});
}

/// @nodoc
class __$$RefAppModelImplCopyWithImpl<$Res>
    extends _$RefAppModelCopyWithImpl<$Res, _$RefAppModelImpl>
    implements _$$RefAppModelImplCopyWith<$Res> {
  __$$RefAppModelImplCopyWithImpl(
    _$RefAppModelImpl _value,
    $Res Function(_$RefAppModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RefAppModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? name = freezed,
    Object? description = null,
    Object? url = null,
  }) {
    return _then(
      _$RefAppModelImpl(
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RefAppModelImpl implements _RefAppModel {
  const _$RefAppModelImpl({
    required this.icon,
    this.name,
    required this.description,
    required this.url,
  });

  factory _$RefAppModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefAppModelImplFromJson(json);

  @override
  final String icon;
  @override
  final String? name;
  @override
  final String description;
  @override
  final String url;

  @override
  String toString() {
    return 'RefAppModel(icon: $icon, name: $name, description: $description, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefAppModelImpl &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, icon, name, description, url);

  /// Create a copy of RefAppModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefAppModelImplCopyWith<_$RefAppModelImpl> get copyWith =>
      __$$RefAppModelImplCopyWithImpl<_$RefAppModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefAppModelImplToJson(this);
  }
}

abstract class _RefAppModel implements RefAppModel {
  const factory _RefAppModel({
    required final String icon,
    final String? name,
    required final String description,
    required final String url,
  }) = _$RefAppModelImpl;

  factory _RefAppModel.fromJson(Map<String, dynamic> json) =
      _$RefAppModelImpl.fromJson;

  @override
  String get icon;
  @override
  String? get name;
  @override
  String get description;
  @override
  String get url;

  /// Create a copy of RefAppModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefAppModelImplCopyWith<_$RefAppModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) {
  return _BannerModel.fromJson(json);
}

/// @nodoc
mixin _$BannerModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'app_name')
  String? get appName => throw _privateConstructorUsedError;
  String get cover => throw _privateConstructorUsedError;
  @JsonKey(name: 'ref_app')
  List<RefAppModel> get refApp => throw _privateConstructorUsedError;
  String get updated => throw _privateConstructorUsedError;

  /// Serializes this BannerModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BannerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BannerModelCopyWith<BannerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BannerModelCopyWith<$Res> {
  factory $BannerModelCopyWith(
    BannerModel value,
    $Res Function(BannerModel) then,
  ) = _$BannerModelCopyWithImpl<$Res, BannerModel>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'app_name') String? appName,
    String cover,
    @JsonKey(name: 'ref_app') List<RefAppModel> refApp,
    String updated,
  });
}

/// @nodoc
class _$BannerModelCopyWithImpl<$Res, $Val extends BannerModel>
    implements $BannerModelCopyWith<$Res> {
  _$BannerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BannerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? appName = freezed,
    Object? cover = null,
    Object? refApp = null,
    Object? updated = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            appName: freezed == appName
                ? _value.appName
                : appName // ignore: cast_nullable_to_non_nullable
                      as String?,
            cover: null == cover
                ? _value.cover
                : cover // ignore: cast_nullable_to_non_nullable
                      as String,
            refApp: null == refApp
                ? _value.refApp
                : refApp // ignore: cast_nullable_to_non_nullable
                      as List<RefAppModel>,
            updated: null == updated
                ? _value.updated
                : updated // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BannerModelImplCopyWith<$Res>
    implements $BannerModelCopyWith<$Res> {
  factory _$$BannerModelImplCopyWith(
    _$BannerModelImpl value,
    $Res Function(_$BannerModelImpl) then,
  ) = __$$BannerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'app_name') String? appName,
    String cover,
    @JsonKey(name: 'ref_app') List<RefAppModel> refApp,
    String updated,
  });
}

/// @nodoc
class __$$BannerModelImplCopyWithImpl<$Res>
    extends _$BannerModelCopyWithImpl<$Res, _$BannerModelImpl>
    implements _$$BannerModelImplCopyWith<$Res> {
  __$$BannerModelImplCopyWithImpl(
    _$BannerModelImpl _value,
    $Res Function(_$BannerModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BannerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? appName = freezed,
    Object? cover = null,
    Object? refApp = null,
    Object? updated = null,
  }) {
    return _then(
      _$BannerModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        appName: freezed == appName
            ? _value.appName
            : appName // ignore: cast_nullable_to_non_nullable
                  as String?,
        cover: null == cover
            ? _value.cover
            : cover // ignore: cast_nullable_to_non_nullable
                  as String,
        refApp: null == refApp
            ? _value._refApp
            : refApp // ignore: cast_nullable_to_non_nullable
                  as List<RefAppModel>,
        updated: null == updated
            ? _value.updated
            : updated // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BannerModelImpl implements _BannerModel {
  const _$BannerModelImpl({
    required this.id,
    @JsonKey(name: 'app_name') this.appName,
    required this.cover,
    @JsonKey(name: 'ref_app') required final List<RefAppModel> refApp,
    required this.updated,
  }) : _refApp = refApp;

  factory _$BannerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BannerModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'app_name')
  final String? appName;
  @override
  final String cover;
  final List<RefAppModel> _refApp;
  @override
  @JsonKey(name: 'ref_app')
  List<RefAppModel> get refApp {
    if (_refApp is EqualUnmodifiableListView) return _refApp;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_refApp);
  }

  @override
  final String updated;

  @override
  String toString() {
    return 'BannerModel(id: $id, appName: $appName, cover: $cover, refApp: $refApp, updated: $updated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BannerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.appName, appName) || other.appName == appName) &&
            (identical(other.cover, cover) || other.cover == cover) &&
            const DeepCollectionEquality().equals(other._refApp, _refApp) &&
            (identical(other.updated, updated) || other.updated == updated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    appName,
    cover,
    const DeepCollectionEquality().hash(_refApp),
    updated,
  );

  /// Create a copy of BannerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BannerModelImplCopyWith<_$BannerModelImpl> get copyWith =>
      __$$BannerModelImplCopyWithImpl<_$BannerModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BannerModelImplToJson(this);
  }
}

abstract class _BannerModel implements BannerModel {
  const factory _BannerModel({
    required final int id,
    @JsonKey(name: 'app_name') final String? appName,
    required final String cover,
    @JsonKey(name: 'ref_app') required final List<RefAppModel> refApp,
    required final String updated,
  }) = _$BannerModelImpl;

  factory _BannerModel.fromJson(Map<String, dynamic> json) =
      _$BannerModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'app_name')
  String? get appName;
  @override
  String get cover;
  @override
  @JsonKey(name: 'ref_app')
  List<RefAppModel> get refApp;
  @override
  String get updated;

  /// Create a copy of BannerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BannerModelImplCopyWith<_$BannerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
