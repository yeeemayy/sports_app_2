import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';

part 'basketball_match.freezed.dart';
part 'basketball_match.g.dart';

@freezed
class BasketballMatch with _$BasketballMatch implements SportMatch {
  const BasketballMatch._();

  const factory BasketballMatch({
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

    /// Game clock remaining, e.g. "01:23".
    String? counterTiming,
    int? runningTime,
    List<dynamic>? oddsEuro,
    String? statusDescription,
  }) = _BasketballMatch;

  factory BasketballMatch.fromJson(Map<String, dynamic> json) =>
      _$BasketballMatchFromJson(json);

  factory BasketballMatch.fromSportJson(Map<String, dynamic> json) {
    final homeInfo = json['homeInfo'] is Map
        ? (json['homeInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final awayInfo = json['awayInfo'] is Map
        ? (json['awayInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final leagueInfo = json['leagueInfo'] is Map
        ? (json['leagueInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    int sectionTotal(Map<String, dynamic> info) =>
        (info['section_1'] as int? ?? 0) +
        (info['section_2'] as int? ?? 0) +
        (info['section_3'] as int? ?? 0) +
        (info['section_4'] as int? ?? 0) +
        (info['section_overtime'] as int? ?? 0);

    final homeTotal = sectionTotal(homeInfo);
    final awayTotal = sectionTotal(awayInfo);

    return BasketballMatch(
      id: json['id'] as String? ?? '',
      statusId: json['status_id'] as int? ?? 0,
      matchTimeSim: json['match_time_bj_sim'] as String? ?? '',
      homeName: SportMatch.teamName(homeInfo),
      homeLogo: homeInfo['logo'] as String? ?? '',
      homeScore: homeTotal == 0 ? '-' : homeTotal.toString(),
      awayName: SportMatch.teamName(awayInfo),
      awayLogo: awayInfo['logo'] as String? ?? '',
      awayScore: awayTotal == 0 ? '-' : awayTotal.toString(),
      leagueName: SportMatch.teamName(leagueInfo),
      leagueLogo: leagueInfo['logo'] as String? ?? '',
      matchTime: json['match_time'] as int?,
      counterTiming: json['counter_timing'] is String
          ? json['counter_timing']
          : json['counter_timing'].toString(),
      runningTime: json['runningTime'] as int?,
      oddsEuro: (json['odds']?['euro'] as List?)?.toList(),
      statusDescription: json['statusDescription'] as String?,
    );
  }

  @override
  String? get liveMinute => counterTiming;
}
