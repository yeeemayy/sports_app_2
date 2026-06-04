import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/event/domain/baseball_status.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:sports_app/src/features/watchlist/presentation/watchlist_bell_button.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class BaseballMatchHeader extends ConsumerWidget {
  const BaseballMatchHeader({
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
      matchDetailProvider(sport: SportType.baseball, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.baseball,
      ).select((map) => map[matchId] as BaseballRealtimeData?),
    );

    final detail = detailAsync.valueOrNull as BaseballMatchDetail?;
    final homeName = detail?.homeName ?? '';
    final awayName = detail?.awayName ?? '';
    final canWatchlist =
        homeName.isNotEmpty && awayName.isNotEmpty && matchTimestamp != null && matchTimestamp! > 0;
    final watchlistEntry = canWatchlist
        ? WatchlistEntry(
            matchId: matchId,
            sport: 'baseball',
            homeName: homeName,
            awayName: awayName,
            leagueName: leagueName ?? '',
            matchTimeMs: matchTimestamp! * 1000,
          )
        : null;

    return SportDetailHeaderShell<BaseballMatchDetail>(
      detailAsync: detailAsync,
      skeletonHeight: 80,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      actions: watchlistEntry != null ? [WatchlistBellButton(entry: watchlistEntry)] : null,
      builder: (detail) => _BaseballHeaderContent(detail: detail, rt: rt),
    );
  }
}

class _BaseballHeaderContent extends StatelessWidget {
  const _BaseballHeaderContent({required this.detail, this.rt});

  final BaseballMatchDetail detail;
  final BaseballRealtimeData? rt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final statusId = rt?.statusId ?? detail.statusId;
    final homeScore =
        rt?.homeScore ??
        (detail.scores['ft'] as List<dynamic>?)
            ?.elementAtOrNull(0)
            ?.toString() ??
        '-';
    final awayScore =
        rt?.awayScore ??
        (detail.scores['ft'] as List<dynamic>?)
            ?.elementAtOrNull(1)
            ?.toString() ??
        '-';

    final isLive = baseballLiveStatuses.contains(statusId);
    final isNotStarted = statusId == 1;
    final statusLabel = baseballStatusLabel(statusId);
    final pillColor = isLive ? colors.live : colors.text2;
    final scoreColor = isLive ? colors.accent : colors.text2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SportLogo(url: detail.homeInfo.logo, size: 48, circular: false),
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
                  border: Border.all(color: pillColor.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel.isNotEmpty ? statusLabel : 'common.unknown'.tr(),
                  style: AppTextStyles.mono(
                    10,
                  ).copyWith(color: pillColor, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              if (isNotStarted)
                Text(
                  '-',
                  style: AppTextStyles.display(
                    32,
                    context,
                  ).copyWith(color: scoreColor),
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
              SportLogo(url: detail.awayInfo.logo, size: 48, circular: false),
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
