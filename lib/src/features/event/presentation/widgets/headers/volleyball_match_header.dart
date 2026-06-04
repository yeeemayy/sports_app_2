import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/volleyball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/volleyball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/volleyball_status.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:sports_app/src/features/watchlist/presentation/watchlist_bell_button.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class VolleyballMatchHeader extends ConsumerWidget {
  const VolleyballMatchHeader({
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
      matchDetailProvider(sport: SportType.volleyball, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.volleyball,
      ).select((map) => map[matchId] as VolleyballRealtimeData?),
    );

    final detail = detailAsync.valueOrNull as VolleyballMatchDetail?;
    final homeName = detail?.homeName ?? '';
    final awayName = detail?.awayName ?? '';
    final canWatchlist =
        homeName.isNotEmpty && awayName.isNotEmpty && matchTimestamp != null && matchTimestamp! > 0;
    final watchlistEntry = canWatchlist
        ? WatchlistEntry(
            matchId: matchId,
            sport: 'volleyball',
            homeName: homeName,
            awayName: awayName,
            leagueName: leagueName ?? '',
            matchTimeMs: matchTimestamp! * 1000,
          )
        : null;

    return SportDetailHeaderShell<VolleyballMatchDetail>(
      detailAsync: detailAsync,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      skeletonHeight: 80,
      actions: watchlistEntry != null ? [WatchlistBellButton(entry: watchlistEntry)] : null,
      builder: (detail) => _VolleyballHeaderContent(detail: detail, rt: rt),
    );
  }
}

class _VolleyballHeaderContent extends StatelessWidget {
  const _VolleyballHeaderContent({required this.detail, this.rt});

  final VolleyballMatchDetail detail;
  final VolleyballRealtimeData? rt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effStatusId = rt?.statusId ?? detail.statusId;
    final homeTotal = rt?.homeTotal ?? detail.homeInfo.totalScore;
    final awayTotal = rt?.awayTotal ?? detail.awayInfo.totalScore;

    final isNotStarted = effStatusId == 1;
    const liveStatuses = {432, 434, 436, 438, 440};
    final isLive = liveStatuses.contains(effStatusId);
    final statusLabel = volleyballStatusLabel(
      effStatusId,
      detail.statusDescription,
    );
    final statusColor = isLive ? colors.live : colors.text3;
    final scoreColor = isLive ? colors.accent : colors.text3;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SportLogo(url: detail.homeInfo.logo, size: 52),
                  const SizedBox(height: 6),
                  Text(
                    detail.homeName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(
                      12,
                      context,
                    ).copyWith(color: colors.text),
                  ),
                ],
              ),
            ),
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
                      '– –',
                      style: AppTextStyles.display(
                        40,
                        context,
                      ).copyWith(color: scoreColor),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$homeTotal',
                          style: AppTextStyles.display(
                            56,
                            context,
                          ).copyWith(color: scoreColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: AppTextStyles.display(
                              48,
                              context,
                            ).copyWith(color: colors.text3),
                          ),
                        ),
                        Text(
                          '$awayTotal',
                          style: AppTextStyles.display(
                            56,
                            context,
                          ).copyWith(color: scoreColor),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SportLogo(url: detail.awayInfo.logo, size: 52),
                  const SizedBox(height: 6),
                  Text(
                    detail.awayName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(
                      12,
                      context,
                    ).copyWith(color: colors.text),
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
