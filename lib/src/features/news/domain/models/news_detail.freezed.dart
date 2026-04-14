// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NewsDetail _$NewsDetailFromJson(Map<String, dynamic> json) {
  return _NewsDetail.fromJson(json);
}

/// @nodoc
mixin _$NewsDetail {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'path')
  String? get imageUrl => throw _privateConstructorUsedError;
  String get keywords => throw _privateConstructorUsedError;
  @JsonKey(name: 'create_time')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'create_time_bj')
  String? get createdAtBj => throw _privateConstructorUsedError;
  @JsonKey(name: 'slug_url')
  String get slugUrl => throw _privateConstructorUsedError;
  int get browse => throw _privateConstructorUsedError;
  int get category => throw _privateConstructorUsedError;

  /// Serializes this NewsDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsDetailCopyWith<NewsDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsDetailCopyWith<$Res> {
  factory $NewsDetailCopyWith(
    NewsDetail value,
    $Res Function(NewsDetail) then,
  ) = _$NewsDetailCopyWithImpl<$Res, NewsDetail>;
  @useResult
  $Res call({
    int id,
    String title,
    String description,
    String content,
    @JsonKey(name: 'path') String? imageUrl,
    String keywords,
    @JsonKey(name: 'create_time') String createdAt,
    @JsonKey(name: 'create_time_bj') String? createdAtBj,
    @JsonKey(name: 'slug_url') String slugUrl,
    int browse,
    int category,
  });
}

/// @nodoc
class _$NewsDetailCopyWithImpl<$Res, $Val extends NewsDetail>
    implements $NewsDetailCopyWith<$Res> {
  _$NewsDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? keywords = null,
    Object? createdAt = null,
    Object? createdAtBj = freezed,
    Object? slugUrl = null,
    Object? browse = null,
    Object? category = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            keywords: null == keywords
                ? _value.keywords
                : keywords // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAtBj: freezed == createdAtBj
                ? _value.createdAtBj
                : createdAtBj // ignore: cast_nullable_to_non_nullable
                      as String?,
            slugUrl: null == slugUrl
                ? _value.slugUrl
                : slugUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            browse: null == browse
                ? _value.browse
                : browse // ignore: cast_nullable_to_non_nullable
                      as int,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NewsDetailImplCopyWith<$Res>
    implements $NewsDetailCopyWith<$Res> {
  factory _$$NewsDetailImplCopyWith(
    _$NewsDetailImpl value,
    $Res Function(_$NewsDetailImpl) then,
  ) = __$$NewsDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String description,
    String content,
    @JsonKey(name: 'path') String? imageUrl,
    String keywords,
    @JsonKey(name: 'create_time') String createdAt,
    @JsonKey(name: 'create_time_bj') String? createdAtBj,
    @JsonKey(name: 'slug_url') String slugUrl,
    int browse,
    int category,
  });
}

/// @nodoc
class __$$NewsDetailImplCopyWithImpl<$Res>
    extends _$NewsDetailCopyWithImpl<$Res, _$NewsDetailImpl>
    implements _$$NewsDetailImplCopyWith<$Res> {
  __$$NewsDetailImplCopyWithImpl(
    _$NewsDetailImpl _value,
    $Res Function(_$NewsDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewsDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? keywords = null,
    Object? createdAt = null,
    Object? createdAtBj = freezed,
    Object? slugUrl = null,
    Object? browse = null,
    Object? category = null,
  }) {
    return _then(
      _$NewsDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        keywords: null == keywords
            ? _value.keywords
            : keywords // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAtBj: freezed == createdAtBj
            ? _value.createdAtBj
            : createdAtBj // ignore: cast_nullable_to_non_nullable
                  as String?,
        slugUrl: null == slugUrl
            ? _value.slugUrl
            : slugUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        browse: null == browse
            ? _value.browse
            : browse // ignore: cast_nullable_to_non_nullable
                  as int,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NewsDetailImpl implements _NewsDetail {
  const _$NewsDetailImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    @JsonKey(name: 'path') this.imageUrl,
    required this.keywords,
    @JsonKey(name: 'create_time') required this.createdAt,
    @JsonKey(name: 'create_time_bj') this.createdAtBj,
    @JsonKey(name: 'slug_url') required this.slugUrl,
    required this.browse,
    required this.category,
  });

  factory _$NewsDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsDetailImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String content;
  @override
  @JsonKey(name: 'path')
  final String? imageUrl;
  @override
  final String keywords;
  @override
  @JsonKey(name: 'create_time')
  final String createdAt;
  @override
  @JsonKey(name: 'create_time_bj')
  final String? createdAtBj;
  @override
  @JsonKey(name: 'slug_url')
  final String slugUrl;
  @override
  final int browse;
  @override
  final int category;

  @override
  String toString() {
    return 'NewsDetail(id: $id, title: $title, description: $description, content: $content, imageUrl: $imageUrl, keywords: $keywords, createdAt: $createdAt, createdAtBj: $createdAtBj, slugUrl: $slugUrl, browse: $browse, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.keywords, keywords) ||
                other.keywords == keywords) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdAtBj, createdAtBj) ||
                other.createdAtBj == createdAtBj) &&
            (identical(other.slugUrl, slugUrl) || other.slugUrl == slugUrl) &&
            (identical(other.browse, browse) || other.browse == browse) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    content,
    imageUrl,
    keywords,
    createdAt,
    createdAtBj,
    slugUrl,
    browse,
    category,
  );

  /// Create a copy of NewsDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsDetailImplCopyWith<_$NewsDetailImpl> get copyWith =>
      __$$NewsDetailImplCopyWithImpl<_$NewsDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsDetailImplToJson(this);
  }
}

abstract class _NewsDetail implements NewsDetail {
  const factory _NewsDetail({
    required final int id,
    required final String title,
    required final String description,
    required final String content,
    @JsonKey(name: 'path') final String? imageUrl,
    required final String keywords,
    @JsonKey(name: 'create_time') required final String createdAt,
    @JsonKey(name: 'create_time_bj') final String? createdAtBj,
    @JsonKey(name: 'slug_url') required final String slugUrl,
    required final int browse,
    required final int category,
  }) = _$NewsDetailImpl;

  factory _NewsDetail.fromJson(Map<String, dynamic> json) =
      _$NewsDetailImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get content;
  @override
  @JsonKey(name: 'path')
  String? get imageUrl;
  @override
  String get keywords;
  @override
  @JsonKey(name: 'create_time')
  String get createdAt;
  @override
  @JsonKey(name: 'create_time_bj')
  String? get createdAtBj;
  @override
  @JsonKey(name: 'slug_url')
  String get slugUrl;
  @override
  int get browse;
  @override
  int get category;

  /// Create a copy of NewsDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsDetailImplCopyWith<_$NewsDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
