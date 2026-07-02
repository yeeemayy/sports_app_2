import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shenghaotiyu/src/features/news/domain/models/news_article.dart';

part 'news_list_response.freezed.dart';
part 'news_list_response.g.dart';

@freezed
class NewsListResponse with _$NewsListResponse {
  const factory NewsListResponse({
    required List<NewsArticle> list,
    required NewsListMeta meta,
  }) = _NewsListResponse;

  factory NewsListResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsListResponseFromJson(json);
}

@freezed
class NewsListMeta with _$NewsListMeta {
  const factory NewsListMeta({
    required int currentPage,
    required int lastPage,
    required int perPage,
    required int total,
  }) = _NewsListMeta;

  factory NewsListMeta.fromJson(Map<String, dynamic> json) =>
      _$NewsListMetaFromJson(json);
}
