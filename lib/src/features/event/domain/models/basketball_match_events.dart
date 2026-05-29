import 'package:flutter/foundation.dart';

@immutable
class BasketballStat {
  const BasketballStat({
    required this.typeCode,
    required this.homeValue,
    required this.awayValue,
  });

  final int typeCode;
  final double homeValue;
  final double awayValue;

  /// i18n key for this stat type. Call `.tr()` in the widget.
  String get labelKey {
    switch (typeCode) {
      case 1:
        return 'event.basketball.stat.three_pointers';
      case 2:
        return 'event.basketball.stat.two_pointers';
      case 3:
        return 'event.basketball.stat.free_throws_made';
      case 4:
        return 'event.basketball.stat.remaining_timeouts';
      case 5:
        return 'event.basketball.stat.fouls';
      case 6:
        return 'event.basketball.stat.free_throw_pct';
      case 7:
        return 'event.basketball.stat.total_timeouts';
      default:
        return '';
    }
  }

  factory BasketballStat.fromList(List<dynamic> list) {
    return BasketballStat(
      typeCode: (list[0] as num).toInt(),
      homeValue: double.tryParse(list[1]?.toString() ?? '0') ?? 0,
      awayValue: double.tryParse(list[2]?.toString() ?? '0') ?? 0,
    );
  }
}

@immutable
class BasketballMatchEventsData {
  const BasketballMatchEventsData({
    required this.id,
    required this.statusId,
    required this.homeQuarterScores,
    required this.awayQuarterScores,
    required this.homeTotal,
    required this.awayTotal,
    required this.timerRunning,
    required this.timerCountdown,
    required this.timerUpdateTime,
    required this.timerRemaining,
    required this.stats,
  });

  final String id;
  final int statusId;

  /// Per-section scores: [Q1, Q2, Q3, Q4, OT]
  final List<int> homeQuarterScores;
  final List<int> awayQuarterScores;

  /// Pre-computed totals (regular + OT, handling multi-OT via over_time_scores).
  final int homeTotal;
  final int awayTotal;

  final bool timerRunning;
  final bool timerCountdown;
  final int timerUpdateTime;
  final int timerRemaining;

  final List<BasketballStat> stats;

  int get currentRemainingSeconds {
    if (!timerRunning || timerUpdateTime == 0) return timerRemaining;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final elapsed = now - timerUpdateTime;
    if (timerCountdown)
      return (timerRemaining - elapsed).clamp(0, timerRemaining);
    return timerRemaining + elapsed;
  }

  String get clockDisplay {
    final secs = currentRemainingSeconds;
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get showClock => const {2, 4, 6, 8, 9, 13}.contains(statusId);

  factory BasketballMatchEventsData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>;
    final homeScores = (score[3] as List<dynamic>)
        .map((e) => (e as num).toInt())
        .toList();
    final awayScores = (score[4] as List<dynamic>)
        .map((e) => (e as num).toInt())
        .toList();
    final timer = json['timer'] as List<dynamic>?;

    // Regular quarters (Q1–Q4), excluding OT slot.
    final homeRegular = homeScores.take(4).fold(0, (a, b) => a + b);
    final awayRegular = awayScores.take(4).fold(0, (a, b) => a + b);

    // over_time_scores is only present for 2+ OT periods; otherwise fall back to score[x][4].
    final otScores = json['over_time_scores'] as List<dynamic>?;
    final int homeOt;
    final int awayOt;
    if (otScores != null && otScores.length >= 2) {
      homeOt = (otScores[0] as List<dynamic>).fold(
        0,
        (a, b) => a + (b as num).toInt(),
      );
      awayOt = (otScores[1] as List<dynamic>).fold(
        0,
        (a, b) => a + (b as num).toInt(),
      );
    } else {
      homeOt = homeScores.length > 4 ? homeScores[4] : 0;
      awayOt = awayScores.length > 4 ? awayScores[4] : 0;
    }

    return BasketballMatchEventsData(
      id: score[0] as String,
      statusId: score[1] as int,
      homeQuarterScores: homeScores,
      awayQuarterScores: awayScores,
      homeTotal: homeRegular + homeOt,
      awayTotal: awayRegular + awayOt,
      timerRunning: timer != null ? (timer[0] as int) == 1 : false,
      timerCountdown: timer != null ? (timer[1] as int) == 1 : false,
      timerUpdateTime: timer != null ? (timer[2] as num).toInt() : 0,
      timerRemaining: timer != null ? (timer[3] as num).toInt() : 0,
      stats: (json['stats'] as List<dynamic>? ?? [])
          .map((e) => BasketballStat.fromList(e as List<dynamic>))
          .toList(),
    );
  }
}
