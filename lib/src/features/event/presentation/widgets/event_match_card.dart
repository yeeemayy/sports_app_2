import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match.dart';
import 'package:sports_app/src/features/event/domain/models/football_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/table_tennis_match.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match.dart';
import 'package:sports_app/src/features/event/presentation/widgets/badminton_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/baseball_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/basketball_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/football_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/table_tennis_match_card.dart';
import 'package:sports_app/src/features/event/presentation/widgets/tennis_match_card.dart';
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
    return _DefaultMatchCard(match: match);
  }
}

class _DefaultMatchCard extends StatelessWidget {
  const _DefaultMatchCard({required this.match});

  final SportMatch match;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
                      color: Colors.grey.shade700,
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
                      _MatchScore(
                        homeScore: match.homeScore,
                        awayScore: match.awayScore,
                        statusId: match.statusId,
                      ),
                      const SizedBox(height: 6),
                      _StatusBadge(
                        statusId: match.statusId,
                        statusDescription: match.statusDescription,
                        matchTimeSim: match.matchTimeSim,
                      ),
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

class _MatchScore extends StatelessWidget {
  const _MatchScore({
    required this.homeScore,
    required this.awayScore,
    required this.statusId,
  });

  final String homeScore;
  final String awayScore;
  final int statusId;

  bool get _isLive => statusId > 0 && statusId < 100;

  @override
  Widget build(BuildContext context) {
    if (statusId == 0) {
      return Text(
        '-',
        style: context.textTheme.titleMedium?.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final scoreColor = _isLive ? Colors.pink : Colors.black87;
    return RichText(
      text: TextSpan(
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: scoreColor,
        ),
        children: [
          TextSpan(text: homeScore),
          TextSpan(
            text: ' - ',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          TextSpan(text: awayScore),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.statusId,
    required this.statusDescription,
    required this.matchTimeSim,
  });

  final int statusId;
  final String? statusDescription;
  final String matchTimeSim;

  bool get _isLive => statusId > 0 && statusId < 100;
  bool get _isUpcoming => statusId == 0;

  @override
  Widget build(BuildContext context) {
    if (_isUpcoming) {
      return Text(
        matchTimeSim,
        style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
      );
    }

    final isLive = _isLive;
    final label = isLive
        ? (statusDescription?.isNotEmpty == true ? statusDescription! : 'event.status.live'.tr())
        : 'event.status.finished'.tr();
    final bgColor = isLive ? Colors.pink.shade50 : Colors.orange.shade50;
    final textColor = isLive ? Colors.pink : Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}