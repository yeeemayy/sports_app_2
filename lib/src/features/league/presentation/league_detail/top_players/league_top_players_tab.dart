import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/top_players/basketball_top_players_tab.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/top_players/football_top_players_tab.dart';

/// Dispatcher that picks football or basketball top-players widget.
class LeagueTopPlayersTab extends ConsumerWidget {
  const LeagueTopPlayersTab({
    super.key,
    required this.sport,
    required this.leagueId,
    required this.onPlayerTap,
  });

  final LeagueSport sport;
  final String leagueId;
  final ValueChanged<String> onPlayerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sport == LeagueSport.football) {
      return FootballTopPlayersTab(
        leagueId: leagueId,
        onPlayerTap: onPlayerTap,
      );
    } else {
      return BasketballTopPlayersTab(
        leagueId: leagueId,
        onPlayerTap: onPlayerTap,
      );
    }
  }
}
