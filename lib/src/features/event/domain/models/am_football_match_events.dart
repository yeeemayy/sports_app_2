import 'package:flutter/foundation.dart';

// ─── Stat ─────────────────────────────────────────────────────────────────────

@immutable
class AmFootballStat {
  const AmFootballStat({required this.typeCode, required this.homeValue, required this.awayValue});

  final int typeCode;
  final double homeValue;
  final double awayValue;

  bool get isPercentage => false;

  String get labelKey {
    switch (typeCode) {
      case 71:
        return 'event.am_football.stat.total_plays';
      case 72:
        return 'event.am_football.stat.net_yards';
      case 75:
        return 'event.am_football.stat.net_passing_yards';
      case 83:
        return 'event.am_football.stat.rushing_yards';
      case 61:
        return 'event.am_football.stat.first_downs';
      case 89:
        return 'event.am_football.stat.total_penalties';
      case 95:
        return 'event.am_football.stat.possession';
      case 91:
        return 'event.am_football.stat.turnovers';
      default:
        return '';
    }
  }

  String _fmt(double v) {
    if (v.isNaN) return '-';
    return v.toInt().toString();
  }

  String get homeDisplay => _fmt(homeValue);
  String get awayDisplay => _fmt(awayValue);

  factory AmFootballStat.fromList(List<dynamic> list) => AmFootballStat(
    typeCode: (list[0] as num).toInt(),
    homeValue: double.tryParse(list[1]?.toString() ?? '0') ?? 0,
    awayValue: double.tryParse(list[2]?.toString() ?? '0') ?? 0,
  );
}

// ─── Stats set ────────────────────────────────────────────────────────────────

@immutable
class AmFootballStatSet {
  const AmFootballStatSet({required this.setIndex, required this.stats});

  final int setIndex;
  final List<AmFootballStat> stats;
}

// ─── Incident ─────────────────────────────────────────────────────────────────

@immutable
class AmFootballIncident {
  const AmFootballIncident({
    required this.type,
    required this.extra,
    required this.second,
    required this.position,
    required this.homeScore,
    required this.awayScore,
    this.playerId,
  });

  final int type;
  final int extra;

  /// Seconds elapsed
  final int second;

  /// 0 = neutral, 1 = home, 2 = away
  final int position;
  final int homeScore;
  final int awayScore;
  final String? playerId;

  /// Formats `second` as "MM:SS"
  String get timeLabel {
    final m = second ~/ 60;
    final s = second % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  factory AmFootballIncident.fromJson(Map<String, dynamic> json) => AmFootballIncident(
    type: (json['type'] as num?)?.toInt() ?? 0,
    extra: (json['extra'] as num?)?.toInt() ?? 0,
    second: (json['second'] as num?)?.toInt() ?? 0,
    position: (json['position'] as num?)?.toInt() ?? 0,
    homeScore: (json['home_score'] as num?)?.toInt() ?? 0,
    awayScore: (json['away_score'] as num?)?.toInt() ?? 0,
    playerId: json['player_id'] as String?,
  );
}

// ─── Full events data ─────────────────────────────────────────────────────────

@immutable
class AmFootballMatchEventsData {
  const AmFootballMatchEventsData({
    required this.id,
    required this.statusId,
    required this.homeScore,
    required this.awayScore,
    required this.homeP1,
    required this.awayP1,
    required this.homeP2,
    required this.awayP2,
    required this.homeP3,
    required this.awayP3,
    required this.homeP4,
    required this.awayP4,
    required this.homeOt,
    required this.awayOt,
    required this.timer,
    required this.statSets,
    required this.incidents,
  });

  final String id;
  final int statusId;
  final int homeScore;
  final int awayScore;
  final int homeP1;
  final int awayP1;
  final int homeP2;
  final int awayP2;
  final int homeP3;
  final int awayP3;
  final int homeP4;
  final int awayP4;
  final int homeOt;
  final int awayOt;

  /// [running, countdown, timestamp, seconds]
  final List<dynamic> timer;

  final List<AmFootballStatSet> statSets;
  final List<AmFootballIncident> incidents;

  factory AmFootballMatchEventsData.fromJson(Map<String, dynamic> json) {
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
          .map((s) => AmFootballStat.fromList(s))
          .toList();
      return AmFootballStatSet(setIndex: setIndex, stats: stats);
    }).toList();

    final rawIncidents = json['incidents'] as List<dynamic>? ?? [];
    final incidents = rawIncidents
        .whereType<Map>()
        .map((m) => AmFootballIncident.fromJson(m.cast<String, dynamic>()))
        .toList();

    final timer = json['timer'] as List<dynamic>? ?? [];

    return AmFootballMatchEventsData(
      id: score.isNotEmpty ? score[0] as String? ?? '' : '',
      statusId: score.length > 1 ? (score[1] as num?)?.toInt() ?? 0 : 0,
      homeScore: (ft?[0] as num?)?.toInt() ?? 0,
      awayScore: (ft?[1] as num?)?.toInt() ?? 0,
      homeP1: periodScore('p1', 0),
      awayP1: periodScore('p1', 1),
      homeP2: periodScore('p2', 0),
      awayP2: periodScore('p2', 1),
      homeP3: periodScore('p3', 0),
      awayP3: periodScore('p3', 1),
      homeP4: periodScore('p4', 0),
      awayP4: periodScore('p4', 1),
      homeOt: periodScore('ot', 0),
      awayOt: periodScore('ot', 1),
      timer: timer,
      statSets: statSets,
      incidents: incidents,
    );
  }
}
