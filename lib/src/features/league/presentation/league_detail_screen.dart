import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_detail_header.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/overview/league_overview_tab.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/standings/generic_standings_tab.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/standings/league_standings_tab.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/team_stats/league_team_stats_tab.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/top_players/league_top_players_tab.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';
import 'package:sports_app/src/features/league/presentation/widgets/inner_tab_bar.dart';
import 'package:sports_app/src/routes/app_routes.dart';

const _kHeroHeight = 160.0;

class LeagueDetailScreen extends ConsumerStatefulWidget {
  const LeagueDetailScreen({
    super.key,
    required this.sport,
    required this.leagueId,
  });

  final LeagueSport sport;
  final String leagueId;

  @override
  ConsumerState<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends ConsumerState<LeagueDetailScreen> {
  int _tabIndex = 0;

  bool get _isFullSport =>
      widget.sport == LeagueSport.football ||
      widget.sport == LeagueSport.basketball;

  List<String> get _tabs {
    if (_isFullSport) {
      return [
        'league.tabs.overview'.tr(),
        'league.tabs.standings'.tr(),
        widget.sport == LeagueSport.football
            ? 'league.tabs.top_scorers'.tr()
            : 'league.tabs.top_players'.tr(),
        'league.tabs.team_stats'.tr(),
      ];
    }
    if (widget.sport.hasStandings) {
      return ['league.tabs.standings'.tr()];
    }
    return [];
  }

  bool get _hasTeamDetail =>
      widget.sport == LeagueSport.football ||
      widget.sport == LeagueSport.basketball ||
      widget.sport == LeagueSport.amFootball;

  void _navigateToTeam(String teamId) {
    if (teamId.isNotEmpty && _hasTeamDetail) {
      context.push(AppRoutes.leagueTeamPath(widget.sport.apiPath, teamId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = switch (widget.sport) {
      LeagueSport.football => ref.watch(
        footballLeagueDetailProvider(leagueId: widget.leagueId),
      ),
      LeagueSport.basketball => ref.watch(
        basketballLeagueDetailProvider(leagueId: widget.leagueId),
      ),
      final s => ref.watch(
        sportLeagueDetailProvider(sport: s, leagueId: widget.leagueId),
      ),
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: detailAsync.when(
        loading: () => _buildSkeleton(),
        error: (e, _) => _buildError(),
        data: (detail) => Column(
          children: [
            LeagueDetailHeader(
              detail: detail,
              sport: widget.sport,
              onBack: () => context.pop(),
            ),
            if (_tabs.isNotEmpty) ...[
              if (_tabs.length > 1)
                LeagueInnerTabBar(
                  tabs: _tabs,
                  activeIndex: _tabIndex,
                  onTap: (i) => setState(() => _tabIndex = i),
                ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: _isFullSport
                      ? IndexedStack(
                          index: _tabIndex,
                          children: [
                            LeagueOverviewTab(
                              detail: detail,
                              sport: widget.sport,
                            ),
                            LeagueStandingsTab(
                              sport: widget.sport,
                              leagueId: widget.leagueId,
                              onTeamTap: (teamId, _) => _navigateToTeam(teamId),
                            ),
                            LeagueTopPlayersTab(
                              sport: widget.sport,
                              leagueId: widget.leagueId,
                              onPlayerTap: (playerId) => context.push(
                                AppRoutes.leaguePlayerPath(
                                  widget.sport.apiPath,
                                  playerId,
                                ),
                              ),
                            ),
                            LeagueTeamStatsTab(
                              sport: widget.sport,
                              leagueId: widget.leagueId,
                              onTeamTap: (teamId) => _navigateToTeam(teamId),
                            ),
                          ],
                        )
                      : GenericStandingsTab(
                          sport: widget.sport,
                          leagueId: widget.leagueId,
                          onTeamTap: (teamId, _) => _navigateToTeam(teamId),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return SafeArea(
      bottom: false,
      child: IconButton(
        icon: const Icon(Icons.arrow_circle_left_outlined),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        Skeletonizer(
          enabled: true,
          child: Container(
            height: _kHeroHeight,
            color: context.appColors.surface2,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: context.appColors.text3,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'league.empty'.tr(),
                  style: AppTextStyles.body(
                    14,
                  ).copyWith(color: context.appColors.text3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
