import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/football_lineup.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/football_match.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/football_match_detail.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/football_match_events.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/event_providers.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/headers/football_match_header.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/football_pitch_lineup.dart';
import 'package:shenghaotiyu/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:shenghaotiyu/src/features/prediction/presentation/widgets/fan_prediction_card.dart';
import 'package:shenghaotiyu/src/shared_widgets/arena_stat_bar.dart';
import 'package:shenghaotiyu/src/shared_widgets/sport_logo.dart';

class FootballMatchDetailScreen extends ConsumerStatefulWidget {
  const FootballMatchDetailScreen({super.key, required this.matchId, this.initialMatch});

  final String matchId;
  final FootballMatch? initialMatch;

  @override
  ConsumerState<FootballMatchDetailScreen> createState() => _FootballMatchDetailScreenState();
}

class _FootballMatchDetailScreenState extends SportDetailScaffoldState<FootballMatchDetailScreen> {
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
    final v =
        ref.watch(matchDetailProvider(sport: SportType.football, matchId: matchId)).valueOrNull
            as FootballMatchDetail?;
    return (
      v?.leagueName ?? widget.initialMatch?.leagueName,
      v?.matchTime ?? widget.initialMatch?.matchTime,
    );
  }

  @override
  Widget buildHeader(BuildContext context, {String? leagueName, int? matchTimestamp}) =>
      FootballMatchHeader(
        matchId: matchId,
        initialMatch: widget.initialMatch,
        leagueName: leagueName,
        matchTimestamp: matchTimestamp,
      );

  @override
  List<Tab> buildTabs(BuildContext context) => [
    Tab(text: 'event.football.detail.stats'.tr()),
    Tab(text: 'event.football.detail.events'.tr()),
    Tab(text: 'event.football.detail.lineups'.tr()),
  ];

  @override
  List<Widget> buildTabViews(BuildContext context) => [
    _StatsTab(matchId: matchId, initialMatch: widget.initialMatch),
    _EventsTab(matchId: matchId),
    _LineupsTab(matchId: matchId, initialMatch: widget.initialMatch),
  ];
}

// ─── Stats Tab ────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerWidget {
  const _StatsTab({required this.matchId, this.initialMatch});

  final String matchId;
  final FootballMatch? initialMatch;

  static const _minimalTypeCodes = ['2', '3', '4', '8', '21', '22', '23', '24', '25'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.football, matchId: matchId));
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.football, matchId: matchId));

    final detail = detailAsync.valueOrNull as FootballMatchDetail?;
    final effStatusId = detail?.statusId ?? initialMatch?.statusId ?? 1;
    final isEnded = effStatusId >= 8;

    final homeName = detail?.homeName ?? initialMatch?.homeName ?? '';
    final awayName = detail?.awayName ?? initialMatch?.awayName ?? '';

    return eventsAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: colors.text3)),
      ),
      data: (obj) {
        final events = obj as FootballMatchEvents?;
        final apiStats =
            events?.stats.where((s) => s.label != null && s.label!.isNotEmpty).toList() ?? [];
        final apiByLabel = {for (final s in apiStats) s.label!: s};

        final displayStats = _minimalTypeCodes.map((code) {
          final label = 'event.football.detail.incident_type.$code'.tr();
          return apiByLabel[label] ?? MatchStat(label: label, home: 0, away: 0);
        }).toList();
        final minimalLabels = displayStats.map((s) => s.label).toSet();
        for (final s in apiStats) {
          if (!minimalLabels.contains(s.label)) displayStats.add(s);
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            FanPredictionCard(
              matchId: matchId,
              homeName: homeName,
              awayName: awayName,
              hasDraw: true,
              isMatchEnded: isEnded,
            ),
            if (displayStats.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Row(
                  children: [
                    Text(
                      'event.football.detail.stats'.tr().toUpperCase(),
                      style: AppTextStyles.display(18, context).copyWith(color: colors.text),
                    ),
                  ],
                ),
              ),
              ...displayStats.map((s) => ArenaStatBar(label: s.label!, home: s.home, away: s.away)),
            ],
          ],
        );
      },
    );
  }
}

// ─── Events Tab ───────────────────────────────────────────────────────────────

class _EventsTab extends ConsumerWidget {
  const _EventsTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.football, matchId: matchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF3C00))),
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
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(color: colors.surface2, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Text(
        "$time'",
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.text3),
      ),
    );
  }
}

class _HalfTimeSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: colors.shimmerHighlight,
      child: Center(
        child: Text(
          'event.football.detail.half_time'.tr(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.text2,
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
      color: context.appColors.shimmerHighlight,
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
      final inName = i.inPlayerName ?? '';
      final outName = i.outPlayerName ?? '';
      return '$inName ↑\n$outName ↓';
    }
    return i.playerName ?? '';
  }

  static const _incidentColors = {
    1: Color(0xFFFF3C00),
    2: Colors.orange,
    3: Colors.amber,
    4: Colors.red,
    5: Colors.blueGrey,
    6: Colors.blue,
    7: Colors.teal,
    8: Colors.deepOrange,
    9: Colors.green,
    10: Colors.teal,
    11: Colors.grey,
    12: Colors.grey,
    13: Colors.grey,
    15: Colors.red,
    16: Colors.red,
    17: Colors.orange,
    19: Colors.amber,
    21: Colors.blue,
    22: Colors.blueGrey,
    23: Colors.orange,
    24: Colors.deepOrange,
    25: Colors.purple,
    26: Colors.grey,
    27: Colors.grey,
    28: Colors.indigo,
    29: Colors.green,
    30: Colors.red,
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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF3C00),
            ),
          ),
      ],
    );
  }
}

// ─── Lineups Tab ──────────────────────────────────────────────────────────────

class _LineupsTab extends ConsumerStatefulWidget {
  const _LineupsTab({required this.matchId, this.initialMatch});

  final String matchId;
  final FootballMatch? initialMatch;

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
    final colors = context.appColors;
    final lineupsAsync = ref.watch(footballMatchLineupsProvider(matchId: widget.matchId));

    return lineupsAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: colors.text3)),
      ),
      data: (lineups) {
        if (lineups == null || (lineups.home.isEmpty && lineups.away.isEmpty)) {
          return Center(
            child: Text(
              'event.football.detail.no_lineups'.tr(),
              style: TextStyle(color: colors.text3),
            ),
          );
        }

        final detail =
            ref
                    .watch(matchDetailProvider(sport: SportType.football, matchId: widget.matchId))
                    .valueOrNull
                as FootballMatchDetail?;
        final homeIcon = detail?.homeInfo.logo ?? widget.initialMatch?.homeLogo;
        final awayIcon = detail?.awayInfo.logo ?? widget.initialMatch?.awayLogo;
        final homeName = detail?.homeName ?? widget.initialMatch?.homeName ?? 'Home';
        final awayName = detail?.awayName ?? widget.initialMatch?.awayName ?? 'Away';

        final homeStarters = lineups.home.where((p) => p.first == 1).toList();
        final awayStarters = lineups.away.where((p) => p.first == 1).toList();
        final homeSubs = lineups.home.where((p) => p.first == 0).toList();
        final awaySubs = lineups.away.where((p) => p.first == 0).toList();

        final hasCoords =
            FootballPitchLineup.hasCoordinates(homeStarters) ||
            FootballPitchLineup.hasCoordinates(awayStarters);

        if (hasCoords) {
          return SingleChildScrollView(
            child: FootballPitchLineup(
              homeStarters: homeStarters,
              awayStarters: awayStarters,
              homeSubs: homeSubs,
              awaySubs: awaySubs,
              homeName: homeName,
              awayName: awayName,
              homeIcon: homeIcon,
              awayIcon: awayIcon,
            ),
          );
        }

        // Fallback to list view when coordinates aren't available
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.line, width: 0.5),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorWeight: 0,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colors.accent,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: const Color(0xFF0E0E0E),
                unselectedLabelColor: colors.text2,
                splashBorderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.all(3),
                tabs: [
                  _TeamTab(logo: homeIcon, name: homeName),
                  _TeamTab(logo: awayIcon, name: awayName),
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

class _TeamTab extends StatelessWidget {
  const _TeamTab({required this.logo, required this.name});

  final String? logo;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (logo != null) ...[SportLogo(url: logo!, size: 18), const SizedBox(width: 6)],
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _TeamLineupList extends StatelessWidget {
  const _TeamLineupList({required this.players});

  final List<LineupPlayer> players;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final starters = players.where((p) => p.first == 1).toList();
    final subs = players.where((p) => p.first == 0).toList();

    return ListView(
      children: [
        if (starters.isNotEmpty) ...[
          _SectionLabel(
            label: 'event.football.detail.starting_xi'.tr(),
            colors: colors,
            context: context,
          ),
          for (final p in starters) _LineupPlayerRow(player: p, colors: colors, context: context),
        ],
        if (subs.isNotEmpty) ...[
          _SectionLabel(
            label: 'event.football.detail.substitutes'.tr(),
            colors: colors,
            context: context,
          ),
          for (final p in subs) _LineupPlayerRow(player: p, colors: colors, context: context),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.colors, required this.context});

  final String label;
  final AppColors colors;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      color: colors.surface,
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.mono(10).copyWith(color: colors.text3, letterSpacing: 0.14 * 10),
      ),
    );
  }
}

class _LineupPlayerRow extends StatelessWidget {
  const _LineupPlayerRow({required this.player, required this.colors, required this.context});

  final LineupPlayer player;
  final AppColors colors;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.line, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              '${player.shirtNumber}',
              style: AppTextStyles.mono(
                11,
              ).copyWith(color: colors.accent, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          SportLogo(url: player.logo, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(fontSize: 13, color: colors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (player.position.isNotEmpty)
            Text(player.position, style: AppTextStyles.mono(10).copyWith(color: colors.text3)),
        ],
      ),
    );
  }
}
