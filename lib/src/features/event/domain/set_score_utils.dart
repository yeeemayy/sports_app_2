/// Extracts per-period scores for one side from a match's score map.
///
/// [scores] — the match's raw score map (e.g. `match.scores`).
/// [side] — 0 for home, 1 for away.
/// [maxSets] — upper bound for periods to read (5 for most sports, 7 for table tennis).
List<int> extractSetScores(
  Map<String, dynamic>? scores,
  int side, {
  int maxSets = 5,
}) {
  if (scores == null) return [];
  final result = <int>[];
  for (var i = 1; i <= maxSets; i++) {
    final s = scores['p$i'] as List<dynamic>?;
    if (s == null) break;
    result.add((s[side] as num?)?.toInt() ?? 0);
  }
  return result;
}
