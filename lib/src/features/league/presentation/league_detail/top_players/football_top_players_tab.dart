import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/models/football_player_stat.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';

const _kPad = 16.0;

const _kKnownPositions = {'F', 'M', 'D', 'G'};

String _localizedPosition(String? position) {
  final key = (position != null && _kKnownPositions.contains(position))
      ? position
      : 'unknown';
  return 'league.player.position.$key'.tr();
}

enum _PlayerStatType {
  goals,
  assists,
  shots,
  yellowCards,
  rating,
  keyPasses,
  dribbles,
  tackles,
  saves,
}

extension _PlayerStatTypeX on _PlayerStatType {
  String get labelKey => switch (this) {
    _PlayerStatType.goals => 'league.player_stat_filter.goals',
    _PlayerStatType.assists => 'league.player_stat_filter.assists',
    _PlayerStatType.shots => 'league.player_stat_filter.shots',
    _PlayerStatType.yellowCards => 'league.player_stat_filter.yellow_cards',
    _PlayerStatType.rating => 'league.player_stat_filter.rating',
    _PlayerStatType.keyPasses => 'league.player_stat_filter.key_passes',
    _PlayerStatType.dribbles => 'league.player_stat_filter.dribbles',
    _PlayerStatType.tackles => 'league.player_stat_filter.tackles',
    _PlayerStatType.saves => 'league.player_stat_filter.saves',
  };

  num statValue(FootballPlayerStat p) => switch (this) {
    _PlayerStatType.goals => p.goals ?? 0,
    _PlayerStatType.assists => p.assists ?? 0,
    _PlayerStatType.shots => p.shotsOnTarget ?? 0,
    _PlayerStatType.yellowCards => p.yellowCards ?? 0,
    _PlayerStatType.rating => p.rating ?? 0,
    _PlayerStatType.keyPasses => p.keyPasses ?? 0,
    _PlayerStatType.dribbles => p.dribbleSucc ?? 0,
    _PlayerStatType.tackles => p.tackles ?? 0,
    _PlayerStatType.saves => p.saves ?? 0,
  };

  String displayValue(FootballPlayerStat p) => switch (this) {
    _PlayerStatType.rating => ((p.rating ?? 0) / 1000).toStringAsFixed(2),
    _ => '${statValue(p).toInt()}',
  };
}

class FootballTopPlayersTab extends ConsumerStatefulWidget {
  const FootballTopPlayersTab({
    super.key,
    required this.leagueId,
    required this.onPlayerTap,
  });

  final String leagueId;
  final ValueChanged<String> onPlayerTap;

  @override
  ConsumerState<FootballTopPlayersTab> createState() =>
      _FootballTopPlayersTabState();
}

class _FootballTopPlayersTabState extends ConsumerState<FootballTopPlayersTab> {
  _PlayerStatType _statType = _PlayerStatType.goals;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(
      footballPlayerStatsProvider(leagueId: widget.leagueId),
    );

    return LeagueTabContent(
      async: async,
      builder: (players) {
        final sorted = [...players]
          ..sort(
            (a, b) => _statType.statValue(b).compareTo(_statType.statValue(a)),
          );

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
                itemBuilder: (context, i) {
                  final p = sorted[i];
                  return _FootballPlayerRow(
                    rank: i + 1,
                    player: p,
                    statType: _statType,
                    onTap: () => widget.onPlayerTap(p.player.id),
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

class _StatFilterBar extends StatelessWidget {
  const _StatFilterBar({required this.selected, required this.onChanged});

  final _PlayerStatType selected;
  final ValueChanged<_PlayerStatType> onChanged;

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
            for (int i = 0; i < _PlayerStatType.values.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _StatChip(
                label: _PlayerStatType.values[i].labelKey.tr(),
                selected: selected == _PlayerStatType.values[i],
                onTap: () => onChanged(_PlayerStatType.values[i]),
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

class _FootballPlayerRow extends StatelessWidget {
  const _FootballPlayerRow({
    required this.rank,
    required this.player,
    required this.statType,
    required this.onTap,
  });

  final int rank;
  final FootballPlayerStat player;
  final _PlayerStatType statType;
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
            LeaguePlayerAvatar(logoUrl: player.player.logo, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context
                        .localizedName(
                          en: player.player.name,
                          cn: player.player.cnName,
                        )
                        .toUpperCase(),
                    style: AppTextStyles.display(
                      15,
                      context,
                    ).copyWith(color: context.appColors.text, height: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${player.team.name} · ${_localizedPosition(player.player.position)}',
                    style: AppTextStyles.mono(
                      9,
                    ).copyWith(color: context.appColors.text3),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      statType.displayValue(player),
                      style: AppTextStyles.display(
                        22,
                        context,
                      ).copyWith(color: context.appColors.text),
                    ),
                  ],
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
