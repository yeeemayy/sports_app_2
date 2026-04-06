import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/football_lineup.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_events.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/football_match_card.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';
import 'package:timeline_tile/timeline_tile.dart';

class FootballMatchDetailScreen extends ConsumerStatefulWidget {
  const FootballMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<FootballMatchDetailScreen> createState() =>
      _FootballMatchDetailScreenState();
}

class _FootballMatchDetailScreenState
    extends ConsumerState<FootballMatchDetailScreen> {
  Timer? _pollTimer;

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(footballMatchDetailProvider(matchId: widget.matchId));
      ref.invalidate(footballMatchEventsKeyProvider(matchId: widget.matchId));
      ref.invalidate(footballMatchLineupsProvider(matchId: widget.matchId));
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(footballMatchDetailProvider(matchId: widget.matchId));

    final isFinished = detailAsync.valueOrNull?.isReallyFinished ?? false;
    if (isFinished) {
      _stopPolling();
    } else if (_pollTimer == null) {
      _startPolling();
    }

    final title = detailAsync.valueOrNull?.leagueName ?? '';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (detailAsync.valueOrNull?.matchTime != null)
                Text(
                  DateFormat(
                    context.locale.languageCode == 'zh'
                        ? 'yyyy年MM月dd日 EEEE ahh:mm'
                        : 'yyyy MMM dd EEEE hh:mmaa',
                    context.locale.toString(),
                  ).format(
                    DateTime.fromMillisecondsSinceEpoch(detailAsync.valueOrNull!.matchTime * 1000),
                  ),
                  style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
            ],
          ),
        ),
        body: Column(
          children: [
            _MatchHeader(matchId: widget.matchId),
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.pink,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.pink,
                indicatorWeight: 2,
                tabs: [
                  Tab(text: 'event.football.detail.stats'.tr()),
                  Tab(text: 'event.football.detail.events'.tr()),
                  Tab(text: 'event.football.detail.lineups'.tr()),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _StatsTab(matchId: widget.matchId),
                  _EventsTab(matchId: widget.matchId),
                  _LineupsTab(matchId: widget.matchId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Match Header ────────────────────────────────────────────────────────────

class _MatchHeader extends ConsumerWidget {
  const _MatchHeader({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(footballMatchDetailProvider(matchId: matchId));

    return Container(
      width: double.maxFinite,
      color: Colors.pink,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: detailAsync.when(
        loading: () => const SizedBox(height: 72),
        error: (_, __) => const SizedBox(height: 72),
        data: (detail) => _MatchHeaderContent(detail: detail),
      ),
    );
  }
}

class _MatchHeaderContent extends StatelessWidget {
  const _MatchHeaderContent({required this.detail});

  final FootballMatchDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home team
            Expanded(
              child: Column(
                children: [
                  _TeamLogo(url: detail.homeInfo.logo, size: 40),
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
                    statusId: detail.isReallyFinished ? 8 : detail.statusId,
                    label: detail.isReallyFinished
                        ? 'event.football.status.finished'.tr()
                        : detail.statusLabel,
                    liveColor: Colors.white,
                    staticColor: Colors.grey.shade200,
                  ),
                  _ScoreOrStatus(detail: detail),
                  const SizedBox(height: 4),
                  if (!detail.isReallyFinished &&
                      detail.homeInfo.halfTimeScore != null &&
                      detail.awayInfo.halfTimeScore != null)
                    Text(
                      '${'event.football.ht'.tr()} ${detail.homeInfo.halfTimeScore}-${detail.awayInfo.halfTimeScore}',
                      style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade300),
                    ),
                ],
              ),
            ),
            // Away team
            Expanded(
              child: Column(
                children: [
                  _TeamLogo(url: detail.awayInfo.logo, size: 40),
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
  const _ScoreOrStatus({required this.detail});

  final FootballMatchDetail detail;

  static const _noScoreStatuses = {0, 1, 13};
  static const _liveStatuses = {2, 3, 4, 5, 6, 7};

  @override
  Widget build(BuildContext context) {
    if (_noScoreStatuses.contains(detail.statusId)) {
      return Text(
        '-',
        style: context.textTheme.headlineSmall?.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    final color = _liveStatuses.contains(detail.statusId) ? Colors.white : Colors.black87;

    return RichText(
      text: TextSpan(
        style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: color),
        children: [
          TextSpan(text: detail.homeScore),
          TextSpan(
            text: ' - ',
            style: TextStyle(color: Colors.grey.shade200),
          ),
          TextSpan(text: detail.awayScore),
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
    final eventsAsync = ref.watch(footballMatchEventsKeyProvider(matchId: matchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.pink)),
      error: (e, st) {
        debugPrint('$e\n$st');
        return Center(
          child: Text(
            'event.error.load_failed'.tr(),
            style: TextStyle(color: Colors.grey.shade500),
          ),
        );
      },
      data: (events) {
        if (events.incidents.isEmpty) {
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
    1: Colors.pink, // Goal
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.pink),
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
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.pink)),
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

        final detail = ref.watch(footballMatchDetailProvider(matchId: widget.matchId)).valueOrNull;
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
                  color: Colors.pink,
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
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              width: 20,
                              height: 20,
                              child: homeIcon == null || homeIcon.isEmpty
                                  ? AvatarFallback(size: 20, iconSize: 14)
                                  : CachedNetworkImage(
                                      imageUrl: homeIcon,
                                      fit: BoxFit.contain,
                                      placeholder: (_, _) => Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: AvatarFallback(size: 20, iconSize: 14),
                                      ),
                                      errorBuilder: (_, _, _) =>
                                          AvatarFallback(size: 20, iconSize: 14),
                                    ),
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
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              width: 20,
                              height: 20,
                              child: awayIcon == null || awayIcon.isEmpty
                                  ? AvatarFallback(size: 20, iconSize: 14)
                                  : CachedNetworkImage(
                                      imageUrl: awayIcon,
                                      fit: BoxFit.contain,
                                      placeholder: (_, _) => Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: AvatarFallback(size: 20, iconSize: 14),
                                      ),
                                      errorBuilder: (_, _, _) =>
                                          AvatarFallback(size: 20, iconSize: 14),
                                    ),
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
              color: Colors.pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              '${player.shirtNumber}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.pink),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            height: 28,
            child: player.logo.isEmpty
                ? AvatarFallback(size: 28, iconSize: 14)
                : CachedNetworkImage(
                    imageUrl: player.logo,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: AvatarFallback(size: 28, iconSize: 14),
                    ),
                    errorBuilder: (_, _, _) => AvatarFallback(size: 28, iconSize: 14),
                  ),
          ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(footballMatchEventsKeyProvider(matchId: matchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.pink)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (events) {
        final stats = events.stats.where((s) => s.label != null && s.label!.isNotEmpty).toList();

        if (stats.isEmpty) {
          return Center(child: Text('event.football.detail.no_events'.tr()));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          children: stats.map((stat) => _StatRow(stat: stat)).toList(),
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
    final total = stat.home + stat.away;
    final homeRatio = total == 0 ? 0.5 : stat.home / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '${stat.home}',
                  style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
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
                width: 36,
                child: Text(
                  '${stat.away}',
                  style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Row(
                children: [
                  Container(
                    width: width * homeRatio,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3),
                        bottomLeft: Radius.circular(3),
                      ),
                    ),
                  ),
                  Container(
                    width: width * (1 - homeRatio),
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(3),
                        bottomRight: Radius.circular(3),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Shared ──────────────────────────────────────────────────────────────────

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: url.isEmpty
          ? AvatarFallback(size: size, iconSize: size * 0.5)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, _) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: AvatarFallback(size: size, iconSize: size * 0.5),
              ),
              errorBuilder: (_, _, _) => AvatarFallback(size: size, iconSize: size * 0.5),
            ),
    );
  }
}
