import 'package:flutter/foundation.dart';

@immutable
class TennisRealtimeData {
  const TennisRealtimeData({
    required this.id,
    required this.statusId,
    required this.servingSide,
    required this.homeTotal,
    required this.awayTotal,
    required this.homeSets,
    required this.awaySets,
    required this.homePt,
    required this.awayPt,
  });

  final String id;
  final int statusId;

  /// 0 = nobody, 1 = home, 2 = away
  final int servingSide;

  /// Sets won (ft score)
  final int homeTotal;
  final int awayTotal;

  /// Per-set game scores: index 0 = set 1, etc.
  final List<int> homeSets;
  final List<int> awaySets;

  /// Current game point score, e.g. "40", "AD", ""
  final String homePt;
  final String awayPt;

  static const _liveStatuses = {3, 51, 52, 53, 54, 55};

  bool get isLive => _liveStatuses.contains(statusId);

  String get statusLabelKey {
    switch (statusId) {
      case 1:
        return 'event.tennis.status.pre';
      case 3:
        return 'event.tennis.status.live';
      case 51:
        return 'event.tennis.status.s1';
      case 52:
        return 'event.tennis.status.s2';
      case 53:
        return 'event.tennis.status.s3';
      case 54:
        return 'event.tennis.status.s4';
      case 55:
        return 'event.tennis.status.s5';
      case 100:
        return 'event.tennis.status.ft';
      case 20:
      case 22:
      case 23:
        return 'event.tennis.status.wo';
      case 21:
      case 24:
      case 25:
        return 'event.tennis.status.ret';
      case 26:
      case 27:
        return 'event.tennis.status.def';
      case 14:
        return 'event.tennis.status.pst';
      case 15:
        return 'event.tennis.status.dly';
      case 16:
        return 'event.tennis.status.can';
      case 17:
        return 'event.tennis.status.int';
      case 18:
        return 'event.tennis.status.sus';
      case 99:
        return 'event.tennis.status.tbd';
      default:
        return '';
    }
  }

  factory TennisRealtimeData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>;
    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ft = scoreData['ft'] as List<dynamic>?;
    final pt = scoreData['pt'] as List<dynamic>?;

    // Collect per-set scores from p1, p2, p3... keys
    final homeSets = <int>[];
    final awaySets = <int>[];
    for (var i = 1; i <= 5; i++) {
      final setKey = 'p$i';
      final setScore = scoreData[setKey] as List<dynamic>?;
      if (setScore == null) break;
      homeSets.add((setScore[0] as num?)?.toInt() ?? 0);
      awaySets.add((setScore[1] as num?)?.toInt() ?? 0);
    }

    return TennisRealtimeData(
      id: score[0] as String? ?? '',
      statusId: (score[1] as num?)?.toInt() ?? 0,
      servingSide: (score[2] as num?)?.toInt() ?? 0,
      homeTotal: (ft?[0] as num?)?.toInt() ?? 0,
      awayTotal: (ft?[1] as num?)?.toInt() ?? 0,
      homeSets: homeSets,
      awaySets: awaySets,
      homePt: pt?[0]?.toString() ?? '',
      awayPt: pt?[1]?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TennisRealtimeData &&
          id == other.id &&
          statusId == other.statusId &&
          servingSide == other.servingSide &&
          homeTotal == other.homeTotal &&
          awayTotal == other.awayTotal;

  @override
  int get hashCode =>
      Object.hash(id, statusId, servingSide, homeTotal, awayTotal);
}
