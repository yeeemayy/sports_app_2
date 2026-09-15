class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.nickname,
    required this.points,
    required this.correct,
    required this.total,
    required this.streak,
    required this.bestStreak,
  });

  factory LeaderboardEntry.fromMap(String uid, Map<String, dynamic> map) {
    return LeaderboardEntry(
      uid: uid,
      nickname: map['nickname'] as String? ?? '',
      points: (map['points'] as num?)?.toInt() ?? 0,
      correct: (map['correct'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toInt() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      bestStreak: (map['bestStreak'] as num?)?.toInt() ?? 0,
    );
  }

  final String uid;
  final String nickname;
  final int points;
  final int correct;
  final int total;
  final int streak;
  final int bestStreak;
}
