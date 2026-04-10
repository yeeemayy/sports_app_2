import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/badminton_status.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';
import 'package:easy_localization/easy_localization.dart';

class BadmintonMatchCard extends ConsumerWidget {
  const BadmintonMatchCard({super.key, required this.match});

  final BadmintonMatch match;

  static List<int> _homeSets(BadmintonMatch m) {
    final scores = m.scores;
    if (scores == null) return [];
    final sets = <int>[];
    for (var i = 1; i <= 5; i++) {
      final s = scores['p$i'] as List<dynamic>?;
      if (s == null) break;
      sets.add((s[0] as num?)?.toInt() ?? 0);
    }
    return sets;
  }

  static List<int> _awaySets(BadmintonMatch m) {
    final scores = m.scores;
    if (scores == null) return [];
    final sets = <int>[];
    for (var i = 1; i <= 5; i++) {
      final s = scores['p$i'] as List<dynamic>?;
      if (s == null) break;
      sets.add((s[1] as num?)?.toInt() ?? 0);
    }
    return sets;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(SportType.badminton).select((map) => map[match.id] as BadmintonRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeSets = rt?.homeSets ?? _homeSets(match);
    final effectiveAwaySets = rt?.awaySets ?? _awaySets(match);
    final effectiveHomeTotal = rt?.homeTotal.toString() ?? match.homeScore;
    final effectiveAwayTotal = rt?.awayTotal.toString() ?? match.awayScore;

    final statusLabel = badmintonStatusLabel(effectiveStatusId, match.statusDescription);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.badmintonMatchDetailPath(match.id)),
      child: Container(
        color: Colors.white,
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
                    child: _BadmintonScoreDisplay(
                      statusId: effectiveStatusId,
                      statusLabel: statusLabel,
                      homeTotal: effectiveHomeTotal,
                      awayTotal: effectiveAwayTotal,
                      homeSets: effectiveHomeSets,
                      awaySets: effectiveAwaySets,
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
              child: Container(
                constraints: const BoxConstraints(minWidth: 50),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusLabel.isNotEmpty ? Colors.orange : Colors.white,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel.isNotEmpty ? statusLabel : 'common.unknown'.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: statusLabel.isNotEmpty ? Colors.white : Colors.pink,
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

// ─── Score display ────────────────────────────────────────────────────────────

class _BadmintonScoreDisplay extends StatelessWidget {
  const _BadmintonScoreDisplay({
    required this.statusId,
    required this.statusLabel,
    required this.homeTotal,
    required this.awayTotal,
    required this.homeSets,
    required this.awaySets,
  });

  final int statusId;
  final String statusLabel;
  final String homeTotal;
  final String awayTotal;
  final List<int> homeSets;
  final List<int> awaySets;

  static const _liveStatuses = {3, 51, 52, 53, 54, 55};

  @override
  Widget build(BuildContext context) {
    final isNotStarted = statusId == 1;
    final isLive = _liveStatuses.contains(statusId);
    final scoreColor = isNotStarted
        ? Colors.grey.shade400
        : isLive
        ? Colors.pink
        : Colors.black87;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isNotStarted || statusLabel.isEmpty)
          Text(
            '-',
            style: context.textTheme.titleSmall?.copyWith(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          RichText(
            text: TextSpan(
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: scoreColor,
              ),
              children: [
                TextSpan(text: homeTotal),
                const TextSpan(text: ' - '),
                TextSpan(text: awayTotal),
              ],
            ),
          ),
        if (homeSets.isNotEmpty)
          Text(
            '${homeSets.last}:${awaySets.last}',
            style: context.textTheme.labelMedium?.copyWith(color: Colors.grey.shade500),
          ),
      ],
    );
  }
}
