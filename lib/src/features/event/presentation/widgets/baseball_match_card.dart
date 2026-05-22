import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/event/domain/baseball_status.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_card_header.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_card_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

// Design: "DIAMOND" — horizontal face-off. Teams left and right, big run scores
// flanking a central status column. Looks like an outfield scoreboard.

class BaseballMatchCard extends ConsumerWidget {
  const BaseballMatchCard({super.key, required this.match});

  final BaseballMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.baseball,
      ).select((map) => map[match.id] as BaseballRealtimeData?),
    );

    final effective = rt == null
        ? match
        : match.copyWith(
            statusId: rt.statusId,
            homeScore: rt.homeScore,
            awayScore: rt.awayScore,
            scores: rt.scores,
          );

    final isLive = baseballLiveStatuses.contains(effective.statusId);
    final isNotStarted = effective.statusId == 1;
    final label = baseballStatusLabel(effective.statusId);
    final scoreColor = isLive ? context.appColors.accent : context.appColors.text;

    return MatchCardShell(
      onTap: () => context.push(AppRoutes.baseballMatchDetailPath(match.id)),
      child: Column(
        children: [
          MatchCardHeader(
            leagueLogo: effective.leagueLogo,
            leagueName: effective.leagueName,
            matchTime: effective.matchTimeSim,
          ),
          const SizedBox(height: 12),
          SportStatusBadge(label: label, isLive: isLive),
          // Scoreboard row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Home team
              Expanded(
                child: Column(
                  children: [
                    SportLogo(url: match.homeLogo, size: 32, circular: true),
                    const SizedBox(height: 5),
                    Text(
                      match.homeName,
                      style: AppTextStyles.mono(11).copyWith(color: context.appColors.text2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Home score
              SizedBox(
                width: 44,
                child: Text(
                  isNotStarted ? '-' : effective.homeScore,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display(34, context).copyWith(color: scoreColor),
                ),
              ),
              // Center status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('–', style: AppTextStyles.display(22, context).copyWith(color: context.appColors.text3)),
              ),
              // Away score
              SizedBox(
                width: 44,
                child: Text(
                  isNotStarted ? '-' : effective.awayScore,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display(34, context).copyWith(color: scoreColor),
                ),
              ),
              // Away team
              Expanded(
                child: Column(
                  children: [
                    SportLogo(url: match.awayLogo, size: 32, circular: true),
                    const SizedBox(height: 5),
                    Text(
                      match.awayName,
                      style: AppTextStyles.mono(11).copyWith(color: context.appColors.text2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
