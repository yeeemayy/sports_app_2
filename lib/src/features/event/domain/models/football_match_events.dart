import 'package:flutter/foundation.dart';

@immutable
class MatchIncident {
  const MatchIncident({
    required this.type,
    required this.position,
    required this.time,
    this.second,
    this.reason,
    this.playerId,
    this.playerName,
    this.homeScore,
    this.awayScore,
    this.inPlayerId,
    this.inPlayerName,
    this.outPlayerId,
    this.outPlayerName,
  });

  final int type;
  final int position;
  final int time;
  final int? second;
  final int? reason;
  final String? playerId;
  final String? playerName;
  final int? homeScore;
  final int? awayScore;
  final String? inPlayerId;
  final String? inPlayerName;
  final String? outPlayerId;
  final String? outPlayerName;

  factory MatchIncident.fromJson(Map<String, dynamic> json) => MatchIncident(
        type: json['type'] as int? ?? 0,
        position: json['position'] as int? ?? 0,
        time: json['time'] as int? ?? 0,
        second: json['second'] as int?,
        reason: json['reason'] as int?,
        playerId: json['player_id'] as String?,
        playerName: json['player_name'] as String?,
        homeScore: json['home_score'] as int?,
        awayScore: json['away_score'] as int?,
        inPlayerId: json['in_player_id'] as String?,
        inPlayerName: json['in_player_name'] as String?,
        outPlayerId: json['out_player_id'] as String?,
        outPlayerName: json['out_player_name'] as String?,
      );
}

@immutable
class MatchStat {
  const MatchStat({this.label, required this.home, required this.away});

  /// The stat name (Chinese string). Null if the key is a numeric type code.
  final String? label;
  final int home;
  final int away;

  factory MatchStat.fromJson(Map<String, dynamic> json) => MatchStat(
        label: json['key'] is String ? json['key'] as String : null,
        home: (json['home'] as num? ?? 0).toInt(),
        away: (json['away'] as num? ?? 0).toInt(),
      );
}

@immutable
class FootballMatchEvents {
  const FootballMatchEvents({
    required this.id,
    required this.incidents,
    required this.stats,
  });

  final String id;
  final List<MatchIncident> incidents;
  final List<MatchStat> stats;

  factory FootballMatchEvents.fromJson(Map<String, dynamic> json) =>
      FootballMatchEvents(
        id: json['id'] as String? ?? '',
        incidents: (json['incidents'] as List<dynamic>? ?? [])
            .map((e) => MatchIncident.fromJson(e as Map<String, dynamic>))
            .toList(),
        stats: (json['stats'] as List<dynamic>? ?? [])
            .map((e) => MatchStat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
