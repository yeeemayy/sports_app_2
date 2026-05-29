import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/event/domain/cricket_status.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_match.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_card_header.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_card_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_status_badge.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

// Design: "INNINGS" — portrait face-off with prominent innings data.
// [logo 40px] ← (center) → [logo 40px]
// [name]    [score runs/wkts]   [name]
//           [overs below]

class CricketMatchCard extends ConsumerWidget {
  const CricketMatchCard({super.key, required this.match});

  final CricketMatch match;

  static const _liveStatuses = {
    2,
    3,
    532,
    533,
    534,
    535,
    536,
    537,
    538,
    539,
    540,
    541,
    542,
    543,
    544,
    545,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.cricket,
      ).select((map) => map[match.id] as CricketRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? match.statusId;
    final effectiveHomeScore = rt?.homeScore.toString() ?? match.homeScore;
    final effectiveAwayScore = rt?.awayScore.toString() ?? match.awayScore;
    final statusLabel = cricketStatusLabel(
      effectiveStatusId,
      match.statusDescription,
    );
    final isLive = _liveStatuses.contains(effectiveStatusId);
    final innings = rt?.innings ?? match.innings;
    final homeInnings = innings.where((i) => i.team == 1).lastOrNull;
    final awayInnings = innings.where((i) => i.team == 2).lastOrNull;

    String homeDisplay = effectiveHomeScore;
    String awayDisplay = effectiveAwayScore;
    String? homeOvers;
    String? awayOvers;

    if (homeInnings != null) {
      homeDisplay = '${homeInnings.runs}/${homeInnings.wickets}';
      homeOvers = _formatOvers(homeInnings.overs);
    }
    if (awayInnings != null) {
      awayDisplay = '${awayInnings.runs}/${awayInnings.wickets}';
      awayOvers = _formatOvers(awayInnings.overs);
    }

    return MatchCardShell(
      onTap: () => context.push(AppRoutes.cricketMatchDetailPath(match.id)),
      child: Column(
        children: [
          MatchCardHeader(
            leagueLogo: match.leagueLogo,
            leagueName: match.leagueName,
            matchTime: match.matchTimeSim,
          ),
          const SizedBox(height: 12),
          // Face-off row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Home team
              Expanded(
                child: Column(
                  children: [
                    SportLogo(url: match.homeLogo, size: 40, circular: true),
                    const SizedBox(height: 6),
                    Text(
                      match.homeName,
                      style: AppTextStyles.mono(
                        11,
                      ).copyWith(color: context.appColors.text2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Center score column
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Home innings score
                    Text(
                      homeDisplay,
                      style: AppTextStyles.display(18, context).copyWith(
                        color: isLive
                            ? context.appColors.accent
                            : context.appColors.text,
                      ),
                    ),
                    if (homeOvers != null)
                      Text(
                        '($homeOvers ov)',
                        style: AppTextStyles.mono(
                          9,
                        ).copyWith(color: context.appColors.text3),
                      ),
                    const SizedBox(height: 6),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: context.appColors.line,
                    ),
                    const SizedBox(height: 6),
                    // Away innings score
                    Text(
                      awayDisplay,
                      style: AppTextStyles.display(18, context).copyWith(
                        color: isLive
                            ? context.appColors.accent
                            : context.appColors.text,
                      ),
                    ),
                    if (awayOvers != null)
                      Text(
                        '($awayOvers ov)',
                        style: AppTextStyles.mono(
                          9,
                        ).copyWith(color: context.appColors.text3),
                      ),
                    const SizedBox(height: 8),
                    SportStatusBadge(label: statusLabel, isLive: isLive),
                  ],
                ),
              ),
              // Away team
              Expanded(
                child: Column(
                  children: [
                    SportLogo(url: match.awayLogo, size: 40, circular: true),
                    const SizedBox(height: 6),
                    Text(
                      match.awayName,
                      style: AppTextStyles.mono(
                        11,
                      ).copyWith(color: context.appColors.text2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatOvers(double overs) {
    final str = overs.toString();
    return str.contains('.') ? str : '$str.0';
  }
}
