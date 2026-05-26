import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/squad_player.dart';
import 'package:sports_app/src/features/league/domain/squad_grouping.dart';
import 'package:sports_app/src/features/league/presentation/league_detail/league_tab_content.dart';
import 'package:sports_app/src/features/league/presentation/providers/league_providers.dart';

const _kPad = 16.0;

class SquadList extends ConsumerWidget {
  const SquadList({
    super.key,
    required this.sport,
    required this.teamId,
    required this.onPlayerTap,
  });

  final LeagueSport sport;
  final String teamId;
  final ValueChanged<String> onPlayerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = sport == LeagueSport.football
        ? ref.watch(footballSquadProvider(teamId: teamId))
        : ref.watch(basketballSquadProvider(teamId: teamId));

    return LeagueTabContent(
      async: async,
      builder: (players) {
        final groups = groupSquadByPosition(players, sport);

        return Column(
          children: [
            // Col headers
            Container(
              padding: const EdgeInsets.fromLTRB(_kPad, 6, _kPad, 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.appColors.line, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'league.squad.player'.tr(),
                      style: AppTextStyles.mono(8).copyWith(
                        color: context.appColors.text3,
                        letterSpacing: 8 * 0.1,
                      ),
                    ),
                  ),
                  if (sport == LeagueSport.basketball)
                    SizedBox(
                      width: 32,
                      child: Text(
                        '#',
                        style: AppTextStyles.mono(
                          8,
                        ).copyWith(color: context.appColors.text3),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      'league.squad.age'.tr(),
                      style: AppTextStyles.mono(8).copyWith(
                        color: context.appColors.text3,
                        letterSpacing: 8 * 0.1,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      'league.squad.height'.tr(),
                      style: AppTextStyles.mono(8).copyWith(
                        color: context.appColors.text3,
                        letterSpacing: 8 * 0.1,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: groups.fold<int>(
                  0,
                  (sum, g) => sum + 1 + g.players.length,
                ),
                itemBuilder: (context, index) {
                  int count = 0;
                  for (final group in groups) {
                    if (index == count) {
                      return _SquadPositionHeader(pos: group.position);
                    }
                    count++;
                    if (index < count + group.players.length) {
                      final player = group.players[index - count];
                      return _SquadPlayerRow(
                        player: player,
                        sport: sport,
                        showNum: sport == LeagueSport.basketball,
                        onTap: () => onPlayerTap(player.id),
                      );
                    }
                    count += group.players.length;
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
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _SquadPositionHeader extends StatelessWidget {
  const _SquadPositionHeader({required this.pos});

  final String pos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _kPad, vertical: 7),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(
          bottom: BorderSide(color: context.appColors.line, width: 0.5),
        ),
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
          border: Border(
            bottom: BorderSide(color: context.appColors.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Avatar — always 32×32 with initial-letter fallback
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.appColors.surface2,
              ),
              child: player.logo != null && player.logo!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: player.logo!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _initial(context),
                      ),
                    )
                  : _initial(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.localizedName(en: player.name, cn: player.cnName),
                style: AppTextStyles.mono(
                  11,
                ).copyWith(color: context.appColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showNum)
              SizedBox(
                width: 32,
                child: Text(
                  '${player.shirtNumber ?? '-'}',
                  style: AppTextStyles.mono(
                    11,
                  ).copyWith(color: context.appColors.text3),
                  textAlign: TextAlign.right,
                ),
              ),
            SizedBox(
              width: 36,
              child: Text(
                '${player.age ?? '-'}',
                style: AppTextStyles.mono(
                  11,
                ).copyWith(color: context.appColors.text2),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                player.height != null ? '${player.height}cm' : '-',
                style: AppTextStyles.mono(
                  10,
                ).copyWith(color: context.appColors.text3),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initial(BuildContext context) => Center(
    child: Text(
      player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
      style: AppTextStyles.display(
        12,
        context,
      ).copyWith(color: context.appColors.text2),
    ),
  );
}
