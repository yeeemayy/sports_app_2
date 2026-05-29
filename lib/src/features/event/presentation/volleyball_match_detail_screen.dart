import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/volleyball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/volleyball_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/volleyball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/volleyball_status.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/arena_stat_bar.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class VolleyballMatchDetailScreen extends ConsumerStatefulWidget {
  const VolleyballMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<VolleyballMatchDetailScreen> createState() =>
      _VolleyballMatchDetailScreenState();
}

class _VolleyballMatchDetailScreenState
    extends SportDetailScaffoldState<VolleyballMatchDetailScreen> {
  @override
  String get matchId => widget.matchId;

  @override
  SportType get sportType => SportType.volleyball;

  @override
  Duration get eventsRefreshInterval => const Duration(seconds: 5);

  @override
  (String?, int?) watchDetail() {
    final v =
        ref
                .watch(
                  matchDetailProvider(
                    sport: SportType.volleyball,
                    matchId: matchId,
                  ),
                )
                .valueOrNull
            as VolleyballMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(
    BuildContext context, {
    String? leagueName,
    int? matchTimestamp,
  }) => _VolleyballMatchHeader(
    matchId: matchId,
    leagueName: leagueName,
    matchTimestamp: matchTimestamp,
  );

  @override
  List<Tab> buildTabs(BuildContext context) => [
    Tab(text: 'event.volleyball.detail.score'.tr()),
    Tab(text: 'event.volleyball.detail.stats'.tr()),
  ];

  @override
  List<Widget> buildTabViews(BuildContext context) => [
    _ScoreTab(matchId: matchId),
    _StatsTab(matchId: matchId),
  ];
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _VolleyballMatchHeader extends ConsumerWidget {
  const _VolleyballMatchHeader({
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
      matchDetailProvider(sport: SportType.volleyball, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.volleyball,
      ).select((map) => map[matchId] as VolleyballRealtimeData?),
    );

    return SportDetailHeaderShell<VolleyballMatchDetail>(
      detailAsync: detailAsync,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      skeletonHeight: 80,
      builder: (detail) => _VolleyballHeaderContent(detail: detail, rt: rt),
    );
  }
}

class _VolleyballHeaderContent extends StatelessWidget {
  const _VolleyballHeaderContent({required this.detail, this.rt});

  final VolleyballMatchDetail detail;
  final VolleyballRealtimeData? rt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effStatusId = rt?.statusId ?? detail.statusId;
    final homeTotal = rt?.homeTotal ?? detail.homeInfo.totalScore;
    final awayTotal = rt?.awayTotal ?? detail.awayInfo.totalScore;

    final isNotStarted = effStatusId == 1;
    const liveStatuses = {432, 434, 436, 438, 440};
    final isLive = liveStatuses.contains(effStatusId);
    final statusLabel = volleyballStatusLabel(
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
                  SportLogo(url: detail.homeInfo.logo, size: 52),
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
                            56,
                            context,
                          ).copyWith(color: scoreColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: AppTextStyles.display(
                              48,
                              context,
                            ).copyWith(color: colors.text3),
                          ),
                        ),
                        Text(
                          '$awayTotal',
                          style: AppTextStyles.display(
                            56,
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
                  SportLogo(url: detail.awayInfo.logo, size: 52),
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
      matchDetailProvider(sport: SportType.volleyball, matchId: matchId),
    );
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.volleyball, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.volleyball,
      ).select((map) => map[matchId] as VolleyballRealtimeData?),
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
        final detail = obj as VolleyballMatchDetail;
        final ev = eventsAsync.valueOrNull as VolleyballMatchEventsData?;
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
  final String homeName, awayName, homeLogo, awayLogo;
  final List<int> homeSets, awaySets;
  final int homeTotal, awayTotal;

  int? get _activeSetIndex {
    switch (statusId) {
      case 432:
        return 0;
      case 434:
        return 1;
      case 436:
        return 2;
      case 438:
        return 3;
      case 440:
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
            (i) => 'event.volleyball.detail.set_n'.tr(
              namedArgs: {'n': '${i + 1}'},
            ),
          )
        : [
            'event.volleyball.detail.set_n'.tr(namedArgs: {'n': '1'}),
          ];

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
                        'event.volleyball.detail.total'.tr().toUpperCase(),
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
                setScores: setCount > 0 ? homeSets : [],
                total: homeTotal,
                activeIdx: activeIdx,
              ),
              Divider(height: 1, thickness: 0.5, color: colors.line),
              _PlayerRow(
                name: awayName,
                logo: awayLogo,
                setScores: setCount > 0 ? awaySets : [],
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

  final String name, logo;
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
          ...List.generate(setScores.length, (i) {
            final isActive = i == activeIdx;
            return Expanded(
              child: Text(
                '${setScores[i]}',
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
      matchEventsProvider(sport: SportType.volleyball, matchId: widget.matchId),
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
        final events = obj as VolleyballMatchEventsData?;
        if (events == null || events.statSets.isEmpty) {
          return Center(
            child: Text(
              'event.volleyball.detail.no_stats'.tr(),
              style: AppTextStyles.body(13).copyWith(color: colors.text3),
            ),
          );
        }

        final setIndices =
            events.statSets.map((s) => s.setIndex).toSet().toList()..sort();
        final safeIdx = _selectedIdx.clamp(0, setIndices.length - 1);
        final tabLabels = setIndices.map((idx) {
          if (idx == 0) return 'event.volleyball.detail.overall'.tr();
          return 'event.volleyball.detail.set_n'.tr(namedArgs: {'n': '$idx'});
        }).toList();
        final stats = events.statSets
            .where((s) => s.setIndex == setIndices[safeIdx])
            .expand((s) => s.stats)
            .toList();

        return Column(
          children: [
            Container(
              color: colors.surface,
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
                        'event.volleyball.detail.no_stats'.tr(),
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
