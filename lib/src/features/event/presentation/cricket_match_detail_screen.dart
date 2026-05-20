import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/cricket_status.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/cricket_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/arena_stat_bar.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class CricketMatchDetailScreen extends ConsumerStatefulWidget {
  const CricketMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<CricketMatchDetailScreen> createState() => _CricketMatchDetailScreenState();
}

class _CricketMatchDetailScreenState extends SportDetailScaffoldState<CricketMatchDetailScreen> {
  @override
  String get matchId => widget.matchId;

  @override
  SportType get sportType => SportType.cricket;

  @override
  Duration get eventsRefreshInterval => const Duration(seconds: 5);

  @override
  (String?, int?) watchDetail() {
    final v =
        ref.watch(matchDetailProvider(sport: SportType.cricket, matchId: matchId)).valueOrNull
            as CricketMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(
    BuildContext context, {
    String? leagueName,
    int? matchTimestamp,
  }) =>
      _CricketMatchHeader(
        matchId: matchId,
        leagueName: leagueName,
        matchTimestamp: matchTimestamp,
      );

  @override
  List<Tab> buildTabs(BuildContext context) => [
    Tab(text: 'event.cricket.detail.score'.tr()),
    Tab(text: 'event.cricket.detail.stats'.tr()),
    Tab(text: 'event.cricket.detail.situation'.tr()),
  ];

  @override
  List<Widget> buildTabViews(BuildContext context) => [
    _ScoreTab(matchId: matchId),
    _StatsTab(matchId: matchId),
    _SituationTab(matchId: matchId),
  ];
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _CricketMatchHeader extends ConsumerWidget {
  const _CricketMatchHeader({
    required this.matchId,
    this.leagueName,
    this.matchTimestamp,
  });

  final String matchId;
  final String? leagueName;
  final int? matchTimestamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.cricket, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.cricket,
      ).select((map) => map[matchId] as CricketRealtimeData?),
    );

    return SportDetailHeaderShell<CricketMatchDetail>(
      detailAsync: detailAsync,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      skeletonHeight: 80,
      builder: (detail) => _CricketHeaderContent(detail: detail, rt: rt),
    );
  }
}

class _CricketHeaderContent extends StatelessWidget {
  const _CricketHeaderContent({required this.detail, this.rt});

  final CricketMatchDetail detail;
  final CricketRealtimeData? rt;

  String _formatOvers(double overs) {
    final str = overs.toString();
    return str.contains('.') ? str : '$str.0';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effStatusId = rt?.statusId ?? detail.statusId;

    final innings = rt?.innings ?? detail.innings;
    final homeInnings = innings.where((i) => i.team == 1).lastOrNull;
    final awayInnings = innings.where((i) => i.team == 2).lastOrNull;

    final isNotStarted = effStatusId == 1;
    const liveStatuses = {2, 3, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545};
    final isLive = liveStatuses.contains(effStatusId);
    final statusLabel = cricketStatusLabel(effStatusId, detail.statusDescription);
    final statusColor = isLive ? colors.live : colors.text3;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home team
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SportLogo(url: detail.homeInfo.logo, size: 52),
                  const SizedBox(height: 6),
                  Text(
                    detail.homeName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(12, context).copyWith(color: colors.text),
                  ),
                ],
              ),
            ),
            // Centre: status + score
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        color: const Color(0xFF0E0E0E),
                        letterSpacing: 0.1 * 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isNotStarted)
                    Text(
                      '–  –',
                      style: AppTextStyles.display(40, context).copyWith(color: colors.text3),
                    )
                  else if (homeInnings != null && awayInnings != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${homeInnings.runs}/${homeInnings.wickets}',
                          style: AppTextStyles.display(26, context).copyWith(color: colors.text),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: AppTextStyles.display(26, context).copyWith(color: colors.text3),
                          ),
                        ),
                        Text(
                          '${awayInnings.runs}/${awayInnings.wickets}',
                          style: AppTextStyles.display(26, context).copyWith(color: colors.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(${_formatOvers(homeInnings.overs)}) · (${_formatOvers(awayInnings.overs)})',
                      style: AppTextStyles.mono(10).copyWith(color: colors.text3),
                    ),
                  ] else
                    Text(
                      '–  –',
                      style: AppTextStyles.display(40, context).copyWith(color: colors.text3),
                    ),
                ],
              ),
            ),
            // Away team
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SportLogo(url: detail.awayInfo.logo, size: 52),
                  const SizedBox(height: 6),
                  Text(
                    detail.awayName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(12, context).copyWith(color: colors.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Score Tab ────────────────────────────────────────────────────────────────

class _ScoreTab extends ConsumerWidget {
  const _ScoreTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.cricket, matchId: matchId));
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.cricket, matchId: matchId));

    return detailAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: context.appColors.accent)),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: AppTextStyles.body(13).copyWith(color: context.appColors.text3),
        ),
      ),
      data: (obj) {
        final detail = obj as CricketMatchDetail;
        final ev = eventsAsync.valueOrNull as CricketMatchEventsData?;

        final innings = ev?.innings ?? detail.innings;
        final results = ev?.results ?? detail.results;

        return _CricketScoreContent(detail: detail, innings: innings, results: results);
      },
    );
  }
}

class _CricketScoreContent extends StatelessWidget {
  const _CricketScoreContent({required this.detail, required this.innings, this.results});

  final CricketMatchDetail detail;
  final List<CricketInnings> innings;
  final CricketResults? results;

  String _resultText(BuildContext context) {
    final r = results;
    if (r == null || r.result == 0) return '';
    final winnerName = r.result == 1
        ? detail.homeName
        : r.result == 2
        ? detail.awayName
        : '';
    switch (r.winby) {
      case 1:
        return 'event.cricket.detail.won_by_runs'.tr(
          namedArgs: {'winner': winnerName, 'margin': '${r.margin}'},
        );
      case 2:
        return 'event.cricket.detail.won_by_wickets'.tr(
          namedArgs: {'winner': winnerName, 'margin': '${r.margin}'},
        );
      case 3:
        return 'event.cricket.detail.won_by_innings'.tr(namedArgs: {'winner': winnerName});
      default:
        if (r.result == 3) return 'event.cricket.detail.draw'.tr();
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final resultText = _resultText(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      children: [
        if (resultText.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.accent.withValues(alpha: 0.4), width: 0.5),
            ),
            child: Text(
              resultText,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(13).copyWith(color: colors.accent),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.line, width: 0.5),
          ),
          child: Column(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Expanded(flex: 2, child: SizedBox()),
                    ...[
                      'event.cricket.detail.col_runs'.tr(),
                      'event.cricket.detail.col_wickets'.tr(),
                      'event.cricket.detail.col_overs'.tr(),
                    ].map(
                      (h) => Expanded(
                        child: Text(
                          h.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.mono(9).copyWith(
                            color: colors.text3,
                            letterSpacing: 0.14 * 9,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: colors.line),
              if (innings.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '–',
                    style: AppTextStyles.mono(13).copyWith(color: colors.text3),
                  ),
                )
              else
                ...innings.asMap().entries.map((e) {
                  final idx = e.key;
                  final inning = e.value;
                  final teamLogo = inning.team == 1 ? detail.homeInfo.logo : detail.awayInfo.logo;
                  final teamName = inning.team == 1 ? detail.homeName : detail.awayName;
                  final isLast = idx == innings.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  SportLogo(url: teamLogo, size: 20),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      teamName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body(12).copyWith(color: colors.text2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${inning.runs}',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.mono(13).copyWith(
                                  color: colors.text,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${inning.wickets}',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.mono(13).copyWith(color: colors.text2),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                inning.overs.toStringAsFixed(1),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.mono(13).copyWith(color: colors.text2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast) Divider(height: 1, thickness: 0.5, color: colors.line),
                    ],
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stats Tab ────────────────────────────────────────────────────────────────

class _CricketStats {
  int battingRuns = 0;
  int ballsFaced = 0;
  int fours = 0;
  int sixes = 0;
  int wides = 0;
  int byes = 0;
  int legByes = 0;
  int noBalls = 0;
  int penalty = 0;
  int extra = 0;
}

({_CricketStats home, _CricketStats away}) _computeCricketStats(
  List<CricketInnings> innings,
  List<CricketInningPlayerStats> inningStats,
) {
  final home = _CricketStats();
  final away = _CricketStats();
  for (final stat in inningStats) {
    final idx = stat.inning - 1;
    if (idx < 0 || idx >= innings.length) continue;
    final battingTeam = innings[idx].team;
    final batting = battingTeam == 1 ? home : away;
    final bowling = battingTeam == 1 ? away : home;
    batting.battingRuns += stat.batting.runs;
    batting.ballsFaced += stat.batting.ballsFaced;
    batting.fours += stat.batting.fours;
    batting.sixes += stat.batting.sixes;
    bowling.wides += stat.bowling.wides;
    bowling.byes += stat.bowling.byes;
    bowling.legByes += stat.bowling.legByes;
    bowling.noBalls += stat.bowling.noBalls;
    bowling.penalty += stat.bowling.penalty;
    bowling.extra += stat.bowling.extra;
  }
  return (home: home, away: away);
}

class _StatsTab extends ConsumerWidget {
  const _StatsTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.cricket, matchId: matchId));
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.cricket, matchId: matchId));

    final ev = eventsAsync.valueOrNull as CricketMatchEventsData?;
    final detail = detailAsync.valueOrNull as CricketMatchDetail?;

    if (ev == null || ev.inningStats.isEmpty) {
      return Center(
        child: Text(
          'event.cricket.detail.no_stats'.tr(),
          style: AppTextStyles.body(13).copyWith(color: context.appColors.text3),
        ),
      );
    }

    final innings = ev.innings.isNotEmpty ? ev.innings : (detail?.innings ?? []);
    final stats = _computeCricketStats(innings, ev.inningStats);

    final battingRows = <(String, int, int)>[
      ('event.cricket.detail.stat_runs', stats.home.battingRuns, stats.away.battingRuns),
      ('event.cricket.detail.stat_balls_faced', stats.home.ballsFaced, stats.away.ballsFaced),
      ('event.cricket.detail.stat_fours', stats.home.fours, stats.away.fours),
      ('event.cricket.detail.stat_sixes', stats.home.sixes, stats.away.sixes),
    ];

    final bowlingRows = <(String, int, int)>[
      ('event.cricket.detail.stat_wides', stats.home.wides, stats.away.wides),
      ('event.cricket.detail.stat_byes', stats.home.byes, stats.away.byes),
      ('event.cricket.detail.stat_leg_byes', stats.home.legByes, stats.away.legByes),
      ('event.cricket.detail.stat_penalty', stats.home.penalty, stats.away.penalty),
      ('event.cricket.detail.stat_no_balls', stats.home.noBalls, stats.away.noBalls),
      ('event.cricket.detail.stat_extra', stats.home.extra, stats.away.extra),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        if (battingRows.isNotEmpty)
          _ArenaStatSection(
            title: 'event.cricket.detail.batting_comparison'.tr(),
            rows: battingRows,
          ),
        if (battingRows.isNotEmpty && bowlingRows.isNotEmpty) const SizedBox(height: 12),
        if (bowlingRows.isNotEmpty)
          _ArenaStatSection(
            title: 'event.cricket.detail.bowling_comparison'.tr(),
            rows: bowlingRows,
          ),
      ],
    );
  }
}

class _ArenaStatSection extends StatelessWidget {
  const _ArenaStatSection({required this.title, required this.rows});

  final String title;
  final List<(String, int, int)> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.display(12, context).copyWith(color: colors.text),
              ),
            ],
          ),
        ),
        ...rows.map((r) => ArenaStatBar(label: r.$1.tr(), home: r.$2, away: r.$3)),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ─── Situation Tab ────────────────────────────────────────────────────────────

class _SituationTab extends ConsumerStatefulWidget {
  const _SituationTab({required this.matchId});

  final String matchId;

  @override
  ConsumerState<_SituationTab> createState() => _SituationTabState();
}

class _SituationTabState extends ConsumerState<_SituationTab> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.cricket, matchId: widget.matchId),
    );
    final ev = eventsAsync.valueOrNull as CricketMatchEventsData?;

    if (eventsAsync.isLoading && ev == null) {
      return Center(child: CircularProgressIndicator(color: colors.accent));
    }

    final timeline = ev?.timeline ?? [];
    if (timeline.isEmpty) {
      return Center(
        child: Text(
          'event.cricket.detail.no_situation'.tr(),
          style: AppTextStyles.body(13).copyWith(color: colors.text3),
        ),
      );
    }

    final validIndex = _selectedIndex.clamp(0, timeline.length - 1);
    final selectedInning = timeline[validIndex];

    final balls = <(int, CricketBall)>[];
    for (final over in selectedInning.overs) {
      for (final ball in over.balls) {
        balls.add((over.overNumber, ball));
      }
    }

    return Column(
      children: [
        Container(
          color: colors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: timeline.asMap().entries.map((e) {
                final isSelected = e.key == validIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.accent : colors.surface2,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(color: colors.line, width: 0.5),
                      ),
                      child: Text(
                        'event.cricket.detail.inning_btn'
                            .tr(namedArgs: {'n': '${e.value.inning}'})
                            .toUpperCase(),
                        style: AppTextStyles.mono(10).copyWith(
                          color: isSelected ? const Color(0xFF0E0E0E) : colors.text2,
                          letterSpacing: 0.1 * 10,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: colors.line),
        Expanded(
          child: balls.isEmpty
              ? Center(
                  child: Text(
                    'event.cricket.detail.no_situation'.tr(),
                    style: AppTextStyles.body(13).copyWith(color: colors.text3),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: balls.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, thickness: 0.5, color: colors.line),
                  itemBuilder: (context, i) {
                    final (overNum, ball) = balls[i];
                    return _BallRow(overNumber: overNum, ball: ball);
                  },
                ),
        ),
      ],
    );
  }
}

class _BallRow extends StatelessWidget {
  const _BallRow({required this.overNumber, required this.ball});

  final int overNumber;
  final CricketBall ball;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final IconData iconData;
    final Color iconColor;
    Color runTextColor = colors.text2;
    String? extraLabel;

    if (ball.isWicket) {
      iconData = Icons.close;
      iconColor = colors.danger;
      runTextColor = colors.danger;
    } else if (ball.extraType == 'WD' ||
        ball.extraType == 'NB' ||
        ball.extraType == 'B' ||
        ball.extraType == 'LB') {
      iconData = Icons.add_alert;
      iconColor = colors.live;
      if (ball.extraRuns > 0) {
        extraLabel = '+ ${ball.extraRuns} (${ball.extraType})';
      }
    } else if (ball.runs == 6) {
      iconData = Icons.sports_cricket;
      iconColor = colors.accent;
      runTextColor = colors.accent;
    } else if (ball.runs == 4) {
      iconData = Icons.square_foot;
      iconColor = colors.text;
      runTextColor = colors.text;
    } else if (ball.runs > 0) {
      iconData = Icons.directions_run;
      iconColor = colors.text2;
    } else {
      iconData = Icons.sports_cricket;
      iconColor = colors.text3;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '$overNumber.${ball.ballNumber}',
              style: AppTextStyles.mono(13).copyWith(color: colors.text),
            ),
          ),
          Icon(iconData, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(
            'event.cricket.detail.ball_runs'.tr(namedArgs: {'n': '${ball.runs}'}),
            style: AppTextStyles.mono(13).copyWith(color: runTextColor),
          ),
          if (extraLabel != null) ...[
            const SizedBox(width: 6),
            Text(
              extraLabel,
              style: AppTextStyles.mono(12).copyWith(color: colors.live),
            ),
          ],
        ],
      ),
    );
  }
}
