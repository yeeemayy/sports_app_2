import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/features/league/domain/league_sport.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/team_stats/basketball_team_stats_tab.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/team_stats/football_team_stats_tab.dart';

/// Dispatcher that picks football or basketball team-stats widget.
class LeagueTeamStatsTab extends ConsumerWidget {
  const LeagueTeamStatsTab({
    super.key,
    required this.sport,
    required this.leagueId,
    required this.onTeamTap,
  });

  final LeagueSport sport;
  final String leagueId;
  final ValueChanged<String> onTeamTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sport == LeagueSport.football) {
      return FootballTeamStatsTab(leagueId: leagueId, onTeamTap: onTeamTap);
    } else {
      return BasketballTeamStatsTab(leagueId: leagueId, onTeamTap: onTeamTap);
    }
  }
}
