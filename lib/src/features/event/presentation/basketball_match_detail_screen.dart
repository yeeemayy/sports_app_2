import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_team_squad.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_detail_appbar.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class BasketballMatchDetailScreen extends ConsumerStatefulWidget {
  const BasketballMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<BasketballMatchDetailScreen> createState() =>
      _BasketballMatchDetailScreenState();
}

class _BasketballMatchDetailScreenState
    extends ConsumerState<BasketballMatchDetailScreen> {
  Timer? _eventsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(basketballRealtimeProvider.notifier).setWatchedIds(
        'detail:${widget.matchId}',
        [widget.matchId],
      );
    });
    // Poll events/key every 2 seconds for quarter scores and stats.
    _eventsTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      ref.invalidate(basketballMatchEventsKeyProvider(matchId: widget.matchId));
    });
  }

  @override
  void dispose() {
    _eventsTimer?.cancel();
    ref
        .read(basketballRealtimeProvider.notifier)
        .clearSource('detail:${widget.matchId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(basketballMatchDetailProvider(matchId: widget.matchId));

    // Re-fetch detail and events when status changes.
    ref.listen(
      basketballRealtimeProvider.select((map) => map[widget.matchId]?.statusId),
      (prev, next) {
        if (prev == null || next == null || prev == next) return;
        ref.invalidate(basketballMatchDetailProvider(matchId: widget.matchId));
        ref.invalidate(
            basketballMatchEventsKeyProvider(matchId: widget.matchId));
      },
    );

    final title = detailAsync.valueOrNull?.leagueName ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: MatchDetailAppBar(
          leagueName: title,
          matchTimestamp: detailAsync.valueOrNull?.matchTime,
        ),
        body: Column(
          children: [
            _BasketballMatchHeader(matchId: widget.matchId),
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.pink,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.pink,
                indicatorWeight: 2,
                tabs: [
                  Tab(text: 'event.basketball.detail.overview'.tr()),
                  Tab(text: 'event.basketball.detail.players'.tr()),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BasketballMatchBody(matchId: widget.matchId),
                  _SquadTab(matchId: widget.matchId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Match Header ─────────────────────────────────────────────────────────────

class _BasketballMatchHeader extends ConsumerWidget {
  const _BasketballMatchHeader({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(basketballMatchDetailProvider(matchId: matchId));
    final eventsAsync =
        ref.watch(basketballMatchEventsKeyProvider(matchId: matchId));
    final rt =
        ref.watch(basketballRealtimeProvider.select((map) => map[matchId]));

    return Container(
      width: double.maxFinite,
      color: Colors.pink,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: detailAsync.when(
        loading: () => const SizedBox(height: 72),
        error: (_, __) => const SizedBox(height: 72),
        data: (detail) => _BasketballMatchHeaderContent(
          detail: detail,
          rt: rt,
          eventsData: eventsAsync.valueOrNull,
        ),
      ),
    );
  }
}

class _BasketballMatchHeaderContent extends StatelessWidget {
  const _BasketballMatchHeaderContent({
    required this.detail,
    this.rt,
    this.eventsData,
  });

  final BasketballMatchDetail detail;
  final BasketballRealtimeData? rt;
  final BasketballMatchEventsData? eventsData;

  static String _periodKeyFromStatus(int statusId) {
    switch (statusId) {
      case 1:
        return 'event.basketball.period.not_started';
      case 2:
        return 'event.basketball.period.q1';
      case 3:
        return 'event.basketball.period.q1_over';
      case 4:
        return 'event.basketball.period.q2';
      case 5:
        return 'event.basketball.period.q2_over';
      case 6:
        return 'event.basketball.period.q3';
      case 7:
        return 'event.basketball.period.q3_over';
      case 8:
        return 'event.basketball.period.q4';
      case 9:
        return 'event.basketball.period.ot';
      case 10:
        return 'event.basketball.period.end';
      case 11:
        return 'event.basketball.period.interrupt';
      case 12:
        return 'event.basketball.period.cancel';
      case 13:
        return 'event.basketball.period.extension';
      case 14:
        return 'event.basketball.period.half';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Events API is the primary source; realtime is fallback.
    final effStatusId = eventsData?.statusId ?? rt?.statusId ?? detail.statusId;

    final homeTotal = eventsData?.homeTotal ??
        rt?.homeTotal ??
        detail.homeInfo.total;
    final awayTotal = eventsData?.awayTotal ??
        rt?.awayTotal ??
        detail.awayInfo.total;

    // Period label derived from statusId
    final periodKey = _periodKeyFromStatus(effStatusId);
    final periodLabel = periodKey.isNotEmpty
        ? periodKey.tr()
        : detail.statusDescription ?? '';

    // Clock
    final showClock = eventsData?.showClock ?? rt?.showClock ?? false;
    final clockDisplay = eventsData?.clockDisplay ?? rt?.clockDisplay ?? '';

    final isNoScore = const {0, 1}.contains(effStatusId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Home team
        Expanded(
          child: Column(
            children: [
              SportLogo(url: detail.homeInfo.logo, size: 48),
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
        // Centre: period, clock, score
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (periodLabel.isNotEmpty)
                Text(
                  periodLabel,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (showClock && clockDisplay.isNotEmpty)
                Text(
                  clockDisplay,
                  style: context.textTheme.labelSmall
                      ?.copyWith(color: Colors.white70),
                ),
              const SizedBox(height: 4),
              if (isNoScore)
                Text(
                  '-',
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w900,
                  ),
                )
              else
                RichText(
                  text: TextSpan(
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: '$homeTotal'),
                      TextSpan(
                        text: ' - ',
                        style: TextStyle(color: Colors.grey.shade200),
                      ),
                      TextSpan(text: '$awayTotal'),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Away team
        Expanded(
          child: Column(
            children: [
              SportLogo(url: detail.awayInfo.logo, size: 48),
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

// ─── Body (quarter scores + stats) ───────────────────────────────────────────

class _BasketballMatchBody extends ConsumerWidget {
  const _BasketballMatchBody({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(basketballMatchDetailProvider(matchId: matchId));
    final eventsAsync =
        ref.watch(basketballMatchEventsKeyProvider(matchId: matchId));

    return eventsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.pink)),
      error: (_, __) {
        // Show detail data only if events fail
        final detail = detailAsync.valueOrNull;
        if (detail == null) {
          return Center(
            child: Text(
              'event.error.load_failed'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        final homeQ = detail.homeInfo.sectionScores;
        final awayQ = detail.awayInfo.sectionScores;
        final homeTotal = detail.homeInfo.total;
        final awayTotal = detail.awayInfo.total;
        return _BodyContent(
          statusId: detail.statusId,
          homeLogo: detail.homeInfo.logo,
          awayLogo: detail.awayInfo.logo,
          homeQuarterScores: homeQ,
          awayQuarterScores: awayQ,
          homeTotal: homeTotal,
          awayTotal: awayTotal,
          stats: const [],
        );
      },
      data: (events) {
        final detail = detailAsync.valueOrNull;
        // Events API is the primary source; detail is fallback.
        final effStatusId =
            events?.statusId ?? detail?.statusId ?? 0;
        final homeQ = events?.homeQuarterScores ??
            detail?.homeInfo.sectionScores ??
            [];
        final awayQ = events?.awayQuarterScores ??
            detail?.awayInfo.sectionScores ??
            [];
        final homeTotal = events?.homeTotal ?? detail?.homeInfo.total ?? 0;
        final awayTotal = events?.awayTotal ?? detail?.awayInfo.total ?? 0;

        return _BodyContent(
          statusId: effStatusId,
          homeLogo: detail?.homeInfo.logo ?? '',
          awayLogo: detail?.awayInfo.logo ?? '',
          homeQuarterScores: homeQ,
          awayQuarterScores: awayQ,
          homeTotal: homeTotal,
          awayTotal: awayTotal,
          stats: events?.stats ?? [],
        );
      },
    );
  }
}

class _BodyContent extends StatelessWidget {
  const _BodyContent({
    required this.statusId,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeQuarterScores,
    required this.awayQuarterScores,
    required this.homeTotal,
    required this.awayTotal,
    required this.stats,
  });

  final int statusId;
  final String homeLogo;
  final String awayLogo;
  final List<int> homeQuarterScores;
  final List<int> awayQuarterScores;
  final int homeTotal;
  final int awayTotal;
  final List<BasketballStat> stats;

  List<BasketballStat> _getPlaceholderStats() {
    return List.generate(
      7,
      (i) => BasketballStat(
        typeCode: i + 1,
        homeValue: double.nan,
        awayValue: double.nan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsToShow = stats.isNotEmpty ? stats : _getPlaceholderStats();
    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        _QuarterScoreTable(
          statusId: statusId,
          homeLogo: homeLogo,
          awayLogo: awayLogo,
          homeQuarterScores: homeQuarterScores,
          awayQuarterScores: awayQuarterScores,
          homeTotal: homeTotal,
          awayTotal: awayTotal,
        ),
        Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
        ...statsToShow.map((s) => _BasketballStatRow(stat: s, isPlaceholder: stats.isEmpty)),
      ],
    );
  }
}

// ─── Quarter Score Table ──────────────────────────────────────────────────────

class _QuarterScoreTable extends StatelessWidget {
  const _QuarterScoreTable({
    required this.statusId,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeQuarterScores,
    required this.awayQuarterScores,
    required this.homeTotal,
    required this.awayTotal,
  });

  final int statusId;
  final String homeLogo;
  final String awayLogo;
  final List<int> homeQuarterScores;
  final List<int> awayQuarterScores;
  final int homeTotal;
  final int awayTotal;

  /// Returns 0-based index of the currently active quarter, or null.
  int? get _activeQuarterIndex {
    switch (statusId) {
      case 2:
        return 0;
      case 4:
        return 1;
      case 6:
        return 2;
      case 8:
        return 3;
      case 9:
      case 13:
        return 4;
      default:
        return null;
    }
  }

  /// Whether a quarter at [index] has been reached (score should be shown).
  bool _quarterReached(int index) {
    if (statusId >= 10) return true; // ended
    if (index == 4) return statusId >= 9; // OT
    return statusId >= 2 + index * 2;
  }

  bool get _showOT {
    final hasOtScore =
        (homeQuarterScores.length > 4 && homeQuarterScores[4] > 0) ||
            (awayQuarterScores.length > 4 && awayQuarterScores[4] > 0);
    return statusId == 9 || hasOtScore;
  }

  @override
  Widget build(BuildContext context) {
    final quarterKeys = [
      'event.basketball.detail.q1',
      'event.basketball.detail.q2',
      'event.basketball.detail.q3',
      'event.basketball.detail.q4',
      if (_showOT) 'event.basketball.detail.ot',
    ];
    final activeIdx = _activeQuarterIndex;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const SizedBox(width: 32), // logo placeholder
                ...List.generate(quarterKeys.length, (i) {
                  final isActive = i == activeIdx;
                  return Expanded(
                    child: Text(
                      quarterKeys[i].tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.pink : Colors.grey.shade600,
                      ),
                    ),
                  );
                }),
                SizedBox(
                  width: 44,
                  child: Text(
                    'event.basketball.detail.total'.tr(),
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
          // Home row
          _ScoreRow(
            logo: homeLogo,
            quarterScores: homeQuarterScores,
            total: homeTotal,
            showOT: _showOT,
            activeIdx: activeIdx,
            quarterReached: _quarterReached,
          ),
          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),
          // Away row
          _ScoreRow(
            logo: awayLogo,
            quarterScores: awayQuarterScores,
            total: awayTotal,
            showOT: _showOT,
            activeIdx: activeIdx,
            quarterReached: _quarterReached,
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.logo,
    required this.quarterScores,
    required this.total,
    required this.showOT,
    required this.activeIdx,
    required this.quarterReached,
  });

  final String logo;
  final List<int> quarterScores;
  final int total;
  final bool showOT;
  final int? activeIdx;
  final bool Function(int index) quarterReached;

  String _scoreAt(int index) {
    if (!quarterReached(index)) return '-';
    if (index >= quarterScores.length) return '-';
    return '${quarterScores[index]}';
  }

  @override
  Widget build(BuildContext context) {
    final colCount = showOT ? 5 : 4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SportLogo(url: logo, size: 24),
          ...List.generate(colCount, (i) {
            final isActive = i == activeIdx;
            return Expanded(
              child: Text(
                _scoreAt(i),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.pink : Colors.black87,
                ),
              ),
            );
          }),
          SizedBox(
            width: 44,
            child: Text(
              '$total',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats ────────────────────────────────────────────────────────────────────

class _BasketballStatRow extends StatelessWidget {
  const _BasketballStatRow({
    required this.stat,
    this.isPlaceholder = false,
  });

  final BasketballStat stat;
  final bool isPlaceholder;

  String _getDisplay(double value) {
    if (isPlaceholder || value.isNaN) return '-';
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final homeDisplay = _getDisplay(stat.homeValue);
    final awayDisplay = _getDisplay(stat.awayValue);

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
              homeDisplay,
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
            width: 60,
            child: Text(
              awayDisplay,
              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Squad Tab ────────────────────────────────────────────────────────────────

class _SquadTab extends ConsumerStatefulWidget {
  const _SquadTab({required this.matchId});

  final String matchId;

  @override
  ConsumerState<_SquadTab> createState() => _SquadTabState();
}

class _SquadTabState extends ConsumerState<_SquadTab>
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
    final detail =
        ref.watch(basketballMatchDetailProvider(matchId: widget.matchId)).valueOrNull;

    final homeTeamId = detail?.homeTeamId ?? '';
    final awayTeamId = detail?.awayTeamId ?? '';
    final homeLogo = detail?.homeInfo.logo ?? '';
    final awayLogo = detail?.awayInfo.logo ?? '';
    final homeName = detail?.homeName ?? '';
    final awayName = detail?.awayName ?? '';

    if (homeTeamId.isEmpty && awayTeamId.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.pink));
    }

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
              _TeamTab(logo: homeLogo, name: homeName),
              _TeamTab(logo: awayLogo, name: awayName),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _TeamSquadList(teamId: homeTeamId),
              _TeamSquadList(teamId: awayTeamId),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamTab extends StatelessWidget {
  const _TeamTab({required this.logo, required this.name});

  final String logo;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SportLogo(url: logo, size: 20),
              ),
            ),
            TextSpan(text: name),
          ],
        ),
      ),
    );
  }
}

class _TeamSquadList extends ConsumerWidget {
  const _TeamSquadList({required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final squadAsync =
        ref.watch(basketballTeamSquadProvider(teamId: teamId));

    return squadAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.pink)),
      error: (e, st) {
        debugPrint('$e\n$st');
        return Center(
          child: Text(
            // 'event.error.load_failed'.tr(),
            st.toString(),
            style: TextStyle(color: Colors.grey.shade500),
          ),
        );
      },
      data: (players) {
        if (players.isEmpty) {
          return Center(
            child: Text(
              'event.basketball.detail.no_squad'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        return ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, i) => _PlayerRow(player: players[i]),
        );
      },
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final BasketballPlayer player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              '${player.shirtNumber}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.pink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SportLogo(url: player.logo, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (player.height > 0 || player.weight > 0)
                  Text(
                    [
                      if (player.height > 0) '${player.height}cm',
                      if (player.weight > 0) '${player.weight}kg',
                    ].join(' / '),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          if (player.position.isNotEmpty)
            Text(
              player.position,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }
}

