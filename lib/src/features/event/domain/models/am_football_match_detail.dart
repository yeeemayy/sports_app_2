import 'package:flutter/foundation.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_match.dart';

@immutable
class AmFootballTeamDetailInfo {
  const AmFootballTeamDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
  });

  final String enName;
  final String cnName;
  final String logo;
}

@immutable
class AmFootballLeagueDetailInfo {
  const AmFootballLeagueDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
  });

  final String enName;
  final String cnName;
  final String logo;
}

@immutable
class AmFootballMatchDetail {
  const AmFootballMatchDetail({
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
  final AmFootballTeamDetailInfo homeInfo;
  final AmFootballTeamDetailInfo awayInfo;
  final AmFootballLeagueDetailInfo leagueInfo;

  /// Full scores map: ft, p1, p2, p3, p4, ot
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

  String get homeScore {
    final ft = scores['ft'] as List<dynamic>?;
    return (ft?[0] as num?)?.toInt().toString() ?? '-';
  }

  String get awayScore {
    final ft = scores['ft'] as List<dynamic>?;
    return (ft?[1] as num?)?.toInt().toString() ?? '-';
  }

  static const _liveStatuses = {44, 45, 46, 47, 10};
  bool get isLive => _liveStatuses.contains(statusId);

  factory AmFootballMatchDetail.fromJson(Map<String, dynamic> json) {
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

    return AmFootballMatchDetail(
      id: d['id'] as String? ?? '',
      statusId: d['status_id'] as int? ?? 0,
      matchTime: d['match_time'] as int? ?? 0,
      statusDescription: d['statusDescription'] as String?,
      homeInfo: AmFootballTeamDetailInfo(
        enName: homeInfoJson['en_name'] as String? ?? '',
        cnName: homeInfoJson['cn_name'] as String? ?? '',
        logo: homeInfoJson['logo'] as String? ?? '',
      ),
      awayInfo: AmFootballTeamDetailInfo(
        enName: awayInfoJson['en_name'] as String? ?? '',
        cnName: awayInfoJson['cn_name'] as String? ?? '',
        logo: awayInfoJson['logo'] as String? ?? '',
      ),
      leagueInfo: AmFootballLeagueDetailInfo(
        enName: leagueInfoJson['en_name'] as String? ?? '',
        cnName: leagueInfoJson['cn_name'] as String? ?? '',
        logo: leagueInfoJson['logo'] as String? ?? '',
      ),
      scores: scoresJson,
    );
  }
}
