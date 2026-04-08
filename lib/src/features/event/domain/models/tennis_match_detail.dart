import 'package:flutter/foundation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';

@immutable
class TennisPlayerDetailInfo {
  const TennisPlayerDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
    required this.totalScore,
    required this.setSores,
  });

  final String enName;
  final String cnName;
  final String logo;

  /// Sets won
  final int totalScore;

  /// Game scores per set: [p1, p2, p3, ...]
  final List<int> setSores;
}

@immutable
class TennisLeagueDetailInfo {
  const TennisLeagueDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
  });

  final String enName;
  final String cnName;
  final String logo;
}

@immutable
class TennisMatchDetail {
  const TennisMatchDetail({
    required this.id,
    required this.statusId,
    required this.matchTime,
    this.statusDescription,
    required this.homeInfo,
    required this.awayInfo,
    required this.leagueInfo,
    this.bestof,
    this.homePt,
    this.awayPt,
    this.servingSide,
  });

  final String id;
  final int statusId;
  final int matchTime;
  final String? statusDescription;
  final TennisPlayerDetailInfo homeInfo;
  final TennisPlayerDetailInfo awayInfo;
  final TennisLeagueDetailInfo leagueInfo;
  final int? bestof;

  /// Current game point (e.g. "40", "AD")
  final String? homePt;
  final String? awayPt;

  /// 1 = home serving, 2 = away serving
  final int? servingSide;

  String get homeName =>
      SportMatch.teamName({'en_name': homeInfo.enName, 'cn_name': homeInfo.cnName});
  String get awayName =>
      SportMatch.teamName({'en_name': awayInfo.enName, 'cn_name': awayInfo.cnName});
  String get leagueName =>
      SportMatch.teamName({'en_name': leagueInfo.enName, 'cn_name': leagueInfo.cnName});

  static const _liveStatuses = {3, 51, 52, 53, 54, 55};
  bool get isLive => _liveStatuses.contains(statusId);

  factory TennisMatchDetail.fromJson(Map<String, dynamic> json) {
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

    List<int> parseSets(Map<String, dynamic> info) {
      final sets = <int>[];
      for (var i = 1; i <= 5; i++) {
        final val = info['p$i'];
        if (val == null) break;
        sets.add((val as num).toInt());
      }
      return sets;
    }

    final pt = scoresJson['pt'] as List<dynamic>?;

    return TennisMatchDetail(
      id: d['id'] as String? ?? '',
      statusId: d['status_id'] as int? ?? 0,
      matchTime: d['match_time'] as int? ?? 0,
      statusDescription: d['statusDescription'] as String?,
      bestof: d['bestof'] as int?,
      homeInfo: TennisPlayerDetailInfo(
        enName: homeInfoJson['en_name'] as String? ?? '',
        cnName: homeInfoJson['cn_name'] as String? ?? '',
        logo: homeInfoJson['logo'] as String? ?? '',
        totalScore: homeInfoJson['totalScore'] as int? ?? 0,
        setSores: parseSets(homeInfoJson),
      ),
      awayInfo: TennisPlayerDetailInfo(
        enName: awayInfoJson['en_name'] as String? ?? '',
        cnName: awayInfoJson['cn_name'] as String? ?? '',
        logo: awayInfoJson['logo'] as String? ?? '',
        totalScore: awayInfoJson['totalScore'] as int? ?? 0,
        setSores: parseSets(awayInfoJson),
      ),
      leagueInfo: TennisLeagueDetailInfo(
        enName: leagueInfoJson['en_name'] as String? ?? '',
        cnName: leagueInfoJson['cn_name'] as String? ?? '',
        logo: leagueInfoJson['logo'] as String? ?? '',
      ),
      homePt: pt?[0]?.toString(),
      awayPt: pt?[1]?.toString(),
      servingSide: null, // not available from details endpoint
    );
  }
}