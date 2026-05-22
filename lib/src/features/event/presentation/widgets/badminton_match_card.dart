import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/event/domain/badminton_status.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/set_score_utils.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_card_header.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_card_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

// Design: "RALLY" — two player rows with set-win dot indicators and current game score.
// [logo · name] [●●○ dots] ··· [current set score Anton 26]
// Status badge centered below.

class BadmintonMatchCard extends ConsumerWidget {
  const BadmintonMatchCard({super.key, required this.match});

  final BadmintonMatch match;

  static const _liveStatuses = {3, 51, 52, 53, 54, 55};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(SportType.badminton)
          .select((map) => map[match.id] as BadmintonRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeSets = rt?.homeSets ?? extractSetScores(match.scores, 0);
    final effectiveAwaySets = rt?.awaySets ?? extractSetScores(match.scores, 1);
    final effectiveHomeTotal = rt?.homeTotal ?? 0;
    final effectiveAwayTotal = rt?.awayTotal ?? 0;

    final statusLabel = badmintonStatusLabel(effectiveStatusId, match.statusDescription);
    final isLive = _liveStatuses.contains(effectiveStatusId);
    final isNotStarted = effectiveStatusId == 1;

    // Current (last) set scores for live display
    final homeCurrentSet = effectiveHomeSets.isNotEmpty ? effectiveHomeSets.last : 0;
    final awayCurrentSet = effectiveAwaySets.isNotEmpty ? effectiveAwaySets.last : 0;

    return MatchCardShell(
      onTap: () => context.push(AppRoutes.badmintonMatchDetailPath(match.id)),
      child: Column(
        children: [
          MatchCardHeader(
            leagueLogo: match.leagueLogo,
            leagueName: match.leagueName,
            matchTime: match.matchTimeSim,
          ),
          const SizedBox(height: 12),
          // Home player row
          _RallyRow(
            logo: match.homeLogo,
            name: match.homeName,
            setsWon: effectiveHomeTotal,
            opponentSetsWon: effectiveAwayTotal,
            currentSetScore: isLive ? homeCurrentSet : null,
            isNotStarted: isNotStarted,
            isLive: isLive,
            context: context,
          ),
          const SizedBox(height: 7),
          // Away player row
          _RallyRow(
            logo: match.awayLogo,
            name: match.awayName,
            setsWon: effectiveAwayTotal,
            opponentSetsWon: effectiveHomeTotal,
            currentSetScore: isLive ? awayCurrentSet : null,
            isNotStarted: isNotStarted,
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

class _RallyRow extends StatelessWidget {
  const _RallyRow({
    required this.logo,
    required this.name,
    required this.setsWon,
    required this.opponentSetsWon,
    required this.currentSetScore,
    required this.isNotStarted,
    required this.isLive,
    required this.context,
  });

  final String logo;
  final String name;
  final int setsWon;
  final int opponentSetsWon;
  final int? currentSetScore;
  final bool isNotStarted;
  final bool isLive;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final totalSets = setsWon + opponentSetsWon;

    return Row(
      children: [
        SportLogo(url: logo, size: 24, circular: true),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.mono(11).copyWith(color: context.appColors.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Set win dots
        if (!isNotStarted && totalSets > 0) ...[
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalSets, (i) {
              final won = i < setsWon;
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: won
                      ? (isLive ? context.appColors.accent : context.appColors.text)
                      : context.appColors.surface2,
                  border: won ? null : Border.all(color: context.appColors.lineStrong, width: 0.5),
                ),
              );
            }),
          ),
        ],
        const SizedBox(width: 12),
        // Game score or total sets
        SizedBox(
          width: 50,
          child: Text(
            isNotStarted
                ? '-'
                : (currentSetScore != null ? '$currentSetScore' : '$setsWon'),
            textAlign: TextAlign.center,
            style: AppTextStyles.display(26, context).copyWith(
              color: isLive ? context.appColors.accent : context.appColors.text,
            ),
          ),
        ),
      ],
    );
  }
}
