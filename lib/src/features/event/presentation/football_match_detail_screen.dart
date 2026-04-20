import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/football_lineup.dart';
import 'package:sports_app/src/features/event/domain/models/match_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_events.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/match_status_badge.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';
import 'package:timeline_tile/timeline_tile.dart';

class FootballMatchDetailScreen extends ConsumerStatefulWidget {
  const FootballMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<FootballMatchDetailScreen> createState() => _FootballMatchDetailScreenState();
}

class _FootballMatchDetailScreenState
    extends SportDetailScaffoldState<FootballMatchDetailScreen> {
  @override
  String get matchId => widget.matchId;

  @override
  SportType get sportType => SportType.football;

  @override
  Duration get eventsRefreshInterval => const Duration(seconds: 1);

  @override
  void onStatusChanged() {
    super.onStatusChanged();
    ref.invalidate(footballMatchLineupsProvider(matchId: matchId));
  }

  @override
  (String?, int?) watchDetail() {
    final v = ref.watch(matchDetailProvider(sport: SportType.football, matchId: matchId))
        .valueOrNull as FootballMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(BuildContext context) => _MatchHeader(matchId: matchId);

  @override
  List<Tab> buildTabs(BuildContext context) => [
    Tab(text: 'event.football.detail.stats'.tr()),
    Tab(text: 'event.football.detail.events'.tr()),
    Tab(text: 'event.football.detail.lineups'.tr()),
  ];

  @override
  List<Widget> buildTabViews(BuildContext context) => [
    _StatsTab(matchId: matchId),
    _EventsTab(matchId: matchId),
    _LineupsTab(matchId: matchId),
  ];
}

// ─── Match Header ────────────────────────────────────────────────────────────

class _MatchHeader extends ConsumerWidget {
  const _MatchHeader({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.football, matchId: matchId));
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.football, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.football).select((map) => map[matchId] as MatchRealtimeData?),
    );

    return SportDetailHeaderShell<FootballMatchDetail>(
      detailAsync: detailAsync,
      builder: (detail) {
        final effKickoff = (rt != null && rt.kickoffTimestamp != 0)
            ? rt.kickoffTimestamp
            : (eventsAsync.valueOrNull as FootballMatchEvents?)?.kickoffTimestamp;
        return _MatchHeaderContent(
          detail: detail,
          kickoffTimestamp: effKickoff,
          rtStatusId: rt?.statusId,
          rtHomeScore: rt?.homeScore,
          rtAwayScore: rt?.awayScore,
          rtHomeHtScore: rt?.homeHtScore,
          rtAwayHtScore: rt?.awayHtScore,
        );
      },
    );
  }
}

class _MatchHeaderContent extends StatelessWidget {
  const _MatchHeaderContent({
    required this.detail,
    this.kickoffTimestamp,
    this.rtStatusId,
    this.rtHomeScore,
    this.rtAwayScore,
    this.rtHomeHtScore,
    this.rtAwayHtScore,
  });

  final FootballMatchDetail detail;
  final int? kickoffTimestamp;
  final int? rtStatusId;
  final int? rtHomeScore;
  final int? rtAwayScore;
  final int? rtHomeHtScore;
  final int? rtAwayHtScore;

  @override
  Widget build(BuildContext context) {
    final int effStatusId = rtStatusId ?? detail.statusId;
    final String effHomeScore = rtHomeScore?.toString() ?? detail.homeScore;
    final String effAwayScore = rtAwayScore?.toString() ?? detail.awayScore;
    final int? effHomeHtScore = rtHomeHtScore ?? detail.homeInfo.halfTimeScore;
    final int? effAwayHtScore = rtAwayHtScore ?? detail.awayInfo.halfTimeScore;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home team
            Expanded(
              child: Column(
                children: [
                  SportLogo(url: detail.homeInfo.logo, size: 40),
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
            // Score / status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  MatchStatusBadge(
                    statusId: effStatusId,
                    label: detail.statusLabel(kickoffTimestamp: kickoffTimestamp),
                    liveColor: Colors.white,
                    staticColor: Colors.grey.shade200,
                  ),
                  _ScoreOrStatus(
                    statusId: effStatusId,
                    homeScore: effHomeScore,
                    awayScore: effAwayScore,
                  ),
                  const SizedBox(height: 4),
                  if (effStatusId != 8 && effHomeHtScore != null && effAwayHtScore != null)
                    Text(
                      '${'event.football.ht'.tr()} $effHomeHtScore-$effAwayHtScore',
                      style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade300),
                    ),
                ],
              ),
            ),
            // Away team
            Expanded(
              child: Column(
                children: [
                  SportLogo(url: detail.awayInfo.logo, size: 40),
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
        ),
        if (detail.environment != null) ...[
          const SizedBox(height: 10),
          _EnvironmentRow(env: detail.environment!),
        ],
      ],
    );
  }
}

class _EnvironmentRow extends StatelessWidget {
  const _EnvironmentRow({required this.env});

  final FootballMatchEnvironment env;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, String value})>[];
    if (env.pressure != null) {
      items.add((
        icon: Icons.compress,
        label: 'event.football.detail.environment.pressure'.tr(),
        value: env.pressure!,
      ));
    }
    if (env.temperature != null) {
      items.add((
        icon: Icons.thermostat,
        label: 'event.football.detail.environment.temperature'.tr(),
        value: env.temperature!,
      ));
    }
    if (env.wind != null) {
      items.add((
        icon: Icons.air,
        label: 'event.football.detail.environment.wind'.tr(),
        value: env.wind!,
      ));
    }
    if (env.humidity != null) {
      items.add((
        icon: Icons.water_drop,
        label: 'event.football.detail.environment.humidity'.tr(),
        value: env.humidity!,
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 12, color: Colors.white70),
              const SizedBox(width: 3),
              Text(
                '${item.label} ${item.value}',
                style: context.textTheme.labelSmall?.copyWith(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ScoreOrStatus extends StatelessWidget {
  const _ScoreOrStatus({
    required this.statusId,
    required this.homeScore,
    required this.awayScore,
  });

  final int statusId;
  final String homeScore;
  final String awayScore;

  static const _noScoreStatuses = {0, 1, 13};

  @override
  Widget build(BuildContext context) {
    if (_noScoreStatuses.contains(statusId)) {
      return Text(
        '-',
        style: context.textTheme.headlineSmall?.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        children: [
          TextSpan(text: homeScore),
          TextSpan(
            text: ' - ',
            style: TextStyle(color: Colors.grey.shade200),
          ),
          TextSpan(text: awayScore),
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
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.football, matchId: matchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, st) {
        debugPrint('$e\n$st');
        return Center(
          child: Text(
            'event.error.load_failed'.tr(),
            style: TextStyle(color: Colors.grey.shade500),
          ),
        );
      },
      data: (obj) {
        final events = obj as FootballMatchEvents?;
        if (events == null || events.incidents.isEmpty) {
          return Center(
            child: Text(
              'event.football.detail.no_events'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        return _IncidentTimeline(incidents: events.incidents);
      },
    );
  }
}

class _IncidentTimeline extends StatelessWidget {
  const _IncidentTimeline({required this.incidents});

  final List<MatchIncident> incidents;

  // Types rendered as inline phase markers rather than timeline rows
  static const _phaseTypes = {10, 12, 13, 19, 26, 27};

  @override
  Widget build(BuildContext context) {
    final reversed = incidents.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: reversed.length,
      itemBuilder: (context, index) {
        final incident = reversed[index];

        if (incident.type == 11) return _HalfTimeSeparator();
        if (_phaseTypes.contains(incident.type)) return _PhaseMarker(incident: incident);

        final isHome = incident.position == 1;
        final isFirst = index == 0;
        final isLast = index == reversed.length - 1;

        return TimelineTile(
          alignment: TimelineAlign.center,
          isFirst: isFirst,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 44,
            height: 24,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            indicator: _TimeIndicator(time: incident.time),
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
  const _TimeIndicator({required this.time});

  final int time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        "$time'",
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
      ),
    );
  }
}

class _HalfTimeSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.grey.shade100,
      child: Center(
        child: Text(
          'event.football.detail.half_time'.tr(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _PhaseMarker extends StatelessWidget {
  const _PhaseMarker({required this.incident});

  final MatchIncident incident;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: Colors.grey.shade100,
      child: Center(
        child: Text(
          'event.football.detail.incident_type.${incident.type}'.tr(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

class _IncidentCell extends StatelessWidget {
  const _IncidentCell({required this.incident, required this.isHome});

  final MatchIncident incident;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final icon = _incidentIcon(incident.type);
    final name = _incidentLabel(incident);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: isHome
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: _IncidentText(text: name, incident: incident, align: TextAlign.end),
                ),
                const SizedBox(width: 6),
                icon,
              ],
            )
          : Row(
              children: [
                icon,
                const SizedBox(width: 6),
                Flexible(
                  child: _IncidentText(text: name, incident: incident, align: TextAlign.start),
                ),
              ],
            ),
    );
  }

  String _incidentLabel(MatchIncident i) {
    if (i.type == 9) {
      // Substitution: show in/out players
      final inName = i.inPlayerName ?? '';
      final outName = i.outPlayerName ?? '';
      return '$inName ↑\n$outName ↓';
    }
    return i.playerName ?? '';
  }

  static const _incidentColors = {
    1: AppColors.primary, // Goal
    2: Colors.orange, // Corner
    3: Colors.amber, // Yellow card
    4: Colors.red, // Red card
    5: Colors.blueGrey, // Offside
    6: Colors.blue, // Free kick
    7: Colors.teal, // Goal kick
    8: Colors.deepOrange, // Penalty
    9: Colors.green, // Substitution
    10: Colors.teal, // Kick off
    11: Colors.grey, // Half time
    12: Colors.grey, // Full time
    13: Colors.grey, // Half time score
    15: Colors.red, // Card upgrade
    16: Colors.red, // Penalty missed
    17: Colors.orange, // Own goal
    19: Colors.amber, // Injury time
    21: Colors.blue, // Shot on target
    22: Colors.blueGrey, // Shot off target
    23: Colors.orange, // Attack
    24: Colors.deepOrange, // Dangerous attack
    25: Colors.purple, // Possession
    26: Colors.grey, // Extra time over
    27: Colors.grey, // Penalty shootout over
    28: Colors.indigo, // VAR
    29: Colors.green, // Penalty shootout scored
    30: Colors.red, // Penalty shootout missed
  };

  Widget _incidentIcon(int type) {
    final color = _incidentColors[type] ?? Colors.grey;
    return _IncidentBadge(label: 'event.football.detail.incident_type.$type'.tr(), color: color);
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

class _IncidentText extends StatelessWidget {
  const _IncidentText({required this.text, required this.incident, required this.align});

  final String text;
  final MatchIncident incident;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (text.isNotEmpty)
          Text(
            text,
            style: const TextStyle(fontSize: 11),
            textAlign: align,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (incident.homeScore != null && incident.awayScore != null)
          Text(
            '${incident.homeScore} - ${incident.awayScore}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            textAlign: align,
          ),
        if (incident.reason != null && incident.reason != 0)
          Text(
            'event.football.detail.incident_reason.${incident.reason}'.tr(),
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

// ─── Lineups Tab ─────────────────────────────────────────────────────────────

class _LineupsTab extends ConsumerStatefulWidget {
  const _LineupsTab({required this.matchId});

  final String matchId;

  @override
  ConsumerState<_LineupsTab> createState() => _LineupsTabState();
}

class _LineupsTabState extends ConsumerState<_LineupsTab> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineupsAsync = ref.watch(footballMatchLineupsProvider(matchId: widget.matchId));

    return lineupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, st) {
        debugPrint('$e\n$st');
        return Center(
          child: Text(
            'event.error.load_failed'.tr(),
            style: TextStyle(color: Colors.grey.shade500),
          ),
        );
      },
      data: (lineups) {
        if (lineups == null || (lineups.home.isEmpty && lineups.away.isEmpty)) {
          return Center(
            child: Text(
              'event.football.detail.no_lineups'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        final detail = ref.watch(matchDetailProvider(sport: SportType.football, matchId: widget.matchId)).valueOrNull as FootballMatchDetail?;
        final homeIcon = detail?.homeInfo.logo;
        final awayIcon = detail?.awayInfo.logo;
        final homeName = detail?.homeName ?? 'Home';
        final awayName = detail?.awayName ?? 'Away';

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(width: 1, color: Colors.grey.shade300),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorWeight: 0,
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelColor: Colors.grey,
                splashBorderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(3),
                tabs: [
                  Tab(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SportLogo(url: homeIcon, size: 20),
                            ),
                          ),
                          TextSpan(text: homeName),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SportLogo(url: awayIcon, size: 20),
                            ),
                          ),
                          TextSpan(text: awayName),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TeamLineupList(players: lineups.home),
                  _TeamLineupList(players: lineups.away),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TeamLineupList extends StatelessWidget {
  const _TeamLineupList({required this.players});

  final List<LineupPlayer> players;

  @override
  Widget build(BuildContext context) {
    final starters = players.where((p) => p.first == 1).toList();
    final subs = players.where((p) => p.first == 0).toList();

    return ListView(
      children: [
        if (starters.isNotEmpty) ...[
          _SectionHeader(label: 'event.football.detail.starting_xi'.tr()),
          for (final p in starters) _PlayerRow(player: p),
        ],
        if (subs.isNotEmpty) ...[
          _SectionHeader(label: 'event.football.detail.substitutes'.tr()),
          for (final p in subs) _PlayerRow(player: p),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      color: Colors.grey.shade200,
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final LineupPlayer player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              '${player.shirtNumber}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          SportLogo(url: player.logo, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (player.position.isNotEmpty)
            Text(player.position, style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ─── Stats Tab ───────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerWidget {
  const _StatsTab({required this.matchId});

  final String matchId;

  // Incident type codes for the minimal stat rows (in display order).
  static const _minimalTypeCodes = ['2', '3', '4', '8', '21', '22', '23', '24', '25'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.football, matchId: matchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final events = obj as FootballMatchEvents?;
        final apiStats = events?.stats.where((s) => s.label != null && s.label!.isNotEmpty).toList() ?? [];
        final apiByLabel = {for (final s in apiStats) s.label!: s};

        final displayStats = _minimalTypeCodes.map((code) {
          final label = 'event.football.detail.incident_type.$code'.tr();
          return apiByLabel[label] ?? MatchStat(label: label, home: 0, away: 0);
        }).toList();

        // Append any extra API stats not already covered by the minimal set.
        final minimalLabels = displayStats.map((s) => s.label).toSet();
        for (final s in apiStats) {
          if (!minimalLabels.contains(s.label)) displayStats.add(s);
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: displayStats.map((stat) => _StatRow(stat: stat)).toList(),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stat});

  final MatchStat stat;

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
            width: 60,
            child: Text(
              '${stat.home}',
              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Text(
              stat.label!,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${stat.away}',
              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

