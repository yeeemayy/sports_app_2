import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/am_football_match.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_match.dart';
import 'package:sports_app/src/features/event/domain/models/football_match.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/table_tennis_match.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match.dart';
import 'package:sports_app/src/features/event/domain/models/volleyball_match.dart';
import 'package:sports_app/src/features/event/presentation/widgets/am_football_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/badminton_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/baseball_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/basketball_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/cricket_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/football_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/ice_hockey_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/table_tennis_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/tennis_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/volleyball_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_score_display.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class EventMatchCard extends StatelessWidget {
  const EventMatchCard({super.key, required this.match});

  final SportMatch match;

  @override
  Widget build(BuildContext context) {
    if (match is FootballMatch) return FootballMatchCard(match: match as FootballMatch);
    if (match is BasketballMatch) return BasketballMatchCard(match: match as BasketballMatch);
    if (match is TennisMatch) return TennisMatchCard(match: match as TennisMatch);
    if (match is BadmintonMatch) return BadmintonMatchCard(match: match as BadmintonMatch);
    if (match is TableTennisMatch) return TableTennisMatchCard(match: match as TableTennisMatch);
    if (match is BaseballMatch) return BaseballMatchCard(match: match as BaseballMatch);
    if (match is VolleyballMatch) return VolleyballMatchCard(match: match as VolleyballMatch);
    if (match is IceHockeyMatch) return IceHockeyMatchCard(match: match as IceHockeyMatch);
    if (match is AmFootballMatch) return AmFootballMatchCard(match: match as AmFootballMatch);
    if (match is CricketMatch) return CricketMatchCard(match: match as CricketMatch);
    return _DefaultMatchCard(match: match);
  }
}

class _DefaultMatchCard extends StatelessWidget {
  const _DefaultMatchCard({required this.match});

  final SportMatch match;

  @override
  Widget build(BuildContext context) {
    final isLive = match.statusId > 0 && match.statusId < 100;
    final statusLabel = isLive
        ? (match.statusDescription?.isNotEmpty == true
            ? match.statusDescription!
            : 'event.status.live'.tr())
        : match.statusId == 0
            ? match.matchTimeSim
            : 'event.status.finished'.tr();

    return Container(
      child: Column(
        children: [
          // League header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Row(
              children: [
                LeagueLogo(url: match.leagueLogo),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    match.leagueName,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.appColors.text2,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  match.matchTimeSim,
                  style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Match body
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Home team
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SportLogo(url: match.homeLogo, size: 48, circular: true),
                      const SizedBox(height: 4),
                      Text(
                        match.homeName,
                        style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Centre: score + status badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MatchScoreDisplay(
                        homeScore: match.homeScore,
                        awayScore: match.awayScore,
                        isNotStarted: match.statusId == 0,
                        isLive: isLive,
                      ),
                      const SizedBox(height: 6),
                      SportStatusBadge(label: statusLabel, isLive: isLive),
                    ],
                  ),
                ),
                // Away team
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SportLogo(url: match.awayLogo, size: 48, circular: true),
                      const SizedBox(height: 4),
                      Text(
                        match.awayName,
                        style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}

