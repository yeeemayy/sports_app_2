import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_realtime_data.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';

class TennisMatchDetailScreen extends ConsumerStatefulWidget {
  const TennisMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<TennisMatchDetailScreen> createState() =>
      _TennisMatchDetailScreenState();
}

class _TennisMatchDetailScreenState
    extends ConsumerState<TennisMatchDetailScreen> {
  Timer? _eventsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(tennisRealtimeProvider.notifier)
          .setWatchedIds('detail:${widget.matchId}', [widget.matchId]);
    });
    _eventsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      ref.invalidate(tennisMatchEventsProvider(matchId: widget.matchId));
    });
  }

  @override
  void dispose() {
    _eventsTimer?.cancel();
    ref
        .read(tennisRealtimeProvider.notifier)
        .clearSource('detail:${widget.matchId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(tennisMatchDetailProvider(matchId: widget.matchId));

    ref.listen(
      tennisRealtimeProvider.select((map) => map[widget.matchId]?.statusId),
      (prev, next) {
        if (prev == null || next == null || prev == next) return;
        ref.invalidate(tennisMatchDetailProvider(matchId: widget.matchId));
        ref.invalidate(tennisMatchEventsProvider(matchId: widget.matchId));
      },
    );

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
              if (detailAsync.valueOrNull?.matchTime != null &&
                  detailAsync.valueOrNull!.matchTime > 0)
                Text(
                  DateFormat(
                    context.locale.languageCode == 'zh'
                        ? 'yyyy年MM月dd日 EEEE ahh:mm'
                        : 'yyyy MMM dd EEEE hh:mmaa',
                    context.locale.toString(),
                  ).format(
                    DateTime.fromMillisecondsSinceEpoch(
                        detailAsync.valueOrNull!.matchTime * 1000),
                  ),
                  style: context.textTheme.labelSmall
                      ?.copyWith(color: Colors.white),
                ),
            ],
          ),
        ),
        body: Column(
          children: [
            _TennisMatchHeader(matchId: widget.matchId),
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.pink,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.pink,
                indicatorWeight: 2,
                tabs: [
                  Tab(text: 'event.tennis.detail.score'.tr()),
                  Tab(text: 'event.tennis.detail.stats'.tr()),
                  Tab(text: 'event.tennis.detail.situation'.tr()),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ScoreTab(matchId: widget.matchId),
                  _StatsTab(matchId: widget.matchId),
                  _SituationTab(matchId: widget.matchId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _TennisMatchHeader extends ConsumerWidget {
  const _TennisMatchHeader({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(tennisMatchDetailProvider(matchId: matchId));
    final eventsAsync = ref.watch(tennisMatchEventsProvider(matchId: matchId));
    final rt = ref.watch(tennisRealtimeProvider.select((map) => map[matchId]));

    return Container(
      width: double.maxFinite,
      color: Colors.pink,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: detailAsync.when(
        loading: () => const SizedBox(height: 80),
        error: (_, __) => const SizedBox(height: 80),
        data: (detail) => _TennisHeaderContent(
          detail: detail,
          rt: rt,
          eventsData: eventsAsync.valueOrNull,
        ),
      ),
    );
  }
}

class _TennisHeaderContent extends StatelessWidget {
  const _TennisHeaderContent({
    required this.detail,
    this.rt,
    this.eventsData,
  });

  final TennisMatchDetail detail;
  final TennisRealtimeData? rt;
  final TennisMatchEventsData? eventsData;

  String _statusLabel(int statusId, String? desc) {
    switch (statusId) {
      case 1:
        return 'event.tennis.status.pre'.tr();
      case 3:
        return 'event.tennis.status.live'.tr();
      case 51:
        return 'event.tennis.status.s1'.tr();
      case 52:
        return 'event.tennis.status.s2'.tr();
      case 53:
        return 'event.tennis.status.s3'.tr();
      case 54:
        return 'event.tennis.status.s4'.tr();
      case 55:
        return 'event.tennis.status.s5'.tr();
      case 100:
        return 'event.tennis.status.ft'.tr();
      case 20:
      case 22:
      case 23:
        return 'event.tennis.status.wo'.tr();
      case 21:
      case 24:
      case 25:
        return 'event.tennis.status.ret'.tr();
      case 26:
      case 27:
        return 'event.tennis.status.def'.tr();
      default:
        return desc ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final effStatusId =
        eventsData?.statusId ?? rt?.statusId ?? detail.statusId;

    final homeTotal =
        eventsData?.homeTotal ?? rt?.homeTotal ?? detail.homeInfo.totalScore;
    final awayTotal =
        eventsData?.awayTotal ?? rt?.awayTotal ?? detail.awayInfo.totalScore;

    final homeSets = eventsData?.homeSets ?? rt?.homeSets ?? detail.homeInfo.setSores;
    final awaySets = eventsData?.awaySets ?? rt?.awaySets ?? detail.awayInfo.setSores;

    final homePt = eventsData?.homePt ?? rt?.homePt ?? detail.homePt ?? '';
    final awayPt = eventsData?.awayPt ?? rt?.awayPt ?? detail.awayPt ?? '';

    final servingSide =
        eventsData?.servingSide ?? rt?.servingSide ?? detail.servingSide ?? 0;

    final isLive = const {3, 51, 52, 53, 54, 55}.contains(effStatusId);
    final isNotStarted = effStatusId == 1;

    final statusLabel = _statusLabel(effStatusId, detail.statusDescription);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home player
            Expanded(
              child: Column(
                children: [
                  _PlayerLogo(url: detail.homeInfo.logo, size: 48),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLive && servingSide == 1) _ServingDot(),
                      Flexible(
                        child: Text(
                          detail.homeName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Centre: status + set scores + game point
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (statusLabel.isNotEmpty)
                    Text(
                      statusLabel,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (isNotStarted)
                    Text(
                      '-',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: Colors.grey.shade300,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  else ...[
                    // Set score grid
                    _SetScoreGrid(
                      homeSets: homeSets,
                      awaySets: awaySets,
                      homeTotal: homeTotal,
                      awayTotal: awayTotal,
                      statusId: effStatusId,
                    ),
                    // Current game point
                    if (isLive && homePt.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '$homePt : $awayPt',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            // Away player
            Expanded(
              child: Column(
                children: [
                  _PlayerLogo(url: detail.awayInfo.logo, size: 48),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          detail.awayName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (isLive && servingSide == 2) _ServingDot(),
                    ],
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

class _SetScoreGrid extends StatelessWidget {
  const _SetScoreGrid({
    required this.homeSets,
    required this.awaySets,
    required this.homeTotal,
    required this.awayTotal,
    required this.statusId,
  });

  final List<int> homeSets;
  final List<int> awaySets;
  final int homeTotal;
  final int awayTotal;
  final int statusId;

  int? get _activeSetIndex {
    switch (statusId) {
      case 51:
        return 0;
      case 52:
        return 1;
      case 53:
        return 2;
      case 54:
        return 3;
      case 55:
        return 4;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final setCount = homeSets.length;
    final activeIdx = _activeSetIndex;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Per-set
        ...List.generate(setCount, (i) {
          final isActive = i == activeIdx;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${homeSets[i]}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${awaySets[i]}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }),
        // Separator
        if (setCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '|',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
          ),
        // Sets won
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$homeTotal',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              '$awayTotal',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
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
    final detailAsync = ref.watch(tennisMatchDetailProvider(matchId: matchId));
    final eventsAsync = ref.watch(tennisMatchEventsProvider(matchId: matchId));
    final rt = ref.watch(tennisRealtimeProvider.select((map) => map[matchId]));

    return detailAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.pink)),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ),
      data: (detail) {
        final effStatusId =
            eventsAsync.valueOrNull?.statusId ?? rt?.statusId ?? detail.statusId;
        final homeSets = eventsAsync.valueOrNull?.homeSets ??
            rt?.homeSets ??
            detail.homeInfo.setSores;
        final awaySets = eventsAsync.valueOrNull?.awaySets ??
            rt?.awaySets ??
            detail.awayInfo.setSores;
        final homeTotal = eventsAsync.valueOrNull?.homeTotal ??
            rt?.homeTotal ??
            detail.homeInfo.totalScore;
        final awayTotal = eventsAsync.valueOrNull?.awayTotal ??
            rt?.awayTotal ??
            detail.awayInfo.totalScore;
        final homePt =
            eventsAsync.valueOrNull?.homePt ?? rt?.homePt ?? detail.homePt ?? '';
        final awayPt =
            eventsAsync.valueOrNull?.awayPt ?? rt?.awayPt ?? detail.awayPt ?? '';
        final servingSide = eventsAsync.valueOrNull?.servingSide ??
            rt?.servingSide ??
            detail.servingSide ??
            0;

        return _SetScoreTable(
          statusId: effStatusId,
          homeName: detail.homeName,
          awayName: detail.awayName,
          homeLogo: detail.homeInfo.logo,
          awayLogo: detail.awayInfo.logo,
          homeSets: homeSets,
          awaySets: awaySets,
          homeTotal: homeTotal,
          awayTotal: awayTotal,
          homePt: homePt,
          awayPt: awayPt,
          servingSide: servingSide,
        );
      },
    );
  }
}

class _SetScoreTable extends StatelessWidget {
  const _SetScoreTable({
    required this.statusId,
    required this.homeName,
    required this.awayName,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeSets,
    required this.awaySets,
    required this.homeTotal,
    required this.awayTotal,
    required this.homePt,
    required this.awayPt,
    required this.servingSide,
  });

  final int statusId;
  final String homeName;
  final String awayName;
  final String homeLogo;
  final String awayLogo;
  final List<int> homeSets;
  final List<int> awaySets;
  final int homeTotal;
  final int awayTotal;
  final String homePt;
  final String awayPt;
  final int servingSide;

  static const _liveStatuses = {3, 51, 52, 53, 54, 55};

  bool get isLive => _liveStatuses.contains(statusId);

  int? get _activeSetIndex {
    switch (statusId) {
      case 51:
        return 0;
      case 52:
        return 1;
      case 53:
        return 2;
      case 54:
        return 3;
      case 55:
        return 4;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final setCount = homeSets.length;
    final activeIdx = _activeSetIndex;
    final showPt = isLive && homePt.isNotEmpty;

    final setLabels = List.generate(
        setCount,
        (i) => 'event.tennis.detail.set_n'
            .tr(namedArgs: {'n': '${i + 1}'}));

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
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
                    const SizedBox(width: 32),
                    ...List.generate(setCount, (i) {
                      final isActive = i == activeIdx;
                      return Expanded(
                        child: Text(
                          setLabels[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.pink : Colors.grey.shade600,
                          ),
                        ),
                      );
                    }),
                    if (showPt)
                      SizedBox(
                        width: 40,
                        child: Text(
                          'event.tennis.detail.pt'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        'event.tennis.detail.total'.tr(),
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
              _PlayerScoreRow(
                logo: homeLogo,
                setScores: homeSets,
                total: homeTotal,
                ptScore: showPt ? homePt : null,
                activeIdx: activeIdx,
                isServing: isLive && servingSide == 1,
              ),
              Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),
              // Away row
              _PlayerScoreRow(
                logo: awayLogo,
                setScores: awaySets,
                total: awayTotal,
                ptScore: showPt ? awayPt : null,
                activeIdx: activeIdx,
                isServing: isLive && servingSide == 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerScoreRow extends StatelessWidget {
  const _PlayerScoreRow({
    required this.logo,
    required this.setScores,
    required this.total,
    this.ptScore,
    required this.activeIdx,
    required this.isServing,
  });

  final String logo;
  final List<int> setScores;
  final int total;
  final String? ptScore;
  final int? activeIdx;
  final bool isServing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _PlayerLogoSmall(url: logo),
              if (isServing)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          ...List.generate(setScores.length, (i) {
            final isActive = i == activeIdx;
            return Expanded(
              child: Text(
                '${setScores[i]}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.pink : Colors.black87,
                ),
              ),
            );
          }),
          if (ptScore != null)
            SizedBox(
              width: 40,
              child: Text(
                ptScore!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.pink,
                ),
              ),
            ),
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

// ─── Stats Tab ────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerStatefulWidget {
  const _StatsTab({required this.matchId});

  final String matchId;

  @override
  ConsumerState<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<_StatsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabCount = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _rebuildTabs(int count) {
    if (_tabCount != count) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _tabController.dispose();
          _tabController = TabController(length: count, vsync: this);
          _tabCount = count;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync =
        ref.watch(tennisMatchEventsProvider(matchId: widget.matchId));

    return eventsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.pink)),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ),
      data: (events) {
        if (events == null || events.statSets.isEmpty) {
          return Center(
            child: Text(
              'event.tennis.detail.no_stats'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        // Build tab labels: Overall + per set
        final setIndices =
            events.statSets.map((s) => s.setIndex).toSet().toList()..sort();
        final tabCount = setIndices.length;
        _rebuildTabs(tabCount);

        final tabLabels = setIndices.map((idx) {
          if (idx == 0) return 'event.tennis.detail.overall'.tr();
          return 'event.tennis.detail.set_n'
              .tr(namedArgs: {'n': '$idx'});
        }).toList();

        return Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.pink,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.pink,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: tabLabels.map((l) => Tab(text: l)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: setIndices.map((idx) {
                  final stats = events.statSets
                      .where((s) => s.setIndex == idx)
                      .expand((s) => s.stats)
                      .toList();
                  return _StatsList(stats: stats);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatsList extends StatelessWidget {
  const _StatsList({required this.stats});

  final List<TennisStat> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Center(
        child: Text(
          'event.tennis.detail.no_stats'.tr(),
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: stats.length,
      itemBuilder: (context, i) => _TennisStatRow(stat: stats[i]),
    );
  }
}

class _TennisStatRow extends StatelessWidget {
  const _TennisStatRow({required this.stat});

  final TennisStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              stat.homeDisplay,
              style: context.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Text(
              stat.labelKey.isNotEmpty ? stat.labelKey.tr() : '${stat.typeCode}',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              stat.awayDisplay,
              style: context.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Situation Tab ────────────────────────────────────────────────────────────

class _SituationTab extends ConsumerWidget {
  const _SituationTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync =
        ref.watch(tennisMatchEventsProvider(matchId: matchId));

    return eventsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.pink)),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ),
      data: (events) {
        if (events == null || events.timeline.isEmpty) {
          return Center(
            child: Text(
              'event.tennis.detail.no_situation'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: events.timeline
              .map((setTimeline) => _SetTimelineSection(setTimeline: setTimeline))
              .toList(),
        );
      },
    );
  }
}

class _SetTimelineSection extends StatelessWidget {
  const _SetTimelineSection({required this.setTimeline});

  final TennisSetTimeline setTimeline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Set header
        Container(
          width: double.maxFinite,
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'event.tennis.detail.set_n'
                .tr(namedArgs: {'n': '${setTimeline.set}'}),
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        // Column headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  'event.tennis.detail.game'.tr(),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'event.tennis.detail.score'.tr(),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'event.tennis.detail.points'.tr(),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
        ...setTimeline.rounds.map((r) => _RoundRow(round: r)),
      ],
    );
  }
}

class _RoundRow extends StatelessWidget {
  const _RoundRow({required this.round});

  final TennisRound round;

  @override
  Widget build(BuildContext context) {
    final scoreText = round.isComplete
        ? '${round.homeScore} - ${round.awayScore}'
        : '-';

    // Last point in the sequence
    final lastPt = round.points.isNotEmpty ? round.points.last : null;
    final ptText = lastPt != null ? '${lastPt.home} - ${lastPt.away}' : '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Game number + serve indicator
          SizedBox(
            width: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (round.serve == 1)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  '${round.round}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (round.serve == 2)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              scoreText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ptText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────────

class _ServingDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PlayerLogo extends StatelessWidget {
  const _PlayerLogo({required this.url, required this.size});

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
              errorBuilder: (_, _, _) =>
                  AvatarFallback(size: size, iconSize: size * 0.5),
            ),
    );
  }
}

class _PlayerLogoSmall extends StatelessWidget {
  const _PlayerLogoSmall({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: url.isEmpty
          ? AvatarFallback(size: 24, iconSize: 12)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, _) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: AvatarFallback(size: 24, iconSize: 12),
              ),
              errorBuilder: (_, _, _) => AvatarFallback(size: 24, iconSize: 12),
            ),
    );
  }
}