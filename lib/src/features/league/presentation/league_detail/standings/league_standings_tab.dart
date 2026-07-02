import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/features/league/domain/league_sport.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/standings/basketball_standings_tab.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/standings/football_standings_tab.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/standings/generic_standings_tab.dart';

/// Dispatcher that picks the correct standings widget based on [sport].
/// Used inside the full-sport [IndexedStack] for football and basketball.
/// For other sports, [DefaultStandingsTab] is used directly.
class LeagueStandingsTab extends ConsumerWidget {
  const LeagueStandingsTab({
    super.key,
    required this.sport,
    required this.leagueId,
    required this.onTeamTap,
  });

  final LeagueSport sport;
  final String leagueId;
  final void Function(String teamId, String teamName) onTeamTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sport == LeagueSport.football) {
      return FootballStandingsTab(leagueId: leagueId, onTeamTap: onTeamTap);
    } else if (sport == LeagueSport.basketball) {
      return BasketballStandingsTab(leagueId: leagueId, onTeamTap: onTeamTap);
    } else {
      return DefaultStandingsTab(
        sport: sport,
        leagueId: leagueId,
        onTeamTap: onTeamTap,
      );
    }
  }
}
