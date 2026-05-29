import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/event/domain/badminton_status.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/badminton_realtime_data.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/arena_stat_bar.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class BadmintonMatchDetailScreen extends ConsumerStatefulWidget {
  const BadmintonMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<BadmintonMatchDetailScreen> createState() =>
      _BadmintonMatchDetailScreenState();
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
    final v =
        ref
                .watch(
                  matchDetailProvider(
                    sport: SportType.badminton,
                    matchId: matchId,
                  ),
                )
                .valueOrNull
            as BadmintonMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(
    BuildContext context, {
    String? leagueName,
    int? matchTimestamp,
  }) => _BadmintonMatchHeader(
    matchId: matchId,
    leagueName: leagueName,
    matchTimestamp: matchTimestamp,
  );

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
  const _BadmintonMatchHeader({
    required this.matchId,
    this.leagueName,
    this.matchTimestamp,
  });

  final String matchId;
  final String? leagueName;
  final int? matchTimestamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      matchDetailProvider(sport: SportType.badminton, matchId: matchId),
    );
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.badminton, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.badminton,
      ).select((map) => map[matchId] as BadmintonRealtimeData?),
    );

    return SportDetailHeaderShell<BadmintonMatchDetail>(
      detailAsync: detailAsync,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
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
  const _BadmintonHeaderContent({
    required this.detail,
    this.rt,
    this.eventsData,
  });

  final BadmintonMatchDetail detail;
  final BadmintonRealtimeData? rt;
  final BadmintonMatchEventsData? eventsData;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effStatusId = eventsData?.statusId ?? rt?.statusId ?? detail.statusId;

    final homeTotal =
        eventsData?.homeTotal ?? rt?.homeTotal ?? detail.homeInfo.totalScore;
    final awayTotal =
        eventsData?.awayTotal ?? rt?.awayTotal ?? detail.awayInfo.totalScore;
    final isNotStarted = effStatusId == 1;
    final isLive = effStatusId >= 3 && effStatusId < 100;
    final statusLabel = badmintonStatusLabel(
      effStatusId,
      detail.statusDescription,
    );
    final statusColor = isLive ? colors.live : colors.text3;
    final scoreColor = isLive ? colors.accent : colors.text3;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SportLogo(url: detail.homeInfo.logo, size: 48),
                  const SizedBox(height: 6),
                  Text(
                    detail.homeName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(
                      12,
                      context,
                    ).copyWith(color: colors.text),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        color: statusColor.computeLuminance() > 0.5
                            ? const Color(0xFF0E0E0E)
                            : Colors.white,
                        letterSpacing: 0.1 * 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isNotStarted)
                    Text(
                      '– –',
                      style: AppTextStyles.display(
                        40,
                        context,
                      ).copyWith(color: scoreColor),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$homeTotal',
                          style: AppTextStyles.display(
                            48,
                            context,
                          ).copyWith(color: scoreColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: AppTextStyles.display(
                              40,
                              context,
                            ).copyWith(color: colors.text3),
                          ),
                        ),
                        Text(
                          '$awayTotal',
                          style: AppTextStyles.display(
                            48,
                            context,
                          ).copyWith(color: scoreColor),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SportLogo(url: detail.awayInfo.logo, size: 48),
                  const SizedBox(height: 6),
                  Text(
                    detail.awayName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display(
                      12,
                      context,
                    ).copyWith(color: colors.text),
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

// ─── Score Tab ────────────────────────────────────────────────────────────────

class _ScoreTab extends ConsumerWidget {
  const _ScoreTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      matchDetailProvider(sport: SportType.badminton, matchId: matchId),
    );
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.badminton, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.badminton,
      ).select((map) => map[matchId] as BadmintonRealtimeData?),
    );

    return detailAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: context.appColors.accent),
      ),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: AppTextStyles.body(
            13,
          ).copyWith(color: context.appColors.text3),
        ),
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
          setKeyPrefix: 'event.badminton.detail.set_n',
          totalKey: 'event.badminton.detail.total',
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
    required this.setKeyPrefix,
    required this.totalKey,
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
  final String setKeyPrefix;
  final String totalKey;

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
    final colors = context.appColors;
    final setCount = homeSets.length;
    final activeIdx = _activeSetIndex;

    final setLabels = setCount > 0
        ? List.generate(
            setCount,
            (i) => setKeyPrefix.tr(namedArgs: {'n': '${i + 1}'}),
          )
        : [
            setKeyPrefix.tr(namedArgs: {'n': '1'}),
            setKeyPrefix.tr(namedArgs: {'n': '2'}),
          ];
    final effectiveHomeSets = setCount > 0 ? homeSets : <int>[];
    final effectiveAwaySets = setCount > 0 ? awaySets : <int>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.line, width: 0.5),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    ...List.generate(setLabels.length, (i) {
                      final isActive = setCount > 0 && i == activeIdx;
                      return Expanded(
                        child: Text(
                          setLabels[i].toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.mono(9).copyWith(
                            color: isActive ? colors.accent : colors.text3,
                            letterSpacing: 0.14 * 9,
                          ),
                        ),
                      );
                    }),
                    Expanded(
                      child: Text(
                        totalKey.tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.mono(9).copyWith(
                          color: colors.text3,
                          letterSpacing: 0.14 * 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: colors.line),
              _PlayerRow(
                name: homeName,
                logo: homeLogo,
                setScores: effectiveHomeSets,
                total: homeTotal,
                activeIdx: activeIdx,
              ),
              Divider(height: 1, thickness: 0.5, color: colors.line),
              _PlayerRow(
                name: awayName,
                logo: awayLogo,
                setScores: effectiveAwaySets,
                total: awayTotal,
                activeIdx: activeIdx,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.name,
    required this.logo,
    required this.setScores,
    required this.total,
    required this.activeIdx,
  });

  final String name;
  final String logo;
  final List<int> setScores;
  final int total;
  final int? activeIdx;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    style: AppTextStyles.body(13).copyWith(color: colors.text),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(setScores.isNotEmpty ? setScores.length : 2, (i) {
            final isActive = i == activeIdx;
            return Expanded(
              child: Text(
                setScores.isNotEmpty ? '${setScores[i]}' : '-',
                textAlign: TextAlign.center,
                style: AppTextStyles.mono(13).copyWith(
                  color: isActive ? colors.accent : colors.text2,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            );
          }),
          Expanded(
            child: Text(
              '$total',
              textAlign: TextAlign.center,
              style: AppTextStyles.mono(
                14,
              ).copyWith(color: colors.accent, fontWeight: FontWeight.w700),
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
    final colors = context.appColors;
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.badminton, matchId: widget.matchId),
    );

    return eventsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: colors.accent)),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: AppTextStyles.body(13).copyWith(color: colors.text3),
        ),
      ),
      data: (obj) {
        final events = obj as BadmintonMatchEventsData?;
        if (events == null || events.statSets.isEmpty) {
          return Center(
            child: Text(
              'event.badminton.detail.no_stats'.tr(),
              style: AppTextStyles.body(13).copyWith(color: colors.text3),
            ),
          );
        }

        final setIndices =
            events.statSets.map((s) => s.setIndex).toSet().toList()..sort();
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
              width: double.maxFinite,
              color: colors.surface,
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(tabLabels.length, (i) {
                    final isSelected = i == safeIdx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIdx = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.accent : colors.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(color: colors.line, width: 0.5),
                        ),
                        child: Text(
                          tabLabels[i].toUpperCase(),
                          style: AppTextStyles.mono(10).copyWith(
                            color: isSelected
                                ? const Color(0xFF0E0E0E)
                                : colors.text2,
                            letterSpacing: 0.1 * 10,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Divider(height: 1, thickness: 0.5, color: colors.line),
            Expanded(
              child: stats.isEmpty
                  ? Center(
                      child: Text(
                        'event.badminton.detail.no_stats'.tr(),
                        style: AppTextStyles.body(
                          13,
                        ).copyWith(color: colors.text3),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: stats.length,
                      itemBuilder: (context, i) {
                        final stat = stats[i];
                        final home = stat.homeValue.isNaN
                            ? 0.0
                            : stat.homeValue.abs();
                        final away = stat.awayValue.isNaN
                            ? 0.0
                            : stat.awayValue.abs();
                        final label = stat.labelKey.isNotEmpty
                            ? stat.labelKey.tr()
                            : '${stat.typeCode}';
                        return ArenaStatBar(
                          label: label,
                          home: home,
                          away: away,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
