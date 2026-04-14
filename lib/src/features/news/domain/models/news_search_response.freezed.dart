// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_search_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NewsSearchResponse _$NewsSearchResponseFromJson(Map<String, dynamic> json) {
  return _NewsSearchResponse.fromJson(json);
}

/// @nodoc
mixin _$NewsSearchResponse {
  List<NewsArticle> get data => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_page')
  int get currentPage => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_page')
  int get lastPage => throw _privateConstructorUsedError;
  @JsonKey(name: 'per_page')
  int get perPage => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this NewsSearchResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsSearchResponseCopyWith<NewsSearchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsSearchResponseCopyWith<$Res> {
  factory $NewsSearchResponseCopyWith(
    NewsSearchResponse value,
    $Res Function(NewsSearchResponse) then,
  ) = _$NewsSearchResponseCopyWithImpl<$Res, NewsSearchResponse>;
  @useResult
  $Res call({
    List<NewsArticle> data,
    @JsonKey(name: 'current_page') int currentPage,
    @JsonKey(name: 'last_page') int lastPage,
    @JsonKey(name: 'per_page') int perPage,
    int total,
  });
}

/// @nodoc
class _$NewsSearchResponseCopyWithImpl<$Res, $Val extends NewsSearchResponse>
    implements $NewsSearchResponseCopyWith<$Res> {
  _$NewsSearchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? currentPage = null,
    Object? lastPage = null,
    Object? perPage = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<NewsArticle>,
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
abstract class _$$NewsSearchResponseImplCopyWith<$Res>
    implements $NewsSearchResponseCopyWith<$Res> {
  factory _$$NewsSearchResponseImplCopyWith(
    _$NewsSearchResponseImpl value,
    $Res Function(_$NewsSearchResponseImpl) then,
  ) = __$$NewsSearchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<NewsArticle> data,
    @JsonKey(name: 'current_page') int currentPage,
    @JsonKey(name: 'last_page') int lastPage,
    @JsonKey(name: 'per_page') int perPage,
    int total,
  });
}

/// @nodoc
class __$$NewsSearchResponseImplCopyWithImpl<$Res>
    extends _$NewsSearchResponseCopyWithImpl<$Res, _$NewsSearchResponseImpl>
    implements _$$NewsSearchResponseImplCopyWith<$Res> {
  __$$NewsSearchResponseImplCopyWithImpl(
    _$NewsSearchResponseImpl _value,
    $Res Function(_$NewsSearchResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewsSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? currentPage = null,
    Object? lastPage = null,
    Object? perPage = null,
    Object? total = null,
  }) {
    return _then(
      _$NewsSearchResponseImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<NewsArticle>,
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
class _$NewsSearchResponseImpl implements _NewsSearchResponse {
  const _$NewsSearchResponseImpl({
    required final List<NewsArticle> data,
    @JsonKey(name: 'current_page') required this.currentPage,
    @JsonKey(name: 'last_page') required this.lastPage,
    @JsonKey(name: 'per_page') required this.perPage,
    required this.total,
  }) : _data = data;

  factory _$NewsSearchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsSearchResponseImplFromJson(json);

  final List<NewsArticle> _data;
  @override
  List<NewsArticle> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  @JsonKey(name: 'current_page')
  final int currentPage;
  @override
  @JsonKey(name: 'last_page')
  final int lastPage;
  @override
  @JsonKey(name: 'per_page')
  final int perPage;
  @override
  final int total;

  @override
  String toString() {
    return 'NewsSearchResponse(data: $data, currentPage: $currentPage, lastPage: $lastPage, perPage: $perPage, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsSearchResponseImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.lastPage, lastPage) ||
                other.lastPage == lastPage) &&
            (identical(other.perPage, perPage) || other.perPage == perPage) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_data),
    currentPage,
    lastPage,
    perPage,
    total,
  );

  /// Create a copy of NewsSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsSearchResponseImplCopyWith<_$NewsSearchResponseImpl> get copyWith =>
      __$$NewsSearchResponseImplCopyWithImpl<_$NewsSearchResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsSearchResponseImplToJson(this);
  }
}

abstract class _NewsSearchResponse implements NewsSearchResponse {
  const factory _NewsSearchResponse({
    required final List<NewsArticle> data,
    @JsonKey(name: 'current_page') required final int currentPage,
    @JsonKey(name: 'last_page') required final int lastPage,
    @JsonKey(name: 'per_page') required final int perPage,
    required final int total,
  }) = _$NewsSearchResponseImpl;

  factory _NewsSearchResponse.fromJson(Map<String, dynamic> json) =
      _$NewsSearchResponseImpl.fromJson;

  @override
  List<NewsArticle> get data;
  @override
  @JsonKey(name: 'current_page')
  int get currentPage;
  @override
  @JsonKey(name: 'last_page')
  int get lastPage;
  @override
  @JsonKey(name: 'per_page')
  int get perPage;
  @override
  int get total;

  /// Create a copy of NewsSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsSearchResponseImplCopyWith<_$NewsSearchResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
