// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_article.freezed.dart';
part 'news_article.g.dart';

@freezed
class NewsArticle with _$NewsArticle {
  const factory NewsArticle({
    required int id,
    required String title,
    required String description,
    @JsonKey(name: 'path') String? imageUrl,
    required String keywords,
    @JsonKey(name: 'create_time') required String createdAt,
    @JsonKey(name: 'slug_url') required String slugUrl,
    required int browse,
    required int category,
  }) = _NewsArticle;

  factory NewsArticle.fromJson(Map<String, dynamic> json) =>
      _$NewsArticleFromJson(json);
}
