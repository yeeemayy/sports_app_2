// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'football_player_stat.freezed.dart';
part 'football_player_stat.g.dart';

@freezed
class FootballStatPlayer with _$FootballStatPlayer {
  const factory FootballStatPlayer({
    required String id,
    required String name,
    String? logo,
    String? position,
    String? nationality,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _FootballStatPlayer;

  factory FootballStatPlayer.fromJson(Map<String, dynamic> json) =>
      _$FootballStatPlayerFromJson(json);
}

@freezed
class FootballStatTeam with _$FootballStatTeam {
  const factory FootballStatTeam({
    required String id,
    required String name,
    String? logo,
  }) = _FootballStatTeam;

  factory FootballStatTeam.fromJson(Map<String, dynamic> json) =>
      _$FootballStatTeamFromJson(json);
}

@freezed
class FootballPlayerStat with _$FootballPlayerStat {
  const factory FootballPlayerStat({
    required FootballStatPlayer player,
    required FootballStatTeam team,
    int? matches,
    int? goals,
    int? assists,
    int? shots,
    @JsonKey(name: 'shots_on_target') int? shotsOnTarget,
    @JsonKey(name: 'minutes_played') int? minutesPlayed,
    @JsonKey(name: 'red_cards') int? redCards,
    @JsonKey(name: 'yellow_cards') int? yellowCards,
    int? rating,
    @JsonKey(name: 'key_passes') int? keyPasses,
    @JsonKey(name: 'dribble_succ') int? dribbleSucc,
    int? tackles,
    int? saves,
  }) = _FootballPlayerStat;

  factory FootballPlayerStat.fromJson(Map<String, dynamic> json) =>
      _$FootballPlayerStatFromJson(json);
}
