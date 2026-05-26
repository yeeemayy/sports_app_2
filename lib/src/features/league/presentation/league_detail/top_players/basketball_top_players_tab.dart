import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_player_stat.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_entity_avatar.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';

const _kPad = 16.0;

class BasketballTopPlayersTab extends ConsumerWidget {
  const BasketballTopPlayersTab({
    super.key,
    required this.leagueId,
    required this.onPlayerTap,
  });

  final String leagueId;
  final ValueChanged<String> onPlayerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(basketballPlayerStatsProvider(leagueId: leagueId));

    return LeagueTabContent(
      async: async,
      builder: (players) => ListView.builder(
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

// ─── Private widgets ──────────────────────────────────────────────────────────

class _BasketballPlayerRow extends StatelessWidget {
  const _BasketballPlayerRow({
    required this.rank,
    required this.player,
    required this.onTap,
  });

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
                      14,
                      context,
                    ).copyWith(color: context.appColors.text, height: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${context.localizedName(en: player.team?.name ?? '-', cn: player.team?.cnName)} · ${p?.position ?? '-'}',
                    style: AppTextStyles.mono(
                      9,
                    ).copyWith(color: context.appColors.text3),
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
                  style: AppTextStyles.display(
                    20,
                    context,
                  ).copyWith(color: context.appColors.text),
                ),
                Text(
                  'league.player.ppg'.tr(),
                  style: AppTextStyles.mono(8).copyWith(
                    color: context.appColors.text3,
                    letterSpacing: 8 * 0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.rebounds ?? 0}',
                  style: AppTextStyles.mono(
                    12,
                  ).copyWith(color: context.appColors.text2),
                ),
                Text(
                  'league.player.rpg'.tr(),
                  style: AppTextStyles.mono(
                    8,
                  ).copyWith(color: context.appColors.text3),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.assists ?? 0}',
                  style: AppTextStyles.mono(
                    12,
                  ).copyWith(color: context.appColors.text2),
                ),
                Text(
                  'league.player.apg'.tr(),
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
