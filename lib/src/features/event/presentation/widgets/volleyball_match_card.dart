import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/volleyball_match.dart';
import 'package:sports_app/src/features/event/domain/models/volleyball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/set_score_utils.dart';
import 'package:sports_app/src/features/event/domain/volleyball_status.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

// Design: "SET COUNT" — two team rows. Sets won is the hero number (Anton 28).
// Current set point score shown small below each row. Status badge below.

class VolleyballMatchCard extends ConsumerWidget {
  const VolleyballMatchCard({super.key, required this.match});

  final VolleyballMatch match;

  static const _liveStatuses = {432, 434, 436, 438, 440};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(SportType.volleyball)
          .select((map) => map[match.id] as VolleyballRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeSets = rt?.homeSets ?? extractSetScores(match.scores, 0);
    final effectiveAwaySets = rt?.awaySets ?? extractSetScores(match.scores, 1);
    final effectiveHomeScore = rt?.homeTotal.toString() ?? match.homeScore;
    final effectiveAwayScore = rt?.awayTotal.toString() ?? match.awayScore;
    final statusLabel = volleyballStatusLabel(effectiveStatusId, match.statusDescription);
    final isLive = _liveStatuses.contains(effectiveStatusId);
    final isNotStarted = effectiveStatusId == 1;

    // Current set point scores
    final homeCurrentSet = effectiveHomeSets.isNotEmpty ? effectiveHomeSets.last : null;
    final awayCurrentSet = effectiveAwaySets.isNotEmpty ? effectiveAwaySets.last : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Ink(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          border: Border.all(color: context.appColors.line, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: GestureDetector(
          onTap: () => context.push(AppRoutes.volleyballMatchDetailPath(match.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
            child: Column(
              children: [
                // League header
                Row(
                  children: [
                    LeagueLogo(url: match.leagueLogo),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        match.leagueName,
                        style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      match.matchTimeSim,
                      style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Home team row
                _SetCountRow(
                  logo: match.homeLogo,
                  name: match.homeName,
                  setsWon: effectiveHomeScore,
                  currentSetScore: isLive ? homeCurrentSet : null,
                  isNotStarted: isNotStarted,
                  isLive: isLive,
                  context: context,
                ),
                // Set divider
                if (!isNotStarted && homeCurrentSet != null && awayCurrentSet != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$homeCurrentSet - $awayCurrentSet',
                          style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                // Away team row
                _SetCountRow(
                  logo: match.awayLogo,
                  name: match.awayName,
                  setsWon: effectiveAwayScore,
                  currentSetScore: isLive ? awayCurrentSet : null,
                  isNotStarted: isNotStarted,
                  isLive: isLive,
                  context: context,
                ),
                // Status badge
                if (statusLabel.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _StatusBadge(label: statusLabel, isLive: isLive),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetCountRow extends StatelessWidget {
  const _SetCountRow({
    required this.logo,
    required this.name,
    required this.setsWon,
    required this.currentSetScore,
    required this.isNotStarted,
    required this.isLive,
    required this.context,
  });

  final String logo;
  final String name;
  final String setsWon;
  final int? currentSetScore;
  final bool isNotStarted;
  final bool isLive;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: [
        SportLogo(url: logo, size: 28, circular: true),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.body(13).copyWith(color: context.appColors.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isNotStarted ? '-' : setsWon,
          style: AppTextStyles.display(28, context).copyWith(
            color: isLive ? context.appColors.accent : context.appColors.text,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.isLive});
  final String label;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isLive ? context.appColors.live : context.appColors.surface2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.mono(9).copyWith(
          color: isLive ? context.appColors.ink : context.appColors.text3,
        ),
      ),
    );
  }
}
