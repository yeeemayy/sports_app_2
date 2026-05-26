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

class FootballTopPlayersTab extends ConsumerWidget {
  const FootballTopPlayersTab({
    super.key,
    required this.leagueId,
    required this.onPlayerTap,
  });

  final String leagueId;
  final ValueChanged<String> onPlayerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(footballPlayerStatsProvider(leagueId: leagueId));

    return LeagueTabContent(
      async: async,
      builder: (players) => ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: players.length,
        itemBuilder: (context, i) {
          final p = players[i];
          return _FootballPlayerRow(
            rank: i + 1,
            player: p,
            onTap: () => onPlayerTap(p.player.id),
          );
        },
      ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _FootballPlayerRow extends StatelessWidget {
  const _FootballPlayerRow({
    required this.rank,
    required this.player,
    required this.onTap,
  });

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
                      style: AppTextStyles.mono(
                        10,
                      ).copyWith(color: context.appColors.text3),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Assists
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${player.assists ?? 0}',
                  style: AppTextStyles.mono(
                    12,
                  ).copyWith(color: context.appColors.text2),
                ),
                Text(
                  'league.player.assists'.tr(),
                  style: AppTextStyles.mono(8).copyWith(
                    color: context.appColors.text3,
                    letterSpacing: 8 * 0.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
