import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/table_tennis_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/table_tennis_status.dart';
import 'package:sports_app/src/features/event/domain/models/table_tennis_match.dart';
import 'package:sports_app/src/features/event/domain/set_score_utils.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/set_score_display.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class TableTennisMatchCard extends ConsumerWidget {
  const TableTennisMatchCard({super.key, required this.match});

  final TableTennisMatch match;

  static const _liveStatuses = {3, 51, 52, 53, 54, 55, 472, 473};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(SportType.tableTennis).select((map) => map[match.id] as TableTennisRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeSets = rt?.homeSets ?? extractSetScores(match.scores, 0, maxSets: 7);
    final effectiveAwaySets = rt?.awaySets ?? extractSetScores(match.scores, 1, maxSets: 7);
    final effectiveHomeTotal = rt?.homeTotal.toString() ?? match.homeScore;
    final effectiveAwayTotal = rt?.awayTotal.toString() ?? match.awayScore;

    final statusLabel = tableTennisStatusLabel(effectiveStatusId, match.statusDescription);
    final isLive = _liveStatuses.contains(effectiveStatusId);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.tableTennisMatchDetailPath(match.id)),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  LeagueLogo(url: match.leagueLogo),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      match.leagueName,
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
                        match.matchTimeSim,
                        style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Match body
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Home player
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SportLogo(url: match.homeLogo, size: 48, circular: true),
                        const SizedBox(height: 4),
                        Text(
                          match.homeName,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Score area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SetScoreDisplay(
                      statusId: effectiveStatusId,
                      statusLabel: statusLabel,
                      homeTotal: effectiveHomeTotal,
                      awayTotal: effectiveAwayTotal,
                      homeSets: effectiveHomeSets,
                      awaySets: effectiveAwaySets,
                      isLive: isLive,
                    ),
                  ),
                  // Away player
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SportLogo(url: match.awayLogo, size: 48, circular: true),
                        const SizedBox(height: 4),
                        Text(
                          match.awayName,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
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
            const SizedBox(height: 3),
            Center(
              child: SportStatusBadge(label: statusLabel, isLive: isLive),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
          ],
        ),
      ),
    );
  }
}
