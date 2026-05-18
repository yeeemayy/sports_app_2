import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/tennis_status.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class TennisMatchDetailScreen extends ConsumerStatefulWidget {
  const TennisMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<TennisMatchDetailScreen> createState() => _TennisMatchDetailScreenState();
}

class _TennisMatchDetailScreenState
    extends SportDetailScaffoldState<TennisMatchDetailScreen> {
  @override
  String get matchId => widget.matchId;

  @override
  SportType get sportType => SportType.tennis;

  @override
  Duration get eventsRefreshInterval => const Duration(seconds: 5);

  @override
  (String?, int?) watchDetail() {
    final v = ref.watch(matchDetailProvider(sport: SportType.tennis, matchId: matchId))
        .valueOrNull as TennisMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(BuildContext context) =>
      _TennisMatchHeader(matchId: matchId);

  @override
  List<Tab> buildTabs(BuildContext context) => [
    Tab(text: 'event.tennis.detail.score'.tr()),
    Tab(text: 'event.tennis.detail.stats'.tr()),
    Tab(text: 'event.tennis.detail.situation'.tr()),
  ];

  @override
  List<Widget> buildTabViews(BuildContext context) => [
    _ScoreTab(matchId: matchId),
    _StatsTab(matchId: matchId),
    _SituationTab(matchId: matchId),
  ];
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _TennisMatchHeader extends ConsumerWidget {
  const _TennisMatchHeader({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.tennis, matchId: matchId));
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.tennis, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.tennis).select((map) => map[matchId] as TennisRealtimeData?),
    );

    return SportDetailHeaderShell<TennisMatchDetail>(
      detailAsync: detailAsync,
      skeletonHeight: 80,
      builder: (detail) => _TennisHeaderContent(
        detail: detail,
        rt: rt,
        eventsData: eventsAsync.valueOrNull as TennisMatchEventsData?,
      ),
    );
  }
}

class _TennisHeaderContent extends StatelessWidget {
  const _TennisHeaderContent({required this.detail, this.rt, this.eventsData});

  final TennisMatchDetail detail;
  final TennisRealtimeData? rt;
  final TennisMatchEventsData? eventsData;

  @override
  Widget build(BuildContext context) {
    final effStatusId = eventsData?.statusId ?? rt?.statusId ?? detail.statusId;

    final homeTotal = eventsData?.homeTotal ?? rt?.homeTotal ?? detail.homeInfo.totalScore;
    final awayTotal = eventsData?.awayTotal ?? rt?.awayTotal ?? detail.awayInfo.totalScore;

    final homeSets = eventsData?.homeSets ?? rt?.homeSets ?? detail.homeInfo.setSores;
    final awaySets = eventsData?.awaySets ?? rt?.awaySets ?? detail.awayInfo.setSores;

    final servingSide = eventsData?.servingSide ?? rt?.servingSide ?? detail.servingSide ?? 0;

    final isLive = const {3, 51, 52, 53, 54, 55}.contains(effStatusId);
    final isNotStarted = effStatusId == 1;

    final statusLabel = tennisStatusLabel(effStatusId, detail.statusDescription);

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
            // Centre: status + score display
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
                    RichText(
                      text: TextSpan(
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: '$homeTotal'),
                          const TextSpan(text: ' - '),
                          TextSpan(text: '$awayTotal'),
                        ],
                      ),
                    ),
                    if (isLive && homeSets.isNotEmpty)
                      Text(
                        '${homeSets.last}:${awaySets.last}',
                        style: context.textTheme.labelMedium?.copyWith(color: Colors.white70),
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
            child: Text('|', style: TextStyle(color: Colors.white54, fontSize: 18)),
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
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.tennis, matchId: matchId));
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.tennis, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.tennis).select((map) => map[matchId] as TennisRealtimeData?),
    );

    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final detail = obj as TennisMatchDetail;
        final ev = eventsAsync.valueOrNull as TennisMatchEventsData?;
        final effStatusId = ev?.statusId ?? rt?.statusId ?? detail.statusId;
        final homeSets =
            ev?.homeSets ?? rt?.homeSets ?? detail.homeInfo.setSores;
        final awaySets =
            ev?.awaySets ?? rt?.awaySets ?? detail.awayInfo.setSores;
        final homeTotal =
            ev?.homeTotal ?? rt?.homeTotal ?? detail.homeInfo.totalScore;
        final awayTotal =
            ev?.awayTotal ?? rt?.awayTotal ?? detail.awayInfo.totalScore;
        final homePt = ev?.homePt ?? rt?.homePt ?? detail.homePt ?? '';
        final awayPt = ev?.awayPt ?? rt?.awayPt ?? detail.awayPt ?? '';
        final servingSide =
            ev?.servingSide ?? rt?.servingSide ?? detail.servingSide ?? 0;

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

  Widget _buildBasicTable(BuildContext context) {
    final s1Label = 'event.tennis.detail.set_n'.tr(namedArgs: {'n': '1'});
    final s2Label = 'event.tennis.detail.set_n'.tr(namedArgs: {'n': '2'});
    final ftLabel = 'event.tennis.detail.total'.tr();
    final headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: context.appTheme.greyText,
    );

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
                    SizedBox(
                      width: 44,
                      child: Text(s1Label, textAlign: TextAlign.center, style: headerStyle),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(s2Label, textAlign: TextAlign.center, style: headerStyle),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(ftLabel, textAlign: TextAlign.center, style: headerStyle),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: context.appTheme.shimmerBase),
              _BasicPlayerRow(
                name: homeName,
                logo: homeLogo,
                total: homeTotal,
                isServing: isLive && servingSide == 1,
              ),
              Divider(height: 1, thickness: 0.5, color: context.appTheme.shimmerHighlight),
              _BasicPlayerRow(
                name: awayName,
                logo: awayLogo,
                total: awayTotal,
                isServing: isLive && servingSide == 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final setCount = homeSets.length;
    final activeIdx = _activeSetIndex;
    final showPt = isLive && homePt.isNotEmpty;

    if (setCount == 0) return _buildBasicTable(context);

    final setLabels = List.generate(
      setCount,
      (i) => 'event.tennis.detail.set_n'.tr(namedArgs: {'n': '${i + 1}'}),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        Container(
          color: context.appTheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    ...List.generate(setCount, (i) {
                      final isActive = i == activeIdx;
                      return Expanded(
                        child: Text(
                          setLabels[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppColors.accent : context.appTheme.greyText,
                          ),
                        ),
                      );
                    }),
                    if (showPt)
                      Expanded(
                        child: Text(
                          'event.tennis.detail.pt'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        'event.tennis.detail.total'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.appTheme.greyText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: context.appTheme.shimmerBase),
              // Home row
              _PlayerScoreRow(
                name: homeName,
                setScores: homeSets,
                total: homeTotal,
                ptScore: showPt ? homePt : null,
                activeIdx: activeIdx,
              ),
              Divider(height: 1, thickness: 0.5, color: context.appTheme.shimmerHighlight),
              // Away row
              _PlayerScoreRow(
                name: awayName,
                setScores: awaySets,
                total: awayTotal,
                ptScore: showPt ? awayPt : null,
                activeIdx: activeIdx,
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
    required this.name,
    required this.setScores,
    required this.total,
    this.ptScore,
    required this.activeIdx,
  });

  final String name;
  final List<int> setScores;
  final int total;
  final String? ptScore;
  final int? activeIdx;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
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
                  color: isActive ? AppColors.accent : context.appTheme.baseText,
                ),
              ),
            );
          }),
          if (ptScore != null)
            Expanded(
              child: Text(
                ptScore!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          Expanded(
            child: Text(
              '$total',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicPlayerRow extends StatelessWidget {
  const _BasicPlayerRow({
    required this.name,
    required this.logo,
    required this.total,
    required this.isServing,
  });

  final String name;
  final String logo;
  final int total;
  final bool isServing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SportLogo(url: logo, size: 24),
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
          const SizedBox(
            width: 44,
            child: Text(
              '-',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(
            width: 44,
            child: Text(
              '-',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$total',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accent),
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

class _StatsTabState extends ConsumerState<_StatsTab> {
  int _selectedIdx = 0;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.tennis, matchId: widget.matchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final events = obj as TennisMatchEventsData?;
        if (events == null || events.statSets.isEmpty) {
          return Center(
            child: Text(
              'event.tennis.detail.no_stats'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        final setIndices = events.statSets.map((s) => s.setIndex).toSet().toList()..sort();
        final safeIdx = _selectedIdx.clamp(0, setIndices.length - 1);

        final tabLabels = setIndices.map((idx) {
          if (idx == 0) return 'event.tennis.detail.overall'.tr();
          return 'event.tennis.detail.set_n'.tr(namedArgs: {'n': '$idx'});
        }).toList();

        final stats = events.statSets
            .where((s) => s.setIndex == setIndices[safeIdx])
            .expand((s) => s.stats)
            .toList();

        return Column(
          children: [
            Container(
              color: context.appTheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(tabLabels.length, (i) {
                    final isSelected = i == safeIdx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIdx = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent : context.appTheme.grey_3,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tabLabels[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : context.appTheme.grey_4,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Expanded(child: _StatsList(stats: stats)),
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
          LayoutBuilder(
            builder: (context, constraints) {
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
                              color: AppColors.accent,
                              borderRadius: BorderRadius.only(topRight: radius, bottomRight: radius),
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

class _SituationTab extends ConsumerWidget {
  const _SituationTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.tennis, matchId: matchId));
    final detail = ref.watch(matchDetailProvider(sport: SportType.tennis, matchId: matchId)).valueOrNull as TennisMatchDetail?;

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final events = obj as TennisMatchEventsData?;
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
              .map(
                (setTimeline) => _SetTimelineSection(
                  setTimeline: setTimeline,
                  homeName: detail?.homeName ?? '',
                  awayName: detail?.awayName ?? '',
                  homeLogo: detail?.homeInfo.logo ?? '',
                  awayLogo: detail?.awayInfo.logo ?? '',
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SetTimelineSection extends StatelessWidget {
  const _SetTimelineSection({
    required this.setTimeline,
    required this.homeName,
    required this.awayName,
    required this.homeLogo,
    required this.awayLogo,
  });

  final TennisSetTimeline setTimeline;
  final String homeName;
  final String awayName;
  final String homeLogo;
  final String awayLogo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              const Icon(Icons.sports_tennis, color: AppColors.accent, size: 22),
              const SizedBox(width: 8),
              Text(
                'event.tennis.detail.set_n'.tr(namedArgs: {'n': '${setTimeline.set}'}),
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: context.appTheme.shimmerBase),
        ...setTimeline.rounds.map(
          (r) => _RoundCard(
            round: r,
            homeName: homeName,
            awayName: awayName,
            homeLogo: homeLogo,
            awayLogo: awayLogo,
          ),
        ),
      ],
    );
  }
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    required this.round,
    required this.homeName,
    required this.awayName,
    required this.homeLogo,
    required this.awayLogo,
  });

  final TennisRound round;
  final String homeName;
  final String awayName;
  final String homeLogo;
  final String awayLogo;

  @override
  Widget build(BuildContext context) {
    final servingName = round.serve == 1
        ? homeName
        : round.serve == 2
            ? awayName
            : '';
    final servingLogo = round.serve == 1
        ? homeLogo
        : round.serve == 2
            ? awayLogo
            : '';
    final scoreText =
        round.isComplete ? '${round.homeScore} - ${round.awayScore}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                'event.tennis.detail.round_n'.tr(namedArgs: {'n': '${round.round}'}),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 8),
              SportLogo(url: servingLogo, size: 24, circular: true),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: context.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: servingName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (servingName.isNotEmpty) ...[
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: 'event.tennis.detail.serving'.tr(),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (scoreText.isNotEmpty)
                Text(
                  scoreText,
                  style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
            ],
          ),
        ),
        if (round.points.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: round.points
                  .map((pt) => _PointChip(home: pt.home, away: pt.away))
                  .toList(),
            ),
          ),
        Divider(height: 1, thickness: 0.5, color: context.appTheme.shimmerBase),
      ],
    );
  }
}


class _PointChip extends StatelessWidget {
  const _PointChip({required this.home, required this.away});

  final String home;
  final String away;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$home - $away',
        style: context.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.appTheme.greyText,
        ),
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
      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    );
  }
}

/// Tennis player avatar shown in the match header.
///
/// Wraps [SportLogo] in a white circular container to distinguish player photos
/// from the pink background. Falls back to [SportLogo]'s avatar placeholder.
class _PlayerLogo extends StatelessWidget {
  const _PlayerLogo({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: ClipOval(child: SportLogo(url: url, size: size)),
    );
  }
}
