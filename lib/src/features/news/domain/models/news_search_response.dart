import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shenghaotiyu/src/features/news/domain/models/news_article.dart';

part 'news_search_response.freezed.dart';
part 'news_search_response.g.dart';

@freezed
class NewsSearchResponse with _$NewsSearchResponse {
  const factory NewsSearchResponse({
    required List<NewsArticle> data,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'current_page') required int currentPage,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'last_page') required int lastPage,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'per_page') required int perPage,
    required int total,
  }) = _NewsSearchResponse;

  factory NewsSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsSearchResponseFromJson(json);
}
