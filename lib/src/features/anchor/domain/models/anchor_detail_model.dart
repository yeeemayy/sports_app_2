// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'anchor_detail_model.freezed.dart';
part 'anchor_detail_model.g.dart';

@freezed
class AnchorDetailModel with _$AnchorDetailModel {
  const factory AnchorDetailModel({
    required int id,
    required int isLive,
    required String nickname,
    required String avatarUrl,
    @JsonKey(name: 'collect_status') required int collectStatus,
    required String title,
    required int collect,
    required String notice,
    required int liveMode,
    String? m3u8Url,
    required String cover,
    required String matchId,
    @JsonKey(defaultValue: '') required String mode,
    @JsonKey(defaultValue: <dynamic>[]) required List<dynamic> live,
    @JsonKey(defaultValue: '') required String schedule,
    @JsonKey(defaultValue: false) required bool playAnimate,
    @JsonKey(defaultValue: '') required String client,
    required String updated,
  }) = _AnchorDetailModel;

  factory AnchorDetailModel.fromJson(Map<String, dynamic> json) =>
      _$AnchorDetailModelFromJson(json);
}
