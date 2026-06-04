import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/event/domain/cricket_status.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:sports_app/src/features/watchlist/presentation/watchlist_bell_button.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class CricketMatchHeader extends ConsumerWidget {
  const CricketMatchHeader({
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
      matchDetailProvider(sport: SportType.cricket, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.cricket,
      ).select((map) => map[matchId] as CricketRealtimeData?),
    );

    final detail = detailAsync.valueOrNull as CricketMatchDetail?;
    final homeName = detail?.homeName ?? '';
    final awayName = detail?.awayName ?? '';
    final canWatchlist =
        homeName.isNotEmpty && awayName.isNotEmpty && matchTimestamp != null && matchTimestamp! > 0;
    final watchlistEntry = canWatchlist
        ? WatchlistEntry(
            matchId: matchId,
            sport: 'cricket',
            homeName: homeName,
            awayName: awayName,
            leagueName: leagueName ?? '',
            matchTimeMs: matchTimestamp! * 1000,
          )
        : null;

    return SportDetailHeaderShell<CricketMatchDetail>(
      detailAsync: detailAsync,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      skeletonHeight: 80,
      actions: watchlistEntry != null ? [WatchlistBellButton(entry: watchlistEntry)] : null,
      builder: (detail) => _CricketHeaderContent(detail: detail, rt: rt),
    );
  }
}

class _CricketHeaderContent extends StatelessWidget {
  const _CricketHeaderContent({required this.detail, this.rt});

  final CricketMatchDetail detail;
  final CricketRealtimeData? rt;

  String _formatOvers(double overs) {
    final str = overs.toString();
    return str.contains('.') ? str : '$str.0';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effStatusId = rt?.statusId ?? detail.statusId;

    final innings = rt?.innings ?? detail.innings;
    final homeInnings = innings.where((i) => i.team == 1).lastOrNull;
    final awayInnings = innings.where((i) => i.team == 2).lastOrNull;

    final isNotStarted = effStatusId == 1;
    const liveStatuses = {
      2, 3, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545,
    };
    final isLive = liveStatuses.contains(effStatusId);
    final statusLabel = cricketStatusLabel(
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
            // Home team
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
                  else if (homeInnings != null && awayInnings != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${homeInnings.runs}/${homeInnings.wickets}',
                          style: AppTextStyles.display(
                            26,
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
                          '${awayInnings.runs}/${awayInnings.wickets}',
                          style: AppTextStyles.display(
                            26,
                            context,
                          ).copyWith(color: scoreColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(${_formatOvers(homeInnings.overs)}) · (${_formatOvers(awayInnings.overs)})',
                      style: AppTextStyles.mono(
                        10,
                      ).copyWith(color: colors.text3),
                    ),
                  ] else
                    Text(
                      '–  –',
                      style: AppTextStyles.display(
                        40,
                        context,
                      ).copyWith(color: scoreColor),
                    ),
                ],
              ),
            ),
            // Away team
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
