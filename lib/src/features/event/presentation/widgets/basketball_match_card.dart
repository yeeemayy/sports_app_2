import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';

class BasketballMatchCard extends ConsumerWidget {
  const BasketballMatchCard({super.key, required this.match});

  final BasketballMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(basketballRealtimeProvider.select((map) => map[match.id]));

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeScore = rt != null ? rt.homeTotal.toString() : match.homeScore;
    final effectiveAwayScore = rt != null ? rt.awayTotal.toString() : match.awayScore;
    final effectivePeriodLabel = rt != null
        ? (rt.periodLabelKey.isEmpty ? null : rt.periodLabelKey.tr())
        : match.statusDescription;
    final effectiveClockDisplay = (rt != null && rt.showClock) ? rt.clockDisplay : match.liveMinute;

    final isLive = effectiveStatusId > 0 && effectiveStatusId < 10;
    final isUpcoming = effectiveStatusId == 1 || effectiveStatusId == 0;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // League header row
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
                Text(
                  match.matchTimeSim,
                  style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Match body
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 8, 10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left: period + timer (or status label)
                  SizedBox(
                    width: 60,
                    child: _StatusColumn(
                      status: effectiveStatusId,
                      isUpcoming: isUpcoming,
                      periodLabel: effectivePeriodLabel,
                      liveTimer: effectiveClockDisplay,
                    ),
                  ),
                  // Vertical divider
                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 10),
                  // Teams + scores
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TeamScoreRow(
                          score: effectiveHomeScore,
                          logo: match.homeLogo,
                          name: match.homeName,
                          isLive: isLive,
                        ),
                        const SizedBox(height: 6),
                        _TeamScoreRow(
                          score: effectiveAwayScore,
                          logo: match.awayLogo,
                          name: match.awayName,
                          isLive: isLive,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  const _StatusColumn({
    required this.status,
    required this.isUpcoming,
    required this.periodLabel,
    required this.liveTimer,
  });

  final int status;
  final bool isUpcoming;
  final String? periodLabel;
  final String? liveTimer;

  static const _liveStatuses = {2, 3, 4, 5, 6, 7, 8};
  static const _noScoreStatuses = {0, 1, 3, 5, 7, 12};

  @override
  Widget build(BuildContext context) {
    if (_liveStatuses.contains(status)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (periodLabel != null && periodLabel!.isNotEmpty)
            Text(
              periodLabel!,
              style: context.textTheme.labelSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (!_noScoreStatuses.contains(status) && liveTimer != null && liveTimer!.isNotEmpty)
            Text(liveTimer!, style: context.textTheme.labelSmall?.copyWith(color: Colors.red)),
        ],
      );
    }

    return Center(
      child: Text(
        isUpcoming ? 'event.status.upcoming'.tr() : 'event.status.finished'.tr(),
        style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TeamScoreRow extends StatelessWidget {
  const _TeamScoreRow({
    required this.score,
    required this.logo,
    required this.name,
    required this.isLive,
  });

  final String score;
  final String logo;
  final String name;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 45,
          child: Text(
            score,
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isLive ? Colors.pink : Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 6),
        _TeamLogo(url: logo),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

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

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: url.isEmpty
          ? ColoredBox(color: Colors.grey.shade100)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, _) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: const ColoredBox(color: Colors.grey),
              ),
              errorWidget: (_, _, _) => ColoredBox(color: Colors.grey.shade100),
            ),
    );
  }
}
