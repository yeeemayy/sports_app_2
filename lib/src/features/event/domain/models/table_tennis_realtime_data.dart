import 'package:flutter/foundation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_realtime_data.dart';

@immutable
class TableTennisRealtimeData implements SportRealtimeData {
  const TableTennisRealtimeData({
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

  /// Games won (ft score)
  final int homeTotal;
  final int awayTotal;

  /// Per-game point scores: index 0 = game 1, etc.
  final List<int> homeSets;
  final List<int> awaySets;

  static const _liveStatuses = {3, 51, 52, 53, 54, 55, 472, 473};

  bool get isLive => _liveStatuses.contains(statusId);

  factory TableTennisRealtimeData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>;
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

    return TableTennisRealtimeData(
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
      other is TableTennisRealtimeData &&
          id == other.id &&
          statusId == other.statusId &&
          servingSide == other.servingSide &&
          homeTotal == other.homeTotal &&
          awayTotal == other.awayTotal;

  @override
  int get hashCode =>
      Object.hash(id, statusId, servingSide, homeTotal, awayTotal);
}
