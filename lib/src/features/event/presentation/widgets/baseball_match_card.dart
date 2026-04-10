import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/baseball_status.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class BaseballMatchCard extends ConsumerWidget {
  const BaseballMatchCard({super.key, required this.match});

  final BaseballMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(baseballRealtimeProvider.select((map) => map[match.id]));

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
    final isEnded = effective.statusId == 100;
    final label = baseballStatusLabel(effective.statusId);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.baseballMatchDetailPath(match.id)),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League header row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  LeagueLogo(url: effective.leagueLogo),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      effective.leagueName,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 50,
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
            // Match body
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
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
                          child: Text(
                            effective.homeName,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Score
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _BaseballScoreDisplay(
                      homeScore: effective.homeScore,
                      awayScore: effective.awayScore,
                      isNotStarted: isNotStarted,
                      isLive: isLive,
                      isEnded: isEnded,
                    ),
                  ),
                  // Away team
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            effective.awayName,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
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
            const SizedBox(height: 3),
            Center(
              child: Container(
                constraints: const BoxConstraints(minWidth: 50),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: label.isNotEmpty ? Colors.orange : Colors.white,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label.isNotEmpty ? label : 'event.baseball.status.tbd'.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: label.isNotEmpty ? Colors.white : Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
          ],
        ),
      ),
    );
  }
}

class _BaseballScoreDisplay extends StatelessWidget {
  const _BaseballScoreDisplay({
    required this.homeScore,
    required this.awayScore,
    required this.isNotStarted,
    required this.isLive,
    required this.isEnded,
  });

  final String homeScore;
  final String awayScore;
  final bool isNotStarted;
  final bool isLive;
  final bool isEnded;

  @override
  Widget build(BuildContext context) {
    if (isNotStarted) {
      return Text(
        '-',
        style: context.textTheme.titleSmall?.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final scoreColor = isLive ? Colors.pink : Colors.black87;
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
