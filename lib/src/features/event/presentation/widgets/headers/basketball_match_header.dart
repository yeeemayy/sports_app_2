import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:sports_app/src/features/watchlist/presentation/watchlist_bell_button.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class BasketballMatchHeader extends ConsumerWidget {
  const BasketballMatchHeader({
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
      matchDetailProvider(sport: SportType.basketball, matchId: matchId),
    );
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.basketball, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.basketball,
      ).select((map) => map[matchId] as BasketballRealtimeData?),
    );

    final detail = detailAsync.valueOrNull as BasketballMatchDetail?;
    final homeName = detail?.homeName ?? '';
    final awayName = detail?.awayName ?? '';
    final canWatchlist =
        homeName.isNotEmpty && awayName.isNotEmpty && matchTimestamp != null && matchTimestamp! > 0;
    final watchlistEntry = canWatchlist
        ? WatchlistEntry(
            matchId: matchId,
            sport: 'basketball',
            homeName: homeName,
            awayName: awayName,
            leagueName: leagueName ?? '',
            matchTimeMs: matchTimestamp! * 1000,
          )
        : null;

    return SportDetailHeaderShell<BasketballMatchDetail>(
      detailAsync: detailAsync,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      actions: watchlistEntry != null ? [WatchlistBellButton(entry: watchlistEntry)] : null,
      builder: (detail) {
        final eventsData =
            eventsAsync.valueOrNull as BasketballMatchEventsData?;
        final effStatusId =
            eventsData?.statusId ?? rt?.statusId ?? detail.statusId;
        final homeTotal =
            eventsData?.homeTotal ?? rt?.homeTotal ?? detail.homeInfo.total;
        final awayTotal =
            eventsData?.awayTotal ?? rt?.awayTotal ?? detail.awayInfo.total;

        final periodKey = _periodKey(effStatusId);
        final periodLabel = periodKey.isNotEmpty
            ? periodKey.tr()
            : (detail.statusDescription ?? '');

        final showClock = eventsData?.showClock ?? rt?.showClock ?? false;
        final clockDisplay = eventsData?.clockDisplay ?? rt?.clockDisplay ?? '';
        final isNoScore = const {0, 1}.contains(effStatusId);

        final statusColor = _statusColor(effStatusId, context.appColors);

        return _ScoreBlock(
          homeLogo: detail.homeInfo.logo,
          homeName: detail.homeName,
          awayLogo: detail.awayInfo.logo,
          awayName: detail.awayName,
          homeScore: isNoScore ? '–' : '$homeTotal',
          awayScore: isNoScore ? '–' : '$awayTotal',
          statusLabel: periodLabel,
          statusColor: statusColor,
          clockDisplay: showClock ? clockDisplay : null,
          colors: context.appColors,
          context: context,
        );
      },
    );
  }

  static String _periodKey(int statusId) => switch (statusId) {
    1 => 'event.basketball.period.not_started',
    2 => 'event.basketball.period.q1',
    3 => 'event.basketball.period.q1_over',
    4 => 'event.basketball.period.q2',
    5 => 'event.basketball.period.q2_over',
    6 => 'event.basketball.period.q3',
    7 => 'event.basketball.period.q3_over',
    8 => 'event.basketball.period.q4',
    9 => 'event.basketball.period.ot',
    10 => 'event.basketball.period.end',
    11 => 'event.basketball.period.interrupt',
    12 => 'event.basketball.period.cancel',
    13 => 'event.basketball.period.extension',
    14 => 'event.basketball.period.half',
    _ => '',
  };

  static Color _statusColor(int statusId, AppColors colors) {
    if (const {2, 4, 6, 8, 9, 13, 14}.contains(statusId)) return colors.live;
    if (const {10}.contains(statusId)) return colors.text3;
    if (const {11, 12}.contains(statusId)) return colors.danger;
    return colors.text3;
  }
}

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({
    required this.homeLogo,
    required this.homeName,
    required this.awayLogo,
    required this.awayName,
    required this.homeScore,
    required this.awayScore,
    required this.statusLabel,
    required this.statusColor,
    required this.clockDisplay,
    required this.colors,
    required this.context,
  });

  final String homeLogo;
  final String homeName;
  final String awayLogo;
  final String awayName;
  final String homeScore;
  final String awayScore;
  final String statusLabel;
  final Color statusColor;
  final String? clockDisplay;
  final AppColors colors;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              SportLogo(url: homeLogo, size: 52),
              const SizedBox(height: 6),
              Text(
                homeName.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.display(
                  13,
                  context,
                ).copyWith(color: colors.text),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              if (statusLabel.isNotEmpty)
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
              if (clockDisplay != null && clockDisplay!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    clockDisplay!,
                    style: AppTextStyles.mono(10).copyWith(color: colors.text2),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    homeScore,
                    style: AppTextStyles.display(56, context).copyWith(
                      color: statusColor == colors.live
                          ? colors.accent
                          : statusColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '–',
                      style: AppTextStyles.display(
                        22,
                        context,
                      ).copyWith(color: context.appColors.text3),
                    ),
                  ),
                  Text(
                    awayScore,
                    style: AppTextStyles.display(56, context).copyWith(
                      color: statusColor == colors.live
                          ? colors.accent
                          : statusColor,
                    ),
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
              SportLogo(url: awayLogo, size: 52),
              const SizedBox(height: 6),
              Text(
                awayName.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.display(
                  13,
                  context,
                ).copyWith(color: colors.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
