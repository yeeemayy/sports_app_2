import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/models/football_standings_model.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/standings/standings_shared.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';

enum _StandingsScope { all, home, away }

class FootballStandingsTab extends ConsumerStatefulWidget {
  const FootballStandingsTab({
    super.key,
    required this.leagueId,
    required this.onTeamTap,
  });

  final String leagueId;
  final void Function(String teamId, String teamName) onTeamTap;

  @override
  ConsumerState<FootballStandingsTab> createState() =>
      _FootballStandingsTabState();
}

class _FootballStandingsTabState extends ConsumerState<FootballStandingsTab> {
  _StandingsScope _scope = _StandingsScope.all;

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
  Widget build(BuildContext context) {
    final async = ref.watch(
      footballStandingsProvider(leagueId: widget.leagueId),
    );

    return LeagueTabContent(
      async: async,
      isEmpty: (groups) => groups.isEmpty,
      builder: (groups) => SingleChildScrollView(
        child: Column(
          children: [
            _ScopeFilterBar(
              selected: _scope,
              onChanged: (s) => setState(() => _scope = s),
            ),
            StandingsTableHeader(
              cols: [
                '',
                '#',
                'league.col.club'.tr(),
                'league.col.played'.tr(),
                'league.col.won'.tr(),
                'league.col.draw'.tr(),
                'league.col.loss'.tr(),
                'league.col.gd'.tr(),
                'league.col.pts'.tr(),
              ],
              colWidths: const [14, 22, 0, 24, 24, 24, 24, 56, 32],
            ),
            for (final group
                in (groups.toList()..sort(
                  (a, b) => (a.conference ?? '').compareTo(b.conference ?? ''),
                )))
              for (int i = 0; i < group.rows.length; i++)
                _FootballStandingsRow(
                  row: group.rows[i],
                  scope: _scope,
                  zoneColor: _zoneColor(
                    group.rows[i].position,
                    group.rows.length,
                  ),
                  onTap: () => widget.onTeamTap(
                    group.rows[i].teamId,
                    context.localizedName(
                      en: group.rows[i].teamInfo?.name ?? '',
                      cn: group.rows[i].teamInfo?.cnName,
                    ),
                  ),
                ),
            _ZoneLegend(),
          ],
        ),
      ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _ScopeFilterBar extends StatelessWidget {
  const _ScopeFilterBar({required this.selected, required this.onChanged});

  final _StandingsScope selected;
  final ValueChanged<_StandingsScope> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.appColors.line, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _FilterChip(
            label: 'league.standings_filter.all'.tr(),
            selected: selected == _StandingsScope.all,
            onTap: () => onChanged(_StandingsScope.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'league.standings_filter.home'.tr(),
            selected: selected == _StandingsScope.home,
            onTap: () => onChanged(_StandingsScope.home),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'league.standings_filter.away'.tr(),
            selected: selected == _StandingsScope.away,
            onTap: () => onChanged(_StandingsScope.away),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? context.appColors.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? context.appColors.accent : context.appColors.line,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.mono(9).copyWith(
            color: selected
                ? context.appColors.accent
                : context.appColors.text3,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _FootballStandingsRow extends StatelessWidget {
  const _FootballStandingsRow({
    required this.row,
    required this.scope,
    required this.zoneColor,
    required this.onTap,
  });

  final FootballStandingsRow row;
  final _StandingsScope scope;
  final Color zoneColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = _pick(row.total, row.homeTotal, row.awayTotal);
    final won = _pick(row.won, row.homeWon, row.awayWon);
    final draw = _pick(row.draw, row.homeDraw, row.awayDraw);
    final loss = _pick(row.loss, row.homeLoss, row.awayLoss);
    final goals = _pick(row.goals, row.homeGoals, row.awayGoals);
    final goalsAgainst = _pick(
      row.goalsAgainst,
      row.homeGoalsAgainst,
      row.awayGoalsAgainst,
    );
    final pts = _pick(row.points, row.homePoints, row.awayPoints);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
        decoration: BoxDecoration(
          color: zoneColor == const Color(0xFFE63946)
              ? zoneColor.withValues(alpha: 0.04)
              : null,
          border: Border(
            bottom: BorderSide(color: context.appColors.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Zone indicator
            Container(
              width: 3,
              height: 20,
              margin: const EdgeInsets.only(right: 11),
              decoration: BoxDecoration(
                color: zoneColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Position
            SizedBox(
              width: 22,
              child: Text(
                '${row.position}',
                style: AppTextStyles.mono(
                  11,
                ).copyWith(color: context.appColors.text3),
              ),
            ),
            // Team
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    LeagueTeamAvatar(logoUrl: row.teamInfo?.logo, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.localizedName(
                          en: row.teamInfo?.name ?? '-',
                          cn: row.teamInfo?.cnName,
                        ),
                        style: AppTextStyles.mono(
                          11,
                        ).copyWith(color: context.appColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _statCell('$total', context),
            _statCell('$won', context),
            _statCell('$draw', context),
            _statCell('$loss', context),
            // Goals ratio column
            SizedBox(
              width: 56,
              child: Text(
                '$goals:$goalsAgainst',
                style: AppTextStyles.mono(
                  10,
                ).copyWith(color: context.appColors.text2),
                textAlign: TextAlign.center,
              ),
            ),
            // Points
            SizedBox(
              width: 32,
              child: Text(
                '$pts',
                style: AppTextStyles.mono(12).copyWith(
                  color: context.appColors.text,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _pick(int all, int? home, int? away) => switch (scope) {
    _StandingsScope.all => all,
    _StandingsScope.home => home ?? 0,
    _StandingsScope.away => away ?? 0,
  };

  Widget _statCell(String v, BuildContext context) => SizedBox(
    width: 24,
    child: Text(
      v,
      style: AppTextStyles.mono(10).copyWith(color: context.appColors.text2),
      textAlign: TextAlign.center,
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
          _LegendItem(
            color: const Color(0xFF3B82F6),
            label: 'league.zone.ucl'.tr(),
          ),
          const SizedBox(width: 14),
          _LegendItem(
            color: const Color(0xFFFF7A45),
            label: 'league.zone.europa'.tr(),
          ),
          const SizedBox(width: 14),
          _LegendItem(
            color: const Color(0xFFE63946),
            label: 'league.zone.relegation'.tr(),
          ),
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
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
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
