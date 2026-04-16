// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) {
  return _VideoModel.fromJson(json);
}

/// @nodoc
mixin _$VideoModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'cf_hls_url')
  String? get cfHlsUrl => throw _privateConstructorUsedError;
  String get video => throw _privateConstructorUsedError;
  @JsonKey(name: 'create_time')
  String get createTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_path')
  String get thumbnailPath => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  @JsonKey(name: 'create_time_bj')
  String get createTimeBj => throw _privateConstructorUsedError;

  /// Serializes this VideoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoModelCopyWith<VideoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoModelCopyWith<$Res> {
  factory $VideoModelCopyWith(
    VideoModel value,
    $Res Function(VideoModel) then,
  ) = _$VideoModelCopyWithImpl<$Res, VideoModel>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'cf_hls_url') String? cfHlsUrl,
    String video,
    @JsonKey(name: 'create_time') String createTime,
    @JsonKey(name: 'thumbnail_path') String thumbnailPath,
    String title,
    String path,
    @JsonKey(name: 'create_time_bj') String createTimeBj,
  });
}

/// @nodoc
class _$VideoModelCopyWithImpl<$Res, $Val extends VideoModel>
    implements $VideoModelCopyWith<$Res> {
  _$VideoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cfHlsUrl = freezed,
    Object? video = null,
    Object? createTime = null,
    Object? thumbnailPath = null,
    Object? title = null,
    Object? path = null,
    Object? createTimeBj = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            cfHlsUrl: freezed == cfHlsUrl
                ? _value.cfHlsUrl
                : cfHlsUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            video: null == video
                ? _value.video
                : video // ignore: cast_nullable_to_non_nullable
                      as String,
            createTime: null == createTime
                ? _value.createTime
                : createTime // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnailPath: null == thumbnailPath
                ? _value.thumbnailPath
                : thumbnailPath // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            createTimeBj: null == createTimeBj
                ? _value.createTimeBj
                : createTimeBj // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VideoModelImplCopyWith<$Res>
    implements $VideoModelCopyWith<$Res> {
  factory _$$VideoModelImplCopyWith(
    _$VideoModelImpl value,
    $Res Function(_$VideoModelImpl) then,
  ) = __$$VideoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'cf_hls_url') String? cfHlsUrl,
    String video,
    @JsonKey(name: 'create_time') String createTime,
    @JsonKey(name: 'thumbnail_path') String thumbnailPath,
    String title,
    String path,
    @JsonKey(name: 'create_time_bj') String createTimeBj,
  });
}

/// @nodoc
class __$$VideoModelImplCopyWithImpl<$Res>
    extends _$VideoModelCopyWithImpl<$Res, _$VideoModelImpl>
    implements _$$VideoModelImplCopyWith<$Res> {
  __$$VideoModelImplCopyWithImpl(
    _$VideoModelImpl _value,
    $Res Function(_$VideoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cfHlsUrl = freezed,
    Object? video = null,
    Object? createTime = null,
    Object? thumbnailPath = null,
    Object? title = null,
    Object? path = null,
    Object? createTimeBj = null,
  }) {
    return _then(
      _$VideoModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        cfHlsUrl: freezed == cfHlsUrl
            ? _value.cfHlsUrl
            : cfHlsUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        video: null == video
            ? _value.video
            : video // ignore: cast_nullable_to_non_nullable
                  as String,
        createTime: null == createTime
            ? _value.createTime
            : createTime // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnailPath: null == thumbnailPath
            ? _value.thumbnailPath
            : thumbnailPath // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        createTimeBj: null == createTimeBj
            ? _value.createTimeBj
            : createTimeBj // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoModelImpl implements _VideoModel {
  const _$VideoModelImpl({
    required this.id,
    @JsonKey(name: 'cf_hls_url') this.cfHlsUrl,
    required this.video,
    @JsonKey(name: 'create_time') required this.createTime,
    @JsonKey(name: 'thumbnail_path') required this.thumbnailPath,
    required this.title,
    required this.path,
    @JsonKey(name: 'create_time_bj') required this.createTimeBj,
  });

  factory _$VideoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'cf_hls_url')
  final String? cfHlsUrl;
  @override
  final String video;
  @override
  @JsonKey(name: 'create_time')
  final String createTime;
  @override
  @JsonKey(name: 'thumbnail_path')
  final String thumbnailPath;
  @override
  final String title;
  @override
  final String path;
  @override
  @JsonKey(name: 'create_time_bj')
  final String createTimeBj;

  @override
  String toString() {
    return 'VideoModel(id: $id, cfHlsUrl: $cfHlsUrl, video: $video, createTime: $createTime, thumbnailPath: $thumbnailPath, title: $title, path: $path, createTimeBj: $createTimeBj)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cfHlsUrl, cfHlsUrl) ||
                other.cfHlsUrl == cfHlsUrl) &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.createTime, createTime) ||
                other.createTime == createTime) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.createTimeBj, createTimeBj) ||
                other.createTimeBj == createTimeBj));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    cfHlsUrl,
    video,
    createTime,
    thumbnailPath,
    title,
    path,
    createTimeBj,
  );

  /// Create a copy of VideoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoModelImplCopyWith<_$VideoModelImpl> get copyWith =>
      __$$VideoModelImplCopyWithImpl<_$VideoModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoModelImplToJson(this);
  }
}

abstract class _VideoModel implements VideoModel {
  const factory _VideoModel({
    required final int id,
    @JsonKey(name: 'cf_hls_url') final String? cfHlsUrl,
    required final String video,
    @JsonKey(name: 'create_time') required final String createTime,
    @JsonKey(name: 'thumbnail_path') required final String thumbnailPath,
    required final String title,
    required final String path,
    @JsonKey(name: 'create_time_bj') required final String createTimeBj,
  }) = _$VideoModelImpl;

  factory _VideoModel.fromJson(Map<String, dynamic> json) =
      _$VideoModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'cf_hls_url')
  String? get cfHlsUrl;
  @override
  String get video;
  @override
  @JsonKey(name: 'create_time')
  String get createTime;
  @override
  @JsonKey(name: 'thumbnail_path')
  String get thumbnailPath;
  @override
  String get title;
  @override
  String get path;
  @override
  @JsonKey(name: 'create_time_bj')
  String get createTimeBj;

  /// Create a copy of VideoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoModelImplCopyWith<_$VideoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoListResponse _$VideoListResponseFromJson(Map<String, dynamic> json) {
  return _VideoListResponse.fromJson(json);
}

/// @nodoc
mixin _$VideoListResponse {
  List<VideoModel> get list => throw _privateConstructorUsedError;
  VideoListMeta get meta => throw _privateConstructorUsedError;

  /// Serializes this VideoListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoListResponseCopyWith<VideoListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoListResponseCopyWith<$Res> {
  factory $VideoListResponseCopyWith(
    VideoListResponse value,
    $Res Function(VideoListResponse) then,
  ) = _$VideoListResponseCopyWithImpl<$Res, VideoListResponse>;
  @useResult
  $Res call({List<VideoModel> list, VideoListMeta meta});

  $VideoListMetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$VideoListResponseCopyWithImpl<$Res, $Val extends VideoListResponse>
    implements $VideoListResponseCopyWith<$Res> {
  _$VideoListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? list = null, Object? meta = null}) {
    return _then(
      _value.copyWith(
            list: null == list
                ? _value.list
                : list // ignore: cast_nullable_to_non_nullable
                      as List<VideoModel>,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as VideoListMeta,
          )
          as $Val,
    );
  }

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoListMetaCopyWith<$Res> get meta {
    return $VideoListMetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VideoListResponseImplCopyWith<$Res>
    implements $VideoListResponseCopyWith<$Res> {
  factory _$$VideoListResponseImplCopyWith(
    _$VideoListResponseImpl value,
    $Res Function(_$VideoListResponseImpl) then,
  ) = __$$VideoListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<VideoModel> list, VideoListMeta meta});

  @override
  $VideoListMetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$$VideoListResponseImplCopyWithImpl<$Res>
    extends _$VideoListResponseCopyWithImpl<$Res, _$VideoListResponseImpl>
    implements _$$VideoListResponseImplCopyWith<$Res> {
  __$$VideoListResponseImplCopyWithImpl(
    _$VideoListResponseImpl _value,
    $Res Function(_$VideoListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? list = null, Object? meta = null}) {
    return _then(
      _$VideoListResponseImpl(
        list: null == list
            ? _value._list
            : list // ignore: cast_nullable_to_non_nullable
                  as List<VideoModel>,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as VideoListMeta,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoListResponseImpl implements _VideoListResponse {
  const _$VideoListResponseImpl({
    required final List<VideoModel> list,
    required this.meta,
  }) : _list = list;

  factory _$VideoListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoListResponseImplFromJson(json);

  final List<VideoModel> _list;
  @override
  List<VideoModel> get list {
    if (_list is EqualUnmodifiableListView) return _list;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_list);
  }

  @override
  final VideoListMeta meta;

  @override
  String toString() {
    return 'VideoListResponse(list: $list, meta: $meta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoListResponseImpl &&
            const DeepCollectionEquality().equals(other._list, _list) &&
            (identical(other.meta, meta) || other.meta == meta));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_list),
    meta,
  );

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoListResponseImplCopyWith<_$VideoListResponseImpl> get copyWith =>
      __$$VideoListResponseImplCopyWithImpl<_$VideoListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoListResponseImplToJson(this);
  }
}

abstract class _VideoListResponse implements VideoListResponse {
  const factory _VideoListResponse({
    required final List<VideoModel> list,
    required final VideoListMeta meta,
  }) = _$VideoListResponseImpl;

  factory _VideoListResponse.fromJson(Map<String, dynamic> json) =
      _$VideoListResponseImpl.fromJson;

  @override
  List<VideoModel> get list;
  @override
  VideoListMeta get meta;

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoListResponseImplCopyWith<_$VideoListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoListMeta _$VideoListMetaFromJson(Map<String, dynamic> json) {
  return _VideoListMeta.fromJson(json);
}

/// @nodoc
mixin _$VideoListMeta {
  int get currentPage => throw _privateConstructorUsedError;
  int get lastPage => throw _privateConstructorUsedError;
  int get perPage => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this VideoListMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoListMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoListMetaCopyWith<VideoListMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoListMetaCopyWith<$Res> {
  factory $VideoListMetaCopyWith(
    VideoListMeta value,
    $Res Function(VideoListMeta) then,
  ) = _$VideoListMetaCopyWithImpl<$Res, VideoListMeta>;
  @useResult
  $Res call({int currentPage, int lastPage, int perPage, int total});
}

/// @nodoc
class _$VideoListMetaCopyWithImpl<$Res, $Val extends VideoListMeta>
    implements $VideoListMetaCopyWith<$Res> {
  _$VideoListMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoListMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = null,
    Object? lastPage = null,
    Object? perPage = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            lastPage: null == lastPage
                ? _value.lastPage
                : lastPage // ignore: cast_nullable_to_non_nullable
                      as int,
            perPage: null == perPage
                ? _value.perPage
                : perPage // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VideoListMetaImplCopyWith<$Res>
    implements $VideoListMetaCopyWith<$Res> {
  factory _$$VideoListMetaImplCopyWith(
    _$VideoListMetaImpl value,
    $Res Function(_$VideoListMetaImpl) then,
  ) = __$$VideoListMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int currentPage, int lastPage, int perPage, int total});
}

/// @nodoc
class __$$VideoListMetaImplCopyWithImpl<$Res>
    extends _$VideoListMetaCopyWithImpl<$Res, _$VideoListMetaImpl>
    implements _$$VideoListMetaImplCopyWith<$Res> {
  __$$VideoListMetaImplCopyWithImpl(
    _$VideoListMetaImpl _value,
    $Res Function(_$VideoListMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideoListMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = null,
    Object? lastPage = null,
    Object? perPage = null,
    Object? total = null,
  }) {
    return _then(
      _$VideoListMetaImpl(
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        lastPage: null == lastPage
            ? _value.lastPage
            : lastPage // ignore: cast_nullable_to_non_nullable
                  as int,
        perPage: null == perPage
            ? _value.perPage
            : perPage // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoListMetaImpl implements _VideoListMeta {
  const _$VideoListMetaImpl({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory _$VideoListMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoListMetaImplFromJson(json);

  @override
  final int currentPage;
  @override
  final int lastPage;
  @override
  final int perPage;
  @override
  final int total;

  @override
  String toString() {
    return 'VideoListMeta(currentPage: $currentPage, lastPage: $lastPage, perPage: $perPage, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoListMetaImpl &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.lastPage, lastPage) ||
                other.lastPage == lastPage) &&
            (identical(other.perPage, perPage) || other.perPage == perPage) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, currentPage, lastPage, perPage, total);

  /// Create a copy of VideoListMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoListMetaImplCopyWith<_$VideoListMetaImpl> get copyWith =>
      __$$VideoListMetaImplCopyWithImpl<_$VideoListMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoListMetaImplToJson(this);
  }
}

abstract class _VideoListMeta implements VideoListMeta {
  const factory _VideoListMeta({
    required final int currentPage,
    required final int lastPage,
    required final int perPage,
    required final int total,
  }) = _$VideoListMetaImpl;

  factory _VideoListMeta.fromJson(Map<String, dynamic> json) =
      _$VideoListMetaImpl.fromJson;

  @override
  int get currentPage;
  @override
  int get lastPage;
  @override
  int get perPage;
  @override
  int get total;

  /// Create a copy of VideoListMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoListMetaImplCopyWith<_$VideoListMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
