// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_detail.freezed.dart';
part 'video_detail.g.dart';

@freezed
class VideoDetail with _$VideoDetail {
  const factory VideoDetail({
    required int id,
    @JsonKey(name: 'albb_hls_url') String? albbHlsUrl,
    @JsonKey(name: 'cf_hls_url') String? cfHlsUrl,
    @JsonKey(name: 'thumbnail_path') required String thumbnailPath,
    @JsonKey(name: 'create_time') required String createTime,
    required String title,
    required String path,
    String? type,
  }) = _VideoDetail;

  factory VideoDetail.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailFromJson(json);
}
