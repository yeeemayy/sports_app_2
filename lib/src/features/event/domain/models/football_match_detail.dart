import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';

@immutable
class FootballTeamDetailInfo {
  const FootballTeamDetailInfo({
    required this.enName,
    required this.cnName,
    required this.logo,
    required this.score,
    this.halfTimeScore,
    required this.redCards,
    required this.yellowCards,
    required this.cornerScore,
  });

  final String enName;
  final String cnName;
  final String logo;
  final int score;
  final int? halfTimeScore;
  final int redCards;
  final int yellowCards;
  final int cornerScore;
}

@immutable
class FootballLeagueDetailInfo {
  const FootballLeagueDetailInfo({required this.enName, required this.cnName, required this.logo});

  final String enName;
  final String cnName;
  final String logo;
}

@immutable
class FootballMatchEnvironment {
  const FootballMatchEnvironment({
    this.weather,
    this.pressure,
    this.temperature,
    this.wind,
    this.humidity,
  });

  final int? weather;
  final String? pressure;
  final String? temperature;
  final String? wind;
  final String? humidity;

  factory FootballMatchEnvironment.fromJson(Map<String, dynamic> json) {
    return FootballMatchEnvironment(
      weather: json['weather'] as int?,
      pressure: json['pressure'] as String?,
      temperature: json['temperature'] as String?,
      wind: json['wind'] as String?,
      humidity: json['humidity'] as String?,
    );
  }
}

@immutable
class FootballMatchDetail {
  const FootballMatchDetail({
    required this.id,
    required this.statusId,
    required this.matchTime,
    required this.homeScores,
    required this.awayScores,
    this.environment,
    required this.homeInfo,
    required this.awayInfo,
    required this.leagueInfo,
    this.counterTiming,
    this.matchTiming,
    this.updateTiming,
  });

  final String id;
  final int statusId;
  final int matchTime;
  final List<int> homeScores;
  final List<int> awayScores;
  final FootballMatchEnvironment? environment;
  final FootballTeamDetailInfo homeInfo;
  final FootballTeamDetailInfo awayInfo;
  final FootballLeagueDetailInfo leagueInfo;
  final int? counterTiming;
  final String? matchTiming;
  final String? updateTiming;

  String? get liveMinute {
    if (counterTiming == null || counterTiming == 0) return null;
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final elapsed = ((now - counterTiming!) / 60).floor();
    if (statusId == 2) {
      return elapsed <= 45 ? "$elapsed'" : "45+'";
    }
    if (statusId == 4) {
      final minute = elapsed + 45;
      return minute <= 90 ? "$minute'" : "90+'";
    }
    if (statusId == 5 || statusId == 6) {
      final minute = elapsed + 90;
      return minute <= 105 ? "$minute'" : "105+${elapsed - 15}'";
    }
    return null;
  }

  String get homeScore => homeInfo.score.toString();
  String get awayScore => awayInfo.score.toString();

  String get homeName =>
      SportMatch.teamName({'en_name': homeInfo.enName, 'cn_name': homeInfo.cnName});

  String get awayName =>
      SportMatch.teamName({'en_name': awayInfo.enName, 'cn_name': awayInfo.cnName});

  String get leagueName =>
      SportMatch.teamName({'en_name': leagueInfo.enName, 'cn_name': leagueInfo.cnName});

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

  bool get isReallyFinished {
    if (statusId == 8) return true;

    if (statusId == 4 && counterTiming == 0) {
      final kickoff = matchTiming != null ? DateTime.tryParse(matchTiming!) : null;
      final update = updateTiming != null ? DateTime.tryParse(updateTiming!) : null;

      if (kickoff != null && update != null) {
        final elapsed = update.difference(kickoff).inMinutes;
        if (elapsed > 110) return true;
      }
    }

    return false;
  }

  factory FootballMatchDetail.fromJson(Map<String, dynamic> json) {
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

    return FootballMatchDetail(
      id: d['id'] as String? ?? '',
      statusId: d['status_id'] as int? ?? 0,
      matchTime: d['match_time'] as int? ?? 0,
      homeScores: (d['home_scores'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      awayScores: (d['away_scores'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      environment: d['environment'] is Map
          ? FootballMatchEnvironment.fromJson((d['environment'] as Map).cast<String, dynamic>())
          : null,
      counterTiming: d['counter_timing'] as int?,
      matchTiming: d['match_timing'] as String?,
      updateTiming: d['update_timing'] as String?,
      homeInfo: _parseTeamInfo(homeInfoJson, isHome: true),
      awayInfo: _parseTeamInfo(awayInfoJson, isHome: false),
      leagueInfo: FootballLeagueDetailInfo(
        enName: leagueInfoJson['en_name'] as String? ?? '',
        cnName: leagueInfoJson['cn_name'] as String? ?? '',
        logo: leagueInfoJson['logo'] as String? ?? '',
      ),
    );
  }
}

FootballTeamDetailInfo _parseTeamInfo(Map<String, dynamic> json, {required bool isHome}) {
  return FootballTeamDetailInfo(
    enName: json['en_name'] as String? ?? '',
    cnName: json['cn_name'] as String? ?? '',
    logo: json['logo'] as String? ?? '',
    score: (isHome ? json['home_score'] : json['away_score']) as int? ?? 0,
    halfTimeScore: json['half_time_score'] as int?,
    redCards: json['red_cards'] as int? ?? 0,
    yellowCards: json['yellow_cards'] as int? ?? 0,
    cornerScore: json['corner_score'] as int? ?? 0,
  );
}
