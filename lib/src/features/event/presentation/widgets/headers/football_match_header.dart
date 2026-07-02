import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/football_match.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/football_match_detail.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/football_match_events.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/match_realtime_data.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/event_providers.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:shenghaotiyu/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:shenghaotiyu/src/features/watchlist/presentation/watchlist_bell_button.dart';
import 'package:shenghaotiyu/src/shared_widgets/sport_logo.dart';

class FootballMatchHeader extends ConsumerWidget {
  const FootballMatchHeader({
    super.key,
    required this.matchId,
    this.initialMatch,
    this.leagueName,
    this.matchTimestamp,
  });

  final String matchId;
  final FootballMatch? initialMatch;
  final String? leagueName;
  final int? matchTimestamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.football, matchId: matchId));
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.football, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.football).select((map) => map[matchId] as MatchRealtimeData?),
    );

    Widget? fallback;
    if (initialMatch != null) {
      fallback = _HeaderFallback(match: initialMatch!, rt: rt);
    }

    final detail = detailAsync.valueOrNull as FootballMatchDetail?;
    final homeName = detail?.homeName ?? initialMatch?.homeName ?? '';
    final awayName = detail?.awayName ?? initialMatch?.awayName ?? '';
    final canWatchlist =
        homeName.isNotEmpty && awayName.isNotEmpty && matchTimestamp != null && matchTimestamp! > 0;

    final watchlistEntry = canWatchlist
        ? WatchlistEntry(
            matchId: matchId,
            sport: 'football',
            homeName: homeName,
            awayName: awayName,
            leagueName: leagueName ?? '',
            matchTimeMs: matchTimestamp! * 1000,
          )
        : null;

    return SportDetailHeaderShell<FootballMatchDetail>(
      detailAsync: detailAsync,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      fallback: fallback,
      actions: watchlistEntry != null ? [WatchlistBellButton(entry: watchlistEntry)] : null,
      builder: (detail) {
        final effKickoff = (rt != null && rt.kickoffTimestamp != 0)
            ? rt.kickoffTimestamp
            : (eventsAsync.valueOrNull as FootballMatchEvents?)?.kickoffTimestamp;
        return _HeaderContent(
          detail: detail,
          kickoffTimestamp: effKickoff,
          rtStatusId: rt?.statusId,
          rtHomeScore: rt?.homeScore,
          rtAwayScore: rt?.awayScore,
          rtHomeHtScore: rt?.homeHtScore,
          rtAwayHtScore: rt?.awayHtScore,
        );
      },
    );
  }
}

class _HeaderFallback extends StatelessWidget {
  const _HeaderFallback({required this.match, this.rt});

  final FootballMatch match;
  final MatchRealtimeData? rt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effStatusId = rt?.statusId ?? match.statusId;
    final effHome = rt?.homeScore.toString() ?? match.homeScore;
    final effAway = rt?.awayScore.toString() ?? match.awayScore;
    final isNoScore = const {0, 1, 13}.contains(effStatusId);

    return _ScoreRow(
      homeLogo: match.homeLogo,
      homeName: match.homeName,
      awayLogo: match.awayLogo,
      awayName: match.awayName,
      homeScore: isNoScore ? '–' : effHome,
      awayScore: isNoScore ? '–' : effAway,
      statusLabel: match.statusLabel,
      statusColor: _statusColor(effStatusId, colors),
      statusSubLabel: null,
      environment: null,
      colors: colors,
      context: context,
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({
    required this.detail,
    this.kickoffTimestamp,
    this.rtStatusId,
    this.rtHomeScore,
    this.rtAwayScore,
    this.rtHomeHtScore,
    this.rtAwayHtScore,
  });

  final FootballMatchDetail detail;
  final int? kickoffTimestamp;
  final int? rtStatusId;
  final int? rtHomeScore;
  final int? rtAwayScore;
  final int? rtHomeHtScore;
  final int? rtAwayHtScore;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effStatusId = rtStatusId ?? detail.statusId;
    final effHome = rtHomeScore?.toString() ?? detail.homeScore;
    final effAway = rtAwayScore?.toString() ?? detail.awayScore;
    final effHomeHt = rtHomeHtScore ?? detail.homeInfo.halfTimeScore;
    final effAwayHt = rtAwayHtScore ?? detail.awayInfo.halfTimeScore;
    final isNoScore = const {0, 1, 13}.contains(effStatusId);

    String? statusSubLabel;
    if (effStatusId != 1 && effStatusId != 8 && effHomeHt != null && effAwayHt != null) {
      statusSubLabel = '${'event.football.ht'.tr()} $effHomeHt-$effAwayHt';
    }

    return _ScoreRow(
      homeLogo: detail.homeInfo.logo,
      homeName: detail.homeName,
      awayLogo: detail.awayInfo.logo,
      awayName: detail.awayName,
      homeScore: isNoScore ? '–' : effHome,
      awayScore: isNoScore ? '–' : effAway,
      statusLabel: detail.statusLabel(kickoffTimestamp: kickoffTimestamp),
      statusColor: _statusColor(effStatusId, colors),
      statusSubLabel: statusSubLabel,
      environment: detail.environment,
      colors: colors,
      context: context,
    );
  }
}

Color _statusColor(int statusId, AppColors colors) {
  if (const {2, 3, 4, 5, 6, 7}.contains(statusId)) return colors.live;
  if (statusId == 8) return colors.text3;
  if (const {9, 10, 11, 12}.contains(statusId)) return colors.danger;
  return colors.text3;
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.homeLogo,
    required this.homeName,
    required this.awayLogo,
    required this.awayName,
    required this.homeScore,
    required this.awayScore,
    required this.statusLabel,
    required this.statusColor,
    required this.statusSubLabel,
    required this.environment,
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
  final String? statusSubLabel;
  final FootballMatchEnvironment? environment;
  final AppColors colors;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home
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
                    style: AppTextStyles.display(13, context).copyWith(color: colors.text),
                  ),
                ],
              ),
            ),
            // Score centre
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        homeScore,
                        style: AppTextStyles.display(
                          56,
                          context,
                        ).copyWith(color: statusColor == colors.live ? colors.accent : statusColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          ':',
                          style: AppTextStyles.display(28, context).copyWith(color: colors.text3),
                        ),
                      ),
                      Text(
                        awayScore,
                        style: AppTextStyles.display(
                          56,
                          context,
                        ).copyWith(color: statusColor == colors.live ? colors.accent : statusColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Away
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
                    style: AppTextStyles.display(13, context).copyWith(color: colors.text),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (statusSubLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              statusSubLabel!.toUpperCase(),
              style: AppTextStyles.mono(9).copyWith(color: colors.text3, letterSpacing: 0.14 * 9),
              textAlign: TextAlign.center,
            ),
          ),
        if (environment != null) _EnvRow(env: environment!, colors: colors),
      ],
    );
  }
}

class _EnvRow extends StatelessWidget {
  const _EnvRow({required this.env, required this.colors});

  final FootballMatchEnvironment env;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      if (env.temperature != null) (Icons.thermostat_outlined, env.temperature!),
      if (env.humidity != null) (Icons.water_drop_outlined, env.humidity!),
      if (env.wind != null) (Icons.air_outlined, env.wind!),
      if (env.pressure != null) (Icons.speed_outlined, env.pressure!),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 4,
        children: [
          for (final (icon, label) in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 10, color: colors.text3),
                const SizedBox(width: 3),
                Text(label, style: AppTextStyles.mono(9).copyWith(color: colors.text3)),
              ],
            ),
        ],
      ),
    );
  }
}
