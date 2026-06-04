import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/tennis_status.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/headers/tennis_match_header.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/arena_stat_bar.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class TennisMatchDetailScreen extends ConsumerStatefulWidget {
  const TennisMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<TennisMatchDetailScreen> createState() =>
      _TennisMatchDetailScreenState();
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
    final v =
        ref
                .watch(
                  matchDetailProvider(
                    sport: SportType.tennis,
                    matchId: matchId,
                  ),
                )
                .valueOrNull
            as TennisMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(
    BuildContext context, {
    String? leagueName,
    int? matchTimestamp,
  }) => TennisMatchHeader(
    matchId: matchId,
    leagueName: leagueName,
    matchTimestamp: matchTimestamp,
  );

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

class _ScoreTab extends ConsumerWidget {
  const _ScoreTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      matchDetailProvider(sport: SportType.tennis, matchId: matchId),
    );
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.tennis, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.tennis,
      ).select((map) => map[matchId] as TennisRealtimeData?),
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
    final colors = context.appColors;
    final s1Label = 'event.tennis.detail.set_n'.tr(namedArgs: {'n': '1'});
    final s2Label = 'event.tennis.detail.set_n'.tr(namedArgs: {'n': '2'});
    final ftLabel = 'event.tennis.detail.total'.tr();

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
                    SizedBox(
                      width: 44,
                      child: Text(
                        s1Label.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.mono(9).copyWith(
                          color: colors.text3,
                          letterSpacing: 0.14 * 9,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        s2Label.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.mono(9).copyWith(
                          color: colors.text3,
                          letterSpacing: 0.14 * 9,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        ftLabel.toUpperCase(),
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
              _BasicPlayerRow(
                name: homeName,
                logo: homeLogo,
                total: homeTotal,
                isServing: isLive && servingSide == 1,
              ),
              Divider(height: 1, thickness: 0.5, color: colors.line),
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
    final colors = context.appColors;
    final setCount = homeSets.length;
    final activeIdx = _activeSetIndex;
    final showPt = isLive && homePt.isNotEmpty;

    if (setCount == 0) return _buildBasicTable(context);

    final setLabels = List.generate(
      setCount,
      (i) => 'event.tennis.detail.set_n'.tr(namedArgs: {'n': '${i + 1}'}),
    );

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
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    ...List.generate(setCount, (i) {
                      final isActive = i == activeIdx;
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
                    if (showPt)
                      Expanded(
                        child: Text(
                          'event.tennis.detail.pt'.tr().toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.mono(9).copyWith(
                            color: colors.accent,
                            letterSpacing: 0.14 * 9,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        'event.tennis.detail.total'.tr().toUpperCase(),
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
              _PlayerScoreRow(
                name: homeName,
                setScores: homeSets,
                total: homeTotal,
                ptScore: showPt ? homePt : null,
                activeIdx: activeIdx,
              ),
              Divider(height: 1, thickness: 0.5, color: colors.line),
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
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(13).copyWith(color: colors.text),
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
          if (ptScore != null)
            Expanded(
              child: Text(
                ptScore!,
                textAlign: TextAlign.center,
                style: AppTextStyles.mono(
                  13,
                ).copyWith(color: colors.accent, fontWeight: FontWeight.w700),
              ),
            ),
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
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          decoration: BoxDecoration(
                            color: colors.accent,
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
                    style: AppTextStyles.body(13).copyWith(color: colors.text),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '–',
              textAlign: TextAlign.center,
              style: AppTextStyles.mono(13).copyWith(color: colors.text3),
            ),
          ),
          SizedBox(
            width: 44,
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
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.tennis, matchId: widget.matchId),
    );

    return eventsAsync.when(
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
        final events = obj as TennisMatchEventsData?;
        if (events == null || events.statSets.isEmpty) {
          return Center(
            child: Text(
              'event.tennis.detail.no_stats'.tr(),
              style: AppTextStyles.body(
                13,
              ).copyWith(color: context.appColors.text3),
            ),
          );
        }

        final setIndices =
            events.statSets.map((s) => s.setIndex).toSet().toList()..sort();
        final safeIdx = _selectedIdx.clamp(0, setIndices.length - 1);

        final tabLabels = setIndices.map((idx) {
          if (idx == 0) return 'event.tennis.detail.overall'.tr();
          return 'event.tennis.detail.set_n'.tr(namedArgs: {'n': '$idx'});
        }).toList();

        final stats = events.statSets
            .where((s) => s.setIndex == setIndices[safeIdx])
            .expand((s) => s.stats)
            .toList();

        final colors = context.appColors;
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
          style: AppTextStyles.body(
            13,
          ).copyWith(color: context.appColors.text3),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: stats.length,
      itemBuilder: (context, i) {
        final stat = stats[i];
        final home = stat.homeValue.isNaN ? 0.0 : stat.homeValue.abs();
        final away = stat.awayValue.isNaN ? 0.0 : stat.awayValue.abs();
        final label = stat.labelKey.isNotEmpty
            ? stat.labelKey.tr()
            : '${stat.typeCode}';
        return ArenaStatBar(label: label, home: home, away: away);
      },
    );
  }
}

// ─── Situation Tab ────────────────────────────────────────────────────────────

class _SituationTab extends ConsumerWidget {
  const _SituationTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.tennis, matchId: matchId),
    );
    final detail =
        ref
                .watch(
                  matchDetailProvider(
                    sport: SportType.tennis,
                    matchId: matchId,
                  ),
                )
                .valueOrNull
            as TennisMatchDetail?;

    return eventsAsync.when(
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
        final events = obj as TennisMatchEventsData?;
        if (events == null || events.timeline.isEmpty) {
          return Center(
            child: Text(
              'event.tennis.detail.no_situation'.tr(),
              style: AppTextStyles.body(
                13,
              ).copyWith(color: context.appColors.text3),
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
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'event.tennis.detail.set_n'
                    .tr(namedArgs: {'n': '${setTimeline.set}'})
                    .toUpperCase(),
                style: AppTextStyles.display(
                  13,
                  context,
                ).copyWith(color: colors.text),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: colors.line),
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
    final scoreText = round.isComplete
        ? '${round.homeScore} - ${round.awayScore}'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                'event.tennis.detail.round_n'
                    .tr(namedArgs: {'n': '${round.round}'})
                    .toUpperCase(),
                style: AppTextStyles.mono(10).copyWith(
                  color: context.appColors.accent,
                  letterSpacing: 0.1 * 10,
                ),
              ),
              const SizedBox(width: 8),
              if (servingLogo.isNotEmpty) ...[
                SportLogo(url: servingLogo, size: 20, circular: true),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: servingName,
                        style: AppTextStyles.body(
                          13,
                        ).copyWith(color: context.appColors.text),
                      ),
                      if (servingName.isNotEmpty) ...[
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: 'event.tennis.detail.serving'.tr(),
                          style: AppTextStyles.mono(
                            11,
                          ).copyWith(color: context.appColors.text3),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (scoreText.isNotEmpty)
                Text(
                  scoreText,
                  style: AppTextStyles.mono(
                    12,
                  ).copyWith(color: context.appColors.text),
                ),
            ],
          ),
        ),
        if (round.points.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: round.points
                  .map((pt) => _PointChip(home: pt.home, away: pt.away))
                  .toList(),
            ),
          ),
        Divider(height: 1, thickness: 0.5, color: context.appColors.line),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.appColors.surface2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.appColors.line, width: 0.5),
      ),
      child: Text(
        '$home – $away',
        style: AppTextStyles.mono(11).copyWith(color: context.appColors.text2),
      ),
    );
  }
}

