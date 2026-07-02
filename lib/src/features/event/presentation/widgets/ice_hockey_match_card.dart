import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/features/event/domain/ice_hockey_status.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/ice_hockey_match.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/ice_hockey_realtime_data.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/event/domain/set_score_utils.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/match_card_header.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/match_card_shell.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';
import 'package:shenghaotiyu/src/shared_widgets/sport_logo.dart';

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
    final statusLabel = iceHockeyStatusLabel(
      effectiveStatusId,
      match.statusDescription,
    );
    final isLive = _liveStatuses.contains(effectiveStatusId);
    final isNotStarted = effectiveStatusId == 1;

    // Determine active period (live period = last set index)
    final activePeriod = isLive && effectiveHomeSets.isNotEmpty
        ? effectiveHomeSets.length - 1
        : -1;

    // Pad to 4 columns: P1, P2, P3, OT
    final homePeriods = List<int?>.generate(
      4,
      (i) => i < effectiveHomeSets.length ? effectiveHomeSets[i] : null,
    );
    final awayPeriods = List<int?>.generate(
      4,
      (i) => i < effectiveAwaySets.length ? effectiveAwaySets[i] : null,
    );

    return MatchCardShell(
      onTap: () => context.push(AppRoutes.iceHockeyMatchDetailPath(match.id)),
      child: Column(
        children: [
          MatchCardHeader(
            leagueLogo: match.leagueLogo,
            leagueName: match.leagueName,
            matchTime: match.matchTimeSim,
          ),
          const SizedBox(height: 12),
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
            _NotStartedTeamRow(
              logo: match.homeLogo,
              name: match.homeName,
              context: context,
            ),
            const SizedBox(height: 6),
            _NotStartedTeamRow(
              logo: match.awayLogo,
              name: match.awayName,
              context: context,
            ),
          ],
          // Status badge
          if (statusLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            SportStatusBadge(label: statusLabel, isLive: isLive),
          ],
        ],
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
        Spacer(),
        ...List.generate(_labels.length, (i) {
          final isActive = i == activePeriod;
          return _GridCell(
            child: Text(
              _labels[i],
              style: AppTextStyles.mono(9).copyWith(
                color: isActive
                    ? context.appColors.accent
                    : context.appColors.text3,
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
        Expanded(
          child: Row(
            children: [
              SportLogo(url: logo, size: 24, circular: true),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.mono(
                    11,
                  ).copyWith(color: context.appColors.text2),
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
                    : (score != null
                          ? context.appColors.text2
                          : context.appColors.text3),
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

class _NotStartedTeamRow extends StatelessWidget {
  const _NotStartedTeamRow({
    required this.logo,
    required this.name,
    required this.context,
  });
  final String logo;
  final String name;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: [
        SportLogo(url: logo, size: 24, circular: true),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.mono(
              11,
            ).copyWith(color: context.appColors.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 22,
          child: Text(
            '-',
            textAlign: TextAlign.center,
            style: AppTextStyles.display(
              20,
              context,
            ).copyWith(color: context.appColors.text3),
          ),
        ),
      ],
    );
  }
}
