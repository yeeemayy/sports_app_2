import 'package:flutter/foundation.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_match.dart';

@immutable
class BaseballTeamDetailInfo {
  const BaseballTeamDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
  });

  final String enName;
  final String cnName;
  final String logo;
}

@immutable
class BaseballLeagueDetailInfo {
  const BaseballLeagueDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
  });

  final String enName;
  final String cnName;
  final String logo;
}

@immutable
class BaseballMatchDetail {
  const BaseballMatchDetail({
    required this.id,
    required this.statusId,
    required this.matchTime,
    this.statusDescription,
    required this.homeInfo,
    required this.awayInfo,
    required this.leagueInfo,
    required this.scores,
  });

  final String id;
  final int statusId;
  final int matchTime;
  final String? statusDescription;
  final BaseballTeamDetailInfo homeInfo;
  final BaseballTeamDetailInfo awayInfo;
  final BaseballLeagueDetailInfo leagueInfo;

  /// Full scores map from API: ft, p1..p9, h, e.
  final Map<String, dynamic> scores;

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

  factory BaseballMatchDetail.fromJson(Map<String, dynamic> json) {
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
    final scoresJson = d['scores'] is Map
        ? (d['scores'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    return BaseballMatchDetail(
      id: d['id'] as String? ?? '',
      statusId: d['status_id'] as int? ?? 0,
      matchTime: d['match_time'] as int? ?? 0,
      statusDescription: d['statusDescription'] as String?,
      homeInfo: BaseballTeamDetailInfo(
        enName: homeInfoJson['en_name'] as String? ?? '',
        cnName: homeInfoJson['cn_name'] as String? ?? '',
        logo: homeInfoJson['logo'] as String? ?? '',
      ),
      awayInfo: BaseballTeamDetailInfo(
        enName: awayInfoJson['en_name'] as String? ?? '',
        cnName: awayInfoJson['cn_name'] as String? ?? '',
        logo: awayInfoJson['logo'] as String? ?? '',
      ),
      leagueInfo: BaseballLeagueDetailInfo(
        enName: leagueInfoJson['en_name'] as String? ?? '',
        cnName: leagueInfoJson['cn_name'] as String? ?? '',
        logo: leagueInfoJson['logo'] as String? ?? '',
      ),
      scores: scoresJson,
    );
  }
}
