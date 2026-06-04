import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/models/paginated_response.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sections/shared_section_widgets.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

const _kHPad = 22.0;

class LiveNowSection extends StatelessWidget {
  const LiveNowSection({
    super.key,
    required this.liveAsync,
    required this.onSeeAll,
    required this.favTeamNames,
  });

  final AsyncValue<PaginatedMatchResult> liveAsync;
  final VoidCallback onSeeAll;
  final Set<String> favTeamNames;

  @override
  Widget build(BuildContext context) {
    final raw = liveAsync.valueOrNull?.matches ?? [];
    final matches = _sortByFavourites(raw, favTeamNames);

    if (liveAsync.isLoading && matches.isEmpty) return _shimmer(context);
    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_kHPad, 16, _kHPad, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'home.live_now'.tr().toUpperCase(),
                style: AppTextStyles.display(
                  22,
                  context,
                ).copyWith(color: context.appColors.text),
              ),
              const SizedBox(width: 10),
              Text(
                '${matches.length}',
                style: AppTextStyles.mono(
                  10,
                ).copyWith(color: context.appColors.text3),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'home.see_all'.tr(),
                  style: AppTextStyles.mono(10).copyWith(
                    color: context.appColors.text3,
                    letterSpacing: 10 * 0.14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 0),
            itemCount: matches.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final m = matches[i];
              final isFav = favTeamNames.any((n) => n.isNotEmpty && (
                m.homeName.toLowerCase().contains(n) ||
                m.awayName.toLowerCase().contains(n)
              ));
              return _LiveMatchCard(match: m, sport: SportType.football, isFavourite: isFav);
            },
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _shimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 22),
      child: Skeletonizer(
        enabled: true,
        child: SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 0),
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, _) => Container(
              width: 240,
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveMatchCard extends StatelessWidget {
  const _LiveMatchCard({
    required this.match,
    required this.sport,
    this.isFavourite = false,
  });

  final SportMatch match;
  final SportType sport;
  final bool isFavourite;

  @override
  Widget build(BuildContext context) {
    final homeScore = int.tryParse(match.homeScore) ?? 0;
    final awayScore = int.tryParse(match.awayScore) ?? 0;

    return GestureDetector(
      onTap: () {
        final path = switch (sport) {
          SportType.football => AppRoutes.footballMatchDetailPath(match.id),
          SportType.basketball => AppRoutes.basketballMatchDetailPath(match.id),
          SportType.tennis => AppRoutes.tennisMatchDetailPath(match.id),
          SportType.cricket => AppRoutes.cricketMatchDetailPath(match.id),
          SportType.baseball => AppRoutes.baseballMatchDetailPath(match.id),
          SportType.volleyball => AppRoutes.volleyballMatchDetailPath(match.id),
          SportType.badminton => AppRoutes.badmintonMatchDetailPath(match.id),
          SportType.tableTennis => AppRoutes.tableTennisMatchDetailPath(
            match.id,
          ),
          SportType.iceHockey => AppRoutes.iceHockeyMatchDetailPath(match.id),
          SportType.amFootball => AppRoutes.amFootballMatchDetailPath(match.id),
        };
        context.push(path, extra: match);
      },
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
                      context.appColors.accent.withValues(alpha: 0.08),
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
                    if (isFavourite) ...[
                      Icon(Icons.star_rounded, size: 11, color: context.appColors.accent),
                      const SizedBox(width: 4),
                    ],
                    LivePulseBadge(liveMinute: () => match.liveMinute),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.homeName.toUpperCase(),
                        style: AppTextStyles.mono(
                          13,
                        ).copyWith(color: context.appColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      match.homeScore,
                      style: AppTextStyles.display(
                        22,
                        context,
                      ).copyWith(color: context.appColors.text),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.awayName.toUpperCase(),
                        style: AppTextStyles.mono(
                          13,
                        ).copyWith(color: context.appColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      match.awayScore,
                      style: AppTextStyles.display(22, context).copyWith(
                        color: awayScore > homeScore
                            ? context.appColors.accent
                            : context.appColors.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<SportMatch> _sortByFavourites(
  List<SportMatch> matches,
  Set<String> favNames,
) {
  if (favNames.isEmpty) return matches;
  final fav = <SportMatch>[];
  final rest = <SportMatch>[];
  for (final m in matches) {
    final home = m.homeName.toLowerCase();
    final away = m.awayName.toLowerCase();
    if (favNames.any((n) => n.isNotEmpty && (home.contains(n) || away.contains(n)))) {
      fav.add(m);
    } else {
      rest.add(m);
    }
  }
  return [...fav, ...rest];
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
