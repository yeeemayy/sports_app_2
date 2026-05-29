import 'package:flutter/foundation.dart';

// ─── Stat ─────────────────────────────────────────────────────────────────────

@immutable
class BadmintonStat {
  const BadmintonStat({
    required this.typeCode,
    required this.homeValue,
    required this.awayValue,
  });

  final int typeCode;
  final double homeValue;
  final double awayValue;

  bool get isPercentage => const {9, 12}.contains(typeCode);

  /// i18n key. Call `.tr()` in the widget.
  String get labelKey {
    switch (typeCode) {
      case 1:
        return 'event.badminton.stat.points_won';
      case 2:
        return 'event.badminton.stat.max_points_in_a_row';
      case 4:
        return 'event.badminton.stat.comeback_to_win';
      case 5:
        return 'event.badminton.stat.biggest_lead';
      case 6:
        return 'event.badminton.stat.service_errors';
      case 7:
        return 'event.badminton.stat.service_points_success';
      case 8:
        return 'event.badminton.stat.service_points_total';
      case 9:
        return 'event.badminton.stat.service_points_rate';
      case 10:
        return 'event.badminton.stat.receiver_points_success';
      case 11:
        return 'event.badminton.stat.receiver_points_total';
      case 12:
        return 'event.badminton.stat.receiver_points_rate';
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

  factory BadmintonStat.fromList(List<dynamic> list) => BadmintonStat(
    typeCode: (list[0] as num).toInt(),
    homeValue: double.tryParse(list[1]?.toString() ?? '0') ?? 0,
    awayValue: double.tryParse(list[2]?.toString() ?? '0') ?? 0,
  );
}

// ─── Stats set (per-set or overall) ──────────────────────────────────────────

@immutable
class BadmintonStatSet {
  const BadmintonStatSet({required this.setIndex, required this.stats});

  /// 0 = full match, 1 = set 1, 2 = set 2, etc.
  final int setIndex;
  final List<BadmintonStat> stats;
}

// ─── Full events data ─────────────────────────────────────────────────────────

@immutable
class BadmintonMatchEventsData {
  const BadmintonMatchEventsData({
    required this.id,
    required this.statusId,
    required this.servingSide,
    required this.homeTotal,
    required this.awayTotal,
    required this.homeSets,
    required this.awaySets,
    required this.statSets,
  });

  final String id;
  final int statusId;
  final int servingSide;
  final int homeTotal;
  final int awayTotal;
  final List<int> homeSets;
  final List<int> awaySets;
  final List<BadmintonStatSet> statSets;

  /// Stats for full match (setIndex == 0)
  List<BadmintonStat> get overallStats =>
      statSets.where((s) => s.setIndex == 0).expand((s) => s.stats).toList();

  factory BadmintonMatchEventsData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>? ?? [];
    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ft = scoreData['ft'] as List<dynamic>?;

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
          .map((s) => BadmintonStat.fromList(s))
          .toList();
      return BadmintonStatSet(setIndex: setIndex, stats: stats);
    }).toList();

    return BadmintonMatchEventsData(
      id: score.isNotEmpty ? score[0] as String? ?? '' : '',
      statusId: score.length > 1 ? (score[1] as num?)?.toInt() ?? 0 : 0,
      servingSide: score.length > 2 ? (score[2] as num?)?.toInt() ?? 0 : 0,
      homeTotal: (ft?[0] as num?)?.toInt() ?? 0,
      awayTotal: (ft?[1] as num?)?.toInt() ?? 0,
      homeSets: homeSets,
      awaySets: awaySets,
      statSets: statSets,
    );
  }
}
