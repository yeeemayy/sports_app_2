import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/core/services/api_service.dart';
import 'package:shenghaotiyu/src/features/video/domain/models/video_detail.dart';
import 'package:shenghaotiyu/src/features/video/domain/models/video_model.dart';

part 'video_repository.g.dart';

/// Plain API client for the video endpoints, decoupled from Riverpod's
/// notifier lifecycle so it can be unit tested without a ProviderContainer.
class VideoApi {
  VideoApi(this._dio);

  final Dio _dio;

  static const _basePath = '/video';

  String _listPath(String locale, int page) => '$_basePath-list/$locale/$page';
  String _detailPath(String locale, int id) => '$_basePath/$locale/$id';

  Future<VideoListResponse> fetchList({required String locale, required int page}) async {
    final response = await _dio.get(_listPath(locale, page));
    return VideoListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VideoDetail> fetchDetail({required String locale, required int id}) async {
    final response = await _dio.get(_detailPath(locale, id));
    return VideoDetail.fromJson(response.data as Map<String, dynamic>);
  }
}

@Riverpod(keepAlive: true)
VideoApi videoApi(VideoApiRef ref) {
  return VideoApi(ref.watch(newsApiServiceProvider));
}
