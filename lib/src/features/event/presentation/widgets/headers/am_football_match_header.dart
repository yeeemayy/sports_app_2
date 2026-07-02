import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/features/event/domain/am_football_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/am_football_match_detail.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/am_football_realtime_data.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/event_providers.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:shenghaotiyu/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:shenghaotiyu/src/features/watchlist/presentation/watchlist_bell_button.dart';
import 'package:shenghaotiyu/src/shared_widgets/sport_logo.dart';

class AmFootballMatchHeader extends ConsumerWidget {
  const AmFootballMatchHeader({
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
      matchDetailProvider(sport: SportType.amFootball, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.amFootball,
      ).select((map) => map[matchId] as AmFootballRealtimeData?),
    );

    final detail = detailAsync.valueOrNull as AmFootballMatchDetail?;
    final homeName = detail?.homeName ?? '';
    final awayName = detail?.awayName ?? '';
    final canWatchlist =
        homeName.isNotEmpty && awayName.isNotEmpty && matchTimestamp != null && matchTimestamp! > 0;
    final watchlistEntry = canWatchlist
        ? WatchlistEntry(
            matchId: matchId,
            sport: 'amfootball',
            homeName: homeName,
            awayName: awayName,
            leagueName: leagueName ?? '',
            matchTimeMs: matchTimestamp! * 1000,
          )
        : null;

    return SportDetailHeaderShell<AmFootballMatchDetail>(
      detailAsync: detailAsync,
      skeletonHeight: 80,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      actions: watchlistEntry != null ? [WatchlistBellButton(entry: watchlistEntry)] : null,
      builder: (detail) => _AmFootballHeaderContent(detail: detail, rt: rt),
    );
  }
}

class _AmFootballHeaderContent extends StatelessWidget {
  const _AmFootballHeaderContent({required this.detail, this.rt});

  final AmFootballMatchDetail detail;
  final AmFootballRealtimeData? rt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effStatusId = rt?.statusId ?? detail.statusId;
    final homeScore = rt?.homeScore.toString() ?? detail.homeScore;
    final awayScore = rt?.awayScore.toString() ?? detail.awayScore;

    final isNotStarted = effStatusId == 1;
    const liveStatuses = {44, 45, 46, 47, 10, 6, 331, 332, 333};
    final isLive = liveStatuses.contains(effStatusId);
    final statusLabel = amFootballStatusLabel(
      effStatusId,
      detail.statusDescription,
    );
    final pillColor = isLive ? colors.live : colors.text2;
    final scoreColor = isLive ? colors.accent : colors.text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SportLogo(url: detail.homeInfo.logo, size: 48),
              const SizedBox(height: 6),
              Text(
                detail.homeName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(
                  12,
                ).copyWith(fontWeight: FontWeight.w600),
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
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: pillColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel.isNotEmpty ? statusLabel : 'common.unknown'.tr(),
                  style: AppTextStyles.mono(
                    10,
                  ).copyWith(color: scoreColor, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              if (isNotStarted)
                Text(
                  '–',
                  style: AppTextStyles.display(
                    22,
                    context,
                  ).copyWith(color: colors.text3),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      homeScore,
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
                          32,
                          context,
                        ).copyWith(color: colors.text3),
                      ),
                    ),
                    Text(
                      awayScore,
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
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SportLogo(url: detail.awayInfo.logo, size: 48),
              const SizedBox(height: 6),
              Text(
                detail.awayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(
                  12,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
