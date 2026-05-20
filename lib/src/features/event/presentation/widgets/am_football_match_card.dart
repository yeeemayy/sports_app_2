import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/event/domain/am_football_status.dart';
import 'package:sports_app/src/features/event/domain/models/am_football_match.dart';
import 'package:sports_app/src/features/event/domain/models/am_football_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

// Design: "GRIDIRON" — giant side-by-side scores like a stadium jumbotron.
// Score (Anton 40px) dominates. Teams displayed below logos left and right.
// Quarter badge / status in center with clock display.

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
    final isNotStarted = effectiveStatusId == 1;
    final scoreColor = isLive ? context.appColors.accent : context.appColors.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Ink(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          border: Border.all(color: context.appColors.line, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: GestureDetector(
          onTap: () => context.push(AppRoutes.amFootballMatchDetailPath(match.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
            child: Column(
              children: [
                // League header
                Row(
                  children: [
                    LeagueLogo(url: match.leagueLogo),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        match.leagueName,
                        style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      match.matchTimeSim,
                      style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Jumbotron row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Home side
                    Expanded(
                      child: Column(
                        children: [
                          SportLogo(url: match.homeLogo, size: 34, circular: true),
                          const SizedBox(height: 4),
                          Text(
                            match.homeName,
                            style: AppTextStyles.mono(10).copyWith(color: context.appColors.text2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Home score
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        isNotStarted ? '-' : effectiveHomeScore,
                        style: AppTextStyles.display(40, context).copyWith(color: scoreColor),
                      ),
                    ),
                    // Center status column
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLive) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.appColors.live,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusLabel.toUpperCase(),
                                style: AppTextStyles.mono(9).copyWith(color: context.appColors.ink),
                              ),
                            ),
                          ] else ...[
                            Text(
                              '·',
                              style: AppTextStyles.display(24, context).copyWith(
                                color: context.appColors.text3,
                              ),
                            ),
                            Text(
                              isNotStarted ? 'VS' : statusLabel.toUpperCase(),
                              style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Away score
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        isNotStarted ? '-' : effectiveAwayScore,
                        style: AppTextStyles.display(40, context).copyWith(color: scoreColor),
                      ),
                    ),
                    // Away side
                    Expanded(
                      child: Column(
                        children: [
                          SportLogo(url: match.awayLogo, size: 34, circular: true),
                          const SizedBox(height: 4),
                          Text(
                            match.awayName,
                            style: AppTextStyles.mono(10).copyWith(color: context.appColors.text2),
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
          ),
        ),
      ),
    );
  }
}