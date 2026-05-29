import 'package:flutter/foundation.dart';

// ─── Stat ─────────────────────────────────────────────────────────────────────

@immutable
class IceHockeyStat {
  const IceHockeyStat({
    required this.typeCode,
    required this.homeValue,
    required this.awayValue,
  });

  final int typeCode;
  final double homeValue;
  final double awayValue;

  bool get isPercentage => const {1, 7, 10}.contains(typeCode);

  String get labelKey {
    switch (typeCode) {
      case 1:
        return 'event.ice_hockey.stat.puck_possession';
      case 2:
        return 'event.ice_hockey.stat.power_play_goals';
      case 3:
        return 'event.ice_hockey.stat.short_handed_goals';
      case 4:
        return 'event.ice_hockey.stat.penalties';
      case 5:
        return 'event.ice_hockey.stat.shots_off_goal';
      case 6:
        return 'event.ice_hockey.stat.shots_on_goal';
      case 7:
        return 'event.ice_hockey.stat.shooting_pct';
      case 8:
        return 'event.ice_hockey.stat.blocked_shots';
      case 9:
        return 'event.ice_hockey.stat.saves';
      case 10:
        return 'event.ice_hockey.stat.save_pct';
      case 11:
        return 'event.ice_hockey.stat.penalty_minutes';
      default:
        return '';
    }
  }

  String _fmt(double v) {
    if (v.isNaN) return '-';
    if (isPercentage) return '${v.toStringAsFixed(1)}%';
    return v.toInt().toString();
  }

  String get homeDisplay => _fmt(homeValue);
  String get awayDisplay => _fmt(awayValue);

  factory IceHockeyStat.fromList(List<dynamic> list) => IceHockeyStat(
    typeCode: (list[0] as num).toInt(),
    homeValue: double.tryParse(list[1]?.toString() ?? '0') ?? 0,
    awayValue: double.tryParse(list[2]?.toString() ?? '0') ?? 0,
  );
}

// ─── Stats set ────────────────────────────────────────────────────────────────

@immutable
class IceHockeyStatSet {
  const IceHockeyStatSet({required this.setIndex, required this.stats});

  final int setIndex;
  final List<IceHockeyStat> stats;
}

// ─── Incident ─────────────────────────────────────────────────────────────────

@immutable
class IceHockeyIncident {
  const IceHockeyIncident({
    required this.type,
    required this.extra,
    required this.second,
    required this.position,
    required this.homeScore,
    required this.awayScore,
    this.playerId,
    this.assists1Id,
    this.assists2Id,
  });

  final int type;
  final int extra;

  /// Seconds elapsed in the game
  final int second;

  /// 0 = neutral, 1 = home, 2 = away
  final int position;
  final int homeScore;
  final int awayScore;
  final String? playerId;
  final String? assists1Id;
  final String? assists2Id;

  /// Formats `second` as "MM:SS"
  String get timeLabel {
    final m = second ~/ 60;
    final s = second % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  factory IceHockeyIncident.fromJson(Map<String, dynamic> json) =>
      IceHockeyIncident(
        type: (json['type'] as num?)?.toInt() ?? 0,
        extra: (json['extra'] as num?)?.toInt() ?? 0,
        second: (json['second'] as num?)?.toInt() ?? 0,
        position: (json['position'] as num?)?.toInt() ?? 0,
        homeScore: (json['home_score'] as num?)?.toInt() ?? 0,
        awayScore: (json['away_score'] as num?)?.toInt() ?? 0,
        playerId: json['player_id'] as String?,
        assists1Id: json['assists1_id'] as String?,
        assists2Id: json['assists2_id'] as String?,
      );
}

// ─── Full events data ─────────────────────────────────────────────────────────

@immutable
class IceHockeyMatchEventsData {
  const IceHockeyMatchEventsData({
    required this.id,
    required this.statusId,
    required this.servingSide,
    required this.homeScore,
    required this.awayScore,
    required this.homeP1,
    required this.awayP1,
    required this.homeP2,
    required this.awayP2,
    required this.homeP3,
    required this.awayP3,
    required this.homeOt,
    required this.awayOt,
    required this.homeAp,
    required this.awayAp,
    required this.timer,
    required this.statSets,
    required this.incidents,
  });

  final String id;
  final int statusId;
  final int servingSide;
  final int homeScore;
  final int awayScore;
  final int homeP1;
  final int awayP1;
  final int homeP2;
  final int awayP2;
  final int homeP3;
  final int awayP3;
  final int homeOt;
  final int awayOt;
  final int homeAp;
  final int awayAp;

  /// [running, countdown, timestamp, seconds]
  final List<dynamic> timer;

  final List<IceHockeyStatSet> statSets;
  final List<IceHockeyIncident> incidents;

  factory IceHockeyMatchEventsData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>? ?? [];
    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ft = scoreData['ft'] as List<dynamic>?;

    int periodScore(String key, int idx) {
      final v = scoreData[key] as List<dynamic>?;
      return (v?[idx] as num?)?.toInt() ?? 0;
    }

    final rawStats = json['stats'] as List<dynamic>? ?? [];
    final statSets = rawStats.map((entry) {
      final e = entry as List<dynamic>;
      final setIndex = (e[0] as num).toInt();
      final statList = e[1] as List<dynamic>? ?? [];
      final stats = statList
          .whereType<List<dynamic>>()
          .map((s) => IceHockeyStat.fromList(s))
          .toList();
      return IceHockeyStatSet(setIndex: setIndex, stats: stats);
    }).toList();

    final rawIncidents = json['incidents'] as List<dynamic>? ?? [];
    final incidents = rawIncidents
        .whereType<Map>()
        .map((m) => IceHockeyIncident.fromJson(m.cast<String, dynamic>()))
        .toList();

    final timer = json['timer'] as List<dynamic>? ?? [];

    return IceHockeyMatchEventsData(
      id: score.isNotEmpty ? score[0] as String? ?? '' : '',
      statusId: score.length > 1 ? (score[1] as num?)?.toInt() ?? 0 : 0,
      servingSide: score.length > 2 ? (score[2] as num?)?.toInt() ?? 0 : 0,
      homeScore: (ft?[0] as num?)?.toInt() ?? 0,
      awayScore: (ft?[1] as num?)?.toInt() ?? 0,
      homeP1: periodScore('p1', 0),
      awayP1: periodScore('p1', 1),
      homeP2: periodScore('p2', 0),
      awayP2: periodScore('p2', 1),
      homeP3: periodScore('p3', 0),
      awayP3: periodScore('p3', 1),
      homeOt: periodScore('ot', 0),
      awayOt: periodScore('ot', 1),
      homeAp: periodScore('ap', 0),
      awayAp: periodScore('ap', 1),
      timer: timer,
      statSets: statSets,
      incidents: incidents,
    );
  }
}
