import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/features/video/data/video_repository.dart';
import 'package:sports_app/src/features/video/domain/models/video_detail.dart';
import 'package:sports_app/src/features/video/domain/models/video_model.dart';

part 'video_providers.g.dart';

@riverpod
Future<VideoListResponse> videoList(
  VideoListRef ref, {
  required String locale,
  int page = 1,
}) {
  return ref.watch(videoRepositoryProvider.notifier).getVideos(
        locale: locale,
        page: page,
      );
}

@riverpod
Future<VideoDetail> videoDetail(
  VideoDetailRef ref,
  int id,
  String locale,
) {
  return ref.watch(videoRepositoryProvider.notifier).getVideoDetail(
        locale: locale,
        id: id,
      );
}
