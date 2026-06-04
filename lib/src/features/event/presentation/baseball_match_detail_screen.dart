import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match_events.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/headers/baseball_match_header.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/shared_widgets/arena_stat_bar.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class BaseballMatchDetailScreen extends ConsumerStatefulWidget {
  const BaseballMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<BaseballMatchDetailScreen> createState() => _BaseballMatchDetailScreenState();
}

class _BaseballMatchDetailScreenState extends SportDetailScaffoldState<BaseballMatchDetailScreen> {
  @override
  String get matchId => widget.matchId;

  @override
  SportType get sportType => SportType.baseball;

  @override
  Duration get eventsRefreshInterval => const Duration(seconds: 5);

  @override
  (String?, int?) watchDetail() {
    final v =
        ref.watch(matchDetailProvider(sport: SportType.baseball, matchId: matchId)).valueOrNull
            as BaseballMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(BuildContext context, {String? leagueName, int? matchTimestamp}) =>
      BaseballMatchHeader(matchId: matchId, leagueName: leagueName, matchTimestamp: matchTimestamp);

  @override
  List<Tab> buildTabs(BuildContext context) => [
    Tab(text: 'event.baseball.detail.score'.tr()),
    Tab(text: 'event.baseball.detail.stats'.tr()),
  ];

  @override
  List<Widget> buildTabViews(BuildContext context) => [
    _ScoreTab(matchId: matchId),
    _StatsTab(matchId: matchId),
  ];
}

// ─── Score Tab ────────────────────────────────────────────────────────────────

class _ScoreTab extends ConsumerWidget {
  const _ScoreTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.baseball, matchId: matchId));
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.baseball, matchId: matchId));

    return detailAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: context.appColors.accent)),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: context.appColors.text3),
        ),
      ),
      data: (obj) {
        final detail = obj as BaseballMatchDetail;
        final events = eventsAsync.valueOrNull as BaseballMatchEventsData?;
        return _InningGrid(detail: detail, events: events);
      },
    );
  }
}

class _InningGrid extends StatelessWidget {
  const _InningGrid({required this.detail, this.events});

  final BaseballMatchDetail detail;
  final BaseballMatchEventsData? events;

  List<String> _inningScores(Map<String, dynamic> scores, int sideIndex, int count) {
    return List.generate(count, (i) {
      final val = scores['p${i + 1}'] as List<dynamic>?;
      if (val == null || val.length <= sideIndex) return '-';
      final v = val[sideIndex];
      return v?.toString().isNotEmpty == true ? v.toString() : '-';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    int inningCount = events?.inningCount ?? 0;
    if (inningCount == 0) {
      for (var i = 1; i <= 20; i++) {
        if (detail.scores.containsKey('p$i')) {
          inningCount = i;
        } else {
          break;
        }
      }
    }
    final displayCount = inningCount < 9 ? 9 : inningCount;

    final List<String> awayInnings;
    final List<String> homeInnings;
    final String homeRuns, homeHits, homeErrors;
    final String awayRuns, awayHits, awayErrors;

    if (events != null) {
      awayInnings = List.generate(displayCount, (i) {
        if (i < events!.away.inningScores.length) {
          final v = events!.away.inningScores[i];
          return v.isEmpty ? '-' : v;
        }
        return '-';
      });
      homeInnings = List.generate(displayCount, (i) {
        if (i < events!.home.inningScores.length) {
          final v = events!.home.inningScores[i];
          return v.isEmpty ? '-' : v;
        }
        return '-';
      });
      homeRuns = events!.home.runs;
      homeHits = events!.home.hits;
      homeErrors = events!.home.errors;
      awayRuns = events!.away.runs;
      awayHits = events!.away.hits;
      awayErrors = events!.away.errors;
    } else {
      awayInnings = _inningScores(detail.scores, 1, displayCount);
      homeInnings = _inningScores(detail.scores, 0, displayCount);
      final ft = detail.scores['ft'] as List<dynamic>?;
      final h = detail.scores['h'] as List<dynamic>?;
      final e = detail.scores['e'] as List<dynamic>?;
      homeRuns = ft?.elementAtOrNull(0)?.toString() ?? '-';
      homeHits = h?.elementAtOrNull(0)?.toString() ?? '-';
      homeErrors = e?.elementAtOrNull(0)?.toString() ?? '-';
      awayRuns = ft?.elementAtOrNull(1)?.toString() ?? '-';
      awayHits = h?.elementAtOrNull(1)?.toString() ?? '-';
      awayErrors = e?.elementAtOrNull(1)?.toString() ?? '-';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Subtract container margin (12+12) and Border.all 1px (1+1) so cells fit inside.
        final totalWidth = constraints.maxWidth - 26;
        final nameColWidth = totalWidth * 0.30;
        final cellWidth = (totalWidth * 0.70) / displayCount;

        Widget buildCell(String text, {Color? color}) {
          return SizedBox(
            width: cellWidth,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.mono(12).copyWith(color: color ?? colors.text2),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            // Inning grid
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.inningHeaderBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: nameColWidth),
                        ...List.generate(
                          displayCount,
                          (i) => buildCell('${i + 1}', color: colors.text3),
                        ),
                      ],
                    ),
                  ),
                  // Away row
                  Container(
                    color: colors.inningAwayRowBg,
                    child: Row(
                      children: [
                        SizedBox(
                          width: nameColWidth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            child: Row(
                              children: [
                                SportLogo(url: detail.awayInfo.logo, size: 22),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    detail.awayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body(
                                      11,
                                    ).copyWith(fontWeight: FontWeight.w600, color: colors.text),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...awayInnings.map((s) => buildCell(s)),
                      ],
                    ),
                  ),
                  // Home row
                  Container(
                    decoration: BoxDecoration(
                      color: colors.inningHomeRowBg,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: nameColWidth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            child: Row(
                              children: [
                                SportLogo(url: detail.homeInfo.logo, size: 22),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    detail.homeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body(
                                      11,
                                    ).copyWith(fontWeight: FontWeight.w600, color: colors.text),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...homeInnings.map((s) => buildCell(s)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // RHE summary table
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.line),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: colors.inningHeaderBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        SizedBox(
                          width: 64,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'event.baseball.detail.runs'.tr(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.mono(10).copyWith(color: colors.text3),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: Text(
                            'event.baseball.detail.hits'.tr(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.mono(10).copyWith(color: colors.text3),
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: Text(
                            'event.baseball.detail.errors'.tr(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.mono(10).copyWith(color: colors.text3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 0.5, color: colors.line),
                  _RheRow(
                    name: detail.awayName,
                    runs: awayRuns,
                    hits: awayHits,
                    errors: awayErrors,
                  ),
                  Divider(height: 1, thickness: 0.5, color: colors.line),
                  _RheRow(
                    name: detail.homeName,
                    runs: homeRuns,
                    hits: homeHits,
                    errors: homeErrors,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RheRow extends StatelessWidget {
  const _RheRow({required this.name, required this.runs, required this.hits, required this.errors});

  final String name;
  final String runs;
  final String hits;
  final String errors;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.body(
                13,
              ).copyWith(fontWeight: FontWeight.w600, color: colors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              runs,
              textAlign: TextAlign.center,
              style: AppTextStyles.mono(
                14,
              ).copyWith(color: colors.accent, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              hits,
              textAlign: TextAlign.center,
              style: AppTextStyles.mono(13).copyWith(color: colors.text2),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              errors,
              textAlign: TextAlign.center,
              style: AppTextStyles.mono(13).copyWith(color: colors.text2),
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

  String _inningLabel(int setIndex) {
    if (setIndex == 0) return 'event.baseball.detail.ft'.tr();
    return 'event.baseball.detail.inning_n'.tr(namedArgs: {'n': '$setIndex'});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.baseball, matchId: widget.matchId),
    );

    return eventsAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: colors.accent)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: colors.text3)),
      ),
      data: (obj) {
        final events = obj as BaseballMatchEventsData?;
        if (events == null || events.statSets.isEmpty) {
          return Center(
            child: Text(
              'event.baseball.detail.no_stats'.tr(),
              style: TextStyle(color: colors.text3),
            ),
          );
        }

        final setIndices = events.statSets.map((s) => s.setIndex).toSet().toList()..sort();
        final safeIdx = _selectedIdx.clamp(0, setIndices.length - 1);
        final stats = events.statsFor(setIndices[safeIdx]);

        return Column(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(setIndices.length, (i) {
                  final isSelected = i == safeIdx;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIdx = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.accent : colors.surface2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? colors.accent : colors.line),
                      ),
                      child: Text(
                        _inningLabel(setIndices[i]),
                        style: AppTextStyles.mono(12).copyWith(
                          color: isSelected ? Colors.white : colors.text2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (stats.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'event.baseball.detail.no_stats'.tr(),
                    style: TextStyle(color: colors.text3),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: stats.length,
                  itemBuilder: (context, i) {
                    final s = stats[i];
                    return ArenaStatBar(
                      label: s.labelKey.isNotEmpty ? s.labelKey.tr() : '${s.typeCode}',
                      home: s.homeValue,
                      away: s.awayValue,
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
