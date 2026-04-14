// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_detail.freezed.dart';
part 'news_detail.g.dart';

@freezed
class NewsDetail with _$NewsDetail {
  const factory NewsDetail({
    required int id,
    required String title,
    required String description,
    required String content,
    @JsonKey(name: 'path') String? imageUrl,
    required String keywords,
    @JsonKey(name: 'create_time') required String createdAt,
    @JsonKey(name: 'create_time_bj') String? createdAtBj,
    @JsonKey(name: 'slug_url') required String slugUrl,
    required int browse,
    required int category,
  }) = _NewsDetail;

  factory NewsDetail.fromJson(Map<String, dynamic> json) =>
      _$NewsDetailFromJson(json);
}
