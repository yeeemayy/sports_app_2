import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/event/domain/models/football_match.dart';
import 'package:sports_app/src/features/event/domain/models/match_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

// Design: "SCORELINE" — two stacked team rows with score pushed to right.
// Each row: logo · name · card dots  →  score (Anton)
// Live amber minute pill on bottom-right. HT score footer.

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Ink(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          border: Border.all(color: context.appColors.line, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          onTap: () => context.push(AppRoutes.footballMatchDetailPath(match.id), extra: match),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // League header
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          LeagueLogo(url: effective.leagueLogo),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              effective.leagueName,
                              style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLive && effective.statusLabel.isNotEmpty)
                      _LiveMinuteBadge(label: effective.statusLabel)
                    else if (!isLive && !isNotStarted)
                      _FinishedBadge(label: effective.statusLabel),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          effective.matchTimeSim,
                          style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                // Home row
                _TeamRow(
                  logo: effective.homeLogo,
                  name: effective.homeName,
                  score: effective.homeScore,
                  redCards: effective.homeRedCards,
                  yellowCards: effective.homeYellowCards,
                  isNotStarted: isNotStarted,
                  isLive: isLive,
                  context: context,
                ),
                const SizedBox(height: 7),
                // Away row
                _TeamRow(
                  logo: effective.awayLogo,
                  name: effective.awayName,
                  score: effective.awayScore,
                  redCards: effective.awayRedCards,
                  yellowCards: effective.awayYellowCards,
                  isNotStarted: isNotStarted,
                  isLive: isLive,
                  context: context,
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
          ),
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.logo,
    required this.name,
    required this.score,
    required this.redCards,
    required this.yellowCards,
    required this.isNotStarted,
    required this.isLive,
    required this.context,
  });

  final String logo;
  final String name;
  final String score;
  final int redCards;
  final int yellowCards;
  final bool isNotStarted;
  final bool isLive;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: [
        SportLogo(url: logo, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.mono(12).copyWith(color: context.appColors.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (redCards > 0) _CardDot(count: redCards, color: context.appColors.danger),
        if (yellowCards > 0) _CardDot(count: yellowCards, color: context.appColors.live),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            isNotStarted ? '-' : score,
            textAlign: TextAlign.center,
            style: AppTextStyles.display(
              22,
              context,
            ).copyWith(color: isLive ? context.appColors.accent : context.appColors.text),
          ),
        ),
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
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      child: Text(
        '$count',
        style: TextStyle(fontSize: 10, color: context.appColors.ink, height: 1.2),
      ),
    );
  }
}

class _LiveMinuteBadge extends StatelessWidget {
  const _LiveMinuteBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.appColors.live,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTextStyles.mono(9).copyWith(color: context.appColors.ink)),
    );
  }
}

class _FinishedBadge extends StatelessWidget {
  const _FinishedBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.appColors.surface2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
      ),
    );
  }
}
