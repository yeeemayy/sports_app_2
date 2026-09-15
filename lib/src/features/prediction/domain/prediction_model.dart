enum PredictionPick { home, draw, away }

class PredictionTally {
  const PredictionTally({
    this.homeVotes = 0,
    this.drawVotes = 0,
    this.awayVotes = 0,
  });

  final int homeVotes;
  final int drawVotes;
  final int awayVotes;

  int get total => homeVotes + drawVotes + awayVotes;

  double get homePct => total == 0 ? 0 : homeVotes / total;
  double get drawPct => total == 0 ? 0 : drawVotes / total;
  double get awayPct => total == 0 ? 0 : awayVotes / total;

  factory PredictionTally.fromMap(Map<String, dynamic> map) => PredictionTally(
    homeVotes: (map['homeVotes'] as num?)?.toInt() ?? 0,
    drawVotes: (map['drawVotes'] as num?)?.toInt() ?? 0,
    awayVotes: (map['awayVotes'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'homeVotes': homeVotes,
    'drawVotes': drawVotes,
    'awayVotes': awayVotes,
  };
}

/// A user's aggregate prediction-league record, stored at
/// `users/{uid}/predictionStats/summary`.
class PredictionStats {
  const PredictionStats({
    this.points = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.correct = 0,
    this.total = 0,
  });

  final int points;
  final int streak;
  final int bestStreak;
  final int correct;
  final int total;

  double get accuracy => total == 0 ? 0 : correct / total;

  factory PredictionStats.fromMap(Map<String, dynamic> map) => PredictionStats(
    points: (map['points'] as num?)?.toInt() ?? 0,
    streak: (map['streak'] as num?)?.toInt() ?? 0,
    bestStreak: (map['bestStreak'] as num?)?.toInt() ?? 0,
    correct: (map['correct'] as num?)?.toInt() ?? 0,
    total: (map['total'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'points': points,
    'streak': streak,
    'bestStreak': bestStreak,
    'correct': correct,
    'total': total,
  };
}
