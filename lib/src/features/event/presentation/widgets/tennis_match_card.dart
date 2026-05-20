import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/set_score_utils.dart';
import 'package:sports_app/src/features/event/domain/tennis_status.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

// Design: "SETS GRID" — two player rows with per-set score boxes and sets-won total.
// [logo · name] | [S1][S2][S3] | [total Anton]
// Active/current set gets an accent border. Status badge below.

class TennisMatchCard extends ConsumerWidget {
  const TennisMatchCard({super.key, required this.match});

  final TennisMatch match;

  static const _liveStatuses = {3, 51, 52, 53, 54, 55};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(SportType.tennis)
          .select((map) => map[match.id] as TennisRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeSets = rt?.homeSets ?? extractSetScores(match.scores, 0);
    final effectiveAwaySets = rt?.awaySets ?? extractSetScores(match.scores, 1);
    final effectiveHomeTotal = rt?.homeTotal ?? 0;
    final effectiveAwayTotal = rt?.awayTotal ?? 0;

    final statusLabel = tennisStatusLabel(effectiveStatusId, match.statusDescription);
    final isLive = _liveStatuses.contains(effectiveStatusId);
    final isNotStarted = effectiveStatusId == 1;
    final setCount = effectiveHomeSets.length;
    final activeSetIndex = isLive && setCount > 0 ? setCount - 1 : -1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Ink(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          border: Border.all(color: context.appColors.line, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          onTap: () => context.push(AppRoutes.tennisMatchDetailPath(match.id)),
          borderRadius: BorderRadius.circular(14),
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
                // Home player row
                _PlayerSetRow(
                  logo: match.homeLogo,
                  name: match.homeName,
                  sets: effectiveHomeSets,
                  opponentSets: effectiveAwaySets,
                  totalWon: isNotStarted ? null : effectiveHomeTotal,
                  activeSetIndex: activeSetIndex,
                  isLive: isLive,
                  context: context,
                ),
                const SizedBox(height: 6),
                // Away player row
                _PlayerSetRow(
                  logo: match.awayLogo,
                  name: match.awayName,
                  sets: effectiveAwaySets,
                  opponentSets: effectiveHomeSets,
                  totalWon: isNotStarted ? null : effectiveAwayTotal,
                  activeSetIndex: activeSetIndex,
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

class _PlayerSetRow extends StatelessWidget {
  const _PlayerSetRow({
    required this.logo,
    required this.name,
    required this.sets,
    required this.opponentSets,
    required this.totalWon,
    required this.activeSetIndex,
    required this.isLive,
    required this.context,
  });

  final String logo;
  final String name;
  final List<int> sets;
  final List<int> opponentSets;
  final int? totalWon;
  final int activeSetIndex;
  final bool isLive;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: [
        SportLogo(url: logo, size: 26, circular: true),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.body(12).copyWith(color: context.appColors.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        // Set boxes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(sets.length, (i) {
            final isActive = i == activeSetIndex;
            final won = sets[i] > (i < opponentSets.length ? opponentSets[i] : 0);
            return _SetBox(
              score: sets[i],
              isActive: isActive,
              isWon: won,
              isLive: isLive,
            );
          }),
        ),
        if (totalWon != null) ...[
          const SizedBox(width: 10),
          SizedBox(
            width: 22,
            child: Text(
              '$totalWon',
              textAlign: TextAlign.center,
              style: AppTextStyles.display(20, context).copyWith(
                color: isLive ? context.appColors.accent : context.appColors.text,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(width: 10),
          SizedBox(
            width: 22,
            child: Text(
              '-',
              textAlign: TextAlign.center,
              style: AppTextStyles.display(20, context).copyWith(color: context.appColors.text3),
            ),
          ),
        ],
      ],
    );
  }
}

class _SetBox extends StatelessWidget {
  const _SetBox({
    required this.score,
    required this.isActive,
    required this.isWon,
    required this.isLive,
  });

  final int score;
  final bool isActive;
  final bool isWon;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(left: 3),
      decoration: BoxDecoration(
        color: isActive ? context.appColors.accent.withValues(alpha: 0.12) : context.appColors.surface2,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isActive ? context.appColors.accent : context.appColors.line,
          width: isActive ? 1 : 0.5,
        ),
      ),
      child: Center(
        child: Text(
          '$score',
          style: AppTextStyles.mono(10).copyWith(
            color: isActive ? context.appColors.accent : (isWon ? context.appColors.text : context.appColors.text3),
          ),
        ),
      ),
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
