// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'basketball_player_stat.freezed.dart';
part 'basketball_player_stat.g.dart';

@freezed
class BasketballStatPlayer with _$BasketballStatPlayer {
  const factory BasketballStatPlayer({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    String? logo,
    String? position,
    @JsonKey(name: 'shirt_number') int? shirtNumber,
    int? age,
    int? height,
    int? weight,
    String? city,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _BasketballStatPlayer;

  factory BasketballStatPlayer.fromJson(Map<String, dynamic> json) =>
      _$BasketballStatPlayerFromJson(json);
}

@freezed
class BasketballStatTeam with _$BasketballStatTeam {
  const factory BasketballStatTeam({
    required String id,
    required String name,
    String? logo,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _BasketballStatTeam;

  factory BasketballStatTeam.fromJson(Map<String, dynamic> json) =>
      _$BasketballStatTeamFromJson(json);
}

@freezed
class BasketballPlayerStat with _$BasketballPlayerStat {
  const factory BasketballPlayerStat({
    @JsonKey(name: 'player_id') required String playerId,
    @JsonKey(name: 'team_id') String? teamId,
    int? scope,
    int? matches,
    int? court,
    int? first,
    @JsonKey(name: 'minutes_played') int? minutesPlayed,
    int? points,
    @JsonKey(name: 'free_throws_scored') int? freeThrowsScored,
    @JsonKey(name: 'free_throws_total') int? freeThrowsTotal,
    @JsonKey(name: 'free_throws_accuracy') String? freeThrowsAccuracy,
    @JsonKey(name: 'two_points_scored') int? twoPointsScored,
    @JsonKey(name: 'two_points_total') int? twoPointsTotal,
    @JsonKey(name: 'two_points_accuracy') String? twoPointsAccuracy,
    @JsonKey(name: 'three_points_scored') int? threePointsScored,
    @JsonKey(name: 'three_points_total') int? threePointsTotal,
    @JsonKey(name: 'three_points_accuracy') String? threePointsAccuracy,
    @JsonKey(name: 'field_goals_scored') int? fieldGoalsScored,
    @JsonKey(name: 'field_goals_total') int? fieldGoalsTotal,
    @JsonKey(name: 'field_goals_accuracy') String? fieldGoalsAccuracy,
    int? rebounds,
    @JsonKey(name: 'defensive_rebounds') int? defensiveRebounds,
    @JsonKey(name: 'offensive_rebounds') int? offensiveRebounds,
    int? assists,
    int? turnovers,
    int? steals,
    int? blocks,
    @JsonKey(name: 'personal_fouls') int? personalFouls,
    @JsonKey(name: 'updated_at') int? updatedAt,
    BasketballStatPlayer? player,
    BasketballStatTeam? team,
  }) = _BasketballPlayerStat;

  factory BasketballPlayerStat.fromJson(Map<String, dynamic> json) =>
      _$BasketballPlayerStatFromJson(json);
}
