import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sections/shared_section_widgets.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:sports_app/src/routes/app_routes.dart';

const _kHPad = 22.0;

class FavTeamUpcomingSection extends StatelessWidget {
  const FavTeamUpcomingSection({super.key, required this.items});

  final List<({SportMatch match, SportType sport})> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_kHPad, 16, _kHPad, 12),
          child: Text(
            'home.fav_teams'.tr().toUpperCase(),
            style: AppTextStyles.display(22, context)
                .copyWith(color: context.appColors.text),
          ),
        ),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 0),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _FavUpcomingMatchCard(
              match: items[i].match,
              sport: items[i].sport,
            ),
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _FavUpcomingMatchCard extends StatelessWidget {
  const _FavUpcomingMatchCard({required this.match, required this.sport});

  final SportMatch match;
  final SportType sport;

  @override
  Widget build(BuildContext context) {
    final path = switch (sport) {
      SportType.football => AppRoutes.footballMatchDetailPath(match.id),
      SportType.basketball => AppRoutes.basketballMatchDetailPath(match.id),
      SportType.tennis => AppRoutes.tennisMatchDetailPath(match.id),
      SportType.cricket => AppRoutes.cricketMatchDetailPath(match.id),
      SportType.baseball => AppRoutes.baseballMatchDetailPath(match.id),
      SportType.volleyball => AppRoutes.volleyballMatchDetailPath(match.id),
      SportType.badminton => AppRoutes.badmintonMatchDetailPath(match.id),
      SportType.tableTennis => AppRoutes.tableTennisMatchDetailPath(match.id),
      SportType.iceHockey => AppRoutes.iceHockeyMatchDetailPath(match.id),
      SportType.amFootball => AppRoutes.amFootballMatchDetailPath(match.id),
    };

    final matchTimeMs = (match.matchTime ?? 0) * 1000;
    final canWatchlist = matchTimeMs > 0;
    final watchlistEntry = canWatchlist
        ? WatchlistEntry(
            matchId: match.id,
            sport: sport.apiPath,
            homeName: match.homeName,
            awayName: match.awayName,
            leagueName: match.leagueName,
            matchTimeMs: matchTimeMs,
          )
        : null;

    return GestureDetector(
      onTap: () => context.push(path, extra: match),
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
                      _sportIcon(sport),
                      size: 13,
                      color: context.appColors.text2,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        match.leagueName.toUpperCase(),
                        style: AppTextStyles.mono(9).copyWith(
                          color: context.appColors.text2,
                          letterSpacing: 9 * 0.16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (watchlistEntry != null) ...[
                      const SizedBox(width: 6),
                      CompactBell(entry: watchlistEntry),
                    ],
                  ],
                ),
                const Spacer(),
                Text(
                  match.homeName.toUpperCase(),
                  style: AppTextStyles.mono(13)
                      .copyWith(color: context.appColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  match.awayName.toUpperCase(),
                  style: AppTextStyles.mono(13)
                      .copyWith(color: context.appColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                ReasonLabel(label: 'home.reason.favourite_team'.tr()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _sportIcon(SportType sport) => switch (sport) {
  SportType.football => Icons.sports_soccer,
  SportType.basketball => Icons.sports_basketball,
  SportType.tennis => Icons.sports_tennis,
  SportType.cricket => Icons.sports_cricket,
  SportType.baseball => Icons.sports_baseball,
  SportType.volleyball => Icons.sports_volleyball,
  SportType.badminton => Icons.sports_tennis,
  SportType.tableTennis => Icons.sports_tennis,
  SportType.iceHockey => Icons.sports_hockey,
  SportType.amFootball => Icons.sports_football,
};
