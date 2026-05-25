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
    int? matches,
    int? points,
    int? rebounds,
    int? assists,
    int? steals,
    int? blocks,
    @JsonKey(name: 'minutes_played') int? minutesPlayed,
    BasketballStatPlayer? player,
    BasketballStatTeam? team,
  }) = _BasketballPlayerStat;

  factory BasketballPlayerStat.fromJson(Map<String, dynamic> json) =>
      _$BasketballPlayerStatFromJson(json);
}
