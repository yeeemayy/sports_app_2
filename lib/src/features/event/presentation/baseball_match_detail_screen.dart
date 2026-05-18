import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/baseball_status.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/baseball_realtime_data.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
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
  Widget buildHeader(BuildContext context) => _BaseballMatchHeader(matchId: matchId);

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

// ─── Header ───────────────────────────────────────────────────────────────────

class _BaseballMatchHeader extends ConsumerWidget {
  const _BaseballMatchHeader({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.baseball, matchId: matchId));
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.baseball,
      ).select((map) => map[matchId] as BaseballRealtimeData?),
    );

    return SportDetailHeaderShell<BaseballMatchDetail>(
      detailAsync: detailAsync,
      skeletonHeight: 80,
      builder: (detail) => _HeaderContent(detail: detail, rt: rt),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({required this.detail, this.rt});

  final BaseballMatchDetail detail;
  final BaseballRealtimeData? rt;

  @override
  Widget build(BuildContext context) {
    final statusId = rt?.statusId ?? detail.statusId;
    final homeScore =
        rt?.homeScore ??
        (detail.scores['ft'] as List<dynamic>?)?.elementAtOrNull(0)?.toString() ??
        '-';
    final awayScore =
        rt?.awayScore ??
        (detail.scores['ft'] as List<dynamic>?)?.elementAtOrNull(1)?.toString() ??
        '-';

    final isLive = baseballLiveStatuses.contains(statusId);
    final isNotStarted = statusId == 1;
    final statusLabel = baseballStatusLabel(statusId);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home team
            Expanded(
              child: Column(
                children: [
                  SportLogo(url: detail.homeInfo.logo, size: 48, circular: false),
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
                  if (statusLabel.isNotEmpty)
                    Text(
                      statusLabel,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: isLive ? Colors.yellow.shade300 : Colors.white70,
                        fontWeight: FontWeight.w700,
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
                  else
                    RichText(
                      text: TextSpan(
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: homeScore),
                          const TextSpan(
                            text: ' - ',
                            style: TextStyle(color: Colors.white60),
                          ),
                          TextSpan(text: awayScore),
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
                  SportLogo(url: detail.awayInfo.logo, size: 48, circular: false),
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

// ─── Score Tab ────────────────────────────────────────────────────────────────

class _ScoreTab extends ConsumerWidget {
  const _ScoreTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(matchDetailProvider(sport: SportType.baseball, matchId: matchId));
    final eventsAsync = ref.watch(matchEventsProvider(sport: SportType.baseball, matchId: matchId));

    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: Colors.grey.shade500)),
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
    // Determine inning count
    int inningCount = events?.inningCount ?? 0;
    if (inningCount == 0) {
      // Fall back to detail scores
      for (var i = 1; i <= 20; i++) {
        if (detail.scores.containsKey('p$i')) {
          inningCount = i;
        } else {
          break;
        }
      }
    }
    final displayCount = inningCount < 9 ? 9 : inningCount;

    // Home/away inning scores
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

    final headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: context.appTheme.greyText,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final nameColWidth = totalWidth * 0.30;
        final cellWidth = (totalWidth * 0.70) / displayCount;

        Widget buildCell(String text, {Color? color, FontWeight? weight}) {
          return SizedBox(
            width: cellWidth,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: weight ?? FontWeight.w500,
                color: color ?? context.appTheme.baseText,
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            // Inning grid
            Container(
              color: context.appTheme.surface,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: blank + inning numbers
                  Container(
                    color: context.appTheme.inningHeaderBg,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(width: nameColWidth),
                        ...List.generate(
                          displayCount,
                          (i) => buildCell('${i + 1}', color: context.appTheme.grey_5),
                        ),
                      ],
                    ),
                  ),
                  // Away row
                  Container(
                    color: context.appTheme.inningAwayRowBg,
                    child: Row(
                      children: [
                        SizedBox(
                          width: nameColWidth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                            child: Row(
                              children: [
                                SportLogo(url: detail.awayInfo.logo, size: 22),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    detail.awayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                    color: context.appTheme.inningHomeRowBg,
                    child: Row(
                      children: [
                        SizedBox(
                          width: nameColWidth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                            child: Row(
                              children: [
                                SportLogo(url: detail.homeInfo.logo, size: 22),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    detail.homeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
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
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: context.appTheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: context.appTheme.inningHeaderBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        SizedBox(
                          width: 64,
                          child: Text(
                            'event.baseball.detail.runs'.tr(),
                            textAlign: TextAlign.center,
                            style: headerStyle,
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: Text(
                            'event.baseball.detail.hits'.tr(),
                            textAlign: TextAlign.center,
                            style: headerStyle,
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'event.baseball.detail.errors'.tr(),
                              textAlign: TextAlign.center,
                              style: headerStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 0.5, color: context.appTheme.shimmerBase),
                  // Away team row
                  _RheRow(
                    name: detail.awayName,
                    runs: awayRuns,
                    hits: awayHits,
                    errors: awayErrors,
                  ),
                  Divider(height: 1, thickness: 0.5, color: context.appTheme.shimmerHighlight),
                  // Home team row
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
      }, // end LayoutBuilder builder
    ); // end LayoutBuilder
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              runs,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              hits,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              errors,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.baseball, matchId: widget.matchId),
    );

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => Center(
        child: Text('event.error.load_failed'.tr(), style: TextStyle(color: Colors.grey.shade500)),
      ),
      data: (obj) {
        final events = obj as BaseballMatchEventsData?;
        if (events == null || events.statSets.isEmpty) {
          return Center(
            child: Text(
              'event.baseball.detail.no_stats'.tr(),
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        final setIndices = events.statSets.map((s) => s.setIndex).toSet().toList()..sort();
        final safeIdx = _selectedIdx.clamp(0, setIndices.length - 1);
        final stats = events.statsFor(setIndices[safeIdx]);

        return Column(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        color: isSelected ? AppColors.accent : context.appTheme.grey_3,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _inningLabel(setIndices[i]),
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
            if (stats.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'event.baseball.detail.no_stats'.tr(),
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: stats.length,
                  itemBuilder: (context, i) => _BaseballStatRow(stat: stats[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BaseballStatRow extends StatelessWidget {
  const _BaseballStatRow({required this.stat});

  final BaseballStat stat;

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
