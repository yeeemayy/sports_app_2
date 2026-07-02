import 'package:flutter/foundation.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_match.dart';

@immutable
class BasketballTeamDetailInfo {
  const BasketballTeamDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
    required this.sectionScores,
  });

  final String enName;
  final String cnName;
  final String logo;

  /// Scores per section: [Q1, Q2, Q3, Q4, OT]
  final List<int> sectionScores;

  int get total => sectionScores.fold(0, (a, b) => a + b);
}

@immutable
class BasketballLeagueDetailInfo {
  const BasketballLeagueDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
  });

  final String enName;
  final String cnName;
  final String logo;
}

@immutable
class BasketballMatchDetail {
  const BasketballMatchDetail({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.statusId,
    required this.matchTime,
    this.statusDescription,
    required this.homeInfo,
    required this.awayInfo,
    required this.leagueInfo,
  });

  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final int statusId;
  final int matchTime;
  final String? statusDescription;
  final BasketballTeamDetailInfo homeInfo;
  final BasketballTeamDetailInfo awayInfo;
  final BasketballLeagueDetailInfo leagueInfo;

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

  factory BasketballMatchDetail.fromJson(Map<String, dynamic> json) {
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

    List<int> parseSections(Map<String, dynamic> info) => [
      info['section_1'] as int? ?? 0,
      info['section_2'] as int? ?? 0,
      info['section_3'] as int? ?? 0,
      info['section_4'] as int? ?? 0,
      info['section_overtime'] as int? ?? 0,
    ];

    return BasketballMatchDetail(
      id: d['id'] as String? ?? '',
      homeTeamId: d['home_team_id'] as String? ?? '',
      awayTeamId: d['away_team_id'] as String? ?? '',
      statusId: d['status_id'] as int? ?? 0,
      matchTime: d['match_time'] as int? ?? 0,
      statusDescription: d['statusDescription'] as String?,
      homeInfo: BasketballTeamDetailInfo(
        enName: homeInfoJson['en_name'] as String? ?? '',
        cnName: homeInfoJson['cn_name'] as String? ?? '',
        logo: homeInfoJson['logo'] as String? ?? '',
        sectionScores: parseSections(homeInfoJson),
      ),
      awayInfo: BasketballTeamDetailInfo(
        enName: awayInfoJson['en_name'] as String? ?? '',
        cnName: awayInfoJson['cn_name'] as String? ?? '',
        logo: awayInfoJson['logo'] as String? ?? '',
        sectionScores: parseSections(awayInfoJson),
      ),
      leagueInfo: BasketballLeagueDetailInfo(
        enName: leagueInfoJson['en_name'] as String? ?? '',
        cnName: leagueInfoJson['cn_name'] as String? ?? '',
        logo: leagueInfoJson['logo'] as String? ?? '',
      ),
    );
  }
}
