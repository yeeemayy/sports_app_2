import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_player_stat.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_standings_model.dart';
import 'package:sports_app/src/features/league/domain/models/football_player_stat.dart';
import 'package:sports_app/src/features/league/domain/models/football_standings_model.dart';
import 'package:sports_app/src/features/league/domain/models/league_detail_model.dart';
import 'package:sports_app/src/features/league/domain/models/squad_player.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';
import 'package:sports_app/src/features/league/presentation/widgets/inner_tab_bar.dart';
import 'package:sports_app/src/routes/app_routes.dart';

const _kPad = 22.0;
const _kHeroHeight = 160.0;

class LeagueDetailScreen extends ConsumerStatefulWidget {
  const LeagueDetailScreen({super.key, required this.sport, required this.leagueId});

  final LeagueSport sport;
  final String leagueId;

  @override
  ConsumerState<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends ConsumerState<LeagueDetailScreen> {
  int _tabIndex = 0;

  // Squads tab: selected team
  String? _selectedSquadTeamId;
  String? _selectedSquadTeamName;

  List<String> get _tabs => [
    'league.tabs.standings'.tr(),
    widget.sport == LeagueSport.football
        ? 'league.tabs.top_scorers'.tr()
        : 'league.tabs.top_players'.tr(),
    'league.tabs.team_stats'.tr(),
    'league.tabs.squads'.tr(),
  ];

  @override
  Widget build(BuildContext context) {
    final detailAsync = widget.sport == LeagueSport.football
        ? ref.watch(footballLeagueDetailProvider(leagueId: widget.leagueId))
        : ref.watch(basketballLeagueDetailProvider(leagueId: widget.leagueId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: detailAsync.when(
        loading: () => _buildSkeleton(),
        error: (e, _) => _buildError(),
        data: (detail) => Column(
          children: [
            _Hero(detail: detail, sport: widget.sport, onBack: () => context.pop()),
            _StatStrip(detail: detail, sport: widget.sport),
            LeagueInnerTabBar(
              tabs: _tabs,
              activeIndex: _tabIndex,
              onTap: (i) => setState(() => _tabIndex = i),
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _StandingsTab(
                    sport: widget.sport,
                    leagueId: widget.leagueId,
                    onTeamTap: (teamId, teamName) =>
                        context.push(AppRoutes.leagueTeamPath(widget.sport.apiPath, teamId)),
                  ),
                  _TopScorersTab(
                    sport: widget.sport,
                    leagueId: widget.leagueId,
                    onPlayerTap: (playerId) =>
                        context.push(AppRoutes.leaguePlayerPath(widget.sport.apiPath, playerId)),
                  ),
                  _TeamStatsTab(
                    sport: widget.sport,
                    leagueId: widget.leagueId,
                    onTeamTap: (teamId) =>
                        context.push(AppRoutes.leagueTeamPath(widget.sport.apiPath, teamId)),
                  ),
                  _SquadsTab(
                    sport: widget.sport,
                    leagueId: widget.leagueId,
                    selectedTeamId: _selectedSquadTeamId,
                    selectedTeamName: _selectedSquadTeamName,
                    onTeamSelected: (id, name) => setState(() {
                      _selectedSquadTeamId = id;
                      _selectedSquadTeamName = name;
                    }),
                    onPlayerTap: (playerId) =>
                        context.push(AppRoutes.leaguePlayerPath(widget.sport.apiPath, playerId)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: [
        Skeletonizer(
          enabled: true,
          child: Container(
            height: _kHeroHeight + MediaQuery.of(context).padding.top,
            color: context.appColors.surface2,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: context.appColors.text3, size: 48),
          const SizedBox(height: 12),
          Text(
            'league.empty'.tr(),
            style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
          ),
        ],
      ),
    );
  }
}

// ─── Hero banner ─────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.detail, required this.sport, required this.onBack});

  final LeagueDetailModel detail;
  final LeagueSport sport;
  final VoidCallback onBack;

  Color _parseHex(String? hex, Color fallback) {
    if (hex == null) return fallback;
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c1 = _parseHex(detail.primaryColor, context.appColors.surface2);
    final c2 = _parseHex(detail.secondaryColor, context.appColors.surface);
    final onHero = ThemeData.estimateBrightnessForColor(c1) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Container(
      height: _kHeroHeight + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c1.withValues(alpha: 0.7), c2.withValues(alpha: 0.3)],
        ),
      ),
      child: Stack(
        children: [
          // Accent blob
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [c2.withValues(alpha: 0.22), Colors.transparent]),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.3),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
                ),
                child: const Icon(Icons.chevron_left_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
          // Center content
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                CachedNetworkImage(
                  imageUrl: detail.logo,
                  height: 52,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: Colors.white12),
                  errorBuilder: (_, _, _) => Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white12),
                    child: const Icon(Icons.emoji_events_outlined, size: 26, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.localizedName(en: detail.name, cn: detail.cnName).toUpperCase(),
                  style: AppTextStyles.display(22, context).copyWith(height: 1, color: onHero),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  [
                    if (detail.categoryDetails?.name != null)
                      context
                          .localizedName(
                            en: detail.categoryDetails!.name,
                            cn: detail.categoryDetails!.cnName,
                          )
                          .toUpperCase(),
                    if (detail.currSeasonDetails?.year != null) detail.currSeasonDetails!.year,
                  ].join(' · '),
                  style: AppTextStyles.mono(
                    10,
                  ).copyWith(color: onHero.withValues(alpha: 0.55), letterSpacing: 10 * 0.14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat strip ───────────────────────────────────────────────────────────────

class _StatStrip extends StatelessWidget {
  const _StatStrip({required this.detail, required this.sport});

  final LeagueDetailModel detail;
  final LeagueSport sport;

  @override
  Widget build(BuildContext context) {
    final stats = sport == LeagueSport.football
        ? [
            ('${detail.roundCount ?? '-'}', 'league.stat.rounds'.tr()),
            ('${detail.goals ?? '-'}', 'league.stat.goals'.tr()),
            ('${detail.totalTeams ?? '-'}', 'league.stat.clubs'.tr()),
            ('${detail.totalPlayers ?? '-'}', 'league.stat.matches'.tr()),
          ]
        : [
            ('${detail.currSeasonDetails?.year ?? '-'}', 'league.stat.season'.tr()),
            ('${detail.totalTeams ?? '-'}', 'league.stat.teams'.tr()),
            ('${detail.totalPlayers ?? '-'}', 'league.stat.matches'.tr()),
          ];

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            Expanded(
              child: _StatCell(value: stats[i].$1, label: stats[i].$2),
            ),
            if (i < stats.length - 1)
              VerticalDivider(
                thickness: 0.5,
                width: 1,
                color: context.appColors.line,
                indent: 8,
                endIndent: 8,
              ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.display(16, context).copyWith(color: context.appColors.text),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.mono(
              8,
            ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.12),
          ),
        ],
      ),
    );
  }
}

// ─── Standings Tab ────────────────────────────────────────────────────────────

class _StandingsTab extends ConsumerWidget {
  const _StandingsTab({required this.sport, required this.leagueId, required this.onTeamTap});

  final LeagueSport sport;
  final String leagueId;
  final void Function(String teamId, String teamName) onTeamTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sport == LeagueSport.football) {
      return _FootballStandingsTab(leagueId: leagueId, onTeamTap: onTeamTap);
    } else {
      return _BasketballStandingsTab(leagueId: leagueId, onTeamTap: onTeamTap);
    }
  }
}

class _FootballStandingsTab extends ConsumerWidget {
  const _FootballStandingsTab({required this.leagueId, required this.onTeamTap});

  final String leagueId;
  final void Function(String teamId, String teamName) onTeamTap;

  static const _zoneColors = {
    'ucl': Color(0xFF3B82F6),
    'europa': Color(0xFFFF7A45),
    'relegation': Color(0xFFE63946),
  };

  Color _zoneColor(int pos, int total) {
    if (pos <= 4) return _zoneColors['ucl']!;
    if (pos <= 6) return _zoneColors['europa']!;
    if (total > 0 && pos > total - 3) return _zoneColors['relegation']!;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(footballStandingsProvider(leagueId: leagueId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Text(
          'league.empty'.tr(),
          style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
        ),
      ),
      data: (groups) {
        if (groups.isEmpty) {
          return Center(
            child: Text(
              'league.empty'.tr(),
              style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
            ),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              // Column headers
              _StandingsHeader(
                cols: [
                  '',
                  '#',
                  'league.col.club'.tr(),
                  'league.col.played'.tr(),
                  'league.col.won'.tr(),
                  'league.col.draw'.tr(),
                  'league.col.gd'.tr(),
                  'league.col.pts'.tr(),
                ],
                colWidths: const [14, 22, 0, 24, 24, 24, 32, 32],
              ),
              for (final group in groups)
                for (int i = 0; i < group.rows.length; i++) ...[
                  _FootballStandingsRow(
                    row: group.rows[i],
                    zoneColor: _zoneColor(group.rows[i].position, group.rows.length),
                    onTap: () => onTeamTap(
                      group.rows[i].teamId,
                      context.localizedName(
                        en: group.rows[i].teamInfo?.name ?? '',
                        cn: group.rows[i].teamInfo?.cnName,
                      ),
                    ),
                  ),
                ],
              // Legend
              _ZoneLegend(),
            ],
          ),
        );
      },
    );
  }
}

class _StandingsHeader extends StatelessWidget {
  const _StandingsHeader({required this.cols, required this.colWidths});

  final List<String> cols;
  final List<double> colWidths;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < cols.length; i++)
            i == 2
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        cols[i],
                        style: AppTextStyles.mono(
                          8,
                        ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
                      ),
                    ),
                  )
                : SizedBox(
                    width: colWidths[i],
                    child: Text(
                      cols[i],
                      style: AppTextStyles.mono(
                        8,
                      ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
                      textAlign: i < 2 ? TextAlign.left : TextAlign.right,
                    ),
                  ),
        ],
      ),
    );
  }
}

class _FootballStandingsRow extends StatelessWidget {
  const _FootballStandingsRow({required this.row, required this.zoneColor, required this.onTap});

  final FootballStandingsRow row;
  final Color zoneColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
        decoration: BoxDecoration(
          color: zoneColor == const Color(0xFFE63946) ? zoneColor.withValues(alpha: 0.04) : null,
          border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
        ),
        child: Row(
          children: [
            // Zone indicator
            Container(
              width: 3,
              height: 20,
              margin: const EdgeInsets.only(right: 11),
              decoration: BoxDecoration(color: zoneColor, borderRadius: BorderRadius.circular(2)),
            ),
            // Position
            SizedBox(
              width: 22,
              child: Text(
                '${row.position}',
                style: AppTextStyles.mono(11).copyWith(color: context.appColors.text3),
              ),
            ),
            // Team
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    if (row.teamInfo?.logo != null)
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: row.teamInfo!.logo,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.appColors.surface2,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.localizedName(
                          en: row.teamInfo?.name ?? '-',
                          cn: row.teamInfo?.cnName,
                        ),
                        style: AppTextStyles.mono(11).copyWith(color: context.appColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Stats
            _statCell('${row.total}', context),
            _statCell('${row.won}', context),
            _statCell('${row.draw}', context),
            _statCell('${row.goalDiff >= 0 ? '+' : ''}${row.goalDiff}', context),
            SizedBox(
              width: 32,
              child: Text(
                '${row.points}',
                style: AppTextStyles.mono(
                  12,
                ).copyWith(color: context.appColors.text, fontWeight: FontWeight.w600),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCell(String v, BuildContext context) => SizedBox(
    width: 24,
    child: Text(
      v,
      style: AppTextStyles.mono(10).copyWith(color: context.appColors.text2),
      textAlign: TextAlign.right,
    ),
  );
}

class _ZoneLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _LegendItem(color: const Color(0xFF3B82F6), label: 'league.zone.ucl'.tr()),
          const SizedBox(width: 14),
          _LegendItem(color: const Color(0xFFFF7A45), label: 'league.zone.europa'.tr()),
          const SizedBox(width: 14),
          _LegendItem(color: const Color(0xFFE63946), label: 'league.zone.relegation'.tr()),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.mono(
            8,
          ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
        ),
      ],
    );
  }
}

class _BasketballStandingsTab extends ConsumerWidget {
  const _BasketballStandingsTab({required this.leagueId, required this.onTeamTap});

  final String leagueId;
  final void Function(String teamId, String teamName) onTeamTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(basketballStandingsProvider(leagueId: leagueId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Text(
          'league.empty'.tr(),
          style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
        ),
      ),
      data: (conferences) {
        if (conferences.isEmpty) {
          return Center(
            child: Text(
              'league.empty'.tr(),
              style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
            ),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              for (final entry in conferences.entries) ...[
                _ConferenceHeader(name: entry.key),
                // Col headers
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '#',
                          style: AppTextStyles.mono(8).copyWith(color: context.appColors.text3),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            'league.col.team'.tr(),
                            style: AppTextStyles.mono(
                              8,
                            ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
                          ),
                        ),
                      ),
                      for (final h in [
                        'league.col.won'.tr(),
                        'league.col.loss'.tr(),
                        'league.col.win_rate'.tr(),
                        'league.col.game_back'.tr(),
                        'league.col.ppg'.tr(),
                        'league.col.papg'.tr(),
                      ])
                        SizedBox(
                          width: 45,
                          child: Text(
                            h,
                            style: AppTextStyles.mono(
                              8,
                            ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
                for (final row in entry.value.rows)
                  _BasketballStandingsRow(
                    row: row,
                    onTap: () => onTeamTap(
                      row.teamId,
                      context.localizedName(en: row.teamInfo?.name ?? '', cn: row.teamInfo?.cnName),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ConferenceHeader extends StatelessWidget {
  const _ConferenceHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _kPad, vertical: 7),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            name,
            style: AppTextStyles.mono(
              9,
            ).copyWith(color: context.appColors.live, letterSpacing: 9 * 0.2),
          ),
        ],
      ),
    );
  }
}

class _BasketballStandingsRow extends StatelessWidget {
  const _BasketballStandingsRow({required this.row, required this.onTap});

  final BasketballStandingsRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '${row.position}',
                style: AppTextStyles.mono(11).copyWith(color: context.appColors.text3),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    if (row.teamInfo?.logo != null)
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: row.teamInfo!.logo,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Container(width: 20, height: 20, color: context.appColors.surface2),
                        ),
                      ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        context.localizedName(
                          en: row.teamInfo?.name ?? '-',
                          cn: row.teamInfo?.cnName,
                        ),
                        style: AppTextStyles.mono(11).copyWith(color: context.appColors.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _bCell('${row.won}', context),
            _bCell('${row.lost}', context),
            _bCell(row.wonRate != null ? (row.wonRate! * 100).toStringAsFixed(1) : '-', context),
            _bCell(row.gameBack ?? '-', context),
            _bCell(row.pointsAvg?.toStringAsFixed(1) ?? '-', context, accent: true),
            _bCell(row.pointsAgainstAvg?.toStringAsFixed(1) ?? '-', context),
          ],
        ),
      ),
    );
  }

  Widget _bCell(String v, BuildContext context, {bool accent = false}) => SizedBox(
    width: 45,
    child: Text(
      v,
      style: AppTextStyles.mono(
        11,
      ).copyWith(color: accent ? context.appColors.accent : context.appColors.text2),
      textAlign: TextAlign.center,
    ),
  );
}

// ─── Top Scorers Tab ──────────────────────────────────────────────────────────

class _TopScorersTab extends ConsumerWidget {
  const _TopScorersTab({required this.sport, required this.leagueId, required this.onPlayerTap});

  final LeagueSport sport;
  final String leagueId;
  final ValueChanged<String> onPlayerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sport == LeagueSport.football) {
      return _FootballTopScorers(leagueId: leagueId, onPlayerTap: onPlayerTap);
    } else {
      return _BasketballTopScorers(leagueId: leagueId, onPlayerTap: onPlayerTap);
    }
  }
}

class _FootballTopScorers extends ConsumerWidget {
  const _FootballTopScorers({required this.leagueId, required this.onPlayerTap});

  final String leagueId;
  final ValueChanged<String> onPlayerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(footballPlayerStatsProvider(leagueId: leagueId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Text(
          'league.empty'.tr(),
          style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
        ),
      ),
      data: (players) => ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: players.length,
        itemBuilder: (context, i) {
          final p = players[i];
          return _FootballPlayerRow(rank: i + 1, player: p, onTap: () => onPlayerTap(p.player.id));
        },
      ),
    );
  }
}

class _FootballPlayerRow extends StatelessWidget {
  const _FootballPlayerRow({required this.rank, required this.player, required this.onTap});

  final int rank;
  final FootballPlayerStat player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(_kPad, 13, _kPad, 13),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '$rank',
                style: AppTextStyles.display(
                  20,
                  context,
                ).copyWith(color: rank == 1 ? context.appColors.accent : context.appColors.text3),
              ),
            ),
            const SizedBox(width: 12),
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: player.player.logo ?? '',
                width: 38,
                height: 38,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: context.appColors.surface2),
                errorBuilder: (_, _, _) => Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appColors.surface2,
                  ),
                  child: Icon(Icons.person, color: context.appColors.text3, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context
                        .localizedName(en: player.player.name, cn: player.player.cnName)
                        .toUpperCase(),
                    style: AppTextStyles.display(
                      15,
                      context,
                    ).copyWith(color: context.appColors.text, height: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${player.team.name} · ${player.player.position ?? '-'}',
                    style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                  ),
                ],
              ),
            ),
            // Goals
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${player.goals ?? 0}',
                      style: AppTextStyles.display(
                        22,
                        context,
                      ).copyWith(color: context.appColors.text),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'league.player.goals'.tr(),
                      style: AppTextStyles.mono(10).copyWith(color: context.appColors.text3),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Assists
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.assists ?? 0}',
                  style: AppTextStyles.mono(12).copyWith(color: context.appColors.text2),
                ),
                Text(
                  'league.player.assists'.tr(),
                  style: AppTextStyles.mono(
                    8,
                  ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BasketballTopScorers extends ConsumerWidget {
  const _BasketballTopScorers({required this.leagueId, required this.onPlayerTap});

  final String leagueId;
  final ValueChanged<String> onPlayerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(basketballPlayerStatsProvider(leagueId: leagueId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Text(
          'league.empty'.tr(),
          style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
        ),
      ),
      data: (players) => ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: players.length,
        itemBuilder: (context, i) {
          final p = players[i];
          return _BasketballPlayerRow(
            rank: i + 1,
            player: p,
            onTap: () {
              if (p.player != null) onPlayerTap(p.playerId);
            },
          );
        },
      ),
    );
  }
}

class _BasketballPlayerRow extends StatelessWidget {
  const _BasketballPlayerRow({required this.rank, required this.player, required this.onTap});

  final int rank;
  final BasketballPlayerStat player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = player.player;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(_kPad, 13, _kPad, 13),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 35,
              child: Text(
                '$rank',
                style: AppTextStyles.display(
                  20,
                  context,
                ).copyWith(color: rank == 1 ? context.appColors.accent : context.appColors.text3),
              ),
            ),
            const SizedBox(width: 12),
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: p?.logo ?? '',
                width: 38,
                height: 38,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: context.appColors.surface2),
                errorBuilder: (_, _, _) => Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appColors.surface2,
                  ),
                  child: Icon(Icons.person, color: context.appColors.text3, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.localizedName(en: p?.name ?? '-', cn: p?.cnName).toUpperCase(),
                    style: AppTextStyles.display(
                      14,
                      context,
                    ).copyWith(color: context.appColors.text, height: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${context.localizedName(en: player.team?.name ?? '-', cn: player.team?.cnName)} · ${p?.position ?? '-'}',
                    style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                  ),
                ],
              ),
            ),
            // PPG
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.points ?? 0}',
                  style: AppTextStyles.display(20, context).copyWith(color: context.appColors.text),
                ),
                Text(
                  'league.player.ppg'.tr(),
                  style: AppTextStyles.mono(
                    8,
                  ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.rebounds ?? 0}',
                  style: AppTextStyles.mono(12).copyWith(color: context.appColors.text2),
                ),
                Text(
                  'league.player.rpg'.tr(),
                  style: AppTextStyles.mono(8).copyWith(color: context.appColors.text3),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.assists ?? 0}',
                  style: AppTextStyles.mono(12).copyWith(color: context.appColors.text2),
                ),
                Text(
                  'league.player.apg'.tr(),
                  style: AppTextStyles.mono(8).copyWith(color: context.appColors.text3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Team Stats Tab ───────────────────────────────────────────────────────────

class _TeamStatsTab extends ConsumerWidget {
  const _TeamStatsTab({required this.sport, required this.leagueId, required this.onTeamTap});

  final LeagueSport sport;
  final String leagueId;
  final ValueChanged<String> onTeamTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sport == LeagueSport.football) {
      return _FootballTeamStatsTab(leagueId: leagueId, onTeamTap: onTeamTap);
    } else {
      return _BasketballTeamStatsTab(leagueId: leagueId, onTeamTap: onTeamTap);
    }
  }
}

class _FootballTeamStatsTab extends ConsumerWidget {
  const _FootballTeamStatsTab({required this.leagueId, required this.onTeamTap});

  final String leagueId;
  final ValueChanged<String> onTeamTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(footballTeamStatsProvider(leagueId: leagueId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Text(
          'league.empty'.tr(),
          style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
        ),
      ),
      data: (teams) => Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(_kPad, 7, _kPad, 7),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'league.col.club'.tr(),
                    style: AppTextStyles.mono(
                      9,
                    ).copyWith(color: context.appColors.text3, letterSpacing: 9 * 0.1),
                  ),
                ),
                for (final h in [
                  'league.col.poss'.tr(),
                  'league.col.shots'.tr(),
                  'league.col.pass'.tr(),
                ])
                  SizedBox(
                    width: 54,
                    child: Text(
                      h,
                      style: AppTextStyles.mono(
                        9,
                      ).copyWith(color: context.appColors.text3, letterSpacing: 9 * 0.1),
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: teams.length,
              itemBuilder: (context, i) {
                final t = teams[i];
                final passAcc = t.passesAccuracy != null && t.passes != null && t.passes! > 0
                    ? ((t.passesAccuracy! / t.passes!) * 100).toStringAsFixed(1)
                    : '-';
                return GestureDetector(
                  onTap: () => onTeamTap(t.team.id),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(_kPad, 12, _kPad, 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (t.team.logo != null)
                                ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: t.team.logo!,
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                  ),
                                ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  context.localizedName(en: t.team.name, cn: t.team.cnName),
                                  style: AppTextStyles.mono(
                                    12,
                                  ).copyWith(color: context.appColors.text),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _tsCell('${t.ballPossession ?? '-'}', context),
                        _tsCell('${t.shots ?? '-'}/90', context),
                        _tsCell(passAcc, context),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tsCell(String v, BuildContext context) => SizedBox(
    width: 54,
    child: Text(
      v,
      style: AppTextStyles.mono(12).copyWith(color: context.appColors.text2),
      textAlign: TextAlign.right,
    ),
  );
}

class _BasketballTeamStatsTab extends ConsumerWidget {
  const _BasketballTeamStatsTab({required this.leagueId, required this.onTeamTap});

  final String leagueId;
  final ValueChanged<String> onTeamTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(basketballTeamStatsProvider(leagueId: leagueId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Text(
          'league.empty'.tr(),
          style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
        ),
      ),
      data: (teams) => Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(_kPad, 7, _kPad, 7),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'league.col.team'.tr(),
                    style: AppTextStyles.mono(
                      9,
                    ).copyWith(color: context.appColors.text3, letterSpacing: 9 * 0.1),
                  ),
                ),
                for (final h in [
                  'league.col.fg'.tr(),
                  'league.col.three_p'.tr(),
                  'league.col.reb'.tr(),
                  'league.col.ast'.tr(),
                ])
                  SizedBox(
                    width: 44,
                    child: Text(
                      h,
                      style: AppTextStyles.mono(
                        9,
                      ).copyWith(color: context.appColors.text3, letterSpacing: 9 * 0.1),
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: teams.length,
              itemBuilder: (context, i) {
                final t = teams[i];
                return GestureDetector(
                  onTap: () => onTeamTap(t.teamId ?? t.team?.id ?? ''),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(_kPad, 12, _kPad, 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (t.team?.logo != null)
                                ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: t.team!.logo!,
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                  ),
                                ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  context.localizedName(
                                    en: t.team?.name ?? '-',
                                    cn: t.team?.cnName,
                                  ),
                                  style: AppTextStyles.mono(
                                    12,
                                  ).copyWith(color: context.appColors.text),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _btsCell(t.fieldGoalsAccuracy ?? '-', context),
                        _btsCell(t.threePointersAccuracy ?? '-', context),
                        _btsCell('${t.rebounds ?? '-'}', context),
                        _btsCell('${t.assists ?? '-'}', context),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _btsCell(String v, BuildContext context) => SizedBox(
    width: 44,
    child: Text(
      v,
      style: AppTextStyles.mono(12).copyWith(color: context.appColors.text2),
      textAlign: TextAlign.right,
    ),
  );
}

// ─── Squads Tab ───────────────────────────────────────────────────────────────

class _SquadsTab extends ConsumerWidget {
  const _SquadsTab({
    required this.sport,
    required this.leagueId,
    required this.selectedTeamId,
    required this.selectedTeamName,
    required this.onTeamSelected,
    required this.onPlayerTap,
  });

  final LeagueSport sport;
  final String leagueId;
  final String? selectedTeamId;
  final String? selectedTeamName;
  final void Function(String id, String name) onTeamSelected;
  final ValueChanged<String> onPlayerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get teams from standings to populate the team selector
    final teamsAsync = sport == LeagueSport.football
        ? ref
              .watch(footballStandingsProvider(leagueId: leagueId))
              .whenData(
                (groups) => groups.isEmpty
                    ? <({String id, String name, String logo})>[]
                    : groups.first.rows
                          .take(8)
                          .map(
                            (r) => (
                              id: r.teamId,
                              name: context.localizedName(
                                en: r.teamInfo?.name ?? '-',
                                cn: r.teamInfo?.cnName,
                              ),
                              logo: r.teamInfo?.logo ?? '',
                            ),
                          )
                          .toList(),
              )
        : ref.watch(basketballStandingsProvider(leagueId: leagueId)).whenData((conferences) {
            final allRows = conferences.values.expand((c) => c.rows).take(8).toList();
            return allRows
                .map(
                  (r) => (
                    id: r.teamId,
                    name: context.localizedName(
                      en: r.teamInfo?.name ?? '-',
                      cn: r.teamInfo?.cnName,
                    ),
                    logo: r.teamInfo?.logo ?? '',
                  ),
                )
                .toList();
          });

    return teamsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Text(
          'league.empty'.tr(),
          style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
        ),
      ),
      data: (teams) {
        // Auto-select first team if none selected
        final activeId = selectedTeamId ?? (teams.isNotEmpty ? teams.first.id : null);

        if (activeId == null) {
          return Center(
            child: Text(
              'league.empty'.tr(),
              style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
            ),
          );
        }

        return Column(
          children: [
            // Team selector chips
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(_kPad, 8, _kPad, 8),
                itemCount: teams.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final t = teams[i];
                  final isActive = t.id == activeId;
                  return GestureDetector(
                    onTap: () => onTeamSelected(t.id, t.name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? context.appColors.surface2 : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isActive ? context.appColors.accent : context.appColors.lineStrong,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (t.logo.isNotEmpty)
                            ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: t.logo,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const SizedBox.shrink(),
                              ),
                            ),
                          if (t.logo.isNotEmpty) const SizedBox(width: 7),
                          Text(
                            t.name,
                            style: AppTextStyles.mono(11).copyWith(color: context.appColors.text),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Squad list
            Expanded(
              child: _SquadList(sport: sport, teamId: activeId, onPlayerTap: onPlayerTap),
            ),
          ],
        );
      },
    );
  }
}

class _SquadList extends ConsumerWidget {
  const _SquadList({required this.sport, required this.teamId, required this.onPlayerTap});

  final LeagueSport sport;
  final String teamId;
  final ValueChanged<String> onPlayerTap;

  // Football position order
  static const _footballOrder = ['GK', 'DEF', 'D', 'MID', 'M', 'FWD', 'F'];
  // Basketball position order
  static const _basketballOrder = ['PG', 'SG', 'SF', 'PF', 'C', 'G', 'F'];

  List<String> get _posOrder => sport == LeagueSport.football ? _footballOrder : _basketballOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = sport == LeagueSport.football
        ? ref.watch(footballSquadProvider(teamId: teamId))
        : ref.watch(basketballSquadProvider(teamId: teamId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Text(
          'league.empty'.tr(),
          style: AppTextStyles.body(14).copyWith(color: context.appColors.text3),
        ),
      ),
      data: (players) {
        // Group by position
        final groups = <String, List<SquadPlayer>>{};
        for (final p in players) {
          final pos = _normalizePos(p.position ?? '');
          groups.putIfAbsent(pos, () => []).add(p);
        }

        // Sort groups
        final sortedKeys = groups.keys.toList()
          ..sort((a, b) {
            final ai = _posOrder.indexOf(a);
            final bi = _posOrder.indexOf(b);
            if (ai == -1 && bi == -1) return a.compareTo(b);
            if (ai == -1) return 1;
            if (bi == -1) return -1;
            return ai.compareTo(bi);
          });

        // Col headers
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(_kPad, 6, _kPad, 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'league.squad.player'.tr(),
                      style: AppTextStyles.mono(
                        8,
                      ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
                    ),
                  ),
                  if (sport == LeagueSport.basketball)
                    SizedBox(
                      width: 32,
                      child: Text(
                        '#',
                        style: AppTextStyles.mono(8).copyWith(color: context.appColors.text3),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      'league.squad.age'.tr(),
                      style: AppTextStyles.mono(
                        8,
                      ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      'league.squad.height'.tr(),
                      style: AppTextStyles.mono(
                        8,
                      ).copyWith(color: context.appColors.text3, letterSpacing: 8 * 0.1),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: sortedKeys.fold<int>(0, (sum, k) => sum + 1 + (groups[k]?.length ?? 0)),
                itemBuilder: (context, index) {
                  int count = 0;
                  for (final key in sortedKeys) {
                    if (index == count) {
                      // Section header
                      return _SquadPositionHeader(pos: key);
                    }
                    count++;
                    final groupPlayers = groups[key]!;
                    if (index < count + groupPlayers.length) {
                      final player = groupPlayers[index - count];
                      return _SquadPlayerRow(
                        player: player,
                        sport: sport,
                        showNum: sport == LeagueSport.basketball,
                        onTap: () => onPlayerTap(player.id),
                      );
                    }
                    count += groupPlayers.length;
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _normalizePos(String pos) {
    final upper = pos.toUpperCase();
    if (sport == LeagueSport.football) {
      if (upper == 'GK' || upper == 'G') return 'GK';
      if (upper == 'D' || upper == 'DEF' || upper == 'CB' || upper == 'LB' || upper == 'RB')
        return 'DEF';
      if (upper == 'M' || upper == 'MID' || upper == 'CM' || upper == 'DM' || upper == 'AM')
        return 'MID';
      if (upper == 'F' || upper == 'FWD' || upper == 'ST' || upper == 'LW' || upper == 'RW')
        return 'FWD';
    }
    return upper.isEmpty ? '?' : upper;
  }
}

class _SquadPositionHeader extends StatelessWidget {
  const _SquadPositionHeader({required this.pos});

  final String pos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _kPad, vertical: 7),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
      ),
      child: Text(
        pos,
        style: AppTextStyles.mono(
          9,
        ).copyWith(color: context.appColors.accent, letterSpacing: 9 * 0.2),
      ),
    );
  }
}

class _SquadPlayerRow extends StatelessWidget {
  const _SquadPlayerRow({
    required this.player,
    required this.sport,
    required this.showNum,
    required this.onTap,
  });

  final SquadPlayer player;
  final LeagueSport sport;
  final bool showNum;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(_kPad, 10, _kPad, 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: context.appColors.surface2),
              child: player.logo != null && player.logo!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: player.logo!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Text(
                            player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                            style: AppTextStyles.display(
                              12,
                              context,
                            ).copyWith(color: context.appColors.text2),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                        style: AppTextStyles.display(
                          12,
                          context,
                        ).copyWith(color: context.appColors.text2),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.localizedName(en: player.name, cn: player.cnName),
                style: AppTextStyles.mono(11).copyWith(color: context.appColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showNum)
              SizedBox(
                width: 32,
                child: Text(
                  '${player.shirtNumber ?? '-'}',
                  style: AppTextStyles.mono(11).copyWith(color: context.appColors.text3),
                  textAlign: TextAlign.right,
                ),
              ),
            SizedBox(
              width: 36,
              child: Text(
                '${player.age ?? '-'}',
                style: AppTextStyles.mono(11).copyWith(color: context.appColors.text2),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                player.height != null ? '${player.height}cm' : '-',
                style: AppTextStyles.mono(10).copyWith(color: context.appColors.text3),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
