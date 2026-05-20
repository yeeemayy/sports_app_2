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
