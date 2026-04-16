// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
class VideoModel with _$VideoModel {
  const factory VideoModel({
    required int id,
    @JsonKey(name: 'cf_hls_url') String? cfHlsUrl,
    required String video,
    @JsonKey(name: 'create_time') required String createTime,
    @JsonKey(name: 'thumbnail_path') required String thumbnailPath,
    required String title,
    required String path,
    @JsonKey(name: 'create_time_bj') required String createTimeBj,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);
}

@freezed
class VideoListResponse with _$VideoListResponse {
  const factory VideoListResponse({
    required List<VideoModel> list,
    required VideoListMeta meta,
  }) = _VideoListResponse;

  factory VideoListResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoListResponseFromJson(json);
}

@freezed
class VideoListMeta with _$VideoListMeta {
  const factory VideoListMeta({
    required int currentPage,
    required int lastPage,
    required int perPage,
    required int total,
  }) = _VideoListMeta;

  factory VideoListMeta.fromJson(Map<String, dynamic> json) =>
      _$VideoListMetaFromJson(json);
}
