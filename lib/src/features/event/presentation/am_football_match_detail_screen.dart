import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/am_football_status.dart';
import 'package:sports_app/src/features/event/domain/models/am_football_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/am_football_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/am_football_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AmFootballMatchDetailScreen extends ConsumerStatefulWidget {
  const AmFootballMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<AmFootballMatchDetailScreen> createState() =>
      _AmFootballMatchDetailScreenState();
}

class _AmFootballMatchDetailScreenState
    extends SportDetailScaffoldState<AmFootballMatchDetailScreen> {
  @override
  String get matchId => widget.matchId;

  @override
  SportType get sportType => SportType.amFootball;

  @override
  Duration get eventsRefreshInterval => const Duration(seconds: 5);

  @override
  (String?, int?) watchDetail() {
    final v = ref
        .watch(matchDetailProvider(sport: SportType.amFootball, matchId: matchId))
        .valueOrNull as AmFootballMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(BuildContext context) =>
      _AmFootballMatchHeader(matchId: matchId);

  @override
  List<Tab> buildTabs(BuildContext context) => [
        Tab(text: 'event.am_football.detail.score'.tr()),
        Tab(text: 'event.am_football.detail.stats'.tr()),
        Tab(text: 'event.am_football.detail.events'.tr()),
      ];

  @override
  List<Widget> buildTabViews(BuildContext context) => [
        _ScoreTab(matchId: matchId),
        _StatsTab(matchId: matchId),
        _EventsTab(matchId: matchId),
      ];
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _AmFootballMatchHeader extends ConsumerWidget {
  const _AmFootballMatchHeader({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(matchDetailProvider(sport: SportType.amFootball, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.amFootball)
          .select((map) => map[matchId] as AmFootballRealtimeData?),
    );

    return Container(
      width: double.maxFinite,
      color: Colors.pink,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: detailAsync.when(
        loading: () => const SizedBox(height: 80),
        error: (_, __) => const SizedBox(height: 80),
        data: (obj) {
          final detail = obj as AmFootballMatchDetail;
          return _AmFootballHeaderContent(detail: detail, rt: rt);
        },
      ),
    );
  }
}

class _AmFootballHeaderContent extends StatelessWidget {
  const _AmFootballHeaderContent({required this.detail, this.rt});

  final AmFootballMatchDetail detail;
  final AmFootballRealtimeData? rt;

  @override
  Widget build(BuildContext context) {
    final effStatusId = rt?.statusId ?? detail.statusId;
    final homeScore = rt?.homeScore.toString() ?? detail.homeScore;
    final awayScore = rt?.awayScore.toString() ?? detail.awayScore;

    final isNotStarted = effStatusId == 1;
    const liveStatuses = {44, 45, 46, 47, 10};
    final isLive = liveStatuses.contains(effStatusId);
    final statusLabel = amFootballStatusLabel(effStatusId, detail.statusDescription);

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
              if (isLive) _BlinkingLiveIndicator(label: statusLabel),
              if (isNotStarted)
                Text(
                  '-',
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.w900,
                  ),
                )
              else ...[
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
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  constraints: const BoxConstraints(minWidth: 50),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusLabel.isNotEmpty
                        ? Colors.orange
                        : Colors.white,
                    border: Border.all(color: Colors.deepOrange.shade300),
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
      child: ClipOval(child: SportLogo(url: url, size: size)),
    );
  }
}

// ─── Score Tab ────────────────────────────────────────────────────────────────

class _ScoreTab extends ConsumerWidget {
  const _ScoreTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(matchDetailProvider(sport: SportType.amFootball, matchId: matchId));
    final eventsAsync =
        ref.watch(matchEventsProvider(sport: SportType.amFootball, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.amFootball)
          .select((map) => map[matchId] as AmFootballRealtimeData?),
    );

    return detailAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(),
            style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final detail = obj as AmFootballMatchDetail;
        final ev = eventsAsync.valueOrNull as AmFootballMatchEventsData?;

        final homeP1 = ev?.homeP1 ?? rt?.homeP1 ?? _p(detail.scores, 'p1', 0);
        final awayP1 = ev?.awayP1 ?? rt?.awayP1 ?? _p(detail.scores, 'p1', 1);
        final homeP2 = ev?.homeP2 ?? rt?.homeP2 ?? _p(detail.scores, 'p2', 0);
        final awayP2 = ev?.awayP2 ?? rt?.awayP2 ?? _p(detail.scores, 'p2', 1);
        final homeP3 = ev?.homeP3 ?? rt?.homeP3 ?? _p(detail.scores, 'p3', 0);
        final awayP3 = ev?.awayP3 ?? rt?.awayP3 ?? _p(detail.scores, 'p3', 1);
        final homeP4 = ev?.homeP4 ?? rt?.homeP4 ?? _p(detail.scores, 'p4', 0);
        final awayP4 = ev?.awayP4 ?? rt?.awayP4 ?? _p(detail.scores, 'p4', 1);
        final homeOt = ev?.homeOt ?? rt?.homeOt ?? _p(detail.scores, 'ot', 0);
        final awayOt = ev?.awayOt ?? rt?.awayOt ?? _p(detail.scores, 'ot', 1);
        final homeTotal = ev?.homeScore ?? rt?.homeScore ?? int.tryParse(detail.homeScore) ?? 0;
        final awayTotal = ev?.awayScore ?? rt?.awayScore ?? int.tryParse(detail.awayScore) ?? 0;
        final effStatusId = ev?.statusId ?? rt?.statusId ?? detail.statusId;

        return _AmFootballScoreTable(
          statusId: effStatusId,
          homeName: detail.homeName,
          awayName: detail.awayName,
          homeLogo: detail.homeInfo.logo,
          awayLogo: detail.awayInfo.logo,
          homeP1: homeP1, awayP1: awayP1,
          homeP2: homeP2, awayP2: awayP2,
          homeP3: homeP3, awayP3: awayP3,
          homeP4: homeP4, awayP4: awayP4,
          homeOt: homeOt, awayOt: awayOt,
          homeTotal: homeTotal, awayTotal: awayTotal,
        );
      },
    );
  }

  int _p(Map<String, dynamic> scores, String key, int idx) {
    final v = scores[key] as List<dynamic>?;
    return (v?[idx] as num?)?.toInt() ?? 0;
  }
}

class _AmFootballScoreTable extends StatelessWidget {
  const _AmFootballScoreTable({
    required this.statusId,
    required this.homeName,
    required this.awayName,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeP1, required this.awayP1,
    required this.homeP2, required this.awayP2,
    required this.homeP3, required this.awayP3,
    required this.homeP4, required this.awayP4,
    required this.homeOt, required this.awayOt,
    required this.homeTotal, required this.awayTotal,
  });

  final int statusId;
  final String homeName;
  final String awayName;
  final String homeLogo;
  final String awayLogo;
  final int homeP1, awayP1;
  final int homeP2, awayP2;
  final int homeP3, awayP3;
  final int homeP4, awayP4;
  final int homeOt, awayOt;
  final int homeTotal, awayTotal;

  bool get _hasOt => homeOt > 0 || awayOt > 0;

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade600,
    );

    final columns = <String>[
      'event.am_football.detail.q1'.tr(),
      'event.am_football.detail.q2'.tr(),
      'event.am_football.detail.q3'.tr(),
      'event.am_football.detail.q4'.tr(),
      if (_hasOt) 'event.am_football.detail.ot'.tr(),
      'event.am_football.detail.total'.tr(),
    ];

    final homeScores = [homeP1, homeP2, homeP3, homeP4, if (_hasOt) homeOt, homeTotal];
    final awayScores = [awayP1, awayP2, awayP3, awayP4, if (_hasOt) awayOt, awayTotal];

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    ...columns.map((label) => Expanded(
                          child: Text(label,
                              textAlign: TextAlign.center, style: headerStyle),
                        )),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
              _ScoreRow(
                  name: homeName,
                  logo: homeLogo,
                  scores: homeScores,
                  accentColor: Colors.deepOrange),
              Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),
              _ScoreRow(
                  name: awayName,
                  logo: awayLogo,
                  scores: awayScores,
                  accentColor: Colors.deepOrange),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.name,
    required this.logo,
    required this.scores,
    required this.accentColor,
  });

  final String name;
  final String logo;
  final List<int> scores;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SportLogo(url: logo, size: 20),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          ...scores.asMap().entries.map((e) {
            final isLast = e.key == scores.length - 1;
            return Expanded(
              child: Text(
                '${e.value}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLast ? 14 : 13,
                  fontWeight: isLast ? FontWeight.w800 : FontWeight.w500,
                  color: isLast ? accentColor : Colors.black87,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Stats Tab ────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerWidget {
  const _StatsTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync =
        ref.watch(matchEventsProvider(sport: SportType.amFootball, matchId: matchId));

    return eventsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(),
            style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final events = obj as AmFootballMatchEventsData?;
        final allStats = events?.statSets.expand((s) => s.stats).toList() ?? [];
        if (allStats.isEmpty) {
          return Center(
            child: Text(
              'event.am_football.detail.no_stats'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: allStats.length,
          itemBuilder: (context, i) => _AmFootballStatRow(stat: allStats[i]),
        );
      },
    );
  }
}

class _AmFootballStatRow extends StatelessWidget {
  const _AmFootballStatRow({required this.stat});

  final AmFootballStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              stat.homeDisplay,
              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Text(
              stat.labelKey.isNotEmpty ? stat.labelKey.tr() : '${stat.typeCode}',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              stat.awayDisplay,
              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Events Tab ──────────────────────────────────────────────────────────────

class _EventsTab extends ConsumerWidget {
  const _EventsTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync =
        ref.watch(matchEventsProvider(sport: SportType.amFootball, matchId: matchId));

    return eventsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(),
            style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final events = obj as AmFootballMatchEventsData?;
        if (events == null || events.incidents.isEmpty) {
          return Center(
            child: Text(
              'event.am_football.detail.no_events'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        return _AmFootballIncidentTimeline(incidents: events.incidents);
      },
    );
  }
}

class _AmFootballIncidentTimeline extends StatelessWidget {
  const _AmFootballIncidentTimeline({required this.incidents});

  final List<AmFootballIncident> incidents;

  @override
  Widget build(BuildContext context) {
    final reversed = incidents.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: reversed.length,
      itemBuilder: (context, index) {
        final incident = reversed[index];

        // Phase markers (type 1 = end, type 7 = start)
        if (incident.type == 1 || incident.type == 7) {
          return _PhaseMarker(incident: incident);
        }

        final isHome = incident.position == 1;
        final isFirst = index == 0;
        final isLast = index == reversed.length - 1;

        return TimelineTile(
          alignment: TimelineAlign.center,
          isFirst: isFirst,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 52,
            height: 24,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            indicator: _TimeIndicator(timeLabel: incident.timeLabel),
          ),
          beforeLineStyle: LineStyle(color: Colors.grey.shade300, thickness: 1),
          afterLineStyle: LineStyle(color: Colors.grey.shade300, thickness: 1),
          startChild: isHome ? _IncidentCell(incident: incident, isHome: true) : null,
          endChild: !isHome ? _IncidentCell(incident: incident, isHome: false) : null,
        );
      },
    );
  }
}

class _TimeIndicator extends StatelessWidget {
  const _TimeIndicator({required this.timeLabel});

  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        timeLabel,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
      ),
    );
  }
}

class _PhaseMarker extends StatelessWidget {
  const _PhaseMarker({required this.incident});

  final AmFootballIncident incident;

  String _label() {
    if (incident.type == 1) {
      final key = switch (incident.extra) {
        1 => 'event.am_football.incident.q1_end',
        2 => 'event.am_football.incident.q2_end',
        3 => 'event.am_football.incident.q3_end',
        4 => 'event.am_football.incident.q4_end',
        100 => 'event.am_football.incident.ft_end',
        105 => 'event.am_football.incident.ot_end',
        _ => 'event.am_football.incident.1',
      };
      return key.tr();
    }
    return 'event.am_football.incident.${incident.type}'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: Colors.grey.shade100,
      child: Center(
        child: Text(
          _label(),
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

class _IncidentCell extends StatelessWidget {
  const _IncidentCell({required this.incident, required this.isHome});

  final AmFootballIncident incident;
  final bool isHome;

  static const _incidentColors = {
    2: Colors.deepOrange, // Score
  };

  Widget _incidentIcon() {
    final color = _incidentColors[incident.type] ?? Colors.grey;
    final label = 'event.am_football.incident.${incident.type}'.tr();
    return _IncidentBadge(label: label, color: color);
  }

  String _scoreLabel() => '${incident.homeScore} - ${incident.awayScore}';

  @override
  Widget build(BuildContext context) {
    final icon = _incidentIcon();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: isHome
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(_scoreLabel(),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepOrange)),
                const SizedBox(width: 6),
                icon,
              ],
            )
          : Row(
              children: [
                icon,
                const SizedBox(width: 6),
                Text(_scoreLabel(),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepOrange)),
              ],
            ),
    );
  }
}

class _IncidentBadge extends StatelessWidget {
  const _IncidentBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
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
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
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
                decoration: BoxDecoration(
                    color: Colors.pink.shade50, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.pink.shade50,
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
