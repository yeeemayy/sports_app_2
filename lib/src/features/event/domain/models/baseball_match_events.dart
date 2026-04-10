import 'package:flutter/foundation.dart';

// ─── Stat ──────────────────────────────────────────────────────────────────────

@immutable
class BaseballStat {
  const BaseballStat({
    required this.typeCode,
    required this.homeValue,
    required this.awayValue,
  });

  final int typeCode;
  final double homeValue;
  final double awayValue;

  /// i18n key. Call `.tr()` in the widget.
  String get labelKey {
    switch (typeCode) {
      case 601:
        return 'event.baseball.stat.hits';
      case 602:
        return 'event.baseball.stat.errors';
      case 603:
        return 'event.baseball.stat.doubles';
      case 604:
        return 'event.baseball.stat.triples';
      case 605:
        return 'event.baseball.stat.home_runs';
      case 606:
        return 'event.baseball.stat.rbi';
      case 607:
        return 'event.baseball.stat.left_on_base';
      case 608:
        return 'event.baseball.stat.walks';
      case 609:
        return 'event.baseball.stat.strikeouts';
      case 610:
        return 'event.baseball.stat.stolen_bases';
      case 677:
        return 'event.baseball.stat.runs';
      default:
        return '';
    }
  }

  String get homeDisplay => _fmt(homeValue);
  String get awayDisplay => _fmt(awayValue);

  String _fmt(double v) {
    if (v.isNaN) return '-';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(3);
  }

  factory BaseballStat.fromList(List<dynamic> list) => BaseballStat(
        typeCode: (list[0] as num).toInt(),
        homeValue: double.tryParse(list[1]?.toString() ?? '0') ?? 0,
        awayValue: double.tryParse(list[2]?.toString() ?? '0') ?? 0,
      );
}

// ─── Stats set (full match or per-inning) ─────────────────────────────────────

@immutable
class BaseballStatSet {
  const BaseballStatSet({required this.setIndex, required this.stats});

  /// 0 = full match, 1–9 = inning 1–9, 10+ = extra innings.
  final int setIndex;
  final List<BaseballStat> stats;
}

// ─── Score helpers ─────────────────────────────────────────────────────────────

/// Per-inning score data for one side (home or away).
@immutable
class BaseballInningScores {
  const BaseballInningScores({
    required this.inningScores,
    required this.runs,
    required this.hits,
    required this.errors,
  });

  /// Values for innings 1..N (index 0 = inning 1).
  /// Each entry may be "0", "1", "X", "" etc.
  final List<String> inningScores;
  final String runs;
  final String hits;
  final String errors;
}

// ─── Full events data ──────────────────────────────────────────────────────────

@immutable
class BaseballMatchEventsData {
  const BaseballMatchEventsData({
    required this.id,
    required this.statusId,
    required this.home,
    required this.away,
    required this.inningCount,
    required this.statSets,
  });

  final String id;
  final int statusId;
  final BaseballInningScores home;
  final BaseballInningScores away;

  /// Total number of innings in the per-inning grid (usually 9).
  final int inningCount;
  final List<BaseballStatSet> statSets;

  List<BaseballStat> statsFor(int setIndex) => statSets
      .where((s) => s.setIndex == setIndex)
      .expand((s) => s.stats)
      .toList();

  factory BaseballMatchEventsData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>? ?? [];
    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ft = scoreData['ft'] as List<dynamic>?;
    final h = scoreData['h'] as List<dynamic>?;
    final e = scoreData['e'] as List<dynamic>?;

    // Collect all inning keys (p1..pN)
    final inningKeys = <String>[];
    for (var i = 1; i <= 20; i++) {
      if (scoreData.containsKey('p$i')) {
        inningKeys.add('p$i');
      } else {
        break;
      }
    }

    List<String> parseSide(int sideIndex) {
      return inningKeys.map((key) {
        final val = scoreData[key] as List<dynamic>?;
        if (val == null || val.length <= sideIndex) return '';
        final v = val[sideIndex];
        return v?.toString() ?? '';
      }).toList();
    }

    final homeInnings = parseSide(0);
    final awayInnings = parseSide(1);

    // Parse stats
    final rawStats = json['stats'] as List<dynamic>? ?? [];
    final statSets = rawStats.map((entry) {
      final e2 = entry as List<dynamic>;
      final setIndex = (e2[0] as num).toInt();
      final statList = e2[1] as List<dynamic>? ?? [];
      final stats = statList
          .whereType<List<dynamic>>()
          .map((s) => BaseballStat.fromList(s))
          .toList();
      return BaseballStatSet(setIndex: setIndex, stats: stats);
    }).toList();

    return BaseballMatchEventsData(
      id: score.isNotEmpty ? (score[0] as String? ?? '') : (json['id'] as String? ?? ''),
      statusId: score.length > 1 ? (score[1] as num?)?.toInt() ?? 0 : 0,
      inningCount: inningKeys.length,
      home: BaseballInningScores(
        inningScores: homeInnings,
        runs: ft != null && ft.isNotEmpty ? (ft[0]?.toString() ?? '-') : '-',
        hits: h != null && h.isNotEmpty ? (h[0]?.toString() ?? '-') : '-',
        errors: e != null && e.isNotEmpty ? (e[0]?.toString() ?? '-') : '-',
      ),
      away: BaseballInningScores(
        inningScores: awayInnings,
        runs: ft != null && ft.length > 1 ? (ft[1]?.toString() ?? '-') : '-',
        hits: h != null && h.length > 1 ? (h[1]?.toString() ?? '-') : '-',
        errors: e != null && e.length > 1 ? (e[1]?.toString() ?? '-') : '-',
      ),
      statSets: statSets,
    );
  }
}
