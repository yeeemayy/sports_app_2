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
  Widget buildHeader(BuildContext context) => _CricketMatchHeader(matchId: matchId);

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
  const _CricketMatchHeader({required this.matchId});

  final String matchId;

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
    final effStatusId = rt?.statusId ?? detail.statusId;
    final homeScore = rt?.homeScore.toString() ?? '-';
    final awayScore = rt?.awayScore.toString() ?? '-';

    final innings = rt?.innings ?? detail.innings;
    final homeInnings = innings.where((i) => i.team == 1).lastOrNull;
    final awayInnings = innings.where((i) => i.team == 2).lastOrNull;

    final isNotStarted = effStatusId == 1;
    const liveStatuses = {
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
    final isLive = liveStatuses.contains(effStatusId);
    final statusLabel = cricketStatusLabel(effStatusId, detail.statusDescription);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              _TeamLogo(url: detail.homeInfo.logo, size: 48),
              const SizedBox(height: 6),
              Text(
                detail.homeName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLive)
                _BlinkingLiveIndicator(label: statusLabel)
              else
                Text(
                  statusLabel.isNotEmpty ? statusLabel : 'common.unknown'.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              if (isNotStarted)
                Text(
                  '-',
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.w900,
                  ),
                )
              else ...[
                if (homeInnings != null && awayInnings != null) ...[
                  RichText(
                    text: TextSpan(
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: '${homeInnings.runs}/${homeInnings.wickets}'),
                        const TextSpan(text: ' - '),
                        TextSpan(text: '${awayInnings.runs}/${awayInnings.wickets}'),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: context.textTheme.labelSmall?.copyWith(color: Colors.white70),
                      children: [
                        TextSpan(text: '(${_formatOvers(homeInnings.overs)})'),
                        const TextSpan(text: ' - '),
                        TextSpan(text: '(${_formatOvers(awayInnings.overs)})'),
                      ],
                    ),
                  ),
                ] else
                  RichText(
                    text: TextSpan(
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: homeScore),
                        const TextSpan(text: ' - '),
                        TextSpan(text: awayScore),
                      ],
                    ),
                  ),
                if (isLive)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    constraints: const BoxConstraints(minWidth: 50),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusLabel.isNotEmpty ? Colors.orange : Colors.white,
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel.isNotEmpty ? statusLabel : 'common.unknown'.tr(),
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
                    ),
                  ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _TeamLogo(url: detail.awayInfo.logo, size: 48),
              const SizedBox(height: 6),
              Text(
                detail.awayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: ClipOval(
        child: SportLogo(url: url, size: size),
      ),
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
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: Colors.grey.shade500)),
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
    final resultText = _resultText(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        if (resultText.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryShade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryShade200),
            ),
            child: Text(
              resultText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'R',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'W',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Ov',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
              if (innings.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('-', style: TextStyle(color: Colors.grey.shade500)),
                )
              else
                ...innings.asMap().entries.map((e) {
                  final idx = e.key;
                  final inning = e.value;
                  final teamLogo = inning.team == 1 ? detail.homeInfo.logo : detail.awayInfo.logo;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  SportLogo(url: teamLogo, size: 18),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      inning.team == 1 ? detail.homeName : detail.awayName,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${inning.runs}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${inning.wickets}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                inning.overs.toStringAsFixed(1),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),
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
    // innings[idx].team: 1 = home batting, 2 = away batting
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
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    final innings = ev.innings.isNotEmpty ? ev.innings : (detail?.innings ?? []);
    final stats = _computeCricketStats(innings, ev.inningStats);

    List<_StatRow> buildRows(List<(String, int, int)> candidates) => candidates
        // .where((r) => r.$2 > 0 || r.$3 > 0)
        .map((r) => _StatRow(label: r.$1.tr(), home: r.$2, away: r.$3))
        .toList();

    final battingRows = buildRows([
      ('event.cricket.detail.stat_runs', stats.home.battingRuns, stats.away.battingRuns),
      ('event.cricket.detail.stat_balls_faced', stats.home.ballsFaced, stats.away.ballsFaced),
      ('event.cricket.detail.stat_fours', stats.home.fours, stats.away.fours),
      ('event.cricket.detail.stat_sixes', stats.home.sixes, stats.away.sixes),
    ]);

    final bowlingRows = buildRows([
      ('event.cricket.detail.stat_wides', stats.home.wides, stats.away.wides),
      ('event.cricket.detail.stat_byes', stats.home.byes, stats.away.byes),
      ('event.cricket.detail.stat_leg_byes', stats.home.legByes, stats.away.legByes),
      ('event.cricket.detail.stat_penalty', stats.home.penalty, stats.away.penalty),
      ('event.cricket.detail.stat_no_balls', stats.home.noBalls, stats.away.noBalls),
      ('event.cricket.detail.stat_extra', stats.home.extra, stats.away.extra),
    ]);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        if (battingRows.isNotEmpty)
          _StatSection(title: 'event.cricket.detail.batting_comparison'.tr(), rows: battingRows),
        if (battingRows.isNotEmpty && bowlingRows.isNotEmpty) const SizedBox(height: 12),
        if (bowlingRows.isNotEmpty)
          _StatSection(title: 'event.cricket.detail.bowling_comparison'.tr(), rows: bowlingRows),
      ],
    );
  }
}

class _StatSection extends StatelessWidget {
  const _StatSection({required this.title, required this.rows});

  final String title;
  final List<_StatRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          ...rows,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.home, required this.away});

  final String label;
  final int home;
  final int away;

  @override
  Widget build(BuildContext context) {
    int total = home + away;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  home.toString(),
                  style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  away.toString(),
                  style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              const barHeight = 6.0;
              const radius = Radius.circular(3);
              if (total <= 0) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(height: barHeight, color: Colors.grey.shade200),
                );
              }
              final halfWidth = constraints.maxWidth / 2;
              final homeWidth = halfWidth * (home / total);
              final awayWidth = halfWidth * (away / total);
              return ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: barHeight,
                  color: Colors.grey.shade200,
                  child: Row(
                    children: [
                      SizedBox(
                        width: halfWidth,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: homeWidth,
                            height: barHeight,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(topLeft: radius, bottomLeft: radius),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: halfWidth,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: awayWidth,
                            height: barHeight,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.only(
                                topRight: radius,
                                bottomRight: radius,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.cricket, matchId: widget.matchId),
    );
    final ev = eventsAsync.valueOrNull as CricketMatchEventsData?;

    if (eventsAsync.isLoading && ev == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final timeline = ev?.timeline ?? [];
    if (timeline.isEmpty) {
      return Center(
        child: Text(
          'event.cricket.detail.no_situation'.tr(),
          style: TextStyle(color: Colors.grey.shade500),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: timeline.asMap().entries.map((e) {
              final isSelected = e.key == validIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'event.cricket.detail.inning_btn'.tr(namedArgs: {'n': '${e.value.inning}'}),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: balls.isEmpty
              ? Center(
                  child: Text(
                    'event.cricket.detail.no_situation'.tr(),
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: balls.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
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
    final IconData iconData;
    final Color iconColor;
    Color runTextColor = Colors.grey.shade700;
    String? extraLabel; // e.g. "+ 1 (WD)"

    if (ball.isWicket) {
      iconData = Icons.close;
      iconColor = Colors.red;
    } else if (ball.extraType == 'WD' ||
        ball.extraType == 'NB' ||
        ball.extraType == 'B' ||
        ball.extraType == 'LB') {
      iconData = Icons.add_alert;
      iconColor = Colors.orange;
      if (ball.extraRuns > 0) {
        extraLabel = '+ ${ball.extraRuns} (${ball.extraType})';
      }
    } else if (ball.runs == 6) {
      iconData = Icons.sports_cricket;
      iconColor = Colors.purple.shade600;
      runTextColor = Colors.purple.shade600;
    } else if (ball.runs == 4) {
      iconData = Icons.square_foot;
      iconColor = Colors.green.shade600;
      runTextColor = Colors.green.shade600;
    } else if (ball.runs > 0) {
      iconData = Icons.directions_run;
      iconColor = AppColors.primary;
    } else {
      iconData = Icons.sports_cricket;
      iconColor = Colors.grey.shade400;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '$overNumber.${ball.ballNumber}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          Icon(iconData, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Text(
            'event.cricket.detail.ball_runs'.tr(namedArgs: {'n': '${ball.runs}'}),
            style: TextStyle(fontSize: 14, color: runTextColor),
          ),
          if (extraLabel != null) ...[
            const SizedBox(width: 6),
            Text(
              extraLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Blinking Live Indicator ──────────────────────────────────────────────────

class _BlinkingLiveIndicator extends StatefulWidget {
  const _BlinkingLiveIndicator({required this.label});

  final String label;

  @override
  State<_BlinkingLiveIndicator> createState() => _BlinkingLiveIndicatorState();
}

class _BlinkingLiveIndicatorState extends State<_BlinkingLiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, _) => Opacity(
          opacity: _opacity.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: AppColors.primaryShade50, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryShade50,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
