import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/football_lineup.dart';
import 'package:sports_app/src/features/event/domain/models/football_match.dart';
import 'package:sports_app/src/features/event/domain/models/match_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_events.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/features/prediction/presentation/widgets/fan_prediction_card.dart';
import 'package:sports_app/src/shared_widgets/arena_stat_bar.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class FootballMatchDetailScreen extends ConsumerStatefulWidget {
  const FootballMatchDetailScreen({
    super.key,
    required this.matchId,
    this.initialMatch,
  });

  final String matchId;
  final FootballMatch? initialMatch;

  @override
  ConsumerState<FootballMatchDetailScreen> createState() =>
      _FootballMatchDetailScreenState();
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
    final v = ref
        .watch(matchDetailProvider(sport: SportType.football, matchId: matchId))
        .valueOrNull as FootballMatchDetail?;
    return (
      v?.leagueName ?? widget.initialMatch?.leagueName,
      v?.matchTime ?? widget.initialMatch?.matchTime,
    );
  }

  @override
  Widget buildHeader(
    BuildContext context, {
    String? leagueName,
    int? matchTimestamp,
  }) =>
      _MatchHeader(
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

// ─── Match Header ─────────────────────────────────────────────────────────────

class _MatchHeader extends ConsumerWidget {
  const _MatchHeader({
    required this.matchId,
    this.initialMatch,
    this.leagueName,
    this.matchTimestamp,
  });

  final String matchId;
  final FootballMatch? initialMatch;
  final String? leagueName;
  final int? matchTimestamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(matchDetailProvider(sport: SportType.football, matchId: matchId));
    final eventsAsync =
        ref.watch(matchEventsProvider(sport: SportType.football, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.football)
          .select((map) => map[matchId] as MatchRealtimeData?),
    );

    Widget? fallback;
    if (initialMatch != null) {
      fallback = _HeaderFallback(match: initialMatch!, rt: rt);
    }

    return SportDetailHeaderShell<FootballMatchDetail>(
      detailAsync: detailAsync,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      fallback: fallback,
      builder: (detail) {
        final effKickoff = (rt != null && rt.kickoffTimestamp != 0)
            ? rt.kickoffTimestamp
            : (eventsAsync.valueOrNull as FootballMatchEvents?)?.kickoffTimestamp;
        return _HeaderContent(
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

class _HeaderFallback extends StatelessWidget {
  const _HeaderFallback({required this.match, this.rt});

  final FootballMatch match;
  final MatchRealtimeData? rt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effStatusId = rt?.statusId ?? match.statusId;
    final effHome = rt?.homeScore.toString() ?? match.homeScore;
    final effAway = rt?.awayScore.toString() ?? match.awayScore;
    final isNoScore = const {0, 1, 13}.contains(effStatusId);

    return _ScoreRow(
      homeLogo: match.homeLogo,
      homeName: match.homeName,
      awaLogo: match.awayLogo,
      awayName: match.awayName,
      homeScore: isNoScore ? '–' : effHome,
      awayScore: isNoScore ? '–' : effAway,
      statusLabel: match.statusLabel,
      statusColor: _statusColor(effStatusId, colors),
      subLabel: null,
      colors: colors,
      context: context,
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({
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
    final colors = context.appColors;
    final effStatusId = rtStatusId ?? detail.statusId;
    final effHome = rtHomeScore?.toString() ?? detail.homeScore;
    final effAway = rtAwayScore?.toString() ?? detail.awayScore;
    final effHomeHt = rtHomeHtScore ?? detail.homeInfo.halfTimeScore;
    final effAwayHt = rtAwayHtScore ?? detail.awayInfo.halfTimeScore;
    final isNoScore = const {0, 1, 13}.contains(effStatusId);

    String? subLabel;
    if (effStatusId != 1 &&
        effStatusId != 8 &&
        effHomeHt != null &&
        effAwayHt != null) {
      subLabel = '${'event.football.ht'.tr()} $effHomeHt-$effAwayHt';
    }
    if (detail.environment != null) {
      final env = detail.environment!;
      final parts = <String>[
        if (env.temperature != null) env.temperature!,
        if (env.wind != null) env.wind!,
      ];
      if (parts.isNotEmpty && subLabel == null) subLabel = parts.join(' · ');
    }

    return _ScoreRow(
      homeLogo: detail.homeInfo.logo,
      homeName: detail.homeName,
      awaLogo: detail.awayInfo.logo,
      awayName: detail.awayName,
      homeScore: isNoScore ? '–' : effHome,
      awayScore: isNoScore ? '–' : effAway,
      statusLabel: detail.statusLabel(kickoffTimestamp: kickoffTimestamp),
      statusColor: _statusColor(effStatusId, colors),
      subLabel: subLabel,
      colors: colors,
      context: context,
    );
  }
}

Color _statusColor(int statusId, AppColors colors) {
  if (const {2, 3, 4, 5, 6, 7}.contains(statusId)) return colors.live;
  if (statusId == 8) return colors.text3;
  if (const {9, 10, 11, 12}.contains(statusId)) return colors.danger;
  return colors.text3;
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.homeLogo,
    required this.homeName,
    required this.awaLogo,
    required this.awayName,
    required this.homeScore,
    required this.awayScore,
    required this.statusLabel,
    required this.statusColor,
    required this.subLabel,
    required this.colors,
    required this.context,
  });

  final String homeLogo;
  final String homeName;
  final String awaLogo;
  final String awayName;
  final String homeScore;
  final String awayScore;
  final String statusLabel;
  final Color statusColor;
  final String? subLabel;
  final AppColors colors;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SportLogo(url: homeLogo, size: 52),
                  const SizedBox(height: 6),
                  Text(
                    homeName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(13, context)
                        .copyWith(color: colors.text),
                  ),
                ],
              ),
            ),
            // Score centre
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        homeScore,
                        style: AppTextStyles.display(56, context)
                            .copyWith(color: colors.text),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          ':',
                          style: AppTextStyles.display(28, context)
                              .copyWith(color: colors.text3),
                        ),
                      ),
                      Text(
                        awayScore,
                        style: AppTextStyles.display(56, context)
                            .copyWith(color: colors.text),
                      ),
                    ],
                  ),
                  if (subLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subLabel!.toUpperCase(),
                        style: AppTextStyles.mono(9).copyWith(
                          color: colors.text3,
                          letterSpacing: 0.14 * 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            // Away
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SportLogo(url: awaLogo, size: 52),
                  const SizedBox(height: 6),
                  Text(
                    awayName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(13, context)
                        .copyWith(color: colors.text),
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

// ─── Stats Tab ────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerWidget {
  const _StatsTab({required this.matchId, this.initialMatch});

  final String matchId;
  final FootballMatch? initialMatch;

  static const _minimalTypeCodes = [
    '2', '3', '4', '8', '21', '22', '23', '24', '25',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final eventsAsync =
        ref.watch(matchEventsProvider(sport: SportType.football, matchId: matchId));
    final detailAsync =
        ref.watch(matchDetailProvider(sport: SportType.football, matchId: matchId));

    final detail = detailAsync.valueOrNull as FootballMatchDetail?;
    final effStatusId = detail?.statusId ??
        initialMatch?.statusId ?? 1;
    final isEnded = effStatusId >= 8;

    final homeName = detail?.homeName ??
        initialMatch?.homeName ?? '';
    final awayName = detail?.awayName ??
        initialMatch?.awayName ?? '';

    return eventsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: colors.accent)),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: colors.text3),
        ),
      ),
      data: (obj) {
        final events = obj as FootballMatchEvents?;
        final apiStats = events?.stats
                .where((s) => s.label != null && s.label!.isNotEmpty)
                .toList() ??
            [];
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
                      style: AppTextStyles.display(18, context)
                          .copyWith(color: colors.text),
                    ),
                  ],
                ),
              ),
              ...displayStats.map(
                (s) => ArenaStatBar(
                  label: s.label!,
                  home: s.home,
                  away: s.away,
                ),
              ),
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
    final colors = context.appColors;
    final eventsAsync =
        ref.watch(matchEventsProvider(sport: SportType.football, matchId: matchId));

    return eventsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: colors.accent)),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: colors.text3),
        ),
      ),
      data: (obj) {
        final events = obj as FootballMatchEvents?;
        if (events == null || events.incidents.isEmpty) {
          return Center(
            child: Text(
              'event.football.detail.no_events'.tr(),
              style: TextStyle(color: colors.text3),
            ),
          );
        }
        return _IncidentList(incidents: events.incidents);
      },
    );
  }
}

class _IncidentList extends StatelessWidget {
  const _IncidentList({required this.incidents});

  final List<MatchIncident> incidents;

  static const _phaseTypes = {10, 12, 13, 19, 26, 27};

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final reversed = incidents.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: reversed.length,
      itemBuilder: (context, index) {
        final incident = reversed[index];

        if (incident.type == 11) {
          return _PhaseDivider(
            label: 'event.football.detail.half_time'.tr(),
            colors: colors,
            context: context,
          );
        }
        if (_phaseTypes.contains(incident.type)) {
          return _PhaseDivider(
            label: 'event.football.detail.incident_type.${incident.type}'.tr(),
            colors: colors,
            context: context,
          );
        }

        final isHome = incident.position == 1;
        return _IncidentRow(
          incident: incident,
          isHome: isHome,
          colors: colors,
          context: context,
        );
      },
    );
  }
}

class _PhaseDivider extends StatelessWidget {
  const _PhaseDivider({
    required this.label,
    required this.colors,
    required this.context,
  });

  final String label;
  final AppColors colors;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: colors.surface,
      child: Center(
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.mono(10).copyWith(
            color: colors.text3,
            letterSpacing: 0.14 * 10,
          ),
        ),
      ),
    );
  }
}

class _IncidentRow extends StatelessWidget {
  const _IncidentRow({
    required this.incident,
    required this.isHome,
    required this.colors,
    required this.context,
  });

  final MatchIncident incident;
  final bool isHome;
  final AppColors colors;
  final BuildContext context;

  static Color _incidentColor(int type, AppColors c) => {
    1: c.accent,
    2: Colors.orange,
    3: Colors.amber,
    4: Colors.red,
    5: Colors.blueGrey,
    6: Colors.blue,
    7: Colors.teal,
    8: Colors.deepOrange,
    9: Colors.green,
    15: Colors.red,
    16: Colors.red,
    17: Colors.orange,
    21: Colors.blue,
    22: Colors.blueGrey,
    23: Colors.orange,
    24: Colors.deepOrange,
    25: Colors.purple,
    28: Colors.indigo,
    29: Colors.green,
    30: Colors.red,
  }[type] ?? Colors.grey;

  @override
  Widget build(BuildContext _) {
    final color = _incidentColor(incident.type, colors);
    final timeLabel = "${incident.time}'";

    final playerLabel = incident.type == 9
        ? '${incident.inPlayerName ?? ''} ↑\n${incident.outPlayerName ?? ''} ↓'
        : (incident.playerName ?? '');

    final badgeLabel =
        'event.football.detail.incident_type.${incident.type}'.tr();

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        badgeLabel,
        style:
            AppTextStyles.mono(9).copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );

    Widget textCell = Column(
      crossAxisAlignment:
          isHome ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (playerLabel.isNotEmpty)
          Text(
            playerLabel,
            style: TextStyle(fontSize: 11, color: colors.text),
            textAlign: isHome ? TextAlign.end : TextAlign.start,
            maxLines: 2,
          ),
        if (incident.homeScore != null && incident.awayScore != null)
          Text(
            '${incident.homeScore} - ${incident.awayScore}',
            style: AppTextStyles.mono(11).copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.line, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 36,
            child: Text(
              timeLabel,
              style: AppTextStyles.mono(12).copyWith(
                color: isHome ? colors.accent : colors.text2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Dot
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHome ? colors.accent : colors.text3,
            ),
          ),
          if (isHome) ...[
            Expanded(child: textCell),
            const SizedBox(width: 8),
            badge,
          ] else ...[
            badge,
            const SizedBox(width: 8),
            Expanded(child: textCell),
          ],
        ],
      ),
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

class _LineupsTabState extends ConsumerState<_LineupsTab>
    with SingleTickerProviderStateMixin {
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
    final lineupsAsync =
        ref.watch(footballMatchLineupsProvider(matchId: widget.matchId));

    return lineupsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: colors.accent)),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: colors.text3),
        ),
      ),
      data: (lineups) {
        if (lineups == null ||
            (lineups.home.isEmpty && lineups.away.isEmpty)) {
          return Center(
            child: Text(
              'event.football.detail.no_lineups'.tr(),
              style: TextStyle(color: colors.text3),
            ),
          );
        }

        final detail = ref
            .watch(matchDetailProvider(
              sport: SportType.football,
              matchId: widget.matchId,
            ))
            .valueOrNull as FootballMatchDetail?;
        final homeIcon = detail?.homeInfo.logo ?? widget.initialMatch?.homeLogo;
        final awayIcon = detail?.awayInfo.logo ?? widget.initialMatch?.awayLogo;
        final homeName =
            detail?.homeName ?? widget.initialMatch?.homeName ?? 'Home';
        final awayName =
            detail?.awayName ?? widget.initialMatch?.awayName ?? 'Away';

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
          if (logo != null) ...[
            SportLogo(url: logo!, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
          for (final p in starters)
            _LineupPlayerRow(player: p, colors: colors, context: context),
        ],
        if (subs.isNotEmpty) ...[
          _SectionLabel(
            label: 'event.football.detail.substitutes'.tr(),
            colors: colors,
            context: context,
          ),
          for (final p in subs)
            _LineupPlayerRow(player: p, colors: colors, context: context),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.colors,
    required this.context,
  });

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
        style: AppTextStyles.mono(10).copyWith(
          color: colors.text3,
          letterSpacing: 0.14 * 10,
        ),
      ),
    );
  }
}

class _LineupPlayerRow extends StatelessWidget {
  const _LineupPlayerRow({
    required this.player,
    required this.colors,
    required this.context,
  });

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
              style: AppTextStyles.mono(11).copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w700,
              ),
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
            Text(
              player.position,
              style: AppTextStyles.mono(10).copyWith(color: colors.text3),
            ),
        ],
      ),
    );
  }
}
