import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';

part 'football_match.freezed.dart';
part 'football_match.g.dart';

@freezed
class FootballMatch with _$FootballMatch implements SportMatch {
  const FootballMatch._();

  const factory FootballMatch({
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
    int? counterTiming,
    List<dynamic>? oddsEuro,
    String? statusDescription,
    String? htHomeScore,
    String? htAwayScore,
    @Default(0) int homeYellowCards,
    @Default(0) int awayYellowCards,
    @Default(0) int homeRedCards,
    @Default(0) int awayRedCards,
  }) = _FootballMatch;

  factory FootballMatch.fromJson(Map<String, dynamic> json) => _$FootballMatchFromJson(json);

  factory FootballMatch.fromSportJson(Map<String, dynamic> json) {
    final homeInfo = json['homeInfo'] is Map
        ? (json['homeInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final awayInfo = json['awayInfo'] is Map
        ? (json['awayInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final leagueInfo = json['leagueInfo'] is Map
        ? (json['leagueInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    return FootballMatch(
      id: json['id'] as String? ?? '',
      statusId: json['status_id'] as int? ?? 0,
      matchTimeSim: json['match_time_bj_sim'] as String? ?? '',
      homeName: SportMatch.teamName(homeInfo),
      homeLogo: homeInfo['logo'] as String? ?? '',
      homeScore: (homeInfo['home_score'] ?? '-').toString(),
      awayName: SportMatch.teamName(awayInfo),
      awayLogo: awayInfo['logo'] as String? ?? '',
      awayScore: (awayInfo['away_score'] ?? '-').toString(),
      leagueName: SportMatch.teamName(leagueInfo),
      leagueLogo: leagueInfo['logo'] as String? ?? '',
      matchTime: json['match_time'] as int?,
      counterTiming: json['counter_timing'] as int?,
      oddsEuro: json['odds'] is List && (json['odds'] as List).isNotEmpty
          ? (json['odds']?['euro'] as List?)?.toList()
          : null,
      statusDescription: json['statusDescription'] as String?,
      htHomeScore: _parseHtScore(homeInfo),
      htAwayScore: _parseHtScore(awayInfo),
      homeYellowCards: homeInfo['yellow_cards'] as int? ?? 0,
      awayYellowCards: awayInfo['yellow_cards'] as int? ?? 0,
      homeRedCards: homeInfo['red_cards'] as int? ?? 0,
      awayRedCards: awayInfo['red_cards'] as int? ?? 0,
    );
  }

  @override
  String? get liveMinute {
    if (counterTiming == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final elapsed = ((now - counterTiming!) / 60).floor();
    if (statusId == 2) {
      final minute = elapsed + 1;
      return minute <= 45 ? "$minute'" : "45+'";
    }
    if (statusId == 4) {
      final minute = elapsed + 46;
      return minute <= 90 ? "$minute'" : "90+'";
    }
    if (statusId == 5 || statusId == 6) {
      final minute = elapsed + 91;
      return minute <= 105 ? "$minute'" : "105+${elapsed - 14}'";
    }
    return null;
  }

  String get statusLabel {
    switch (statusId) {
      case 1:
        return 'event.football.status.not_started'.tr();
      case 2:
        return liveMinute ?? 'event.football.status.first_half'.tr();
      case 3:
        return 'event.football.status.half_time'.tr();
      case 4:
        return liveMinute ?? 'event.football.status.second_half'.tr();
      case 5:
      case 6:
        return 'event.football.status.overtime'.tr();
      case 7:
        return 'event.football.status.penalty'.tr();
      case 8:
        return 'event.football.status.finished'.tr();
      case 9:
        return 'event.football.status.delay'.tr();
      case 10:
        return 'event.football.status.interrupt'.tr();
      case 11:
        return 'event.football.status.cut_in_half'.tr();
      case 12:
        return 'event.football.status.cancelled'.tr();
      case 13:
        return 'event.football.status.tbd'.tr();
      default:
        return '';
    }
  }

  static String? _parseHtScore(Map<String, dynamic> info) {
    final score = info['half_score'] ?? info['half_time_score'] ?? info['halftime_score'];
    return score?.toString();
  }
}
