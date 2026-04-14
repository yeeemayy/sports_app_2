import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/am_football_status.dart';
import 'package:sports_app/src/features/event/domain/models/am_football_match.dart';
import 'package:sports_app/src/features/event/domain/models/am_football_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class AmFootballMatchCard extends ConsumerWidget {
  const AmFootballMatchCard({super.key, required this.match});

  final AmFootballMatch match;

  static const _liveStatuses = {44, 45, 46, 47, 10};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(SportType.amFootball)
          .select((map) => map[match.id] as AmFootballRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeScore = rt?.homeScore.toString() ?? match.homeScore;
    final effectiveAwayScore = rt?.awayScore.toString() ?? match.awayScore;
    final statusLabel = amFootballStatusLabel(effectiveStatusId, match.statusDescription);
    final isLive = _liveStatuses.contains(effectiveStatusId);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.amFootballMatchDetailPath(match.id)),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Row(
                children: [
                  LeagueLogo(url: match.leagueLogo),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      match.leagueName,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    match.matchTimeSim,
                    style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
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
                        _AmFootballScore(
                          homeScore: effectiveHomeScore,
                          awayScore: effectiveAwayScore,
                          statusId: effectiveStatusId,
                        ),
                        const SizedBox(height: 6),
                        SportStatusBadge(
                          label: statusLabel,
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

class _AmFootballScore extends StatelessWidget {
  const _AmFootballScore({
    required this.homeScore,
    required this.awayScore,
    required this.statusId,
  });

  final String homeScore;
  final String awayScore;
  final int statusId;

  static const _liveStatuses = {44, 45, 46, 47, 10};
  bool get _isNotStarted => statusId == 1;

  @override
  Widget build(BuildContext context) {
    if (_isNotStarted) {
      return Text(
        '-',
        style: context.textTheme.titleMedium?.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final scoreColor = _liveStatuses.contains(statusId) ? Colors.pink : Colors.black87;
    return RichText(
      text: TextSpan(
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: scoreColor,
        ),
        children: [
          TextSpan(text: homeScore),
          TextSpan(text: ' - ', style: TextStyle(color: Colors.grey.shade400)),
          TextSpan(text: awayScore),
        ],
      ),
    );
  }
}

