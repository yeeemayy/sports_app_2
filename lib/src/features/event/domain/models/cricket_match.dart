import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';

part 'cricket_match.freezed.dart';
part 'cricket_match.g.dart';

@freezed
class CricketMatch with _$CricketMatch implements SportMatch {
  const CricketMatch._();

  const factory CricketMatch({
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
    String? description,
    List<dynamic>? oddsEuro,
    String? statusDescription,
  }) = _CricketMatch;

  factory CricketMatch.fromJson(Map<String, dynamic> json) =>
      _$CricketMatchFromJson(json);

  factory CricketMatch.fromSportJson(Map<String, dynamic> json) {
    final homeInfo = json['homeInfo'] is Map ? (json['homeInfo'] as Map).cast<String, dynamic>() : <String, dynamic>{};
    final awayInfo = json['awayInfo'] is Map ? (json['awayInfo'] as Map).cast<String, dynamic>() : <String, dynamic>{};
    final leagueInfo = json['leagueInfo'] is Map ? (json['leagueInfo'] as Map).cast<String, dynamic>() : <String, dynamic>{};
    final (homeScore, awayScore) = SportMatch.ftScore(json);

    return CricketMatch(
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
      description: json['description'] as String?,
      oddsEuro: (json['odds']?['euro'] as List?)?.toList(),
      statusDescription: json['statusDescription'] as String?,
    );
  }

  @override
  String? get liveMinute => null;
}
