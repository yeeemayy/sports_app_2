import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/baseball_status.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

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
    final isEnded = effective.statusId == 100;
    final label = baseballStatusLabel(effective.statusId);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.baseballMatchDetailPath(match.id)),
      child: Container(
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
                        color: AppTheme.of(context).greyText,
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
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SportLogo(url: match.homeLogo, size: 48, circular: true),
                        const SizedBox(height: 4),
                        Text(
                          match.homeName,
                          style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BaseballScoreDisplay(
                          homeScore: effective.homeScore,
                          awayScore: effective.awayScore,
                          isNotStarted: isNotStarted,
                          isLive: isLive,
                          isEnded: isEnded,
                        ),
                        const SizedBox(height: 6),
                        SportStatusBadge(
                          label: label,
                          isLive: isLive,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SportLogo(url: match.awayLogo, size: 48, circular: true),
                        const SizedBox(height: 4),
                        Text(
                          match.awayName,
                          style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

    final scoreColor = isLive ? AppColors.primary : AppTheme.of(context).baseText;
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
