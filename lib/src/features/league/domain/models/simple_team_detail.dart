// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'simple_team_detail.freezed.dart';
part 'simple_team_detail.g.dart';

/// Lightweight team/participant model used by sports other than Football and
/// Basketball, where the API returns a simpler structure.
@freezed
class SimpleTeamDetail with _$SimpleTeamDetail {
  const factory SimpleTeamDetail({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    String? abbr,
    @JsonKey(defaultValue: '') String? logo,
    @JsonKey(name: 'cn_name') String? cnName,
    int? gender,
    @JsonKey(name: 'country_id') String? countryId,
    // Tennis / badminton doubles partners
    @JsonKey(name: 'sub_ids') @Default([]) List<String> subIds,
  }) = _SimpleTeamDetail;

  factory SimpleTeamDetail.fromJson(Map<String, dynamic> json) =>
      _$SimpleTeamDetailFromJson(json);
}
