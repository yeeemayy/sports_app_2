import 'package:flutter/foundation.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_match.dart';

@immutable
class CricketTeamDetailInfo {
  const CricketTeamDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
  });

  final String enName;
  final String cnName;
  final String logo;
}

@immutable
class CricketLeagueDetailInfo {
  const CricketLeagueDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
  });

  final String enName;
  final String cnName;
  final String logo;
}

@immutable
class CricketInnings {
  const CricketInnings({
    required this.team,
    required this.runs,
    required this.overs,
    required this.wickets,
  });

  /// 1 = home, 2 = away
  final int team;
  final int runs;

  /// e.g. 16.1 = 16 overs + 1 ball
  final double overs;
  final int wickets;

  factory CricketInnings.fromList(List<dynamic> list) => CricketInnings(
    team: (list[0] as num?)?.toInt() ?? 0,
    runs: (list[1] as num?)?.toInt() ?? 0,
    overs: double.tryParse(list[2]?.toString() ?? '0') ?? 0,
    wickets: (list[3] as num?)?.toInt() ?? 0,
  );
}

@immutable
class CricketResults {
  const CricketResults({
    required this.winby,
    required this.margin,
    required this.result,
  });

  /// 1=runs, 2=wickets, 3=innings, 0=none
  final int winby;
  final int margin;

  /// 1=home wins, 2=away wins, 3=draw, 0=no result
  final int result;

  factory CricketResults.fromJson(Map<String, dynamic> json) => CricketResults(
    winby: (json['winby'] as num?)?.toInt() ?? 0,
    margin: (json['margin'] as num?)?.toInt() ?? 0,
    result: (json['result'] as num?)?.toInt() ?? 0,
  );
}

@immutable
class CricketMatchDetail {
  const CricketMatchDetail({
    required this.id,
    required this.statusId,
    required this.matchTime,
    this.statusDescription,
    required this.homeInfo,
    required this.awayInfo,
    required this.leagueInfo,
    required this.innings,
    this.results,
  });

  final String id;
  final int statusId;
  final int matchTime;
  final String? statusDescription;
  final CricketTeamDetailInfo homeInfo;
  final CricketTeamDetailInfo awayInfo;
  final CricketLeagueDetailInfo leagueInfo;
  final List<CricketInnings> innings;
  final CricketResults? results;

  String get homeName => SportMatch.teamName({
    'en_name': homeInfo.enName,
    'cn_name': homeInfo.cnName,
  });
  String get awayName => SportMatch.teamName({
    'en_name': awayInfo.enName,
    'cn_name': awayInfo.cnName,
  });
  String get leagueName => SportMatch.teamName({
    'en_name': leagueInfo.enName,
    'cn_name': leagueInfo.cnName,
  });

  static const _liveStatuses = {
    2,
    3,
    532,
    533,
    534,
    535,
    536,
    537,
    538,
    539,
    540,
    541,
    542,
    543,
    544,
    545,
  };
  bool get isLive => _liveStatuses.contains(statusId);

  factory CricketMatchDetail.fromJson(Map<String, dynamic> json) {
    final d = json['matchDetails'] is Map
        ? (json['matchDetails'] as Map).cast<String, dynamic>()
        : json;

    final homeInfoJson = d['homeInfo'] is Map
        ? (d['homeInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final awayInfoJson = d['awayInfo'] is Map
        ? (d['awayInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final leagueInfoJson = d['leagueInfo'] is Map
        ? (d['leagueInfo'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final extraScores = d['extra_scores'] is Map
        ? (d['extra_scores'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final rawInnings = extraScores['innings'] as List<dynamic>? ?? [];
    final innings = rawInnings
        .whereType<List<dynamic>>()
        .map((i) => CricketInnings.fromList(i))
        .toList();

    final rawResults = extraScores['results'];
    CricketResults? results;
    if (rawResults is Map) {
      results = CricketResults.fromJson(rawResults.cast<String, dynamic>());
    }

    return CricketMatchDetail(
      id: d['id'] as String? ?? '',
      statusId: d['status_id'] as int? ?? 0,
      matchTime: d['match_time'] as int? ?? 0,
      statusDescription: d['statusDescription'] as String?,
      homeInfo: CricketTeamDetailInfo(
        enName: homeInfoJson['en_name'] as String? ?? '',
        cnName: homeInfoJson['cn_name'] as String? ?? '',
        logo: homeInfoJson['logo'] as String? ?? '',
      ),
      awayInfo: CricketTeamDetailInfo(
        enName: awayInfoJson['en_name'] as String? ?? '',
        cnName: awayInfoJson['cn_name'] as String? ?? '',
        logo: awayInfoJson['logo'] as String? ?? '',
      ),
      leagueInfo: CricketLeagueDetailInfo(
        enName: leagueInfoJson['en_name'] as String? ?? '',
        cnName: leagueInfoJson['cn_name'] as String? ?? '',
        logo: leagueInfoJson['logo'] as String? ?? '',
      ),
      innings: innings,
      results: results,
    );
  }
}
