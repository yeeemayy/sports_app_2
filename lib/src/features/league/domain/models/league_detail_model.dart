// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'league_detail_model.freezed.dart';
part 'league_detail_model.g.dart';

@freezed
class LeagueSeasonDetails with _$LeagueSeasonDetails {
  const factory LeagueSeasonDetails({
    required String id,
    @JsonKey(name: 'competition_id') String? competitionId,
    required String year,
    @JsonKey(name: 'has_player_stats') int? hasPlayerStats,
    @JsonKey(name: 'has_team_stats') int? hasTeamStats,
    @JsonKey(name: 'has_table') int? hasTable,
    @JsonKey(name: 'is_current') int? isCurrent,
    @JsonKey(name: 'start_time') int? startTime,
    @JsonKey(name: 'end_time') int? endTime,
  }) = _LeagueSeasonDetails;

  factory LeagueSeasonDetails.fromJson(Map<String, dynamic> json) =>
      _$LeagueSeasonDetailsFromJson(json);
}

@freezed
class LeagueCategoryDetails with _$LeagueCategoryDetails {
  const factory LeagueCategoryDetails({
    required String id,
    required String name,
    @JsonKey(name: 'cn_name') String? cnName,
  }) = _LeagueCategoryDetails;

  factory LeagueCategoryDetails.fromJson(Map<String, dynamic> json) =>
      _$LeagueCategoryDetailsFromJson(json);
}

@freezed
class LeagueDetailModel with _$LeagueDetailModel {
  const factory LeagueDetailModel({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    required String logo,

    /// Type: 1 = regular, 2 = cup
    int? type,
    @JsonKey(name: 'primary_color') String? primaryColor,
    @JsonKey(name: 'secondary_color') String? secondaryColor,
    @JsonKey(name: 'totalTeams') int? totalTeams,
    @JsonKey(name: 'totalPlayers') int? totalPlayers,

    /// Football-specific aggregate stats
    int? goals,
    int? assists,
    int? shots,
    @JsonKey(name: 'red_cards') int? redCards,
    @JsonKey(name: 'yellow_cards') int? yellowCards,
    @JsonKey(name: 'yellow2red_cards') int? yellow2redCards,
    int? fouls,

    /// Basketball-specific aggregate stats
    int? points,
    int? rebounds,
    int? turnovers,
    int? blocks,
    @JsonKey(name: 'cur_round') int? curRound,
    @JsonKey(name: 'round_count') int? roundCount,
    @JsonKey(name: 'cn_name') String? cnName,
    @JsonKey(name: 'curr_season_details') LeagueSeasonDetails? currSeasonDetails,
    @JsonKey(name: 'categoryDetails') LeagueCategoryDetails? categoryDetails,
  }) = _LeagueDetailModel;

  factory LeagueDetailModel.fromJson(Map<String, dynamic> json) =>
      _$LeagueDetailModelFromJson(json);
}
