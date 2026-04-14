// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NewsListResponse _$NewsListResponseFromJson(Map<String, dynamic> json) {
  return _NewsListResponse.fromJson(json);
}

/// @nodoc
mixin _$NewsListResponse {
  List<NewsArticle> get list => throw _privateConstructorUsedError;
  NewsListMeta get meta => throw _privateConstructorUsedError;

  /// Serializes this NewsListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsListResponseCopyWith<NewsListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsListResponseCopyWith<$Res> {
  factory $NewsListResponseCopyWith(
    NewsListResponse value,
    $Res Function(NewsListResponse) then,
  ) = _$NewsListResponseCopyWithImpl<$Res, NewsListResponse>;
  @useResult
  $Res call({List<NewsArticle> list, NewsListMeta meta});

  $NewsListMetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$NewsListResponseCopyWithImpl<$Res, $Val extends NewsListResponse>
    implements $NewsListResponseCopyWith<$Res> {
  _$NewsListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? list = null, Object? meta = null}) {
    return _then(
      _value.copyWith(
            list: null == list
                ? _value.list
                : list // ignore: cast_nullable_to_non_nullable
                      as List<NewsArticle>,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as NewsListMeta,
          )
          as $Val,
    );
  }

  /// Create a copy of NewsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NewsListMetaCopyWith<$Res> get meta {
    return $NewsListMetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NewsListResponseImplCopyWith<$Res>
    implements $NewsListResponseCopyWith<$Res> {
  factory _$$NewsListResponseImplCopyWith(
    _$NewsListResponseImpl value,
    $Res Function(_$NewsListResponseImpl) then,
  ) = __$$NewsListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<NewsArticle> list, NewsListMeta meta});

  @override
  $NewsListMetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$$NewsListResponseImplCopyWithImpl<$Res>
    extends _$NewsListResponseCopyWithImpl<$Res, _$NewsListResponseImpl>
    implements _$$NewsListResponseImplCopyWith<$Res> {
  __$$NewsListResponseImplCopyWithImpl(
    _$NewsListResponseImpl _value,
    $Res Function(_$NewsListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? list = null, Object? meta = null}) {
    return _then(
      _$NewsListResponseImpl(
        list: null == list
            ? _value._list
            : list // ignore: cast_nullable_to_non_nullable
                  as List<NewsArticle>,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as NewsListMeta,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NewsListResponseImpl implements _NewsListResponse {
  const _$NewsListResponseImpl({
    required final List<NewsArticle> list,
    required this.meta,
  }) : _list = list;

  factory _$NewsListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsListResponseImplFromJson(json);

  final List<NewsArticle> _list;
  @override
  List<NewsArticle> get list {
    if (_list is EqualUnmodifiableListView) return _list;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_list);
  }

  @override
  final NewsListMeta meta;

  @override
  String toString() {
    return 'NewsListResponse(list: $list, meta: $meta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsListResponseImpl &&
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

  /// Create a copy of NewsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsListResponseImplCopyWith<_$NewsListResponseImpl> get copyWith =>
      __$$NewsListResponseImplCopyWithImpl<_$NewsListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsListResponseImplToJson(this);
  }
}

abstract class _NewsListResponse implements NewsListResponse {
  const factory _NewsListResponse({
    required final List<NewsArticle> list,
    required final NewsListMeta meta,
  }) = _$NewsListResponseImpl;

  factory _NewsListResponse.fromJson(Map<String, dynamic> json) =
      _$NewsListResponseImpl.fromJson;

  @override
  List<NewsArticle> get list;
  @override
  NewsListMeta get meta;

  /// Create a copy of NewsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsListResponseImplCopyWith<_$NewsListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NewsListMeta _$NewsListMetaFromJson(Map<String, dynamic> json) {
  return _NewsListMeta.fromJson(json);
}

/// @nodoc
mixin _$NewsListMeta {
  int get currentPage => throw _privateConstructorUsedError;
  int get lastPage => throw _privateConstructorUsedError;
  int get perPage => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this NewsListMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsListMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsListMetaCopyWith<NewsListMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsListMetaCopyWith<$Res> {
  factory $NewsListMetaCopyWith(
    NewsListMeta value,
    $Res Function(NewsListMeta) then,
  ) = _$NewsListMetaCopyWithImpl<$Res, NewsListMeta>;
  @useResult
  $Res call({int currentPage, int lastPage, int perPage, int total});
}

/// @nodoc
class _$NewsListMetaCopyWithImpl<$Res, $Val extends NewsListMeta>
    implements $NewsListMetaCopyWith<$Res> {
  _$NewsListMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsListMeta
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
abstract class _$$NewsListMetaImplCopyWith<$Res>
    implements $NewsListMetaCopyWith<$Res> {
  factory _$$NewsListMetaImplCopyWith(
    _$NewsListMetaImpl value,
    $Res Function(_$NewsListMetaImpl) then,
  ) = __$$NewsListMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int currentPage, int lastPage, int perPage, int total});
}

/// @nodoc
class __$$NewsListMetaImplCopyWithImpl<$Res>
    extends _$NewsListMetaCopyWithImpl<$Res, _$NewsListMetaImpl>
    implements _$$NewsListMetaImplCopyWith<$Res> {
  __$$NewsListMetaImplCopyWithImpl(
    _$NewsListMetaImpl _value,
    $Res Function(_$NewsListMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewsListMeta
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
      _$NewsListMetaImpl(
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
class _$NewsListMetaImpl implements _NewsListMeta {
  const _$NewsListMetaImpl({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory _$NewsListMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsListMetaImplFromJson(json);

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
    return 'NewsListMeta(currentPage: $currentPage, lastPage: $lastPage, perPage: $perPage, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsListMetaImpl &&
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

  /// Create a copy of NewsListMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsListMetaImplCopyWith<_$NewsListMetaImpl> get copyWith =>
      __$$NewsListMetaImplCopyWithImpl<_$NewsListMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsListMetaImplToJson(this);
  }
}

abstract class _NewsListMeta implements NewsListMeta {
  const factory _NewsListMeta({
    required final int currentPage,
    required final int lastPage,
    required final int perPage,
    required final int total,
  }) = _$NewsListMetaImpl;

  factory _NewsListMeta.fromJson(Map<String, dynamic> json) =
      _$NewsListMetaImpl.fromJson;

  @override
  int get currentPage;
  @override
  int get lastPage;
  @override
  int get perPage;
  @override
  int get total;

  /// Create a copy of NewsListMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsListMetaImplCopyWith<_$NewsListMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
