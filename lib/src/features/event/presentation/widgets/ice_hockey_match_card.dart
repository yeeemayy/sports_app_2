import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/event/domain/ice_hockey_status.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_match.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/set_score_utils.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

// Design: "PERIOD GRID" — a compact scoreboard grid showing period-by-period scores.
// Header: [team col] | [P1] | [P2] | [P3] | [OT] | [T]
// Each team row: [logo abbr] | [pp] | [pp] | [pp] | [pp] | [total Anton]
// Current period column is accent-tinted. Status badge below.

class IceHockeyMatchCard extends ConsumerWidget {
  const IceHockeyMatchCard({super.key, required this.match});

  final IceHockeyMatch match;

  static const _liveStatuses = {30, 331, 31, 332, 32, 6, 10, 8, 13};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.iceHockey,
      ).select((map) => map[match.id] as IceHockeyRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeSets = rt?.homeSets ?? extractSetScores(match.scores, 0);
    final effectiveAwaySets = rt?.awaySets ?? extractSetScores(match.scores, 1);
    final effectiveHomeScore = rt?.homeScore.toString() ?? match.homeScore;
    final effectiveAwayScore = rt?.awayScore.toString() ?? match.awayScore;
    final statusLabel = iceHockeyStatusLabel(effectiveStatusId, match.statusDescription);
    final isLive = _liveStatuses.contains(effectiveStatusId);
    final isNotStarted = effectiveStatusId == 1;

    // Determine active period (live period = last set index)
    final activePeriod = isLive && effectiveHomeSets.isNotEmpty
        ? effectiveHomeSets.length - 1
        : -1;

    // Pad to 4 columns: P1, P2, P3, OT
    final homePeriods = List<int?>.generate(4, (i) =>
        i < effectiveHomeSets.length ? effectiveHomeSets[i] : null);
    final awayPeriods = List<int?>.generate(4, (i) =>
        i < effectiveAwaySets.length ? effectiveAwaySets[i] : null);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Ink(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          border: Border.all(color: context.appColors.line, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: GestureDetector(
          onTap: () => context.push(AppRoutes.iceHockeyMatchDetailPath(match.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
            child: Column(
              children: [
                // League header
                Row(
                  children: [
                    LeagueLogo(url: match.leagueLogo),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        match.leagueName,
                        style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      match.matchTimeSim,
                      style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Grid
                if (!isNotStarted) ...[
                  // Header row
                  _GridHeaderRow(activePeriod: activePeriod),
                  const SizedBox(height: 4),
                  Divider(height: 1, thickness: 0.5, color: context.appColors.line),
                  const SizedBox(height: 6),
                  // Home row
                  _GridTeamRow(
                    logo: match.homeLogo,
                    name: match.homeName,
                    periods: homePeriods,
                    total: effectiveHomeScore,
                    activePeriod: activePeriod,
                    isLive: isLive,
                    context: context,
                  ),
                  const SizedBox(height: 5),
                  // Away row
                  _GridTeamRow(
                    logo: match.awayLogo,
                    name: match.awayName,
                    periods: awayPeriods,
                    total: effectiveAwayScore,
                    activePeriod: activePeriod,
                    isLive: isLive,
                    context: context,
                  ),
                ] else ...[
                  // Not started: face-off header
                  Row(
                    children: [
                      Flexible(child: _TeamLabel(logo: match.homeLogo, name: match.homeName)),
                      const Spacer(),
                      Text(
                        match.matchTimeSim,
                        style: AppTextStyles.display(18, context).copyWith(color: context.appColors.text3),
                      ),
                      const Spacer(),
                      Flexible(child: _TeamLabel(logo: match.awayLogo, name: match.awayName, rightAlign: true)),
                    ],
                  ),
                ],
                // Status badge
                if (statusLabel.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _StatusBadge(label: statusLabel, isLive: isLive),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridHeaderRow extends StatelessWidget {
  const _GridHeaderRow({required this.activePeriod});
  final int activePeriod;

  static const _labels = ['P1', 'P2', 'P3', 'OT'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 90), // team column width
        ...List.generate(_labels.length, (i) {
          final isActive = i == activePeriod;
          return _GridCell(
            child: Text(
              _labels[i],
              style: AppTextStyles.mono(9).copyWith(
                color: isActive ? context.appColors.accent : context.appColors.text3,
              ),
            ),
          );
        }),
        const _GridCell(child: SizedBox(width: 32)), // total column spacer
      ],
    );
  }
}

class _GridTeamRow extends StatelessWidget {
  const _GridTeamRow({
    required this.logo,
    required this.name,
    required this.periods,
    required this.total,
    required this.activePeriod,
    required this.isLive,
    required this.context,
  });

  final String logo;
  final String name;
  final List<int?> periods;
  final String total;
  final int activePeriod;
  final bool isLive;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Row(
            children: [
              SportLogo(url: logo, size: 22, circular: true),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.mono(10).copyWith(color: context.appColors.text2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        ...List.generate(periods.length, (i) {
          final isActive = i == activePeriod;
          final score = periods[i];
          return _GridCell(
            highlight: isActive,
            child: Text(
              score != null ? '$score' : '–',
              style: AppTextStyles.mono(11).copyWith(
                color: isActive
                    ? context.appColors.accent
                    : (score != null ? context.appColors.text2 : context.appColors.text3),
              ),
            ),
          );
        }),
        _GridCell(
          child: Text(
            total,
            style: AppTextStyles.display(18, context).copyWith(
              color: isLive ? context.appColors.accent : context.appColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.child, this.highlight = false});
  final Widget child;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: highlight
          ? BoxDecoration(
              color: context.appColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _TeamLabel extends StatelessWidget {
  const _TeamLabel({required this.logo, required this.name, this.rightAlign = false});
  final String logo;
  final String name;
  final bool rightAlign;

  @override
  Widget build(BuildContext context) {
    final children = [
      SportLogo(url: logo, size: 28, circular: true),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          name,
          style: AppTextStyles.body(11).copyWith(color: context.appColors.text2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: rightAlign ? TextAlign.right : TextAlign.left,
        ),
      ),
    ];
    return Row(children: rightAlign ? children.reversed.toList() : children);
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.isLive});
  final String label;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isLive ? context.appColors.live : context.appColors.surface2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.mono(9).copyWith(
          color: isLive ? context.appColors.ink : context.appColors.text3,
        ),
      ),
    );
  }
}