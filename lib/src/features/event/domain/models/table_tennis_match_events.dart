import 'package:flutter/foundation.dart';

// ─── Stat ─────────────────────────────────────────────────────────────────────

@immutable
class TableTennisStat {
  const TableTennisStat({
    required this.typeCode,
    required this.homeValue,
    required this.awayValue,
  });

  final int typeCode;
  final double homeValue;
  final double awayValue;

  bool get isPercentage => const {7, 10}.contains(typeCode);

  /// i18n key. Call `.tr()` in the widget.
  String get labelKey {
    switch (typeCode) {
      case 1:
        return 'event.table_tennis.stat.points_won';
      case 2:
        return 'event.table_tennis.stat.max_points_in_a_row';
      case 3:
        return 'event.table_tennis.stat.comeback_to_win';
      case 4:
        return 'event.table_tennis.stat.biggest_lead';
      case 5:
        return 'event.table_tennis.stat.service_points_success';
      case 6:
        return 'event.table_tennis.stat.service_points_total';
      case 7:
        return 'event.table_tennis.stat.service_points_rate';
      case 8:
        return 'event.table_tennis.stat.receiver_points_success';
      case 9:
        return 'event.table_tennis.stat.receiver_points_total';
      case 10:
        return 'event.table_tennis.stat.receiver_points_rate';
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

  factory TableTennisStat.fromList(List<dynamic> list) => TableTennisStat(
        typeCode: (list[0] as num).toInt(),
        homeValue: double.tryParse(list[1]?.toString() ?? '0') ?? 0,
        awayValue: double.tryParse(list[2]?.toString() ?? '0') ?? 0,
      );
}

// ─── Stats set (per-game or overall) ─────────────────────────────────────────

@immutable
class TableTennisStatSet {
  const TableTennisStatSet({required this.setIndex, required this.stats});

  /// 0 = full match, 1 = game 1, 2 = game 2, etc.
  final int setIndex;
  final List<TableTennisStat> stats;
}

// ─── Full events data ─────────────────────────────────────────────────────────

@immutable
class TableTennisMatchEventsData {
  const TableTennisMatchEventsData({
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
  final List<TableTennisStatSet> statSets;

  /// Stats for full match (setIndex == 0)
  List<TableTennisStat> get overallStats =>
      statSets.where((s) => s.setIndex == 0).expand((s) => s.stats).toList();

  factory TableTennisMatchEventsData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>? ?? [];
    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ft = scoreData['ft'] as List<dynamic>?;

    final homeSets = <int>[];
    final awaySets = <int>[];
    for (var i = 1; i <= 7; i++) {
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
          .map((s) => TableTennisStat.fromList(s))
          .toList();
      return TableTennisStatSet(setIndex: setIndex, stats: stats);
    }).toList();

    return TableTennisMatchEventsData(
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
