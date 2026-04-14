import 'package:flutter/foundation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_realtime_data.dart';

@immutable
class IceHockeyRealtimeData implements SportRealtimeData {
  const IceHockeyRealtimeData({
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
    required this.homeOt,
    required this.awayOt,
    required this.homeAp,
    required this.awayAp,
    required this.homeSets,
    required this.awaySets,
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
  final int homeOt;
  final int awayOt;
  final int homeAp;
  final int awayAp;

  /// Per-set game scores: index 0 = set 1, etc.
  final List<int> homeSets;
  final List<int> awaySets;

  static const _liveStatuses = {30, 331, 31, 332, 32, 6, 10, 8, 13};
  bool get isLive => _liveStatuses.contains(statusId);

  factory IceHockeyRealtimeData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>;
    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ft = scoreData['ft'] as List<dynamic>?;

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

    int periodScore(String key, int idx) {
      final v = scoreData[key] as List<dynamic>?;
      return (v?[idx] as num?)?.toInt() ?? 0;
    }

    return IceHockeyRealtimeData(
      id: score[0] as String? ?? '',
      statusId: (score[1] as num?)?.toInt() ?? 0,
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
      homeSets: homeSets,
      awaySets: awaySets,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IceHockeyRealtimeData &&
          id == other.id &&
          statusId == other.statusId &&
          homeScore == other.homeScore &&
          awayScore == other.awayScore;

  @override
  int get hashCode => Object.hash(id, statusId, homeScore, awayScore);
}
