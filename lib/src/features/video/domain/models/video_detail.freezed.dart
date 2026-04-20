// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VideoDetail _$VideoDetailFromJson(Map<String, dynamic> json) {
  return _VideoDetail.fromJson(json);
}

/// @nodoc
mixin _$VideoDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'albb_hls_url')
  String? get albbHlsUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'cf_hls_url')
  String? get cfHlsUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_path')
  String get thumbnailPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'create_time')
  String get createTime => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;

  /// Serializes this VideoDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoDetailCopyWith<VideoDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoDetailCopyWith<$Res> {
  factory $VideoDetailCopyWith(
    VideoDetail value,
    $Res Function(VideoDetail) then,
  ) = _$VideoDetailCopyWithImpl<$Res, VideoDetail>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'albb_hls_url') String? albbHlsUrl,
    @JsonKey(name: 'cf_hls_url') String? cfHlsUrl,
    @JsonKey(name: 'thumbnail_path') String thumbnailPath,
    @JsonKey(name: 'create_time') String createTime,
    String title,
    String path,
    String? type,
  });
}

/// @nodoc
class _$VideoDetailCopyWithImpl<$Res, $Val extends VideoDetail>
    implements $VideoDetailCopyWith<$Res> {
  _$VideoDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? albbHlsUrl = freezed,
    Object? cfHlsUrl = freezed,
    Object? thumbnailPath = null,
    Object? createTime = null,
    Object? title = null,
    Object? path = null,
    Object? type = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            albbHlsUrl: freezed == albbHlsUrl
                ? _value.albbHlsUrl
                : albbHlsUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            cfHlsUrl: freezed == cfHlsUrl
                ? _value.cfHlsUrl
                : cfHlsUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailPath: null == thumbnailPath
                ? _value.thumbnailPath
                : thumbnailPath // ignore: cast_nullable_to_non_nullable
                      as String,
            createTime: null == createTime
                ? _value.createTime
                : createTime // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VideoDetailImplCopyWith<$Res>
    implements $VideoDetailCopyWith<$Res> {
  factory _$$VideoDetailImplCopyWith(
    _$VideoDetailImpl value,
    $Res Function(_$VideoDetailImpl) then,
  ) = __$$VideoDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'albb_hls_url') String? albbHlsUrl,
    @JsonKey(name: 'cf_hls_url') String? cfHlsUrl,
    @JsonKey(name: 'thumbnail_path') String thumbnailPath,
    @JsonKey(name: 'create_time') String createTime,
    String title,
    String path,
    String? type,
  });
}

/// @nodoc
class __$$VideoDetailImplCopyWithImpl<$Res>
    extends _$VideoDetailCopyWithImpl<$Res, _$VideoDetailImpl>
    implements _$$VideoDetailImplCopyWith<$Res> {
  __$$VideoDetailImplCopyWithImpl(
    _$VideoDetailImpl _value,
    $Res Function(_$VideoDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideoDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? albbHlsUrl = freezed,
    Object? cfHlsUrl = freezed,
    Object? thumbnailPath = null,
    Object? createTime = null,
    Object? title = null,
    Object? path = null,
    Object? type = freezed,
  }) {
    return _then(
      _$VideoDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        albbHlsUrl: freezed == albbHlsUrl
            ? _value.albbHlsUrl
            : albbHlsUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        cfHlsUrl: freezed == cfHlsUrl
            ? _value.cfHlsUrl
            : cfHlsUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailPath: null == thumbnailPath
            ? _value.thumbnailPath
            : thumbnailPath // ignore: cast_nullable_to_non_nullable
                  as String,
        createTime: null == createTime
            ? _value.createTime
            : createTime // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoDetailImpl implements _VideoDetail {
  const _$VideoDetailImpl({
    required this.id,
    @JsonKey(name: 'albb_hls_url') this.albbHlsUrl,
    @JsonKey(name: 'cf_hls_url') this.cfHlsUrl,
    @JsonKey(name: 'thumbnail_path') required this.thumbnailPath,
    @JsonKey(name: 'create_time') required this.createTime,
    required this.title,
    required this.path,
    this.type,
  });

  factory _$VideoDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'albb_hls_url')
  final String? albbHlsUrl;
  @override
  @JsonKey(name: 'cf_hls_url')
  final String? cfHlsUrl;
  @override
  @JsonKey(name: 'thumbnail_path')
  final String thumbnailPath;
  @override
  @JsonKey(name: 'create_time')
  final String createTime;
  @override
  final String title;
  @override
  final String path;
  @override
  final String? type;

  @override
  String toString() {
    return 'VideoDetail(id: $id, albbHlsUrl: $albbHlsUrl, cfHlsUrl: $cfHlsUrl, thumbnailPath: $thumbnailPath, createTime: $createTime, title: $title, path: $path, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.albbHlsUrl, albbHlsUrl) ||
                other.albbHlsUrl == albbHlsUrl) &&
            (identical(other.cfHlsUrl, cfHlsUrl) ||
                other.cfHlsUrl == cfHlsUrl) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            (identical(other.createTime, createTime) ||
                other.createTime == createTime) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    albbHlsUrl,
    cfHlsUrl,
    thumbnailPath,
    createTime,
    title,
    path,
    type,
  );

  /// Create a copy of VideoDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoDetailImplCopyWith<_$VideoDetailImpl> get copyWith =>
      __$$VideoDetailImplCopyWithImpl<_$VideoDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoDetailImplToJson(this);
  }
}

abstract class _VideoDetail implements VideoDetail {
  const factory _VideoDetail({
    required final int id,
    @JsonKey(name: 'albb_hls_url') final String? albbHlsUrl,
    @JsonKey(name: 'cf_hls_url') final String? cfHlsUrl,
    @JsonKey(name: 'thumbnail_path') required final String thumbnailPath,
    @JsonKey(name: 'create_time') required final String createTime,
    required final String title,
    required final String path,
    final String? type,
  }) = _$VideoDetailImpl;

  factory _VideoDetail.fromJson(Map<String, dynamic> json) =
      _$VideoDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'albb_hls_url')
  String? get albbHlsUrl;
  @override
  @JsonKey(name: 'cf_hls_url')
  String? get cfHlsUrl;
  @override
  @JsonKey(name: 'thumbnail_path')
  String get thumbnailPath;
  @override
  @JsonKey(name: 'create_time')
  String get createTime;
  @override
  String get title;
  @override
  String get path;
  @override
  String? get type;

  /// Create a copy of VideoDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoDetailImplCopyWith<_$VideoDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
