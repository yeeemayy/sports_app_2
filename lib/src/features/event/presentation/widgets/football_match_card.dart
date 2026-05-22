import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/event/domain/models/football_match.dart';
import 'package:sports_app/src/features/event/domain/models/match_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_card_header.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_card_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

// Design: "SCORELINE" — face-off layout matching basketball/baseball structure.
// [logo · name · cards] [score 30] [center: minute / status] [score 30] [cards · name · logo]
// HT score footer when available.

class FootballMatchCard extends ConsumerWidget {
  const FootballMatchCard({super.key, required this.match});

  final FootballMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.football,
      ).select((map) => map[match.id] as MatchRealtimeData?),
    );

    final effective = rt == null
        ? match
        : match.copyWith(
            statusId: rt.statusId,
            homeScore: rt.homeScore.toString(),
            awayScore: rt.awayScore.toString(),
            htHomeScore: rt.homeHtScore.toString(),
            htAwayScore: rt.awayHtScore.toString(),
            counterTiming: rt.kickoffTimestamp != 0 ? rt.kickoffTimestamp : match.counterTiming,
          );

    final isNotStarted = const {0, 1, 13}.contains(effective.statusId);
    final isLive = const {2, 3, 4, 5, 6, 7}.contains(effective.statusId);
    final hasHtScore = effective.htHomeScore != null && effective.htAwayScore != null;
    final scoreColor = isLive ? context.appColors.accent : context.appColors.text;

    return MatchCardShell(
      onTap: () => context.push(AppRoutes.footballMatchDetailPath(match.id), extra: match),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MatchCardHeader(
            leagueLogo: effective.leagueLogo,
            leagueName: effective.leagueName,
            matchTime: effective.matchTimeSim,
            statusWidget: (isLive || (!isNotStarted)) && effective.statusLabel.isNotEmpty
                ? SportStatusBadge(label: effective.statusLabel, isLive: isLive)
                : null,
          ),
          const SizedBox(height: 12),
          // Face-off row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Home team
              Expanded(
                child: _TeamColumn(
                  logo: effective.homeLogo,
                  name: effective.homeName,
                  redCards: effective.homeRedCards,
                  yellowCards: effective.homeYellowCards,
                  context: context,
                ),
              ),
              // Home score
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  isNotStarted ? '-' : effective.homeScore,
                  style: AppTextStyles.display(30, context).copyWith(color: scoreColor),
                ),
              ),
              // Center separator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '–',
                  style: AppTextStyles.display(
                    22,
                    context,
                  ).copyWith(color: context.appColors.text3),
                ),
              ),
              // Away score
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  isNotStarted ? '-' : effective.awayScore,
                  style: AppTextStyles.display(30, context).copyWith(color: scoreColor),
                ),
              ),
              // Away team
              Expanded(
                child: _TeamColumn(
                  logo: effective.awayLogo,
                  name: effective.awayName,
                  redCards: effective.awayRedCards,
                  yellowCards: effective.awayYellowCards,
                  context: context,
                  rightAlign: true,
                ),
              ),
            ],
          ),
          // HT footer
          if (!isNotStarted && hasHtScore) ...[
            const SizedBox(height: 8),
            Divider(height: 1, thickness: 0.5, color: context.appColors.line),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '${effective.htHomeScore}-${effective.htAwayScore}  ${'event.football.ht'.tr()}',
                style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({
    required this.logo,
    required this.name,
    required this.redCards,
    required this.yellowCards,
    required this.context,
    this.rightAlign = false,
  });

  final String logo;
  final String name;
  final int redCards;
  final int yellowCards;
  final BuildContext context;
  final bool rightAlign;

  @override
  Widget build(BuildContext ctx) {
    return Column(
      children: [
        SportLogo(url: logo, size: 32, circular: true),
        const SizedBox(height: 5),
        Text(
          name,
          style: AppTextStyles.mono(11).copyWith(color: context.appColors.text2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        if (redCards > 0 || yellowCards > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (yellowCards > 0) _CardDot(count: yellowCards, color: context.appColors.live),
              if (redCards > 0) _CardDot(count: redCards, color: context.appColors.danger),
            ],
          ),
        ],
      ],
    );
  }
}

class _CardDot extends StatelessWidget {
  const _CardDot({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 3),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      child: Text(
        '$count',
        style: TextStyle(fontSize: 10, color: context.appColors.ink, height: 1.2),
      ),
    );
  }
}
