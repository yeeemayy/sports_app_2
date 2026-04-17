import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/badminton_status.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_realtime_data.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class BadmintonMatchDetailScreen extends ConsumerStatefulWidget {
  const BadmintonMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<BadmintonMatchDetailScreen> createState() => _BadmintonMatchDetailScreenState();
}

class _BadmintonMatchDetailScreenState
    extends SportDetailScaffoldState<BadmintonMatchDetailScreen> {
  @override
  String get matchId => widget.matchId;

  @override
  SportType get sportType => SportType.badminton;

  @override
  Duration get eventsRefreshInterval => const Duration(seconds: 5);

  @override
  (String?, int?) watchDetail() {
    final v = ref.watch(matchDetailProvider(sport: SportType.badminton, matchId: matchId))
        .valueOrNull as BadmintonMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(BuildContext context) =>
      _BadmintonMatchHeader(matchId: matchId);

  @override
  List<Tab> buildTabs(BuildContext context) => [
    Tab(text: 'event.badminton.detail.score'.tr()),
    Tab(text: 'event.badminton.detail.stats'.tr()),
  ];

  @override
  List<Widget> buildTabViews(BuildContext context) => [
    _ScoreTab(matchId: matchId),
    _StatsTab(matchId: matchId),
  ];
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _BadmintonMatchHeader extends ConsumerWidget {
  const _BadmintonMatchHeader({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.badminton, matchId: matchId));
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.badminton, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.badminton).select((map) => map[matchId] as BadmintonRealtimeData?),
    );

    return SportDetailHeaderShell<BadmintonMatchDetail>(
      detailAsync: detailAsync,
      skeletonHeight: 80,
      builder: (detail) => _BadmintonHeaderContent(
        detail: detail,
        rt: rt,
        eventsData: eventsAsync.valueOrNull as BadmintonMatchEventsData?,
      ),
    );
  }
}

class _BadmintonHeaderContent extends StatelessWidget {
  const _BadmintonHeaderContent({required this.detail, this.rt, this.eventsData});

  final BadmintonMatchDetail detail;
  final BadmintonRealtimeData? rt;
  final BadmintonMatchEventsData? eventsData;

  @override
  Widget build(BuildContext context) {
    final effStatusId = eventsData?.statusId ?? rt?.statusId ?? detail.statusId;

    final homeTotal = eventsData?.homeTotal ?? rt?.homeTotal ?? detail.homeInfo.totalScore;
    final awayTotal = eventsData?.awayTotal ?? rt?.awayTotal ?? detail.awayInfo.totalScore;

    final isNotStarted = effStatusId == 1;
    final isLive = effStatusId >= 3 && effStatusId < 100;

    final statusLabel = badmintonStatusLabel(effStatusId, detail.statusDescription);

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
            // Centre: status + score
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
                          TextSpan(text: '$homeTotal'),
                          const TextSpan(text: ' - '),
                          TextSpan(text: '$awayTotal'),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      constraints: const BoxConstraints(minWidth: 50),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusLabel.isNotEmpty ? Colors.orange : Colors.white,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel.isNotEmpty ? statusLabel : 'common.unknown'.tr(),
                        textAlign: TextAlign.center,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: statusLabel.isNotEmpty ? Colors.white : AppColors.primary,
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
        if (setCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('|', style: TextStyle(color: Colors.white54, fontSize: 18)),
          ),
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

class _PlayerLogo extends StatelessWidget {
  const _PlayerLogo({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: ClipOval(
        child: SportLogo(url: url, size: size),
      ),
    );
  }
}

// ─── Score Tab ────────────────────────────────────────────────────────────────

class _ScoreTab extends ConsumerWidget {
  const _ScoreTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.badminton, matchId: matchId));
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.badminton, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(SportType.badminton).select((map) => map[matchId] as BadmintonRealtimeData?),
    );

    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final detail = obj as BadmintonMatchDetail;
        final ev = eventsAsync.valueOrNull as BadmintonMatchEventsData?;
        final effStatusId = ev?.statusId ?? rt?.statusId ?? detail.statusId;
        final homeSets =
            ev?.homeSets ?? rt?.homeSets ?? detail.homeInfo.setScores;
        final awaySets =
            ev?.awaySets ?? rt?.awaySets ?? detail.awayInfo.setScores;
        final homeTotal =
            ev?.homeTotal ?? rt?.homeTotal ?? detail.homeInfo.totalScore;
        final awayTotal =
            ev?.awayTotal ?? rt?.awayTotal ?? detail.awayInfo.totalScore;

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

    if (setCount == 0) {
      return _buildBasicTable(context);
    }

    final setLabels = List.generate(
      setCount,
      (i) => 'event.badminton.detail.set_n'.tr(namedArgs: {'n': '${i + 1}'}),
    );

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
                            color: isActive ? AppColors.primary : Colors.grey.shade600,
                          ),
                        ),
                      );
                    }),
                    Expanded(
                      child: Text(
                        'event.badminton.detail.total'.tr(),
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
              _PlayerScoreRow(
                name: homeName,
                setScores: homeSets,
                total: homeTotal,
                activeIdx: activeIdx,
              ),
              Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),
              _PlayerScoreRow(
                name: awayName,
                setScores: awaySets,
                total: awayTotal,
                activeIdx: activeIdx,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicTable(BuildContext context) {
    final s1Label = 'event.badminton.detail.set_n'.tr(namedArgs: {'n': '1'});
    final s2Label = 'event.badminton.detail.set_n'.tr(namedArgs: {'n': '2'});
    final ftLabel = 'event.badminton.detail.total'.tr();
    final headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade600,
    );

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
              Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
              _BasicPlayerRow(name: homeName, logo: homeLogo, total: homeTotal),
              Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),
              _BasicPlayerRow(name: awayName, logo: awayLogo, total: awayTotal),
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
    required this.activeIdx,
  });

  final String name;
  final List<int> setScores;
  final int total;
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
                  color: isActive ? AppColors.primary : Colors.black87,
                ),
              ),
            );
          }),
          Expanded(
            child: Text(
              '$total',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicPlayerRow extends StatelessWidget {
  const _BasicPlayerRow({required this.name, required this.logo, required this.total});

  final String name;
  final String logo;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SportLogo(url: logo, size: 24),
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
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
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.badminton, matchId: widget.matchId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final events = obj as BadmintonMatchEventsData?;
        if (events == null || events.statSets.isEmpty) {
          return Center(
            child: Text(
              'event.badminton.detail.no_stats'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        final setIndices = events.statSets.map((s) => s.setIndex).toSet().toList()..sort();
        final safeIdx = _selectedIdx.clamp(0, setIndices.length - 1);

        final tabLabels = setIndices.map((idx) {
          if (idx == 0) return 'event.badminton.detail.overall'.tr();
          return 'event.badminton.detail.set_n'.tr(namedArgs: {'n': '$idx'});
        }).toList();

        final stats = events.statSets
            .where((s) => s.setIndex == setIndices[safeIdx])
            .expand((s) => s.stats)
            .toList();

        return Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
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
                          color: isSelected ? AppColors.primary : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tabLabels[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
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

  final List<BadmintonStat> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Center(
        child: Text(
          'event.badminton.detail.no_stats'.tr(),
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: stats.length,
      itemBuilder: (context, i) => _BadmintonStatRow(stat: stats[i]),
    );
  }
}

class _BadmintonStatRow extends StatelessWidget {
  const _BadmintonStatRow({required this.stat});

  final BadmintonStat stat;

  @override
  Widget build(BuildContext context) {
    final home = stat.homeValue.isNaN ? 0.0 : stat.homeValue.abs();
    final away = stat.awayValue.isNaN ? 0.0 : stat.awayValue.abs();
    final total = home + away;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
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
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              const barHeight = 6.0;
              const radius = Radius.circular(3);
              if (total <= 0) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(height: barHeight, color: Colors.grey.shade200),
                );
              }
              final halfWidth = constraints.maxWidth / 2;
              final homeWidth = halfWidth * (home / total);
              final awayWidth = halfWidth * (away / total);
              return ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: barHeight,
                  color: Colors.grey.shade200,
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
                              color: AppColors.primary,
                              borderRadius: BorderRadius.only(
                                topRight: radius,
                                bottomRight: radius,
                              ),
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
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
                decoration: BoxDecoration(color: AppColors.primaryShade50, shape: BoxShape.circle),
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
