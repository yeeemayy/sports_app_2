import 'package:shenghaotiyu/src/features/event/domain/models/sport_realtime_data.dart';

class BasketballRealtimeData implements SportRealtimeData {
  const BasketballRealtimeData({
    required this.id,
    required this.statusId,
    required this.homeTotal,
    required this.awayTotal,
    required this.timerRunning,
    required this.timerCountdown,
    required this.timerUpdateTime,
    required this.timerRemaining,
  });

  final String id;
  final int statusId;
  final int homeTotal;
  final int awayTotal;

  /// Whether the game clock is currently running.
  final bool timerRunning;

  /// Whether the clock counts down (true) or up (false).
  final bool timerCountdown;

  /// Unix timestamp (seconds) when [timerRemaining] was recorded.
  final int timerUpdateTime;

  /// Remaining seconds in the current section as of [timerUpdateTime].
  final int timerRemaining;

  factory BasketballRealtimeData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>;
    final homeScores = (score[3] as List<dynamic>)
        .map((e) => (e as num).toInt())
        .toList();
    final awayScores = (score[4] as List<dynamic>)
        .map((e) => (e as num).toInt())
        .toList();

    final timer = json['timer'] as List<dynamic>?;

    // Regular quarters total (Q1–Q4), excluding the OT slot at index 4.
    final homeRegular = homeScores.take(4).fold(0, (a, b) => a + b);
    final awayRegular = awayScores.take(4).fold(0, (a, b) => a + b);

    // over_time_scores is only present when there are 2+ OT periods.
    // When it exists, use its sum for OT; otherwise fall back to score[x][4].
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

    return BasketballRealtimeData(
      id: score[0] as String,
      statusId: score[1] as int,
      homeTotal: homeRegular + homeOt,
      awayTotal: awayRegular + awayOt,
      timerRunning: timer != null ? (timer[0] as int) == 1 : false,
      timerCountdown: timer != null ? (timer[1] as int) == 1 : false,
      timerUpdateTime: timer != null ? (timer[2] as num).toInt() : 0,
      timerRemaining: timer != null ? (timer[3] as num).toInt() : 0,
    );
  }

  /// Current remaining seconds, adjusted for clock drift since the last update.
  int get currentRemainingSeconds {
    if (!timerRunning || timerUpdateTime == 0) return timerRemaining;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final elapsed = now - timerUpdateTime;
    if (timerCountdown) {
      return (timerRemaining - elapsed).clamp(0, timerRemaining);
    }
    return timerRemaining + elapsed;
  }

  /// Game clock formatted as "MM:SS".
  String get clockDisplay {
    final secs = currentRemainingSeconds;
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// i18n key for the period label — call `.tr()` on it in the widget.
  String get periodLabelKey {
    switch (statusId) {
      case 1:
        return 'event.basketball.period.not_started';
      case 2:
        return 'event.basketball.period.q1';
      case 3:
        return 'event.basketball.period.q1_over';
      case 4:
        return 'event.basketball.period.q2';
      case 5:
        return 'event.basketball.period.q2_over';
      case 6:
        return 'event.basketball.period.q3';
      case 7:
        return 'event.basketball.period.q3_over';
      case 8:
        return 'event.basketball.period.q4';
      case 9:
        return 'event.basketball.period.ot';
      case 10:
        return 'event.basketball.period.end';
      case 11:
        return 'event.basketball.period.interrupt';
      case 12:
        return 'event.basketball.period.cancel';
      case 13:
        return 'event.basketball.period.extension';
      case 14:
        return 'event.basketball.period.half';
      default:
        return '';
    }
  }

  /// True when the game clock should be displayed (actively playing quarter/OT).
  bool get showClock => const {2, 4, 6, 8, 9, 13}.contains(statusId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasketballRealtimeData &&
          id == other.id &&
          statusId == other.statusId &&
          homeTotal == other.homeTotal &&
          awayTotal == other.awayTotal &&
          timerRunning == other.timerRunning &&
          timerCountdown == other.timerCountdown &&
          timerUpdateTime == other.timerUpdateTime &&
          timerRemaining == other.timerRemaining;

  @override
  int get hashCode => Object.hash(
    id,
    statusId,
    homeTotal,
    awayTotal,
    timerRunning,
    timerCountdown,
    timerUpdateTime,
    timerRemaining,
  );
}
