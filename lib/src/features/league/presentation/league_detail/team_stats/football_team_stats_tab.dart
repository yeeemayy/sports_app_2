import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/models/football_team_stat.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';

const _kPad = 16.0;

enum _TeamStatType {
  goals,
  goalsAgainst,
  shotsOnTarget,
  possession,
  passAcc,
  tackles,
  corners,
  yellowCards,
  keyPasses,
  dribbles,
  interceptions,
}

extension _TeamStatTypeX on _TeamStatType {
  String get labelKey => switch (this) {
    _TeamStatType.goals => 'league.team_stat_filter.goals',
    _TeamStatType.goalsAgainst => 'league.team_stat_filter.goals_against',
    _TeamStatType.shotsOnTarget => 'league.team_stat_filter.shots_on_target',
    _TeamStatType.possession => 'league.team_stat_filter.possession',
    _TeamStatType.passAcc => 'league.team_stat_filter.pass_acc',
    _TeamStatType.tackles => 'league.team_stat_filter.tackles',
    _TeamStatType.corners => 'league.team_stat_filter.corners',
    _TeamStatType.yellowCards => 'league.team_stat_filter.yellow_cards',
    _TeamStatType.keyPasses => 'league.team_stat_filter.key_passes',
    _TeamStatType.dribbles => 'league.team_stat_filter.dribbles',
    _TeamStatType.interceptions => 'league.team_stat_filter.interceptions',
  };

  // For goals_against we sort ascending (fewer is better); everything else descending.
  bool get sortAscending => this == _TeamStatType.goalsAgainst;

  num sortValue(FootballTeamStat t) => switch (this) {
    _TeamStatType.goals => t.goals ?? 0,
    _TeamStatType.goalsAgainst => t.goalsAgainst ?? 0,
    _TeamStatType.shotsOnTarget => t.shotsOnTarget ?? 0,
    _TeamStatType.possession => t.ballPossession ?? 0,
    _TeamStatType.passAcc => _passAccNum(t),
    _TeamStatType.tackles => t.tackles ?? 0,
    _TeamStatType.corners => t.cornerKicks ?? 0,
    _TeamStatType.yellowCards => t.yellowCards ?? 0,
    _TeamStatType.keyPasses => t.keyPasses ?? 0,
    _TeamStatType.dribbles => t.dribbleSucc ?? 0,
    _TeamStatType.interceptions => t.interceptions ?? 0,
  };

  String displayValue(FootballTeamStat t) => switch (this) {
    _TeamStatType.possession => '${t.ballPossession ?? 0}%',
    _TeamStatType.passAcc => '${_passAccNum(t).toStringAsFixed(1)}%',
    _ => '${sortValue(t).toInt()}',
  };

  static double _passAccNum(FootballTeamStat t) =>
      (t.passes != null && t.passes! > 0 && t.passesAccuracy != null)
      ? (t.passesAccuracy! / t.passes!) * 100
      : 0;
}

class FootballTeamStatsTab extends ConsumerStatefulWidget {
  const FootballTeamStatsTab({
    super.key,
    required this.leagueId,
    required this.onTeamTap,
  });

  final String leagueId;
  final ValueChanged<String> onTeamTap;

  @override
  ConsumerState<FootballTeamStatsTab> createState() =>
      _FootballTeamStatsTabState();
}

class _FootballTeamStatsTabState extends ConsumerState<FootballTeamStatsTab> {
  _TeamStatType _statType = _TeamStatType.goals;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(
      footballTeamStatsProvider(leagueId: widget.leagueId),
    );

    return LeagueTabContent(
      async: async,
      builder: (teams) {
        final sorted = [...teams]
          ..sort((a, b) {
            final cmp = _statType
                .sortValue(a)
                .compareTo(_statType.sortValue(b));
            return _statType.sortAscending ? cmp : -cmp;
          });

        return Column(
          children: [
            _StatFilterBar(
              selected: _statType,
              onChanged: (t) => setState(() => _statType = t),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: sorted.length,
                itemBuilder: (context, i) => _TeamStatRow(
                  rank: i + 1,
                  team: sorted[i],
                  statType: _statType,
                  onTap: () => widget.onTeamTap(sorted[i].team.id),
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

class _StatFilterBar extends StatelessWidget {
  const _StatFilterBar({required this.selected, required this.onChanged});

  final _TeamStatType selected;
  final ValueChanged<_TeamStatType> onChanged;

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
            for (int i = 0; i < _TeamStatType.values.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _StatChip(
                label: _TeamStatType.values[i].labelKey.tr(),
                selected: selected == _TeamStatType.values[i],
                onTap: () => onChanged(_TeamStatType.values[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
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

class _TeamStatRow extends StatelessWidget {
  const _TeamStatRow({
    required this.rank,
    required this.team,
    required this.statType,
    required this.onTap,
  });

  final int rank;
  final FootballTeamStat team;
  final _TeamStatType statType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(_kPad, 13, _kPad, 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.appColors.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 35,
              child: Text(
                '$rank',
                style: AppTextStyles.display(20, context).copyWith(
                  color: rank == 1
                      ? context.appColors.accent
                      : context.appColors.text3,
                ),
              ),
            ),
            const SizedBox(width: 12),
            LeagueTeamAvatar(
              logoUrl: team.team.logo,
              size: 38,
              circleFallback: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.localizedName(en: team.team.name, cn: team.team.cnName),
                style: AppTextStyles.mono(
                  13,
                ).copyWith(color: context.appColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  statType.displayValue(team),
                  style: AppTextStyles.display(
                    22,
                    context,
                  ).copyWith(color: context.appColors.text),
                ),
                Text(
                  statType.labelKey.tr(),
                  style: AppTextStyles.mono(
                    8,
                  ).copyWith(color: context.appColors.text3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
