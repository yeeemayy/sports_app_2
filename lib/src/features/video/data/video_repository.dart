import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/core/services/api_service.dart';
import 'package:shenghaotiyu/src/features/video/domain/models/video_detail.dart';
import 'package:shenghaotiyu/src/features/video/domain/models/video_model.dart';

part 'video_repository.g.dart';

@Riverpod(keepAlive: true)
class VideoRepository extends _$VideoRepository {
  @override
  void build() {}

  Future<VideoListResponse> getVideos({
    required String locale,
    int page = 1,
  }) async {
    final dio = ref.read(newsApiServiceProvider);
    final response = await dio.get('/video-list/$locale/$page');
    return VideoListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VideoDetail> getVideoDetail({
    required String locale,
    required int id,
  }) async {
    final dio = ref.read(newsApiServiceProvider);
    final response = await dio.get('/video/$locale/$id');
    return VideoDetail.fromJson(response.data as Map<String, dynamic>);
  }
}
