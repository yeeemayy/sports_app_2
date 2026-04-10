import 'package:flutter/foundation.dart';
import 'package:sports_app/src/features/event/domain/models/sport_realtime_data.dart';

@immutable
class BaseballRealtimeData implements SportRealtimeData {
  const BaseballRealtimeData({
    required this.id,
    required this.statusId,
    required this.homeScore,
    required this.awayScore,
    required this.scores,
  });

  final String id;
  final int statusId;

  /// Total runs — home team (ft[0]).
  final String homeScore;

  /// Total runs — away team (ft[1]).
  final String awayScore;

  /// Full scores map: ft, p1..p9, h, e.
  final Map<String, dynamic> scores;

  factory BaseballRealtimeData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>? ?? [];
    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ft = scoreData['ft'] as List<dynamic>?;

    return BaseballRealtimeData(
      id: score.isNotEmpty ? (score[0] as String? ?? '') : (json['id'] as String? ?? ''),
      statusId: score.length > 1 ? (score[1] as num?)?.toInt() ?? 0 : 0,
      homeScore: ft != null && ft.isNotEmpty ? (ft[0] as String? ?? '0') : '0',
      awayScore: ft != null && ft.length > 1 ? (ft[1] as String? ?? '0') : '0',
      scores: scoreData,
    );
  }
}
