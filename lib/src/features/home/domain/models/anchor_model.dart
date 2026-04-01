// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'anchor_model.freezed.dart';
part 'anchor_model.g.dart';

// Note: JSON mixes camelCase (isLive, liveMode, avatarUrl) and snake_case (collect_status).
// fieldRename is intentionally NOT used — only explicit @JsonKey where needed.
@freezed
class AnchorModel with _$AnchorModel {
  const factory AnchorModel({
    required int id,
    required int isLive,
    required String title,
    required String notice,
    required int liveMode,
    required String nickname,
    required int collect,
    required String avatarUrl,
    @JsonKey(name: 'collect_status') required int collectStatus,
    required String cover,
  }) = _AnchorModel;

  factory AnchorModel.fromJson(Map<String, dynamic> json) =>
      _$AnchorModelFromJson(json);
}
