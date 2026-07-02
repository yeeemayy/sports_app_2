import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/table_tennis_realtime_data.dart';
import 'package:shenghaotiyu/src/features/event/domain/table_tennis_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/table_tennis_match.dart';
import 'package:shenghaotiyu/src/features/event/domain/set_score_utils.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/match_card_header.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/match_card_shell.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';
import 'package:shenghaotiyu/src/shared_widgets/sport_logo.dart';

// Design: "SETS INLINE" — two dense player rows with all set scores shown as small
// inline boxes. Current/live set box is accent-highlighted. Sets won total on right.

class TableTennisMatchCard extends ConsumerWidget {
  const TableTennisMatchCard({super.key, required this.match});

  final TableTennisMatch match;

  static const _liveStatuses = {3, 51, 52, 53, 54, 55, 472, 473};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.tableTennis,
      ).select((map) => map[match.id] as TableTennisRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeSets =
        rt?.homeSets ?? extractSetScores(match.scores, 0, maxSets: 7);
    final effectiveAwaySets =
        rt?.awaySets ?? extractSetScores(match.scores, 1, maxSets: 7);
    final effectiveHomeTotal = rt?.homeTotal ?? int.tryParse(match.homeScore);
    final effectiveAwayTotal = rt?.awayTotal ?? int.tryParse(match.awayScore);

    final statusLabel = tableTennisStatusLabel(
      effectiveStatusId,
      match.statusDescription,
    );
    final isLive = _liveStatuses.contains(effectiveStatusId);
    final isNotStarted = effectiveStatusId == 1;
    final activeSetIndex = isLive && effectiveHomeSets.isNotEmpty
        ? effectiveHomeSets.length - 1
        : -1;

    return MatchCardShell(
      onTap: () => context.push(AppRoutes.tableTennisMatchDetailPath(match.id)),
      child: Column(
        children: [
          MatchCardHeader(
            leagueLogo: match.leagueLogo,
            leagueName: match.leagueName,
            matchTime: match.matchTimeSim,
          ),
          const SizedBox(height: 12),
          // Home player row
          _InlineSetRow(
            logo: match.homeLogo,
            name: match.homeName,
            sets: effectiveHomeSets,
            opponentSets: effectiveAwaySets,
            total: isNotStarted ? null : effectiveHomeTotal,
            activeSetIndex: activeSetIndex,
            isLive: isLive,
            context: context,
          ),
          const SizedBox(height: 5),
          // Away player row
          _InlineSetRow(
            logo: match.awayLogo,
            name: match.awayName,
            sets: effectiveAwaySets,
            opponentSets: effectiveHomeSets,
            total: isNotStarted ? null : effectiveAwayTotal,
            activeSetIndex: activeSetIndex,
            isLive: isLive,
            context: context,
          ),
          // Status badge
          if (statusLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            SportStatusBadge(label: statusLabel, isLive: isLive),
          ],
        ],
      ),
    );
  }
}

class _InlineSetRow extends StatelessWidget {
  const _InlineSetRow({
    required this.logo,
    required this.name,
    required this.sets,
    required this.opponentSets,
    required this.total,
    required this.activeSetIndex,
    required this.isLive,
    required this.context,
  });

  final String logo;
  final String name;
  final List<int> sets;
  final List<int> opponentSets;
  final int? total;
  final int activeSetIndex;
  final bool isLive;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: [
        SportLogo(url: logo, size: 24, circular: true),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.mono(
              11,
            ).copyWith(color: context.appColors.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        // Set score boxes (max 7 sets, use small boxes)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(sets.length, (i) {
              final isActive = i == activeSetIndex;
              final won =
                  sets[i] > (i < opponentSets.length ? opponentSets[i] : 0);
              return _SmallSetBox(
                score: sets[i],
                isActive: isActive,
                isWon: won,
                isLive: isLive,
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        // Sets won total
        SizedBox(
          width: 20,
          child: Text(
            total != null ? '$total' : '-',
            textAlign: TextAlign.center,
            style: AppTextStyles.display(18, context).copyWith(
              color: isLive ? context.appColors.accent : context.appColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallSetBox extends StatelessWidget {
  const _SmallSetBox({
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
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(left: 2),
      decoration: BoxDecoration(
        color: isActive
            ? context.appColors.accent.withValues(alpha: 0.14)
            : context.appColors.surface2,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? context.appColors.accent : context.appColors.line,
          width: isActive ? 1 : 0.5,
        ),
      ),
      child: Center(
        child: Text(
          '$score',
          style: AppTextStyles.mono(9).copyWith(
            color: isActive
                ? context.appColors.accent
                : (isWon ? context.appColors.text : context.appColors.text3),
          ),
        ),
      ),
    );
  }
}
