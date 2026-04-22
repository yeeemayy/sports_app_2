import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/ice_hockey_status.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';
import 'package:timeline_tile/timeline_tile.dart';

class IceHockeyMatchDetailScreen extends ConsumerStatefulWidget {
  const IceHockeyMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<IceHockeyMatchDetailScreen> createState() =>
      _IceHockeyMatchDetailScreenState();
}

class _IceHockeyMatchDetailScreenState
    extends SportDetailScaffoldState<IceHockeyMatchDetailScreen> {
  @override
  String get matchId => widget.matchId;

  @override
  SportType get sportType => SportType.iceHockey;

  @override
  Duration get eventsRefreshInterval => const Duration(seconds: 5);

  @override
  (String?, int?) watchDetail() {
    final v = ref
        .watch(matchDetailProvider(sport: SportType.iceHockey, matchId: matchId))
        .valueOrNull as IceHockeyMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(BuildContext context) =>
      _IceHockeyMatchHeader(matchId: matchId);

  @override
  List<Tab> buildTabs(BuildContext context) => [
        Tab(text: 'event.ice_hockey.detail.score'.tr()),
        Tab(text: 'event.ice_hockey.detail.stats'.tr()),
        Tab(text: 'event.ice_hockey.detail.events'.tr()),
      ];

  @override
  List<Widget> buildTabViews(BuildContext context) => [
        _ScoreTab(matchId: matchId),
        _StatsTab(matchId: matchId),
        _EventsTab(matchId: matchId),
      ];
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _IceHockeyMatchHeader extends ConsumerWidget {
  const _IceHockeyMatchHeader({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(matchDetailProvider(sport: SportType.iceHockey, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.iceHockey)
          .select((map) => map[matchId] as IceHockeyRealtimeData?),
    );

    return SportDetailHeaderShell<IceHockeyMatchDetail>(
      detailAsync: detailAsync,
      skeletonHeight: 80,
      builder: (detail) => _IceHockeyHeaderContent(detail: detail, rt: rt),
    );
  }
}

class _IceHockeyHeaderContent extends StatelessWidget {
  const _IceHockeyHeaderContent({required this.detail, this.rt});

  final IceHockeyMatchDetail detail;
  final IceHockeyRealtimeData? rt;

  @override
  Widget build(BuildContext context) {
    final effStatusId = rt?.statusId ?? detail.statusId;
    final homeScore = rt?.homeScore.toString() ?? detail.homeScore;
    final awayScore = rt?.awayScore.toString() ?? detail.awayScore;

    final isNotStarted = effStatusId == 1;
    const liveStatuses = {30, 331, 31, 332, 32, 6, 10, 8, 13};
    final isLive = liveStatuses.contains(effStatusId);
    final statusLabel = iceHockeyStatusLabel(effStatusId, detail.statusDescription);

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
                        ? Colors.orange.shade600
                        : Colors.white,
                    border: Border.all(color: Colors.orange.shade300),
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
        ref.watch(matchDetailProvider(sport: SportType.iceHockey, matchId: matchId));
    final eventsAsync =
        ref.watch(matchEventsProvider(sport: SportType.iceHockey, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.iceHockey)
          .select((map) => map[matchId] as IceHockeyRealtimeData?),
    );

    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.pink)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(),
            style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final detail = obj as IceHockeyMatchDetail;
        final ev = eventsAsync.valueOrNull as IceHockeyMatchEventsData?;

        final homeP1 = ev?.homeP1 ?? rt?.homeP1 ?? _periodFromScores(detail.scores, 'p1', 0);
        final awayP1 = ev?.awayP1 ?? rt?.awayP1 ?? _periodFromScores(detail.scores, 'p1', 1);
        final homeP2 = ev?.homeP2 ?? rt?.homeP2 ?? _periodFromScores(detail.scores, 'p2', 0);
        final awayP2 = ev?.awayP2 ?? rt?.awayP2 ?? _periodFromScores(detail.scores, 'p2', 1);
        final homeP3 = ev?.homeP3 ?? rt?.homeP3 ?? _periodFromScores(detail.scores, 'p3', 0);
        final awayP3 = ev?.awayP3 ?? rt?.awayP3 ?? _periodFromScores(detail.scores, 'p3', 1);
        final homeOt = ev?.homeOt ?? rt?.homeOt ?? _periodFromScores(detail.scores, 'ot', 0);
        final awayOt = ev?.awayOt ?? rt?.awayOt ?? _periodFromScores(detail.scores, 'ot', 1);
        final homeAp = ev?.homeAp ?? rt?.homeAp ?? _periodFromScores(detail.scores, 'ap', 0);
        final awayAp = ev?.awayAp ?? rt?.awayAp ?? _periodFromScores(detail.scores, 'ap', 1);
        final homeTotal = ev?.homeScore ?? rt?.homeScore ?? int.tryParse(detail.homeScore) ?? 0;
        final awayTotal = ev?.awayScore ?? rt?.awayScore ?? int.tryParse(detail.awayScore) ?? 0;
        final effStatusId = ev?.statusId ?? rt?.statusId ?? detail.statusId;

        return _IceHockeyScoreTable(
          statusId: effStatusId,
          homeName: detail.homeName,
          awayName: detail.awayName,
          homeLogo: detail.homeInfo.logo,
          awayLogo: detail.awayInfo.logo,
          homeP1: homeP1, awayP1: awayP1,
          homeP2: homeP2, awayP2: awayP2,
          homeP3: homeP3, awayP3: awayP3,
          homeOt: homeOt, awayOt: awayOt,
          homeAp: homeAp, awayAp: awayAp,
          homeTotal: homeTotal, awayTotal: awayTotal,
        );
      },
    );
  }

  int _periodFromScores(Map<String, dynamic> scores, String key, int idx) {
    final v = scores[key] as List<dynamic>?;
    return (v?[idx] as num?)?.toInt() ?? 0;
  }
}

class _IceHockeyScoreTable extends StatelessWidget {
  const _IceHockeyScoreTable({
    required this.statusId,
    required this.homeName,
    required this.awayName,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeP1, required this.awayP1,
    required this.homeP2, required this.awayP2,
    required this.homeP3, required this.awayP3,
    required this.homeOt, required this.awayOt,
    required this.homeAp, required this.awayAp,
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
  final int homeOt, awayOt;
  final int homeAp, awayAp;
  final int homeTotal, awayTotal;

  bool get _hasOt => homeOt > 0 || awayOt > 0;
  bool get _hasAp => homeAp > 0 || awayAp > 0;

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: context.appTheme.greyText,
    );

    final columns = <String>[
      'event.ice_hockey.detail.p1'.tr(),
      'event.ice_hockey.detail.p2'.tr(),
      'event.ice_hockey.detail.p3'.tr(),
      if (_hasOt) 'event.ice_hockey.detail.ot'.tr(),
      if (_hasAp) 'event.ice_hockey.detail.ap'.tr(),
      'event.ice_hockey.detail.total'.tr(),
    ];

    final homeScores = [homeP1, homeP2, homeP3, if (_hasOt) homeOt, if (_hasAp) homeAp, homeTotal];
    final awayScores = [awayP1, awayP2, awayP3, if (_hasOt) awayOt, if (_hasAp) awayAp, awayTotal];

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        Container(
          color: context.appTheme.surface,
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
              Divider(height: 1, thickness: 0.5, color: context.appTheme.shimmerBase),
              _ScoreRow(
                  name: homeName,
                  logo: homeLogo,
                  scores: homeScores,
                  accentColor: Colors.pink),
              Divider(height: 1, thickness: 0.5, color: context.appTheme.shimmerHighlight),
              _ScoreRow(
                  name: awayName,
                  logo: awayLogo,
                  scores: awayScores,
                  accentColor: Colors.pink),
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
                  color: isLast ? accentColor : context.appTheme.baseText,
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
        ref.watch(matchEventsProvider(sport: SportType.iceHockey, matchId: matchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.pink)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(),
            style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final events = obj as IceHockeyMatchEventsData?;
        final allStats = events?.statSets
                .expand((s) => s.stats)
                .toList() ??
            [];
        if (allStats.isEmpty) {
          return Center(
            child: Text(
              'event.ice_hockey.detail.no_stats'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: allStats.length,
          itemBuilder: (context, i) => _IceHockeyStatRow(stat: allStats[i]),
        );
      },
    );
  }
}

class _IceHockeyStatRow extends StatelessWidget {
  const _IceHockeyStatRow({required this.stat});

  final IceHockeyStat stat;

  @override
  Widget build(BuildContext context) {
    final home = stat.homeValue.isNaN ? 0.0 : stat.homeValue.abs();
    final away = stat.awayValue.isNaN ? 0.0 : stat.awayValue.abs();
    final total = home + away;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appTheme.shimmerBase, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
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
                  style: context.textTheme.bodySmall?.copyWith(color: context.appTheme.greyText),
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
          const SizedBox(height: 6),
          LayoutBuilder(builder: (context, constraints) {
            const barHeight = 6.0;
            const radius = Radius.circular(3);
            if (total <= 0) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(height: barHeight, color: context.appTheme.shimmerBase),
              );
            }
            final halfWidth = constraints.maxWidth / 2;
            final homeWidth = halfWidth * (home / total);
            final awayWidth = halfWidth * (away / total);
            return ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: barHeight,
                color: context.appTheme.shimmerBase,
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
                            color: Colors.pink,
                            borderRadius:
                                BorderRadius.only(topLeft: radius, bottomLeft: radius),
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
                          decoration: BoxDecoration(
                            color: Colors.blue.shade300, // ice hockey uses blue per design spec
                            borderRadius: const BorderRadius.only(
                                topRight: radius, bottomRight: radius),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
        ref.watch(matchEventsProvider(sport: SportType.iceHockey, matchId: matchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.pink)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(),
            style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final events = obj as IceHockeyMatchEventsData?;
        if (events == null || events.incidents.isEmpty) {
          return Center(
            child: Text(
              'event.ice_hockey.detail.no_events'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        return _IceHockeyIncidentTimeline(incidents: events.incidents);
      },
    );
  }
}

class _IceHockeyIncidentTimeline extends StatelessWidget {
  const _IceHockeyIncidentTimeline({required this.incidents});

  final List<IceHockeyIncident> incidents;

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
          beforeLineStyle: LineStyle(color: context.appTheme.shimmerBase, thickness: 1),
          afterLineStyle: LineStyle(color: context.appTheme.shimmerBase, thickness: 1),
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
        color: context.appTheme.grey_3,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        timeLabel,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.appTheme.grey_4),
      ),
    );
  }
}

class _PhaseMarker extends StatelessWidget {
  const _PhaseMarker({required this.incident});

  final IceHockeyIncident incident;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: context.appTheme.shimmerHighlight,
      child: Center(
        child: Text(
          'event.ice_hockey.incident.${incident.type}'.tr(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

class _IncidentCell extends StatelessWidget {
  const _IncidentCell({required this.incident, required this.isHome});

  final IceHockeyIncident incident;
  final bool isHome;

  // Ice hockey incident colours use blue for goals per design spec
  static const _incidentColors = {
    2: Colors.blue, // Goal
    3: Colors.amber, // Card
    8: Colors.red, // Penalty missed
    9: Colors.orange, // Penalty shootout
    13: Colors.grey, // Goal disallowed
  };

  Widget _incidentIcon() {
    final color = _incidentColors[incident.type] ?? Colors.grey;
    final label = 'event.ice_hockey.incident.${incident.type}'.tr();
    return _IncidentBadge(label: label, color: color);
  }

  String _scoreLabel() {
    return '${incident.homeScore} - ${incident.awayScore}';
  }

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
                        fontSize: 12, fontWeight: FontWeight.w700, color: Colors.pink)),
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
                        fontSize: 12, fontWeight: FontWeight.w700, color: Colors.pink)),
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
                    color: AppColors.primaryShade50, shape: BoxShape.circle),
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
