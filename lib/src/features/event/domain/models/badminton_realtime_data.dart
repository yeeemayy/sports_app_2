import 'package:flutter/foundation.dart';

@immutable
class BadmintonRealtimeData {
  const BadmintonRealtimeData({
    required this.id,
    required this.statusId,
    required this.servingSide,
    required this.homeTotal,
    required this.awayTotal,
    required this.homeSets,
    required this.awaySets,
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

  static const _liveStatuses = {3, 51, 52, 53, 54, 55};

  bool get isLive => _liveStatuses.contains(statusId);

  factory BadmintonRealtimeData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>;
    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ft = scoreData['ft'] as List<dynamic>?;

    final homeSets = <int>[];
    final awaySets = <int>[];
    for (var i = 1; i <= 5; i++) {
      final setKey = 'p$i';
      final setScore = scoreData[setKey] as List<dynamic>?;
      if (setScore == null) break;
      homeSets.add((setScore[0] as num?)?.toInt() ?? 0);
      awaySets.add((setScore[1] as num?)?.toInt() ?? 0);
    }

    return BadmintonRealtimeData(
      id: score[0] as String? ?? '',
      statusId: (score[1] as num?)?.toInt() ?? 0,
      servingSide: (score[2] as num?)?.toInt() ?? 0,
      homeTotal: (ft?[0] as num?)?.toInt() ?? 0,
      awayTotal: (ft?[1] as num?)?.toInt() ?? 0,
      homeSets: homeSets,
      awaySets: awaySets,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadmintonRealtimeData &&
          id == other.id &&
          statusId == other.statusId &&
          servingSide == other.servingSide &&
          homeTotal == other.homeTotal &&
          awayTotal == other.awayTotal;

  @override
  int get hashCode => Object.hash(id, statusId, servingSide, homeTotal, awayTotal);
}
