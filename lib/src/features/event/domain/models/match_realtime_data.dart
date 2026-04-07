class MatchRealtimeData {
  const MatchRealtimeData({
    required this.id,
    required this.statusId,
    required this.homeScore,
    required this.homeHtScore,
    required this.awayScore,
    required this.awayHtScore,
    required this.kickoffTimestamp,
  });

  final String id;
  final int statusId;
  final int homeScore;
  final int homeHtScore;
  final int awayScore;
  final int awayHtScore;
  final int kickoffTimestamp;

  factory MatchRealtimeData.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as List<dynamic>;
    final homeScores = score[2] as List<dynamic>;
    final awayScores = score[3] as List<dynamic>;
    return MatchRealtimeData(
      id: score[0] as String,
      statusId: score[1] as int,
      homeScore: homeScores[0] as int,
      homeHtScore: homeScores[1] as int,
      awayScore: awayScores[0] as int,
      awayHtScore: awayScores[1] as int,
      kickoffTimestamp: score[4] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchRealtimeData &&
          id == other.id &&
          statusId == other.statusId &&
          homeScore == other.homeScore &&
          homeHtScore == other.homeHtScore &&
          awayScore == other.awayScore &&
          awayHtScore == other.awayHtScore &&
          kickoffTimestamp == other.kickoffTimestamp;

  @override
  int get hashCode => Object.hash(
        id,
        statusId,
        homeScore,
        homeHtScore,
        awayScore,
        awayHtScore,
        kickoffTimestamp,
      );
}
