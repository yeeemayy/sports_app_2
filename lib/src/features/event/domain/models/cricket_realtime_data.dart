import 'package:flutter/foundation.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/cricket_match_detail.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_realtime_data.dart';

@immutable
class CricketRealtimeData implements SportRealtimeData {
  const CricketRealtimeData({
    required this.id,
    required this.statusId,
    required this.homeScore,
    required this.awayScore,
    required this.innings,
    this.results,
  });

  final String id;
  final int statusId;
  final int homeScore;
  final int awayScore;
  final List<CricketInnings> innings;
  final CricketResults? results;

  static const _liveStatuses = {
    2,
    3,
    532,
    533,
    534,
    535,
    536,
    537,
    538,
    539,
    540,
    541,
    542,
    543,
    544,
    545,
  };
  bool get isLive => _liveStatuses.contains(statusId);

  factory CricketRealtimeData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>;

    final id = score.isNotEmpty ? score[0] as String? ?? '' : '';
    final statusId = score.length > 1 ? (score[1] as num?)?.toInt() ?? 0 : 0;

    final scoreData = score.length > 3 && score[3] is Map
        ? (score[3] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final ft = scoreData['ft'] as List<dynamic>?;
    final homeScore = (ft?[0] as num?)?.toInt() ?? 0;
    final awayScore = (ft?[1] as num?)?.toInt() ?? 0;

    final extraScores = score.length > 4 && score[4] is Map
        ? (score[4] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final rawInnings = extraScores['innings'] as List<dynamic>? ?? [];
    final innings = rawInnings
        .whereType<List<dynamic>>()
        .map((i) => CricketInnings.fromList(i))
        .toList();

    final rawResults = extraScores['results'];
    CricketResults? results;
    if (rawResults is Map) {
      results = CricketResults.fromJson(rawResults.cast<String, dynamic>());
    }

    return CricketRealtimeData(
      id: id,
      statusId: statusId,
      homeScore: homeScore,
      awayScore: awayScore,
      innings: innings,
      results: results,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CricketRealtimeData &&
          id == other.id &&
          statusId == other.statusId &&
          homeScore == other.homeScore &&
          awayScore == other.awayScore;

  @override
  int get hashCode => Object.hash(id, statusId, homeScore, awayScore);
}
