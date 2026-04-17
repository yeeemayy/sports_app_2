import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/cricket_status.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_match.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class CricketMatchCard extends ConsumerWidget {
  const CricketMatchCard({super.key, required this.match});

  final CricketMatch match;

  static const _liveStatuses = {2, 3, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(SportType.cricket)
          .select((map) => map[match.id] as CricketRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeScore = rt?.homeScore.toString() ?? match.homeScore;
    final effectiveAwayScore = rt?.awayScore.toString() ?? match.awayScore;
    final statusLabel = cricketStatusLabel(effectiveStatusId, match.statusDescription);
    final isLive = _liveStatuses.contains(effectiveStatusId);
    final innings = rt?.innings ?? match.innings;
    final homeInnings = innings.where((i) => i.team == 1).lastOrNull;
    final awayInnings = innings.where((i) => i.team == 2).lastOrNull;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.cricketMatchDetailPath(match.id)),
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
                        _CricketScore(
                          homeScore: effectiveHomeScore,
                          awayScore: effectiveAwayScore,
                          statusId: effectiveStatusId,
                          homeInnings: homeInnings,
                          awayInnings: awayInnings,
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

class _CricketScore extends StatelessWidget {
  const _CricketScore({
    required this.homeScore,
    required this.awayScore,
    required this.statusId,
    this.homeInnings,
    this.awayInnings,
  });

  final String homeScore;
  final String awayScore;
  final int statusId;
  final CricketInnings? homeInnings;
  final CricketInnings? awayInnings;

  static const _liveStatuses = {2, 3, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545};
  bool get _isNotStarted => statusId == 1;

  String _formatOvers(double overs) {
    final str = overs.toString();
    return str.contains('.') ? str : '$str.0';
  }

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

    final scoreColor = _liveStatuses.contains(statusId) ? AppColors.primary : Colors.black87;
    final sep = TextSpan(text: ' - ', style: TextStyle(color: Colors.grey.shade400));

    if (homeInnings != null && awayInnings != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: scoreColor,
              ),
              children: [
                TextSpan(text: '${homeInnings!.runs}/${homeInnings!.wickets}'),
                sep,
                TextSpan(text: '${awayInnings!.runs}/${awayInnings!.wickets}'),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: context.textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade500,
              ),
              children: [
                TextSpan(text: '(${_formatOvers(homeInnings!.overs)})'),
                TextSpan(text: ' - '),
                TextSpan(text: '(${_formatOvers(awayInnings!.overs)})'),
              ],
            ),
          ),
        ],
      );
    }

    return RichText(
      text: TextSpan(
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: scoreColor,
        ),
        children: [
          TextSpan(text: homeScore),
          sep,
          TextSpan(text: awayScore),
        ],
      ),
    );
  }
}

