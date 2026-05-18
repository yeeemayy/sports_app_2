import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/ice_hockey_status.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_match.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/set_score_utils.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class IceHockeyMatchCard extends ConsumerWidget {
  const IceHockeyMatchCard({super.key, required this.match});

  final IceHockeyMatch match;

  static const _liveStatuses = {30, 331, 31, 332, 32, 6, 10, 8, 13};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.iceHockey,
      ).select((map) => map[match.id] as IceHockeyRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeSets = rt?.homeSets ?? extractSetScores(match.scores, 0);
    final effectiveAwaySets = rt?.awaySets ?? extractSetScores(match.scores, 1);
    final effectiveHomeScore = rt?.homeScore.toString() ?? match.homeScore;
    final effectiveAwayScore = rt?.awayScore.toString() ?? match.awayScore;
    final statusLabel = iceHockeyStatusLabel(effectiveStatusId, match.statusDescription);
    final isLive = _liveStatuses.contains(effectiveStatusId);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.iceHockeyMatchDetailPath(match.id)),
      child: Container(
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
                        color: context.appTheme.greyText,
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
                        _IceHockeyScore(
                          homeScore: effectiveHomeScore,
                          awayScore: effectiveAwayScore,
                          statusId: effectiveStatusId,
                          homeSets: effectiveHomeSets,
                          awaySets: effectiveAwaySets,
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

class _IceHockeyScore extends StatelessWidget {
  const _IceHockeyScore({
    required this.homeScore,
    required this.awayScore,
    required this.homeSets,
    required this.awaySets,
    required this.statusId,
  });

  final String homeScore;
  final String awayScore;
  final List<int> homeSets;
  final List<int> awaySets;
  final int statusId;

  static const _liveStatuses = {30, 331, 31, 332, 32, 6, 10, 8, 13};
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

    final scoreColor = _liveStatuses.contains(statusId) ? AppColors.accent : context.appTheme.baseText;
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: scoreColor,
            ),
            children: [
              TextSpan(text: homeScore),
              TextSpan(
                text: ' - ',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              TextSpan(text: awayScore),
            ],
          ),
        ),
        if (_liveStatuses.contains(statusId) && homeSets.isNotEmpty)
          Text(
            '${homeSets.last}:${awaySets.last}',
            style: context.textTheme.labelMedium?.copyWith(color: Colors.grey.shade500),
          ),
      ],
    );
  }
}

