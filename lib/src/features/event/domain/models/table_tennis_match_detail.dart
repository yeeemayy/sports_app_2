import 'package:flutter/foundation.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_match.dart';

@immutable
class TableTennisPlayerDetailInfo {
  const TableTennisPlayerDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
    required this.totalScore,
    required this.setScores,
  });

  final String enName;
  final String cnName;
  final String logo;

  /// Games won
  final int totalScore;

  /// Point scores per game: [p1, p2, p3, ...]
  final List<int> setScores;
}

@immutable
class TableTennisLeagueDetailInfo {
  const TableTennisLeagueDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
  });

  final String enName;
  final String cnName;
  final String logo;
}

@immutable
class TableTennisMatchDetail {
  const TableTennisMatchDetail({
    required this.id,
    required this.statusId,
    required this.matchTime,
    this.statusDescription,
    required this.homeInfo,
    required this.awayInfo,
    required this.leagueInfo,
    this.bestof,
  });

  final String id;
  final int statusId;
  final int matchTime;
  final String? statusDescription;
  final TableTennisPlayerDetailInfo homeInfo;
  final TableTennisPlayerDetailInfo awayInfo;
  final TableTennisLeagueDetailInfo leagueInfo;
  final int? bestof;

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

  static const _liveStatuses = {3, 51, 52, 53, 54, 55, 472, 473};
  bool get isLive => _liveStatuses.contains(statusId);

  factory TableTennisMatchDetail.fromJson(Map<String, dynamic> json) {
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

    List<int> parseSets(Map<String, dynamic> scoresMap, String side) {
      final sets = <int>[];
      for (var i = 1; i <= 7; i++) {
        final val = scoresMap['p$i'];
        if (val == null) break;
        final list = val as List<dynamic>;
        sets.add((list[side == 'home' ? 0 : 1] as num?)?.toInt() ?? 0);
      }
      return sets;
    }

    final ft = scoresJson['ft'] as List<dynamic>?;

    return TableTennisMatchDetail(
      id: d['id'] as String? ?? '',
      statusId: d['status_id'] as int? ?? 0,
      matchTime: d['match_time'] as int? ?? 0,
      statusDescription: d['statusDescription'] as String?,
      bestof: d['bestof'] as int?,
      homeInfo: TableTennisPlayerDetailInfo(
        enName: homeInfoJson['en_name'] as String? ?? '',
        cnName: homeInfoJson['cn_name'] as String? ?? '',
        logo: homeInfoJson['logo'] as String? ?? '',
        totalScore: (ft?[0] as num?)?.toInt() ?? 0,
        setScores: parseSets(scoresJson, 'home'),
      ),
      awayInfo: TableTennisPlayerDetailInfo(
        enName: awayInfoJson['en_name'] as String? ?? '',
        cnName: awayInfoJson['cn_name'] as String? ?? '',
        logo: awayInfoJson['logo'] as String? ?? '',
        totalScore: (ft?[1] as num?)?.toInt() ?? 0,
        setScores: parseSets(scoresJson, 'away'),
      ),
      leagueInfo: TableTennisLeagueDetailInfo(
        enName: leagueInfoJson['en_name'] as String? ?? '',
        cnName: leagueInfoJson['cn_name'] as String? ?? '',
        logo: leagueInfoJson['logo'] as String? ?? '',
      ),
    );
  }
}
