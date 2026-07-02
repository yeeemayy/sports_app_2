import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/basketball_player_stat.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:shenghaotiyu/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:shenghaotiyu/src/features/league/presentation/providers/league_providers.dart';

const _kPad = 16.0;
const _kColW = 44.0;

// ─── Category enum ────────────────────────────────────────────────────────────

enum _Category { offense, shooting, defense, other }

extension _CategoryX on _Category {
  String get labelKey => switch (this) {
    _Category.offense => 'league.basketball_stat_category.offense',
    _Category.shooting => 'league.basketball_stat_category.shooting',
    _Category.defense => 'league.basketball_stat_category.defense',
    _Category.other => 'league.basketball_stat_category.other',
  };
}

// ─── Column definition ────────────────────────────────────────────────────────

class _ColDef {
  const _ColDef({
    required this.headerKey,
    required this.value,
    required this.sortNum,
  });
  final String headerKey;
  final String Function(BasketballPlayerStat) value;
  final num Function(BasketballPlayerStat) sortNum;
}

int _pct(String? s) => int.tryParse(s ?? '') ?? 0;

List<_ColDef> _columnsFor(_Category cat) => switch (cat) {
  _Category.offense => [
    _ColDef(
      headerKey: 'league.basketball_col.gp',
      value: (p) => '${p.matches ?? 0}',
      sortNum: (p) => p.matches ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.pts',
      value: (p) => '${p.points ?? 0}',
      sortNum: (p) => p.points ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.ast',
      value: (p) => '${p.assists ?? 0}',
      sortNum: (p) => p.assists ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.reb',
      value: (p) => '${p.rebounds ?? 0}',
      sortNum: (p) => p.rebounds ?? 0,
    ),
  ],
  _Category.shooting => [
    _ColDef(
      headerKey: 'league.basketball_col.fg_pct',
      value: (p) => '${p.fieldGoalsAccuracy ?? 0}',
      sortNum: (p) => _pct(p.fieldGoalsAccuracy),
    ),
    _ColDef(
      headerKey: 'league.basketball_col.three_pct',
      value: (p) => '${p.threePointsAccuracy ?? 0}',
      sortNum: (p) => _pct(p.threePointsAccuracy),
    ),
    _ColDef(
      headerKey: 'league.basketball_col.two_pct',
      value: (p) => '${p.twoPointsAccuracy ?? 0}',
      sortNum: (p) => _pct(p.twoPointsAccuracy),
    ),
    _ColDef(
      headerKey: 'league.basketball_col.ft_pct',
      value: (p) => '${p.freeThrowsAccuracy ?? 0}',
      sortNum: (p) => _pct(p.freeThrowsAccuracy),
    ),
  ],
  _Category.defense => [
    _ColDef(
      headerKey: 'league.basketball_col.stl',
      value: (p) => '${p.steals ?? 0}',
      sortNum: (p) => p.steals ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.reb',
      value: (p) => '${p.defensiveRebounds ?? 0}',
      sortNum: (p) => p.defensiveRebounds ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.blk',
      value: (p) => '${p.blocks ?? 0}',
      sortNum: (p) => p.blocks ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.tov',
      value: (p) => '${p.turnovers ?? 0}',
      sortNum: (p) => p.turnovers ?? 0,
    ),
  ],
  _Category.other => [
    _ColDef(
      headerKey: 'league.basketball_col.gp',
      value: (p) => '${p.matches ?? 0}',
      sortNum: (p) => p.matches ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.min',
      value: (p) => '${p.minutesPlayed ?? 0}',
      sortNum: (p) => p.minutesPlayed ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.pf',
      value: (p) => '${p.personalFouls ?? 0}',
      sortNum: (p) => p.personalFouls ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.scope',
      value: (p) => '${p.scope ?? 0}',
      sortNum: (p) => p.scope ?? 0,
    ),
  ],
};

// Sort by the "headline" column of each category (shooting sorts by pts behind the scenes)
int _primarySortIndex(_Category cat) => switch (cat) {
  _Category.offense => 1, // pts
  _Category.shooting => -1, // use _shootingSort
  _Category.defense => 0, // stl
  _Category.other => 1, // gp
};

int _shootingSort(BasketballPlayerStat a, BasketballPlayerStat b) {
  final cmp = (b.fieldGoalsScored ?? 0).compareTo(a.fieldGoalsScored ?? 0);
  if (cmp != 0) return cmp;
  return _pct(b.fieldGoalsAccuracy).compareTo(_pct(a.fieldGoalsAccuracy));
}

// ─── Tab widget ───────────────────────────────────────────────────────────────

class BasketballTopPlayersTab extends ConsumerStatefulWidget {
  const BasketballTopPlayersTab({
    super.key,
    required this.leagueId,
    required this.onPlayerTap,
  });

  final String leagueId;
  final ValueChanged<String> onPlayerTap;

  @override
  ConsumerState<BasketballTopPlayersTab> createState() =>
      _BasketballTopPlayersTabState();
}

class _BasketballTopPlayersTabState
    extends ConsumerState<BasketballTopPlayersTab> {
  _Category _category = _Category.offense;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(
      basketballPlayerStatsProvider(leagueId: widget.leagueId),
    );

    return LeagueTabContent(
      async: async,
      builder: (players) {
        final cols = _columnsFor(_category);
        final sortIdx = _primarySortIndex(_category);
        final sorted = [...players]
          ..sort(
            sortIdx == -1
                ? _shootingSort
                : (a, b) => cols[sortIdx]
                      .sortNum(b)
                      .compareTo(cols[sortIdx].sortNum(a)),
          );

        return Column(
          children: [
            _CategoryBar(
              selected: _category,
              onChanged: (c) => setState(() => _category = c),
            ),
            _HeaderRow(cols: cols),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: sorted.length,
                itemBuilder: (context, i) {
                  final p = sorted[i];
                  return _PlayerRow(
                    player: p,
                    cols: cols,
                    onTap: () {
                      if (p.player != null) widget.onPlayerTap(p.playerId);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.selected, required this.onChanged});

  final _Category selected;
  final ValueChanged<_Category> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.appColors.line, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            for (int i = 0; i < _Category.values.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _CategoryChip(
                label: _Category.values[i].labelKey.tr(),
                selected: selected == _Category.values[i],
                onTap: () => onChanged(_Category.values[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.cols});

  final List<_ColDef> cols;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(_kPad, 7, _kPad, 7),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.appColors.line, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 38 + 12), // avatar placeholder
          Expanded(
            child: Text(
              'league.col.team'.tr(),
              style: AppTextStyles.mono(
                9,
              ).copyWith(color: context.appColors.text3),
            ),
          ),
          for (final col in cols)
            SizedBox(
              width: _kColW,
              child: Text(
                col.headerKey.tr(),
                style: AppTextStyles.mono(
                  9,
                ).copyWith(color: context.appColors.text3),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.cols,
    required this.onTap,
  });

  final BasketballPlayerStat player;
  final List<_ColDef> cols;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = player.player;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(_kPad, 11, _kPad, 11),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.appColors.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            LeaguePlayerAvatar(logoUrl: p?.logo, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context
                        .localizedName(en: p?.name ?? '-', cn: p?.cnName)
                        .toUpperCase(),
                    style: AppTextStyles.display(
                      13,
                      context,
                    ).copyWith(color: context.appColors.text, height: 1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p?.position != null && p!.position!.isNotEmpty
                        ? 'league.basketball_position.${p.position}'.tr()
                        : '-',
                    style: AppTextStyles.mono(
                      9,
                    ).copyWith(color: context.appColors.text3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            for (final col in cols)
              SizedBox(
                width: _kColW,
                child: Text(
                  col.value(player),
                  style: AppTextStyles.mono(
                    12,
                  ).copyWith(color: context.appColors.text2),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
