import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';

part 'volleyball_match.freezed.dart';
part 'volleyball_match.g.dart';

@freezed
class VolleyballMatch with _$VolleyballMatch implements SportMatch {
  const VolleyballMatch._();

  const factory VolleyballMatch({
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

    /// Per-set breakdown keyed by "p1".."p4" plus "ft" (sets won).
    Map<String, dynamic>? scores,
    List<dynamic>? oddsEuro,
    String? statusDescription,
  }) = _VolleyballMatch;

  factory VolleyballMatch.fromJson(Map<String, dynamic> json) =>
      _$VolleyballMatchFromJson(json);

  factory VolleyballMatch.fromSportJson(Map<String, dynamic> json) {
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

    return VolleyballMatch(
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
