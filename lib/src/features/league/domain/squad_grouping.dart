import 'package:shenghaotiyu/src/features/league/domain/league_sport.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/squad_player.dart';

/// Groups and sorts [players] into position buckets for display.
///
/// Returns a list of groups in the canonical position order for [sport]
/// (GK → DEF → MID → FWD for football; PG → SG → SF → PF → C for basketball).
/// Unknown positions are appended alphabetically at the end.
///
/// This is a pure function with no Flutter or provider dependencies, making
/// it straightforward to unit-test.
List<SquadGroup> groupSquadByPosition(
  List<SquadPlayer> players,
  LeagueSport sport,
) {
  const footballOrder = ['GK', 'DEF', 'MID', 'FWD'];
  const basketballOrder = ['PG', 'SG', 'SF', 'PF', 'C', 'G', 'F'];
  final posOrder = sport == LeagueSport.football
      ? footballOrder
      : basketballOrder;

  // Group by normalised position key.
  final groups = <String, List<SquadPlayer>>{};
  for (final p in players) {
    final pos = _normalizePos(p.position ?? '', sport);
    groups.putIfAbsent(pos, () => []).add(p);
  }

  // Sort groups by canonical order; unknown positions go last, alphabetically.
  final sorted = groups.entries.toList()
    ..sort((a, b) {
      final ai = posOrder.indexOf(a.key);
      final bi = posOrder.indexOf(b.key);
      if (ai == -1 && bi == -1) return a.key.compareTo(b.key);
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      return ai.compareTo(bi);
    });

  return sorted.map((e) => (position: e.key, players: e.value)).toList();
}

/// Named record for a single position group.
typedef SquadGroup = ({String position, List<SquadPlayer> players});

// ─── Internal helpers ─────────────────────────────────────────────────────────

String _normalizePos(String pos, LeagueSport sport) {
  final upper = pos.toUpperCase();
  if (sport == LeagueSport.football) {
    if (upper == 'GK' || upper == 'G') {
      return 'GK';
    }
    if (upper == 'D' ||
        upper == 'DEF' ||
        upper == 'CB' ||
        upper == 'LB' ||
        upper == 'RB') {
      return 'DEF';
    }
    if (upper == 'M' ||
        upper == 'MID' ||
        upper == 'CM' ||
        upper == 'DM' ||
        upper == 'AM') {
      return 'MID';
    }
    if (upper == 'F' ||
        upper == 'FWD' ||
        upper == 'ST' ||
        upper == 'LW' ||
        upper == 'RW') {
      return 'FWD';
    }
  }
  return upper.isEmpty ? '?' : upper;
}
