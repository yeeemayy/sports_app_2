import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_match.dart';

part 'table_tennis_match.freezed.dart';
part 'table_tennis_match.g.dart';

@freezed
class TableTennisMatch with _$TableTennisMatch implements SportMatch {
  const TableTennisMatch._();

  const factory TableTennisMatch({
    required String id,
    required int statusId,
    required String matchTimeSim,
    required String homeName,
    required String homeLogo,
    required String homeScore,
    required String awayName,
    required String awayLogo,
    required String awayScore,
    required String leagueName,
    required String leagueLogo,
    int? matchTime,
    int? bestof,

    /// Per-game breakdown keyed by "p1".."p4" plus "ft" (games won).
    Map<String, dynamic>? scores,
    List<dynamic>? oddsEuro,
    String? statusDescription,
  }) = _TableTennisMatch;

  factory TableTennisMatch.fromJson(Map<String, dynamic> json) =>
      _$TableTennisMatchFromJson(json);

  factory TableTennisMatch.fromSportJson(Map<String, dynamic> json) {
    final homeInfo = json['homeInfo'] is Map
        ? (json['homeInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final awayInfo = json['awayInfo'] is Map
        ? (json['awayInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final leagueInfo = json['leagueInfo'] is Map
        ? (json['leagueInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final (homeScore, awayScore) = SportMatch.ftScore(json);

    return TableTennisMatch(
      id: json['id'] as String? ?? '',
      statusId: json['status_id'] as int? ?? 0,
      matchTimeSim: json['match_time_bj_sim'] as String? ?? '',
      homeName: SportMatch.teamName(homeInfo),
      homeLogo: homeInfo['logo'] as String? ?? '',
      homeScore: homeScore,
      awayName: SportMatch.teamName(awayInfo),
      awayLogo: awayInfo['logo'] as String? ?? '',
      awayScore: awayScore,
      leagueName: SportMatch.teamName(leagueInfo),
      leagueLogo: leagueInfo['logo'] as String? ?? '',
      matchTime: json['match_time'] as int?,
      bestof: json['bestof'] as int?,
      scores: json['scores'] is Map
          ? (json['scores'] as Map).cast<String, dynamic>()
          : null,
      oddsEuro: (json['odds']?['euro'] as List?)?.toList(),
      statusDescription: json['statusDescription'] as String?,
    );
  }

  @override
  String? get liveMinute => null;
}
