import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_team_squad.dart';
import 'package:sports_app/src/features/event/presentation/providers/event_providers.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_header_shell.dart';
import 'package:sports_app/src/features/event/presentation/widgets/sport_detail_scaffold.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:sports_app/src/features/watchlist/presentation/watchlist_bell_button.dart';
import 'package:sports_app/src/shared_widgets/arena_stat_bar.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

class BasketballMatchDetailScreen extends ConsumerStatefulWidget {
  const BasketballMatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<BasketballMatchDetailScreen> createState() =>
      _BasketballMatchDetailScreenState();
}

class _BasketballMatchDetailScreenState
    extends SportDetailScaffoldState<BasketballMatchDetailScreen> {
  @override
  String get matchId => widget.matchId;

  @override
  SportType get sportType => SportType.basketball;

  @override
  Duration get eventsRefreshInterval => const Duration(seconds: 2);

  @override
  (String?, int?) watchDetail() {
    final v =
        ref
                .watch(
                  matchDetailProvider(
                    sport: SportType.basketball,
                    matchId: matchId,
                  ),
                )
                .valueOrNull
            as BasketballMatchDetail?;
    return (v?.leagueName, v?.matchTime);
  }

  @override
  Widget buildHeader(
    BuildContext context, {
    String? leagueName,
    int? matchTimestamp,
  }) => _BasketballHeader(
    matchId: matchId,
    leagueName: leagueName,
    matchTimestamp: matchTimestamp,
  );

  @override
  List<Tab> buildTabs(BuildContext context) => [
    Tab(text: 'event.basketball.detail.overview'.tr()),
    Tab(text: 'event.basketball.detail.players'.tr()),
  ];

  @override
  List<Widget> buildTabViews(BuildContext context) => [
    _OverviewTab(matchId: matchId),
    _SquadTab(matchId: matchId),
  ];
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _BasketballHeader extends ConsumerWidget {
  const _BasketballHeader({
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
      matchDetailProvider(sport: SportType.basketball, matchId: matchId),
    );
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.basketball, matchId: matchId),
    );
    final rt = ref.watch(
      sportRealtimeProvider(
        SportType.basketball,
      ).select((map) => map[matchId] as BasketballRealtimeData?),
    );

    final detail = detailAsync.valueOrNull as BasketballMatchDetail?;
    final homeName = detail?.homeName ?? '';
    final awayName = detail?.awayName ?? '';
    final canWatchlist =
        homeName.isNotEmpty && awayName.isNotEmpty && matchTimestamp != null && matchTimestamp! > 0;
    final watchlistEntry = canWatchlist
        ? WatchlistEntry(
            matchId: matchId,
            sport: 'basketball',
            homeName: homeName,
            awayName: awayName,
            leagueName: leagueName ?? '',
            matchTimeMs: matchTimestamp! * 1000,
          )
        : null;

    return SportDetailHeaderShell<BasketballMatchDetail>(
      detailAsync: detailAsync,
      leagueName: leagueName,
      matchTimestamp: matchTimestamp,
      actions: watchlistEntry != null ? [WatchlistBellButton(entry: watchlistEntry)] : null,
      builder: (detail) {
        final eventsData =
            eventsAsync.valueOrNull as BasketballMatchEventsData?;
        final effStatusId =
            eventsData?.statusId ?? rt?.statusId ?? detail.statusId;
        final homeTotal =
            eventsData?.homeTotal ?? rt?.homeTotal ?? detail.homeInfo.total;
        final awayTotal =
            eventsData?.awayTotal ?? rt?.awayTotal ?? detail.awayInfo.total;

        final periodKey = _periodKey(effStatusId);
        final periodLabel = periodKey.isNotEmpty
            ? periodKey.tr()
            : (detail.statusDescription ?? '');

        final showClock = eventsData?.showClock ?? rt?.showClock ?? false;
        final clockDisplay = eventsData?.clockDisplay ?? rt?.clockDisplay ?? '';
        final isNoScore = const {0, 1}.contains(effStatusId);

        final statusColor = _statusColor(effStatusId, context.appColors);

        return _ScoreBlock(
          homeLogo: detail.homeInfo.logo,
          homeName: detail.homeName,
          awayLogo: detail.awayInfo.logo,
          awayName: detail.awayName,
          homeScore: isNoScore ? '–' : '$homeTotal',
          awayScore: isNoScore ? '–' : '$awayTotal',
          statusLabel: periodLabel,
          statusColor: statusColor,
          clockDisplay: showClock ? clockDisplay : null,
          colors: context.appColors,
          context: context,
        );
      },
    );
  }

  static String _periodKey(int statusId) => switch (statusId) {
    1 => 'event.basketball.period.not_started',
    2 => 'event.basketball.period.q1',
    3 => 'event.basketball.period.q1_over',
    4 => 'event.basketball.period.q2',
    5 => 'event.basketball.period.q2_over',
    6 => 'event.basketball.period.q3',
    7 => 'event.basketball.period.q3_over',
    8 => 'event.basketball.period.q4',
    9 => 'event.basketball.period.ot',
    10 => 'event.basketball.period.end',
    11 => 'event.basketball.period.interrupt',
    12 => 'event.basketball.period.cancel',
    13 => 'event.basketball.period.extension',
    14 => 'event.basketball.period.half',
    _ => '',
  };

  static Color _statusColor(int statusId, AppColors colors) {
    if (const {2, 4, 6, 8, 9, 13, 14}.contains(statusId)) return colors.live;
    if (const {10}.contains(statusId)) return colors.text3;
    if (const {11, 12}.contains(statusId)) return colors.danger;
    return colors.text3;
  }
}

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({
    required this.homeLogo,
    required this.homeName,
    required this.awayLogo,
    required this.awayName,
    required this.homeScore,
    required this.awayScore,
    required this.statusLabel,
    required this.statusColor,
    required this.clockDisplay,
    required this.colors,
    required this.context,
  });

  final String homeLogo;
  final String homeName;
  final String awayLogo;
  final String awayName;
  final String homeScore;
  final String awayScore;
  final String statusLabel;
  final Color statusColor;
  final String? clockDisplay;
  final AppColors colors;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              SportLogo(url: homeLogo, size: 52),
              const SizedBox(height: 6),
              Text(
                homeName.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.display(
                  13,
                  context,
                ).copyWith(color: colors.text),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              if (statusLabel.isNotEmpty)
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
              if (clockDisplay != null && clockDisplay!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    clockDisplay!,
                    style: AppTextStyles.mono(10).copyWith(color: colors.text2),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    homeScore,
                    style: AppTextStyles.display(56, context).copyWith(
                      color: statusColor == colors.live
                          ? colors.accent
                          : statusColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '–',
                      style: AppTextStyles.display(
                        22,
                        context,
                      ).copyWith(color: context.appColors.text3),
                    ),
                  ),
                  Text(
                    awayScore,
                    style: AppTextStyles.display(56, context).copyWith(
                      color: statusColor == colors.live
                          ? colors.accent
                          : statusColor,
                    ),
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
              SportLogo(url: awayLogo, size: 52),
              const SizedBox(height: 6),
              Text(
                awayName.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.display(
                  13,
                  context,
                ).copyWith(color: colors.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final detailAsync = ref.watch(
      matchDetailProvider(sport: SportType.basketball, matchId: matchId),
    );
    final eventsAsync = ref.watch(
      matchEventsProvider(sport: SportType.basketball, matchId: matchId),
    );

    final detail = detailAsync.valueOrNull as BasketballMatchDetail?;

    return eventsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: colors.accent)),
      error: (_, __) {
        if (detail == null) {
          return Center(
            child: Text(
              'event.error.load_failed'.tr(),
              style: TextStyle(color: colors.text3),
            ),
          );
        }
        return _OverviewContent(
          statusId: detail.statusId,
          homeLogo: detail.homeInfo.logo,
          awayLogo: detail.awayInfo.logo,
          homeName: detail.homeName,
          awayName: detail.awayName,
          homeQuarterScores: detail.homeInfo.sectionScores,
          awayQuarterScores: detail.awayInfo.sectionScores,
          homeTotal: detail.homeInfo.total,
          awayTotal: detail.awayInfo.total,
          stats: const [],
          matchId: matchId,
          isEnded: detail.statusId >= 10,
        );
      },
      data: (obj) {
        final events = obj as BasketballMatchEventsData?;
        final effStatusId = events?.statusId ?? detail?.statusId ?? 0;
        final homeQ =
            events?.homeQuarterScores ?? detail?.homeInfo.sectionScores ?? [];
        final awayQ =
            events?.awayQuarterScores ?? detail?.awayInfo.sectionScores ?? [];
        final homeTotal = events?.homeTotal ?? detail?.homeInfo.total ?? 0;
        final awayTotal = events?.awayTotal ?? detail?.awayInfo.total ?? 0;

        return _OverviewContent(
          statusId: effStatusId,
          homeLogo: detail?.homeInfo.logo ?? '',
          awayLogo: detail?.awayInfo.logo ?? '',
          homeName: detail?.homeName ?? '',
          awayName: detail?.awayName ?? '',
          homeQuarterScores: homeQ,
          awayQuarterScores: awayQ,
          homeTotal: homeTotal,
          awayTotal: awayTotal,
          stats: events?.stats ?? [],
          matchId: matchId,
          isEnded: effStatusId >= 10,
        );
      },
    );
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({
    required this.statusId,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeName,
    required this.awayName,
    required this.homeQuarterScores,
    required this.awayQuarterScores,
    required this.homeTotal,
    required this.awayTotal,
    required this.stats,
    required this.matchId,
    required this.isEnded,
  });

  final int statusId;
  final String homeLogo;
  final String awayLogo;
  final String homeName;
  final String awayName;
  final List<int> homeQuarterScores;
  final List<int> awayQuarterScores;
  final int homeTotal;
  final int awayTotal;
  final List<BasketballStat> stats;
  final String matchId;
  final bool isEnded;

  List<BasketballStat> _placeholders() => List.generate(
    7,
    (i) => BasketballStat(
      typeCode: i + 1,
      homeValue: double.nan,
      awayValue: double.nan,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final statsToShow = stats.isNotEmpty ? stats : _placeholders();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Quarter scores
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            'event.basketball.detail.q1'.tr().replaceAll('Q1', 'BY QUARTER'),
            style: AppTextStyles.display(
              18,
              context,
            ).copyWith(color: colors.text),
          ),
        ),
        _QuarterTable(
          statusId: statusId,
          homeLogo: homeLogo,
          awayLogo: awayLogo,
          homeQ: homeQuarterScores,
          awayQ: awayQuarterScores,
          homeTotal: homeTotal,
          awayTotal: awayTotal,
          colors: colors,
          context: context,
        ),

        // Stats
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'event.basketball.detail.overview'.tr().toUpperCase(),
            style: AppTextStyles.display(
              18,
              context,
            ).copyWith(color: colors.text),
          ),
        ),
        ...statsToShow.map((s) {
          final h = s.homeValue.isNaN ? 0.0 : s.homeValue;
          final a = s.awayValue.isNaN ? 0.0 : s.awayValue;
          final label = s.labelKey.isNotEmpty
              ? s.labelKey.tr()
              : '${s.typeCode}';
          return ArenaStatBar(label: label, home: h, away: a);
        }),
      ],
    );
  }
}

class _QuarterTable extends StatelessWidget {
  const _QuarterTable({
    required this.statusId,
    required this.homeLogo,
    required this.awayLogo,
    required this.homeQ,
    required this.awayQ,
    required this.homeTotal,
    required this.awayTotal,
    required this.colors,
    required this.context,
  });

  final int statusId;
  final String homeLogo;
  final String awayLogo;
  final List<int> homeQ;
  final List<int> awayQ;
  final int homeTotal;
  final int awayTotal;
  final AppColors colors;
  final BuildContext context;

  int? get _activeIdx {
    return switch (statusId) {
      2 => 0,
      4 => 1,
      6 => 2,
      8 => 3,
      9 || 13 => 4,
      _ => null,
    };
  }

  bool _reached(int i) {
    if (statusId >= 10) return true;
    if (i == 4) return statusId >= 9;
    return statusId >= 2 + i * 2;
  }

  bool get _showOT {
    final hasOt =
        (homeQ.length > 4 && homeQ[4] > 0) ||
        (awayQ.length > 4 && awayQ[4] > 0);
    return statusId == 9 || hasOt;
  }

  @override
  Widget build(BuildContext _) {
    final quarters = [
      'event.basketball.detail.q1'.tr(),
      'event.basketball.detail.q2'.tr(),
      'event.basketball.detail.q3'.tr(),
      'event.basketball.detail.q4'.tr(),
      if (_showOT) 'event.basketball.detail.ot'.tr(),
    ];
    final activeIdx = _activeIdx;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.line, width: 0.5),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                const SizedBox(width: 32),
                ...List.generate(quarters.length, (i) {
                  final isActive = i == activeIdx;
                  return Expanded(
                    child: Text(
                      quarters[i],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.mono(9).copyWith(
                        color: isActive ? colors.accent : colors.text3,
                        letterSpacing: 0.12 * 9,
                      ),
                    ),
                  );
                }),
                SizedBox(
                  width: 44,
                  child: Text(
                    'event.basketball.detail.total'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.mono(
                      9,
                    ).copyWith(color: colors.accent, letterSpacing: 0.12 * 9),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0.5, thickness: 0.5, color: colors.line),
          _ScoreRow(
            logo: homeLogo,
            scores: homeQ,
            total: homeTotal,
            showOT: _showOT,
            activeIdx: activeIdx,
            reached: _reached,
            colors: colors,
            context: context,
            isLast: false,
          ),
          Divider(height: 0.5, thickness: 0.5, color: colors.line),
          _ScoreRow(
            logo: awayLogo,
            scores: awayQ,
            total: awayTotal,
            showOT: _showOT,
            activeIdx: activeIdx,
            reached: _reached,
            colors: colors,
            context: context,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.logo,
    required this.scores,
    required this.total,
    required this.showOT,
    required this.activeIdx,
    required this.reached,
    required this.colors,
    required this.context,
    required this.isLast,
  });

  final String logo;
  final List<int> scores;
  final int total;
  final bool showOT;
  final int? activeIdx;
  final bool Function(int) reached;
  final AppColors colors;
  final BuildContext context;
  final bool isLast;

  String _at(int i) {
    if (!reached(i)) return '-';
    if (i >= scores.length) return '-';
    return '${scores[i]}';
  }

  @override
  Widget build(BuildContext _) {
    final colCount = showOT ? 5 : 4;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          SportLogo(url: logo, size: 24),
          ...List.generate(colCount, (i) {
            final isActive = i == activeIdx;
            return Expanded(
              child: Text(
                _at(i),
                textAlign: TextAlign.center,
                style: AppTextStyles.mono(13).copyWith(
                  color: isActive ? colors.accent : colors.text,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          }),
          SizedBox(
            width: 44,
            child: Text(
              '$total',
              textAlign: TextAlign.center,
              style: AppTextStyles.display(
                18,
                context,
              ).copyWith(color: colors.accent),
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
    final colors = context.appColors;
    final detail =
        ref
                .watch(
                  matchDetailProvider(
                    sport: SportType.basketball,
                    matchId: widget.matchId,
                  ),
                )
                .valueOrNull
            as BasketballMatchDetail?;

    final homeTeamId = detail?.homeTeamId ?? '';
    final awayTeamId = detail?.awayTeamId ?? '';

    if (homeTeamId.isEmpty && awayTeamId.isEmpty) {
      return Center(child: CircularProgressIndicator(color: colors.accent));
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.line, width: 0.5),
          ),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorWeight: 0,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colors.accent,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: const Color(0xFF0E0E0E),
            unselectedLabelColor: colors.text2,
            splashBorderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.all(3),
            tabs: [
              _TeamTab(
                logo: detail?.homeInfo.logo,
                name: detail?.homeName ?? '',
              ),
              _TeamTab(
                logo: detail?.awayInfo.logo,
                name: detail?.awayName ?? '',
              ),
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

  final String? logo;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (logo != null) ...[
            SportLogo(url: logo!, size: 18),
            const SizedBox(width: 6),
          ],
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _TeamSquadList extends ConsumerWidget {
  const _TeamSquadList({required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final squadAsync = ref.watch(basketballTeamSquadProvider(teamId: teamId));

    return squadAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: colors.accent)),
      error: (_, __) => Center(
        child: Text(
          'event.error.load_failed'.tr(),
          style: TextStyle(color: colors.text3),
        ),
      ),
      data: (players) {
        if (players.isEmpty) {
          return Center(
            child: Text(
              'event.basketball.detail.no_squad'.tr(),
              style: TextStyle(color: colors.text3),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 10),
          itemCount: players.length,
          itemBuilder: (context, i) =>
              _PlayerRow(player: players[i], colors: colors, context: context),
        );
      },
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.colors,
    required this.context,
  });

  final BasketballPlayer player;
  final AppColors colors;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.line, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              '${player.shirtNumber}',
              style: AppTextStyles.mono(
                11,
              ).copyWith(color: colors.accent, fontWeight: FontWeight.w700),
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
                  style: TextStyle(fontSize: 13, color: colors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (player.height > 0 || player.weight > 0)
                  Text(
                    [
                      if (player.height > 0) '${player.height}cm',
                      if (player.weight > 0) '${player.weight}kg',
                    ].join(' / '),
                    style: AppTextStyles.mono(10).copyWith(color: colors.text3),
                  ),
              ],
            ),
          ),
          if (player.position.isNotEmpty)
            Text(
              player.position,
              style: AppTextStyles.mono(10).copyWith(color: colors.text2),
            ),
        ],
      ),
    );
  }
}
