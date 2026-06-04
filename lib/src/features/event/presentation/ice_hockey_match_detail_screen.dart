import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/ice_hockey_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/headers/ice_hockey_match_header.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/arena_stat_bar.dart';
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
    final v =
        ref
                .watch(
                  matchDetailProvider(
                    sport: SportType.iceHockey,
                    matchId: matchId,
                  ),
                )
                .valueOrNull
            as IceHockeyMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(
    BuildContext context, {
    String? leagueName,
    int? matchTimestamp,
  }) => IceHockeyMatchHeader(
    matchId: matchId,
    leagueName: leagueName,
    matchTimestamp: matchTimestamp,
  );

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

// ─── Score Tab ────────────────────────────────────────────────────────────────

class _ScoreTab extends ConsumerWidget {
  const _ScoreTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      matchDetailProvider(sport: SportType.iceHockey, matchId: matchId),
    );
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.iceHockey, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.iceHockey,
      ).select((map) => map[matchId] as IceHockeyRealtimeData?),
    );

    return detailAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: context.appColors.accent),
      ),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: context.appColors.text3),
        ),
      ),
      data: (obj) {
        final detail = obj as IceHockeyMatchDetail;
        final ev = eventsAsync.valueOrNull as IceHockeyMatchEventsData?;

        final homeP1 = ev?.homeP1 ?? rt?.homeP1 ?? _p(detail.scores, 'p1', 0);
        final awayP1 = ev?.awayP1 ?? rt?.awayP1 ?? _p(detail.scores, 'p1', 1);
        final homeP2 = ev?.homeP2 ?? rt?.homeP2 ?? _p(detail.scores, 'p2', 0);
        final awayP2 = ev?.awayP2 ?? rt?.awayP2 ?? _p(detail.scores, 'p2', 1);
        final homeP3 = ev?.homeP3 ?? rt?.homeP3 ?? _p(detail.scores, 'p3', 0);
        final awayP3 = ev?.awayP3 ?? rt?.awayP3 ?? _p(detail.scores, 'p3', 1);
        final homeOt = ev?.homeOt ?? rt?.homeOt ?? _p(detail.scores, 'ot', 0);
        final awayOt = ev?.awayOt ?? rt?.awayOt ?? _p(detail.scores, 'ot', 1);
        final homeAp = ev?.homeAp ?? rt?.homeAp ?? _p(detail.scores, 'ap', 0);
        final awayAp = ev?.awayAp ?? rt?.awayAp ?? _p(detail.scores, 'ap', 1);
        final homeTotal =
            ev?.homeScore ??
            rt?.homeScore ??
            int.tryParse(detail.homeScore) ??
            0;
        final awayTotal =
            ev?.awayScore ??
            rt?.awayScore ??
            int.tryParse(detail.awayScore) ??
            0;
        final effStatusId = ev?.statusId ?? rt?.statusId ?? detail.statusId;

        return _IceHockeyScoreTable(
          statusId: effStatusId,
          homeName: detail.homeName,
          awayName: detail.awayName,
          homeLogo: detail.homeInfo.logo,
          awayLogo: detail.awayInfo.logo,
          homeP1: homeP1,
          awayP1: awayP1,
          homeP2: homeP2,
          awayP2: awayP2,
          homeP3: homeP3,
          awayP3: awayP3,
          homeOt: homeOt,
          awayOt: awayOt,
          homeAp: homeAp,
          awayAp: awayAp,
          homeTotal: homeTotal,
          awayTotal: awayTotal,
        );
      },
    );
  }

  int _p(Map<String, dynamic> scores, String key, int idx) {
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
    required this.homeP1,
    required this.awayP1,
    required this.homeP2,
    required this.awayP2,
    required this.homeP3,
    required this.awayP3,
    required this.homeOt,
    required this.awayOt,
    required this.homeAp,
    required this.awayAp,
    required this.homeTotal,
    required this.awayTotal,
  });

  final int statusId;
  final String homeName, awayName;
  final String homeLogo, awayLogo;
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
    final colors = context.appColors;

    final columns = <String>[
      'event.ice_hockey.detail.p1'.tr(),
      'event.ice_hockey.detail.p2'.tr(),
      'event.ice_hockey.detail.p3'.tr(),
      if (_hasOt) 'event.ice_hockey.detail.ot'.tr(),
      if (_hasAp) 'event.ice_hockey.detail.ap'.tr(),
      'event.ice_hockey.detail.total'.tr(),
    ];

    final homeScores = [
      homeP1,
      homeP2,
      homeP3,
      if (_hasOt) homeOt,
      if (_hasAp) homeAp,
      homeTotal,
    ];
    final awayScores = [
      awayP1,
      awayP2,
      awayP3,
      if (_hasOt) awayOt,
      if (_hasAp) awayAp,
      awayTotal,
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.line),
          ),
          child: Column(
            children: [
              // Header: [empty] | Home | Away
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  spacing: 2,
                  children: [
                    const Expanded(flex: 2, child: SizedBox()),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SportLogo(url: homeLogo, size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              homeName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body(12).copyWith(
                                color: colors.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SportLogo(url: awayLogo, size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              awayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body(12).copyWith(
                                color: colors.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: colors.line),
              // One row per period
              ...List.generate(columns.length, (i) {
                final isTotal = i == columns.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              columns[i],
                              style: AppTextStyles.mono(
                                11,
                              ).copyWith(color: colors.text3),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${homeScores[i]}',
                              textAlign: TextAlign.center,
                              style: isTotal
                                  ? AppTextStyles.mono(14).copyWith(
                                      color: colors.accent,
                                      fontWeight: FontWeight.w800,
                                    )
                                  : AppTextStyles.mono(
                                      13,
                                    ).copyWith(color: colors.text2),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${awayScores[i]}',
                              textAlign: TextAlign.center,
                              style: isTotal
                                  ? AppTextStyles.mono(14).copyWith(
                                      color: colors.accent,
                                      fontWeight: FontWeight.w800,
                                    )
                                  : AppTextStyles.mono(
                                      13,
                                    ).copyWith(color: colors.text2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < columns.length - 1)
                      Divider(height: 1, thickness: 0.5, color: colors.line),
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

class _StatsTab extends ConsumerWidget {
  const _StatsTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.iceHockey, matchId: matchId),
    );

    return eventsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: context.appColors.accent),
      ),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: context.appColors.text3),
        ),
      ),
      data: (obj) {
        final events = obj as IceHockeyMatchEventsData?;
        final allStats = events?.statSets.expand((s) => s.stats).toList() ?? [];
        if (allStats.isEmpty) {
          return Center(
            child: Text(
              'event.ice_hockey.detail.no_stats'.tr(),
              style: TextStyle(color: context.appColors.text3),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: allStats.length,
          itemBuilder: (context, i) {
            final s = allStats[i];
            return ArenaStatBar(
              label: s.labelKey.isNotEmpty ? s.labelKey.tr() : '${s.typeCode}',
              home: s.homeValue,
              away: s.awayValue,
            );
          },
        );
      },
    );
  }
}

// ─── Events Tab ──────────────────────────────────────────────────────────────

class _EventsTab extends ConsumerWidget {
  const _EventsTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.iceHockey, matchId: matchId),
    );

    return eventsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: context.appColors.accent),
      ),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: context.appColors.text3),
        ),
      ),
      data: (obj) {
        final events = obj as IceHockeyMatchEventsData?;
        if (events == null || events.incidents.isEmpty) {
          return Center(
            child: Text(
              'event.ice_hockey.detail.no_events'.tr(),
              style: TextStyle(color: context.appColors.text3),
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
          beforeLineStyle: LineStyle(
            color: context.appColors.line,
            thickness: 1,
          ),
          afterLineStyle: LineStyle(
            color: context.appColors.line,
            thickness: 1,
          ),
          startChild: isHome
              ? _IncidentCell(incident: incident, isHome: true)
              : null,
          endChild: !isHome
              ? _IncidentCell(incident: incident, isHome: false)
              : null,
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
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.line),
      ),
      alignment: Alignment.center,
      child: Text(
        timeLabel,
        style: AppTextStyles.mono(10).copyWith(color: colors.text3),
      ),
    );
  }
}

class _PhaseMarker extends StatelessWidget {
  const _PhaseMarker({required this.incident});

  final IceHockeyIncident incident;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: colors.surface2,
      child: Center(
        child: Text(
          'event.ice_hockey.incident.${incident.type}'.tr(),
          style: AppTextStyles.mono(11).copyWith(color: colors.text3),
        ),
      ),
    );
  }
}

class _IncidentCell extends StatelessWidget {
  const _IncidentCell({required this.incident, required this.isHome});

  final IceHockeyIncident incident;
  final bool isHome;

  Color _incidentColor(AppColors colors) => switch (incident.type) {
    2 => colors.accent, // Goal
    3 => colors.live, // Penalty
    8 => colors.danger, // Penalty missed
    9 => colors.text2, // Penalty shootout
    13 => colors.text3, // Goal disallowed
    _ => colors.text3,
  };

  String _scoreLabel() => '${incident.homeScore} - ${incident.awayScore}';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = _incidentColor(colors);
    final label = 'event.ice_hockey.incident.${incident.type}'.tr();
    final badge = _IncidentBadge(label: label, color: color);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: isHome
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _scoreLabel(),
                  style: AppTextStyles.mono(
                    12,
                  ).copyWith(color: colors.accent, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 6),
                badge,
              ],
            )
          : Row(
              children: [
                badge,
                const SizedBox(width: 6),
                Text(
                  _scoreLabel(),
                  style: AppTextStyles.mono(
                    12,
                  ).copyWith(color: colors.accent, fontWeight: FontWeight.w700),
                ),
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
        style: AppTextStyles.mono(
          9,
        ).copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
