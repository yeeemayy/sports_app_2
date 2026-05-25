// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'basketball_standings_model.freezed.dart';
part 'basketball_standings_model.g.dart';

@freezed
class BasketballStandingsTeamInfo with _$BasketballStandingsTeamInfo {
  const factory BasketballStandingsTeamInfo({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    required String logo,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _BasketballStandingsTeamInfo;

  factory BasketballStandingsTeamInfo.fromJson(Map<String, dynamic> json) =>
      _$BasketballStandingsTeamInfoFromJson(json);
}

@freezed
class BasketballStandingsRow with _$BasketballStandingsRow {
  const factory BasketballStandingsRow({
    @JsonKey(name: 'team_id') required String teamId,
    required int position,
    required int won,
    required int lost,
    @JsonKey(name: 'won_rate') double? wonRate,
    @JsonKey(name: 'game_back') String? gameBack,
    @JsonKey(name: 'points_avg') double? pointsAvg,
    @JsonKey(name: 'points_against_avg') double? pointsAgainstAvg,
    @JsonKey(name: 'diff_avg') double? diffAvg,
    @JsonKey(name: 'teamInfo') BasketballStandingsTeamInfo? teamInfo,
  }) = _BasketballStandingsRow;

  factory BasketballStandingsRow.fromJson(Map<String, dynamic> json) =>
      _$BasketballStandingsRowFromJson(json);
}

@freezed
class BasketballConferenceGroup with _$BasketballConferenceGroup {
  const factory BasketballConferenceGroup({
    required String id,
    int? scope,
    required String name,
    @JsonKey(name: 'stage_id') String? stageId,
    @JsonKey(defaultValue: []) required List<BasketballStandingsRow> rows,
  }) = _BasketballConferenceGroup;

  factory BasketballConferenceGroup.fromJson(Map<String, dynamic> json) =>
      _$BasketballConferenceGroupFromJson(json);
}
