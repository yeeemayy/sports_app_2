import 'package:flutter/foundation.dart';

// ─── Stat ─────────────────────────────────────────────────────────────────────

@immutable
class TennisStat {
  const TennisStat({
    required this.typeCode,
    required this.homeValue,
    required this.awayValue,
  });

  final int typeCode;
  final double homeValue;
  final double awayValue;

  bool get isPercentage => const {304, 307, 310, 315, 317}.contains(typeCode);

  /// i18n key. Call `.tr()` in the widget.
  String get labelKey {
    switch (typeCode) {
      case 301:
        return 'event.tennis.stat.aces';
      case 302:
        return 'event.tennis.stat.first_serve_success';
      case 303:
        return 'event.tennis.stat.first_serve_total';
      case 304:
        return 'event.tennis.stat.first_serve_rate';
      case 305:
        return 'event.tennis.stat.second_serve_success';
      case 306:
        return 'event.tennis.stat.second_serve_total';
      case 307:
        return 'event.tennis.stat.second_serve_rate';
      case 308:
        return 'event.tennis.stat.break_points_success';
      case 309:
        return 'event.tennis.stat.break_points_total';
      case 310:
        return 'event.tennis.stat.break_points_rate';
      case 311:
        return 'event.tennis.stat.double_faults';
      case 313:
        return 'event.tennis.stat.points_won';
      case 314:
        return 'event.tennis.stat.first_serve_points_success';
      case 315:
        return 'event.tennis.stat.first_serve_points_rate';
      case 316:
        return 'event.tennis.stat.second_serve_points_success';
      case 317:
        return 'event.tennis.stat.second_serve_points_rate';
      default:
        return '';
    }
  }

  String _fmt(double v) {
    if (v.isNaN) return '-';
    if (isPercentage) return '${(v * 100).toStringAsFixed(1)}%';
    return v.toInt().toString();
  }

  String get homeDisplay => _fmt(homeValue);
  String get awayDisplay => _fmt(awayValue);

  factory TennisStat.fromList(List<dynamic> list) => TennisStat(
    typeCode: (list[0] as num).toInt(),
    homeValue: double.tryParse(list[1]?.toString() ?? '0') ?? 0,
    awayValue: double.tryParse(list[2]?.toString() ?? '0') ?? 0,
  );
}

// ─── Stats set (per-set or overall) ─────────────────────────────────────────

@immutable
class TennisStatSet {
  const TennisStatSet({required this.setIndex, required this.stats});

  /// 0 = full match, 1 = set 1, 2 = set 2, etc.
  final int setIndex;
  final List<TennisStat> stats;
}

// ─── Timeline ────────────────────────────────────────────────────────────────

@immutable
class TennisGamePoint {
  const TennisGamePoint({required this.home, required this.away});
  final String home;
  final String away;
}

@immutable
class TennisRound {
  const TennisRound({
    required this.round,
    this.homeScore,
    this.awayScore,
    this.serve,
    required this.points,
  });

  final int round;

  /// Null when this is the current (in-progress) game
  final int? homeScore;
  final int? awayScore;

  /// 1 = home serving, 2 = away
  final int? serve;
  final List<TennisGamePoint> points;

  bool get isComplete => homeScore != null && awayScore != null;
}

@immutable
class TennisSetTimeline {
  const TennisSetTimeline({required this.set, required this.rounds});

  final int set;
  final List<TennisRound> rounds;
}

// ─── Full events data ─────────────────────────────────────────────────────────

@immutable
class TennisMatchEventsData {
  const TennisMatchEventsData({
    required this.id,
    required this.statusId,
    required this.servingSide,
    required this.homeTotal,
    required this.awayTotal,
    required this.homeSets,
    required this.awaySets,
    required this.homePt,
    required this.awayPt,
    required this.statSets,
    required this.timeline,
  });

  final String id;
  final int statusId;
  final int servingSide;
  final int homeTotal;
  final int awayTotal;
  final List<int> homeSets;
  final List<int> awaySets;
  final String homePt;
  final String awayPt;
  final List<TennisStatSet> statSets;
  final List<TennisSetTimeline> timeline;

  /// Stats for full match (setIndex == 0)
  List<TennisStat> get overallStats =>
      statSets.where((s) => s.setIndex == 0).expand((s) => s.stats).toList();

  /// Stats for a given set (1-based)
  List<TennisStat> statsForSet(int setNumber) => statSets
      .where((s) => s.setIndex == setNumber)
      .expand((s) => s.stats)
      .toList();

  factory TennisMatchEventsData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>? ?? [];
    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ft = scoreData['ft'] as List<dynamic>?;
    final pt = scoreData['pt'] as List<dynamic>?;

    final homeSets = <int>[];
    final awaySets = <int>[];
    for (var i = 1; i <= 5; i++) {
      final setScore = scoreData['p$i'] as List<dynamic>?;
      if (setScore == null) break;
      homeSets.add((setScore[0] as num?)?.toInt() ?? 0);
      awaySets.add((setScore[1] as num?)?.toInt() ?? 0);
    }

    // Parse stats: [[setIndex, [[typeCode, home, away], ...]], ...]
    final rawStats = json['stats'] as List<dynamic>? ?? [];
    final statSets = rawStats.map((entry) {
      final e = entry as List<dynamic>;
      final setIndex = (e[0] as num).toInt();
      final statList = e[1] as List<dynamic>? ?? [];
      final stats = statList
          .whereType<List<dynamic>>()
          .map((s) => TennisStat.fromList(s))
          .toList();
      return TennisStatSet(setIndex: setIndex, stats: stats);
    }).toList();

    // Parse timeline: [{set, rounds: [{round, score:{home,away,serve}, points:[[h,a],...]}]}]
    final rawTimeline = json['timeline'] as List<dynamic>? ?? [];
    final timeline = rawTimeline.map((entry) {
      final e = (entry as Map).cast<String, dynamic>();
      final setNum = (e['set'] as num).toInt();
      final rawRounds = e['rounds'] as List<dynamic>? ?? [];
      final rounds = rawRounds.map((r) {
        final rd = (r as Map).cast<String, dynamic>();
        final scoreMap = rd['score'] as Map?;
        final rawPoints = rd['points'] as List<dynamic>? ?? [];
        final points = rawPoints
            .whereType<List<dynamic>>()
            .map(
              (p) => TennisGamePoint(
                home: p[0]?.toString() ?? '',
                away: p[1]?.toString() ?? '',
              ),
            )
            .toList();
        return TennisRound(
          round: (rd['round'] as num).toInt(),
          homeScore: scoreMap != null
              ? (scoreMap['home'] as num?)?.toInt()
              : null,
          awayScore: scoreMap != null
              ? (scoreMap['away'] as num?)?.toInt()
              : null,
          serve: scoreMap != null ? (scoreMap['serve'] as num?)?.toInt() : null,
          points: points,
        );
      }).toList();
      return TennisSetTimeline(set: setNum, rounds: rounds);
    }).toList();

    return TennisMatchEventsData(
      id: score.isNotEmpty ? score[0] as String? ?? '' : '',
      statusId: score.length > 1 ? (score[1] as num?)?.toInt() ?? 0 : 0,
      servingSide: score.length > 2 ? (score[2] as num?)?.toInt() ?? 0 : 0,
      homeTotal: (ft?[0] as num?)?.toInt() ?? 0,
      awayTotal: (ft?[1] as num?)?.toInt() ?? 0,
      homeSets: homeSets,
      awaySets: awaySets,
      homePt: pt?[0]?.toString() ?? '',
      awayPt: pt?[1]?.toString() ?? '',
      statSets: statSets,
      timeline: timeline,
    );
  }
}
