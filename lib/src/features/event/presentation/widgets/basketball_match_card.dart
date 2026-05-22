import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_card_header.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_card_shell.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

// Design: "BOXSCORE" — dramatic score-first horizontal layout.
// [logo · name] ··· [Anton 36 score] [quarter badge] [Anton 36 score] ··· [name · logo]
// Score highlight animation on update preserved.

class BasketballMatchCard extends ConsumerStatefulWidget {
  const BasketballMatchCard({super.key, required this.match});

  final BasketballMatch match;

  @override
  ConsumerState<BasketballMatchCard> createState() => _BasketballMatchCardState();
}

class _BasketballMatchCardState extends ConsumerState<BasketballMatchCard>
    with TickerProviderStateMixin {
  late final AnimationController _homeCtrl;
  late final AnimationController _awayCtrl;
  late final Animation<Color?> _homeHighlight;
  late final Animation<Color?> _awayHighlight;

  static const _highlightDuration = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _homeCtrl = AnimationController(vsync: this, duration: _highlightDuration, value: 1.0);
    _awayCtrl = AnimationController(vsync: this, duration: _highlightDuration, value: 1.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeHighlight = ColorTween(
      begin: context.appColors.accent.withValues(alpha: 0.25),
      end: Colors.transparent,
    ).animate(CurvedAnimation(parent: _homeCtrl, curve: Curves.easeOut));
    _awayHighlight = ColorTween(
      begin: context.appColors.accent.withValues(alpha: 0.25),
      end: Colors.transparent,
    ).animate(CurvedAnimation(parent: _awayCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _homeCtrl.dispose();
    _awayCtrl.dispose();
    super.dispose();
  }

  void _onRealtimeUpdate(BasketballRealtimeData? prev, BasketballRealtimeData? next) {
    if (next == null || prev == null) return;
    if (next.homeTotal > prev.homeTotal) _homeCtrl.forward(from: 0);
    if (next.awayTotal > prev.awayTotal) _awayCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BasketballRealtimeData?>(
      sportRealtimeProvider(
        SportType.basketball,
      ).select((map) => map[widget.match.id] as BasketballRealtimeData?),
      _onRealtimeUpdate,
    );

    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.basketball,
      ).select((map) => map[widget.match.id] as BasketballRealtimeData?),
    );

    final effectiveStatusId = rt?.statusId ?? widget.match.statusId;
    final effectiveHomeScore = rt != null ? rt.homeTotal.toString() : widget.match.homeScore;
    final effectiveAwayScore = rt != null ? rt.awayTotal.toString() : widget.match.awayScore;
    final effectivePeriodLabel = rt != null
        ? (rt.periodLabelKey.isEmpty ? null : rt.periodLabelKey.tr())
        : widget.match.statusDescription;
    final effectiveClockDisplay = (rt != null && rt.showClock)
        ? rt.clockDisplay
        : widget.match.liveMinute;

    final isLive = effectiveStatusId > 0 && effectiveStatusId < 10;
    final isUpcoming = effectiveStatusId == 1 || effectiveStatusId == 0;
    final scoreColor = isLive ? context.appColors.accent : context.appColors.text;

    return MatchCardShell(
      onTap: () => context.push(AppRoutes.basketballMatchDetailPath(widget.match.id)),
      child: Column(
        children: [
          MatchCardHeader(
            leagueLogo: widget.match.leagueLogo,
            leagueName: widget.match.leagueName,
            matchTime: widget.match.matchTimeSim,
          ),
          const SizedBox(height: 12),
          Center(
            child: _StatusFooter(
              isLive: isLive,
              isUpcoming: isUpcoming,
              periodLabel: effectivePeriodLabel,
              clockDisplay: effectiveClockDisplay,
              context: context,
            ),
          ),
          // Main scoreboard row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Home team
              Expanded(
                child: Column(
                  children: [
                    SportLogo(url: widget.match.homeLogo, size: 32, circular: true),
                    const SizedBox(height: 5),
                    Text(
                      widget.match.homeName,
                      style: AppTextStyles.mono(11).copyWith(color: context.appColors.text2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Scores + hyphen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _homeHighlight,
                      builder: (_, child) => Container(
                        width: 52,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: _homeHighlight.value,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: child,
                      ),
                      child: Text(
                        isUpcoming ? '-' : effectiveHomeScore,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display(36, context).copyWith(color: scoreColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '–',
                      style: AppTextStyles.display(
                        22,
                        context,
                      ).copyWith(color: context.appColors.text3),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _awayHighlight,
                      builder: (_, child) => Container(
                        width: 52,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: _awayHighlight.value,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: child,
                      ),
                      child: Text(
                        isUpcoming ? '-' : effectiveAwayScore,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display(36, context).copyWith(color: scoreColor),
                      ),
                    ),
                  ],
                ),
              ),
              // Away team
              Expanded(
                child: Column(
                  children: [
                    SportLogo(url: widget.match.awayLogo, size: 32, circular: true),
                    const SizedBox(height: 5),
                    Text(
                      widget.match.awayName,
                      style: AppTextStyles.mono(11).copyWith(color: context.appColors.text2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Status footer
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatusFooter extends StatelessWidget {
  const _StatusFooter({
    required this.isLive,
    required this.isUpcoming,
    required this.periodLabel,
    required this.clockDisplay,
    required this.context,
  });

  final bool isLive;
  final bool isUpcoming;
  final String? periodLabel;
  final String? clockDisplay;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    if (isLive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (periodLabel != null && periodLabel!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.appColors.live,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                periodLabel!,
                style: AppTextStyles.mono(9).copyWith(color: context.appColors.ink),
              ),
            ),
          if (clockDisplay != null && clockDisplay != '0' && clockDisplay!.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              clockDisplay!,
              style: AppTextStyles.mono(10).copyWith(color: context.appColors.accent),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isUpcoming ? 'event.status.upcoming'.tr() : 'event.status.finished'.tr(),
          style: AppTextStyles.mono(9).copyWith(color: context.appColors.text3),
        ),
      ],
    );
  }
}
