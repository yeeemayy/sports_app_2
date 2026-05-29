// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'football_standings_model.freezed.dart';
part 'football_standings_model.g.dart';

@freezed
class FootballStandingsTeamInfo with _$FootballStandingsTeamInfo {
  const factory FootballStandingsTeamInfo({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    required String logo,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _FootballStandingsTeamInfo;

  factory FootballStandingsTeamInfo.fromJson(Map<String, dynamic> json) =>
      _$FootballStandingsTeamInfoFromJson(json);
}

@freezed
class FootballStandingsRow with _$FootballStandingsRow {
  const factory FootballStandingsRow({
    @JsonKey(name: 'team_id') required String teamId,
    @JsonKey(name: 'promotion_id') String? promotionId,
    required int points,
    required int position,
    @JsonKey(name: 'deduct_points') int? deductPoints,
    required int total,
    required int won,
    required int draw,
    required int loss,
    required int goals,
    @JsonKey(name: 'goals_against') required int goalsAgainst,
    @JsonKey(name: 'goal_diff') required int goalDiff,
    // home stats
    @JsonKey(name: 'home_points') int? homePoints,
    @JsonKey(name: 'home_total') int? homeTotal,
    @JsonKey(name: 'home_won') int? homeWon,
    @JsonKey(name: 'home_draw') int? homeDraw,
    @JsonKey(name: 'home_loss') int? homeLoss,
    @JsonKey(name: 'home_goals') int? homeGoals,
    @JsonKey(name: 'home_goals_against') int? homeGoalsAgainst,
    @JsonKey(name: 'home_goal_diff') int? homeGoalDiff,
    // away stats
    @JsonKey(name: 'away_points') int? awayPoints,
    @JsonKey(name: 'away_total') int? awayTotal,
    @JsonKey(name: 'away_won') int? awayWon,
    @JsonKey(name: 'away_draw') int? awayDraw,
    @JsonKey(name: 'away_loss') int? awayLoss,
    @JsonKey(name: 'away_goals') int? awayGoals,
    @JsonKey(name: 'away_goals_against') int? awayGoalsAgainst,
    @JsonKey(name: 'away_goal_diff') int? awayGoalDiff,
    @JsonKey(name: 'teamInfo') FootballStandingsTeamInfo? teamInfo,
  }) = _FootballStandingsRow;

  factory FootballStandingsRow.fromJson(Map<String, dynamic> json) =>
      _$FootballStandingsRowFromJson(json);
}

@freezed
class FootballStandingsGroup with _$FootballStandingsGroup {
  const factory FootballStandingsGroup({
    required String id,
    String? conference,
    int? group,
    @JsonKey(name: 'stage_id') String? stageId,
    @JsonKey(defaultValue: []) required List<FootballStandingsRow> rows,
  }) = _FootballStandingsGroup;

  factory FootballStandingsGroup.fromJson(Map<String, dynamic> json) =>
      _$FootballStandingsGroupFromJson(json);
}
