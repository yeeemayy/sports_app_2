import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/football_match.dart';
import 'package:sports_app/src/features/event/domain/models/match_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/match_status_badge.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

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

    final hasHtScore = effective.htHomeScore != null && effective.htAwayScore != null;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.footballMatchDetailPath(match.id), extra: match),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League header row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                spacing: 6,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        LeagueLogo(url: effective.leagueLogo),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            effective.leagueName,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppTheme.of(context).greyText,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 35,
                    child: Center(
                      child: MatchStatusBadge(
                        statusId: effective.statusId,
                        label: effective.statusLabel,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        effective.matchTimeSim,
                        style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Match body — horizontal layout
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Home team
                  Expanded(
                    child: Row(
                      children: [
                        SportLogo(url: effective.homeLogo, size: 24),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: effective.homeName,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (effective.homeRedCards > 0)
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: _CardBadge(
                                      count: effective.homeRedCards,
                                      color: Colors.red,
                                      isHome: true,
                                    ),
                                  ),
                                if (effective.homeYellowCards > 0)
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: _CardBadge(
                                      count: effective.homeYellowCards,
                                      color: Colors.amber,
                                      isHome: true,
                                    ),
                                  ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Score / status
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _ScoreDisplay(
                      homeScore: effective.homeScore,
                      awayScore: effective.awayScore,
                      statusId: effective.statusId,
                    ),
                  ),
                  // Away team
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                if (effective.awayRedCards > 0)
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: _CardBadge(
                                      count: effective.awayRedCards,
                                      color: Colors.red,
                                      isHome: false,
                                    ),
                                  ),
                                if (effective.awayYellowCards > 0)
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: _CardBadge(
                                      count: effective.awayYellowCards,
                                      color: Colors.amber,
                                      isHome: false,
                                    ),
                                  ),
                                TextSpan(
                                  text: effective.awayName,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 6),
                        SportLogo(url: effective.awayLogo, size: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Footer row — HT score
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 8, 8),
              child: Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: effective.statusId > 3 && effective.statusId != 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasHtScore)
                      Text(
                        '${'event.football.ht'.tr()} ${effective.htHomeScore}-${effective.htAwayScore}',
                        style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
          ],
        ),
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.homeScore, required this.awayScore, required this.statusId});

  final String homeScore;
  final String awayScore;
  final int statusId;

  static const _liveStatuses = {2, 3, 4, 5, 6, 7};
  static const _noScoreStatuses = {0, 1, 13};

  @override
  Widget build(BuildContext context) {
    if (_noScoreStatuses.contains(statusId)) {
      return Text(
        '-',
        style: context.textTheme.titleSmall?.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final scoreColor = _liveStatuses.contains(statusId) ? AppColors.primary : AppTheme.of(context).baseText;
    return RichText(
      text: TextSpan(
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: scoreColor,
        ),
        children: [
          TextSpan(text: homeScore),
          const TextSpan(text: ' - '),
          TextSpan(text: awayScore),
        ],
      ),
    );
  }
}

class _CardBadge extends StatelessWidget {
  const _CardBadge({required this.isHome, required this.count, required this.color});
  final bool isHome;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: isHome ? 4 : 0, right: isHome ? 0 : 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          color: color.computeLuminance() > 0.4 ? Colors.black87 : Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}
