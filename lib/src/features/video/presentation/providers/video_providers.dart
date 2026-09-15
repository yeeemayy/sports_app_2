import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/features/video/data/video_repository.dart';
import 'package:shenghaotiyu/src/features/video/domain/models/video_detail.dart';
import 'package:shenghaotiyu/src/features/video/domain/models/video_model.dart';

part 'video_providers.g.dart';

/// Small in-memory cache so revisiting an already-fetched page (e.g. paging
/// back to page 1 on the home feed) doesn't refire a network call for the
/// lifetime of this provider container.
final _listCache = <String, VideoListResponse>{};

String _listCacheKey(String locale, int page) => '$locale/$page';

@riverpod
Future<VideoListResponse> videoList(
  VideoListRef ref, {
  required String locale,
  int page = 1,
}) async {
  final cacheKey = _listCacheKey(locale, page);
  final cached = _listCache[cacheKey];
  if (cached != null) return cached;

  final api = ref.watch(videoApiProvider);
  final result = await api.fetchList(locale: locale, page: page);
  _listCache[cacheKey] = result;
  return result;
}

@riverpod
Future<VideoDetail> videoDetail(VideoDetailRef ref, int id, String locale) {
  final api = ref.watch(videoApiProvider);
  return api.fetchDetail(locale: locale, id: id);
}
