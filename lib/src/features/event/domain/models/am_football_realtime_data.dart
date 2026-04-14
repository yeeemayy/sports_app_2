import 'package:flutter/foundation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_realtime_data.dart';

@immutable
class AmFootballRealtimeData implements SportRealtimeData {
  const AmFootballRealtimeData({
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
    required this.homeP4,
    required this.awayP4,
    required this.homeOt,
    required this.awayOt,
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
  final int homeP4;
  final int awayP4;
  final int homeOt;
  final int awayOt;

  static const _liveStatuses = {44, 45, 46, 47, 10};
  bool get isLive => _liveStatuses.contains(statusId);

  factory AmFootballRealtimeData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>;
    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ft = scoreData['ft'] as List<dynamic>?;

    int periodScore(String key, int idx) {
      final v = scoreData[key] as List<dynamic>?;
      return (v?[idx] as num?)?.toInt() ?? 0;
    }

    return AmFootballRealtimeData(
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
      homeP4: periodScore('p4', 0),
      awayP4: periodScore('p4', 1),
      homeOt: periodScore('ot', 0),
      awayOt: periodScore('ot', 1),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmFootballRealtimeData &&
          id == other.id &&
          statusId == other.statusId &&
          homeScore == other.homeScore &&
          awayScore == other.awayScore;

  @override
  int get hashCode => Object.hash(id, statusId, homeScore, awayScore);
}
