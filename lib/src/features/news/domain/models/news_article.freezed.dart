// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NewsArticle _$NewsArticleFromJson(Map<String, dynamic> json) {
  return _NewsArticle.fromJson(json);
}

/// @nodoc
mixin _$NewsArticle {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'path')
  String? get imageUrl => throw _privateConstructorUsedError;
  String get keywords => throw _privateConstructorUsedError;
  @JsonKey(name: 'create_time')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'slug_url')
  String get slugUrl => throw _privateConstructorUsedError;
  int get browse => throw _privateConstructorUsedError;
  int get category => throw _privateConstructorUsedError;

  /// Serializes this NewsArticle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsArticle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsArticleCopyWith<NewsArticle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsArticleCopyWith<$Res> {
  factory $NewsArticleCopyWith(
    NewsArticle value,
    $Res Function(NewsArticle) then,
  ) = _$NewsArticleCopyWithImpl<$Res, NewsArticle>;
  @useResult
  $Res call({
    int id,
    String title,
    String description,
    @JsonKey(name: 'path') String? imageUrl,
    String keywords,
    @JsonKey(name: 'create_time') String createdAt,
    @JsonKey(name: 'slug_url') String slugUrl,
    int browse,
    int category,
  });
}

/// @nodoc
class _$NewsArticleCopyWithImpl<$Res, $Val extends NewsArticle>
    implements $NewsArticleCopyWith<$Res> {
  _$NewsArticleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsArticle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? keywords = null,
    Object? createdAt = null,
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
abstract class _$$NewsArticleImplCopyWith<$Res>
    implements $NewsArticleCopyWith<$Res> {
  factory _$$NewsArticleImplCopyWith(
    _$NewsArticleImpl value,
    $Res Function(_$NewsArticleImpl) then,
  ) = __$$NewsArticleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String description,
    @JsonKey(name: 'path') String? imageUrl,
    String keywords,
    @JsonKey(name: 'create_time') String createdAt,
    @JsonKey(name: 'slug_url') String slugUrl,
    int browse,
    int category,
  });
}

/// @nodoc
class __$$NewsArticleImplCopyWithImpl<$Res>
    extends _$NewsArticleCopyWithImpl<$Res, _$NewsArticleImpl>
    implements _$$NewsArticleImplCopyWith<$Res> {
  __$$NewsArticleImplCopyWithImpl(
    _$NewsArticleImpl _value,
    $Res Function(_$NewsArticleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewsArticle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? keywords = null,
    Object? createdAt = null,
    Object? slugUrl = null,
    Object? browse = null,
    Object? category = null,
  }) {
    return _then(
      _$NewsArticleImpl(
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
class _$NewsArticleImpl implements _NewsArticle {
  const _$NewsArticleImpl({
    required this.id,
    required this.title,
    required this.description,
    @JsonKey(name: 'path') this.imageUrl,
    required this.keywords,
    @JsonKey(name: 'create_time') required this.createdAt,
    @JsonKey(name: 'slug_url') required this.slugUrl,
    required this.browse,
    required this.category,
  });

  factory _$NewsArticleImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsArticleImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey(name: 'path')
  final String? imageUrl;
  @override
  final String keywords;
  @override
  @JsonKey(name: 'create_time')
  final String createdAt;
  @override
  @JsonKey(name: 'slug_url')
  final String slugUrl;
  @override
  final int browse;
  @override
  final int category;

  @override
  String toString() {
    return 'NewsArticle(id: $id, title: $title, description: $description, imageUrl: $imageUrl, keywords: $keywords, createdAt: $createdAt, slugUrl: $slugUrl, browse: $browse, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsArticleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.keywords, keywords) ||
                other.keywords == keywords) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
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
    imageUrl,
    keywords,
    createdAt,
    slugUrl,
    browse,
    category,
  );

  /// Create a copy of NewsArticle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsArticleImplCopyWith<_$NewsArticleImpl> get copyWith =>
      __$$NewsArticleImplCopyWithImpl<_$NewsArticleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsArticleImplToJson(this);
  }
}

abstract class _NewsArticle implements NewsArticle {
  const factory _NewsArticle({
    required final int id,
    required final String title,
    required final String description,
    @JsonKey(name: 'path') final String? imageUrl,
    required final String keywords,
    @JsonKey(name: 'create_time') required final String createdAt,
    @JsonKey(name: 'slug_url') required final String slugUrl,
    required final int browse,
    required final int category,
  }) = _$NewsArticleImpl;

  factory _NewsArticle.fromJson(Map<String, dynamic> json) =
      _$NewsArticleImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get description;
  @override
  @JsonKey(name: 'path')
  String? get imageUrl;
  @override
  String get keywords;
  @override
  @JsonKey(name: 'create_time')
  String get createdAt;
  @override
  @JsonKey(name: 'slug_url')
  String get slugUrl;
  @override
  int get browse;
  @override
  int get category;

  /// Create a copy of NewsArticle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsArticleImplCopyWith<_$NewsArticleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
