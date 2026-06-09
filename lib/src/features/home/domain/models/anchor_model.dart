import 'package:freezed_annotation/freezed_annotation.dart';

part 'anchor_model.freezed.dart';
part 'anchor_model.g.dart';

@freezed
class AnchorModel with _$AnchorModel {
  const factory AnchorModel({
    required int id,
    required int isLive,
    required String title,
    required String notice,
    required int liveMode,
    required String nickname,
    required String avatarUrl,
    required String cover,
  }) = _AnchorModel;

  factory AnchorModel.fromJson(Map<String, dynamic> json) =>
      _$AnchorModelFromJson(json);
}
