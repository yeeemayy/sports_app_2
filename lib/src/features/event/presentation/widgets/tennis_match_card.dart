import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';

class TennisMatchCard extends ConsumerWidget {
  const TennisMatchCard({super.key, required this.match});

  final TennisMatch match;

  static const _liveStatuses = {3, 51, 52, 53, 54, 55};

  static List<int> _homeSets(TennisMatch m) {
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

  static List<int> _awaySets(TennisMatch m) {
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

  String _statusLabel(int statusId, String? desc) {
    switch (statusId) {
      case 1:
        return 'event.tennis.status.pre'.tr();
      case 3:
        return 'event.tennis.status.live'.tr();
      case 51:
        return 'event.tennis.status.s1'.tr();
      case 52:
        return 'event.tennis.status.s2'.tr();
      case 53:
        return 'event.tennis.status.s3'.tr();
      case 54:
        return 'event.tennis.status.s4'.tr();
      case 55:
        return 'event.tennis.status.s5'.tr();
      case 100:
        return 'event.tennis.status.ft'.tr();
      case 20:
      case 22:
      case 23:
        return 'event.tennis.status.wo'.tr();
      case 21:
      case 24:
      case 25:
        return 'event.tennis.status.ret'.tr();
      case 26:
      case 27:
        return 'event.tennis.status.def'.tr();
      case 14:
        return 'event.tennis.status.pst'.tr();
      case 15:
        return 'event.tennis.status.dly'.tr();
      case 16:
        return 'event.tennis.status.can'.tr();
      case 17:
        return 'event.tennis.status.int'.tr();
      case 18:
        return 'event.tennis.status.sus'.tr();
      case 99:
        return 'event.tennis.status.tbd'.tr();
      default:
        return desc ?? '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(tennisRealtimeProvider.select((map) => map[match.id]));

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeSets = rt?.homeSets ?? _homeSets(match);
    final effectiveAwaySets = rt?.awaySets ?? _awaySets(match);
    final effectiveHomeTotal = rt?.homeTotal.toString() ?? match.homeScore;
    final effectiveAwayTotal = rt?.awayTotal.toString() ?? match.awayScore;
    final effectiveServingSide = rt?.servingSide ?? 0;

    final isLive = _liveStatuses.contains(effectiveStatusId);
    final statusLabel = _statusLabel(effectiveStatusId, match.statusDescription);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.tennisMatchDetailPath(match.id)),
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
                  _LeagueLogo(url: match.leagueLogo),
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
                        _PlayerLogo(url: match.homeLogo),
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
                    child: _TennisScoreDisplay(
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
                        _PlayerLogo(url: match.awayLogo),
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
            SizedBox(height: 3),
            Center(
              child: Container(
                constraints: BoxConstraints(minWidth: 50),
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
                    color: statusLabel.isNotEmpty ? Colors.white : Colors.orange,
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

// ─── Set score display ────────────────────────────────────────────────────────

class _TennisScoreDisplay extends StatelessWidget {
  const _TennisScoreDisplay({
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
        // Main sets-won score
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
                TextSpan(text: ' - '),
                TextSpan(text: awayTotal),
              ],
            ),
          ),
        // Current set game score
        if (homeSets.isNotEmpty)
          Text(
            '${homeSets.last}:${awaySets.last}',
            style: context.textTheme.labelMedium?.copyWith(color: Colors.grey.shade500),
          ),
      ],
    );
  }
}

// ─── Serving indicator ────────────────────────────────────────────────────────

class _ServingDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    );
  }
}

// ─── Logo helpers ─────────────────────────────────────────────────────────────

class _LeagueLogo extends StatelessWidget {
  const _LeagueLogo({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox(width: 16, height: 16);
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 16,
        height: 16,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => const SizedBox(width: 16, height: 16),
      ),
    );
  }
}

class _PlayerLogo extends StatelessWidget {
  const _PlayerLogo({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 48,
        height: 48,
        child: url.isEmpty
            ? AvatarFallback(size: 48, iconSize: 24)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: const ColoredBox(color: Colors.grey),
                ),
                errorBuilder: (_, _, _) => AvatarFallback(size: 48, iconSize: 20),
              ),
      ),
    );
  }
}
