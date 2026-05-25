// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'football_team_stat.freezed.dart';
part 'football_team_stat.g.dart';

@freezed
class FootballStatTeamInfo with _$FootballStatTeamInfo {
  const factory FootballStatTeamInfo({
    required String id,
    required String name,
    String? logo,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _FootballStatTeamInfo;

  factory FootballStatTeamInfo.fromJson(Map<String, dynamic> json) =>
      _$FootballStatTeamInfoFromJson(json);
}

@freezed
class FootballTeamStat with _$FootballTeamStat {
  const factory FootballTeamStat({
    required FootballStatTeamInfo team,
    int? matches,
    int? goals,
    int? assists,
    @JsonKey(name: 'red_cards') int? redCards,
    @JsonKey(name: 'yellow_cards') int? yellowCards,
    int? shots,
    @JsonKey(name: 'shots_on_target') int? shotsOnTarget,
    @JsonKey(name: 'passes_accuracy') int? passesAccuracy,
    int? passes,
    @JsonKey(name: 'ball_possession') int? ballPossession,
    @JsonKey(name: 'goals_against') int? goalsAgainst,
  }) = _FootballTeamStat;

  factory FootballTeamStat.fromJson(Map<String, dynamic> json) =>
      _$FootballTeamStatFromJson(json);
}
