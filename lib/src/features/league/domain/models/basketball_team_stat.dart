// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'basketball_team_stat.freezed.dart';
part 'basketball_team_stat.g.dart';

@freezed
class BasketballStatTeamInfo with _$BasketballStatTeamInfo {
  const factory BasketballStatTeamInfo({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    String? logo,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _BasketballStatTeamInfo;

  factory BasketballStatTeamInfo.fromJson(Map<String, dynamic> json) =>
      _$BasketballStatTeamInfoFromJson(json);
}

@freezed
class BasketballTeamStat with _$BasketballTeamStat {
  const factory BasketballTeamStat({
    @JsonKey(name: 'team_id') String? teamId,
    int? matches,
    int? points,
    @JsonKey(name: 'two_pointers_accuracy') String? twoPointersAccuracy,
    @JsonKey(name: 'three_pointers_accuracy') String? threePointersAccuracy,
    @JsonKey(name: 'field_goals_accuracy') String? fieldGoalsAccuracy,
    @JsonKey(name: 'free_throws_accuracy') String? freeThrowsAccuracy,
    int? rebounds,
    @JsonKey(name: 'defensive_rebounds') int? defensiveRebounds,
    @JsonKey(name: 'offensive_rebounds') int? offensiveRebounds,
    int? assists,
    int? turnovers,
    int? steals,
    int? blocks,
    BasketballStatTeamInfo? team,
  }) = _BasketballTeamStat;

  factory BasketballTeamStat.fromJson(Map<String, dynamic> json) =>
      _$BasketballTeamStatFromJson(json);
}
