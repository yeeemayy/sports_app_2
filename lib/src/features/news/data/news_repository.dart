import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/services/api_service.dart';
import 'package:sports_app/src/core/utils/app_info.dart';
import 'package:sports_app/src/features/news/domain/models/news_detail.dart';
import 'package:sports_app/src/features/news/domain/models/news_list_response.dart';
import 'package:sports_app/src/features/news/domain/models/news_search_response.dart';

part 'news_repository.g.dart';

@Riverpod(keepAlive: true)
class NewsRepository extends _$NewsRepository {
  @override
  void build() {}

  Future<NewsListResponse> getNewsList({
    required String locale,
    required int page,
    int? dayOffsets,
  }) async {
    final dio = ref.read(newsApiServiceProvider);
    final response = await dio.get(
      '/post-list/$locale/$page',
      queryParameters: {
        if (dayOffsets != null) 'dayoffsets': dayOffsets,
        'appid': AppInfo.packageName,
      },
    );
    return NewsListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NewsDetail> getNewsDetail({required String locale, required int id}) async {
    final dio = ref.read(newsApiServiceProvider);
    final response = await dio.get(
      '/post/$locale/$id',
      queryParameters: {'appid': AppInfo.packageName},
    );
    return NewsDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NewsSearchResponse> searchNews({
    required String locale,
    required String keywords,
    required int page,
    int perPage = 10,
  }) async {
    final dio = ref.read(newsApiServiceProvider);
    final response = await dio.get(
      '/post-keyword/$locale/$keywords',
      queryParameters: {'page': page, 'perPage': perPage, 'appid': AppInfo.packageName},
    );
    return NewsSearchResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
