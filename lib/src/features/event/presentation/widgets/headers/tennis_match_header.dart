import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/tennis_status.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:sports_app/src/features/watchlist/presentation/watchlist_bell_button.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class TennisMatchHeader extends ConsumerWidget {
  const TennisMatchHeader({
    super.key,
    required this.matchId,
    this.leagueName,
    this.matchTimestamp,
  });

  final String matchId;
  final String? leagueName;
  final int? matchTimestamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      matchDetailProvider(sport: SportType.tennis, matchId: matchId),
    );
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.tennis, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.tennis,
      ).select((map) => map[matchId] as TennisRealtimeData?),
    );

    final detail = detailAsync.valueOrNull as TennisMatchDetail?;
    final homeName = detail?.homeName ?? '';
    final awayName = detail?.awayName ?? '';
    final canWatchlist =
        homeName.isNotEmpty && awayName.isNotEmpty && matchTimestamp != null && matchTimestamp! > 0;
    final watchlistEntry = canWatchlist
        ? WatchlistEntry(
            matchId: matchId,
            sport: 'tennis',
            homeName: homeName,
            awayName: awayName,
            leagueName: leagueName ?? '',
            matchTimeMs: matchTimestamp! * 1000,
          )
        : null;

    return SportDetailHeaderShell<TennisMatchDetail>(
      detailAsync: detailAsync,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      skeletonHeight: 80,
      actions: watchlistEntry != null ? [WatchlistBellButton(entry: watchlistEntry)] : null,
      builder: (detail) => _TennisHeaderContent(
        detail: detail,
        rt: rt,
        eventsData: eventsAsync.valueOrNull as TennisMatchEventsData?,
      ),
    );
  }
}

class _TennisHeaderContent extends StatelessWidget {
  const _TennisHeaderContent({required this.detail, this.rt, this.eventsData});

  final TennisMatchDetail detail;
  final TennisRealtimeData? rt;
  final TennisMatchEventsData? eventsData;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effStatusId = eventsData?.statusId ?? rt?.statusId ?? detail.statusId;

    final homeTotal =
        eventsData?.homeTotal ?? rt?.homeTotal ?? detail.homeInfo.totalScore;
    final awayTotal =
        eventsData?.awayTotal ?? rt?.awayTotal ?? detail.awayInfo.totalScore;

    final servingSide =
        eventsData?.servingSide ?? rt?.servingSide ?? detail.servingSide ?? 0;

    final isLive = const {3, 51, 52, 53, 54, 55}.contains(effStatusId);
    final isNotStarted = effStatusId == 1;

    final statusLabel = tennisStatusLabel(
      effStatusId,
      detail.statusDescription,
    );
    final statusColor = _tennisStatusColor(effStatusId, colors);
    final scoreColor = isLive ? colors.accent : colors.text3;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home player
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _PlayerLogo(url: detail.homeInfo.logo, size: 48),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLive && servingSide == 1) ...[
                        _ServingDot(colors: colors),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          detail.homeName.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.display(
                            12,
                            context,
                          ).copyWith(color: colors.text),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Centre: status + score
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel.toUpperCase(),
                      style: AppTextStyles.display(11, context).copyWith(
                        color: statusColor.computeLuminance() > 0.5
                            ? const Color(0xFF0E0E0E)
                            : Colors.white,
                        letterSpacing: 0.1 * 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isNotStarted)
                    Text(
                      '–  –',
                      style: AppTextStyles.display(
                        40,
                        context,
                      ).copyWith(color: scoreColor),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$homeTotal',
                          style: AppTextStyles.display(
                            48,
                            context,
                          ).copyWith(color: scoreColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '–',
                            style: AppTextStyles.display(
                              22,
                              context,
                            ).copyWith(color: context.appColors.text3),
                          ),
                        ),
                        Text(
                          '$awayTotal',
                          style: AppTextStyles.display(
                            48,
                            context,
                          ).copyWith(color: scoreColor),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Away player
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _PlayerLogo(url: detail.awayInfo.logo, size: 48),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          detail.awayName.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.display(
                            12,
                            context,
                          ).copyWith(color: colors.text),
                        ),
                      ),
                      if (isLive && servingSide == 2) ...[
                        const SizedBox(width: 4),
                        _ServingDot(colors: colors),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Color _tennisStatusColor(int statusId, AppColors colors) {
  if (const {3, 51, 52, 53, 54, 55}.contains(statusId)) return colors.live;
  if (statusId == 8) return colors.text3;
  return colors.text3;
}

class _ServingDot extends StatelessWidget {
  const _ServingDot({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
    );
  }
}

class _PlayerLogo extends StatelessWidget {
  const _PlayerLogo({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        height: size,
        width: size,
        color: context.appColors.surface2,
        child: SportLogo(url: url, size: size),
      ),
    );
  }
}
