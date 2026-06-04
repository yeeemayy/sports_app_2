import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sections/shared_section_widgets.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

const _kHPad = 22.0;

class YourMatchesTodaySection extends StatelessWidget {
  const YourMatchesTodaySection({super.key, required this.entries});

  final List<WatchlistEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_kHPad, 16, _kHPad, 12),
          child: Text(
            'home.your_matches'.tr().toUpperCase(),
            style: AppTextStyles.display(22, context)
                .copyWith(color: context.appColors.text),
          ),
        ),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 0),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => WatchlistMatchCard(entry: entries[i]),
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

class WatchlistMatchCard extends StatelessWidget {
  const WatchlistMatchCard({super.key, required this.entry});

  final WatchlistEntry entry;

  @override
  Widget build(BuildContext context) {
    final path = _matchDetailPath(entry.sport, entry.matchId);
    return GestureDetector(
      onTap: path.isNotEmpty ? () => context.push(path) : null,
      child: Container(
        width: 240,
        height: 118,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.line, width: 0.5),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      context.appColors.accent.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _sportIconFromPath(entry.sport),
                      size: 13,
                      color: context.appColors.text2,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry.leagueName.toUpperCase(),
                        style: AppTextStyles.mono(9).copyWith(
                          color: context.appColors.text2,
                          letterSpacing: 9 * 0.16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TimeBadge(matchTime: entry.matchTime),
                  ],
                ),
                const Spacer(),
                Text(
                  entry.homeName.toUpperCase(),
                  style: AppTextStyles.mono(13)
                      .copyWith(color: context.appColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  entry.awayName.toUpperCase(),
                  style: AppTextStyles.mono(13)
                      .copyWith(color: context.appColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                ReasonLabel(label: 'home.reason.watchlist'.tr()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _matchDetailPath(String sport, String matchId) => switch (sport) {
  'football' => AppRoutes.footballMatchDetailPath(matchId),
  'basketball' => AppRoutes.basketballMatchDetailPath(matchId),
  'tennis' => AppRoutes.tennisMatchDetailPath(matchId),
  'badminton' => AppRoutes.badmintonMatchDetailPath(matchId),
  'table_tennis' => AppRoutes.tableTennisMatchDetailPath(matchId),
  'baseball' => AppRoutes.baseballMatchDetailPath(matchId),
  'volleyball' => AppRoutes.volleyballMatchDetailPath(matchId),
  'hockey' => AppRoutes.iceHockeyMatchDetailPath(matchId),
  'amfootball' => AppRoutes.amFootballMatchDetailPath(matchId),
  'cricket' => AppRoutes.cricketMatchDetailPath(matchId),
  _ => '',
};

IconData _sportIconFromPath(String sport) => switch (sport) {
  'football' => Icons.sports_soccer,
  'basketball' => Icons.sports_basketball,
  'tennis' => Icons.sports_tennis,
  'cricket' => Icons.sports_cricket,
  'baseball' => Icons.sports_baseball,
  'volleyball' => Icons.sports_volleyball,
  'badminton' => Icons.sports_tennis,
  'table_tennis' => Icons.sports_tennis,
  'hockey' => Icons.sports_hockey,
  'amfootball' => Icons.sports_football,
  _ => Icons.sports,
};
