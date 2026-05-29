import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_team_stat.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';

const _kPad = 16.0;
const _kColW = 50.0;

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
  const _ColDef({required this.headerKey, required this.value, required this.sortNum});
  final String headerKey;
  final String Function(BasketballTeamStat) value;
  final num Function(BasketballTeamStat) sortNum;
}

double _pct(String? s) => double.tryParse(s ?? '') ?? 0;

List<_ColDef> _columnsFor(_Category cat) => switch (cat) {
  _Category.offense => [
    _ColDef(
      headerKey: 'league.basketball_col.gp',
      value: (t) => '${t.matches ?? 0}',
      sortNum: (t) => t.matches ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.pts',
      value: (t) => '${t.points ?? 0}',
      sortNum: (t) => t.points ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.ast',
      value: (t) => '${t.assists ?? 0}',
      sortNum: (t) => t.assists ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.reb',
      value: (t) => '${t.rebounds ?? 0}',
      sortNum: (t) => t.rebounds ?? 0,
    ),
  ],
  _Category.shooting => [
    _ColDef(
      headerKey: 'league.basketball_col.fg_pct',
      value: (t) => '${t.fieldGoalsAccuracy ?? 0}',
      sortNum: (t) => _pct(t.fieldGoalsAccuracy),
    ),
    _ColDef(
      headerKey: 'league.basketball_col.three_pct',
      value: (t) => '${t.threePointersAccuracy ?? 0}',
      sortNum: (t) => _pct(t.threePointersAccuracy),
    ),
    _ColDef(
      headerKey: 'league.basketball_col.two_pct',
      value: (t) => '${t.twoPointersAccuracy ?? 0}',
      sortNum: (t) => _pct(t.twoPointersAccuracy),
    ),
    _ColDef(
      headerKey: 'league.basketball_col.ft_pct',
      value: (t) => '${t.freeThrowsAccuracy ?? 0}',
      sortNum: (t) => _pct(t.freeThrowsAccuracy),
    ),
  ],
  _Category.defense => [
    _ColDef(
      headerKey: 'league.basketball_col.stl',
      value: (t) => '${t.steals ?? 0}',
      sortNum: (t) => t.steals ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.reb',
      value: (t) => '${t.defensiveRebounds ?? 0}',
      sortNum: (t) => t.defensiveRebounds ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.blk',
      value: (t) => '${t.blocks ?? 0}',
      sortNum: (t) => t.blocks ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.tov',
      value: (t) => '${t.turnovers ?? 0}',
      sortNum: (t) => t.turnovers ?? 0,
    ),
  ],
  _Category.other => [
    _ColDef(
      headerKey: 'league.basketball_col.gp',
      value: (t) => '${t.matches ?? 0}',
      sortNum: (t) => t.matches ?? 0,
    ),
    _ColDef(headerKey: 'league.basketball_col.min', value: (_) => '-', sortNum: (_) => 0),
    _ColDef(
      headerKey: 'league.basketball_col.pf',
      value: (t) => '${t.totalFouls ?? 0}',
      sortNum: (t) => t.totalFouls ?? 0,
    ),
    _ColDef(
      headerKey: 'league.basketball_col.scope',
      value: (t) => '${t.scope ?? 0}',
      sortNum: (t) => t.scope ?? 0,
    ),
  ],
};

int _primarySortIndex(_Category cat) => switch (cat) {
  _Category.offense => 1, // pts
  _Category.shooting => 0, // fg%
  _Category.defense => 0, // stl
  _Category.other => 0, // gp
};

// ─── Tab widget ───────────────────────────────────────────────────────────────

class BasketballTeamStatsTab extends ConsumerStatefulWidget {
  const BasketballTeamStatsTab({super.key, required this.leagueId, required this.onTeamTap});

  final String leagueId;
  final ValueChanged<String> onTeamTap;

  @override
  ConsumerState<BasketballTeamStatsTab> createState() => _BasketballTeamStatsTabState();
}

class _BasketballTeamStatsTabState extends ConsumerState<BasketballTeamStatsTab> {
  _Category _category = _Category.offense;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(basketballTeamStatsProvider(leagueId: widget.leagueId));

    return LeagueTabContent(
      async: async,
      builder: (teams) {
        final cols = _columnsFor(_category);
        final sortIdx = _primarySortIndex(_category);
        final sorted = [...teams]
          ..sort((a, b) => cols[sortIdx].sortNum(b).compareTo(cols[sortIdx].sortNum(a)));

        return Column(
          children: [
            _CategoryBar(selected: _category, onChanged: (c) => setState(() => _category = c)),
            _HeaderRow(cols: cols),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: sorted.length,
                itemBuilder: (context, i) => _TeamRow(
                  team: sorted[i],
                  cols: cols,
                  onTap: () => widget.onTeamTap(sorted[i].teamId ?? sorted[i].team?.id ?? ''),
                ),
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
        border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
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
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

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
          color: selected ? context.appColors.accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? context.appColors.accent : context.appColors.line,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.mono(9).copyWith(
            color: selected ? context.appColors.accent : context.appColors.text3,
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
        border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 26 + 9), // avatar placeholder
          Expanded(
            child: Text(
              'league.col.team'.tr(),
              style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
            ),
          ),
          for (final col in cols)
            SizedBox(
              width: _kColW,
              child: Text(
                col.headerKey.tr(),
                style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.team, required this.cols, required this.onTap});

  final BasketballTeamStat team;
  final List<_ColDef> cols;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(_kPad, 11, _kPad, 11),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.appColors.line, width: 0.5)),
        ),
        child: Row(
          children: [
            LeagueTeamAvatar(logoUrl: team.team?.logo, size: 26, circleFallback: false),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                context.localizedName(en: team.team?.name ?? '-', cn: team.team?.cnName),
                style: AppTextStyles.mono(12).copyWith(color: context.appColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            for (final col in cols)
              SizedBox(
                width: _kColW,
                child: Text(
                  col.value(team),
                  style: AppTextStyles.mono(12).copyWith(color: context.appColors.text2),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
