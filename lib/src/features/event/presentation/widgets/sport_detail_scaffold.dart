import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/event_providers.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/realtime_providers.dart';

/// Base state for all sport detail screens.
abstract class SportDetailScaffoldState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  Timer? _eventsTimer;
  SportRealtime? _realtimeNotifier;

  String get matchId;
  SportType get sportType;
  Duration get eventsRefreshInterval;

  void onEventsTimerTick() {
    ref.invalidate(matchEventsProvider(sport: sportType, matchId: matchId));
  }

  void onStatusChanged() {
    ref.invalidate(matchDetailProvider(sport: sportType, matchId: matchId));
    ref.invalidate(matchEventsProvider(sport: sportType, matchId: matchId));
  }

  /// Return (leagueName, matchTimestamp) — called inside build().
  (String?, int?) watchDetail();

  /// Sport-specific header (gradient shell + score). Receives leagueName and
  /// matchTimestamp so they can be forwarded to [SportDetailHeaderShell].
  Widget buildHeader(
    BuildContext context, {
    String? leagueName,
    int? matchTimestamp,
  });

  List<Tab> buildTabs(BuildContext context);
  List<Widget> buildTabViews(BuildContext context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _realtimeNotifier = ref.read(sportRealtimeProvider(sportType).notifier);
      _realtimeNotifier!.setWatchedIds('detail:$matchId', [matchId]);
    });
    _eventsTimer = Timer.periodic(eventsRefreshInterval, (_) {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      onEventsTimerTick();
    });
  }

  @override
  void dispose() {
    _eventsTimer?.cancel();
    _realtimeNotifier?.clearSource('detail:$matchId');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (leagueName, matchTimestamp) = watchDetail();
    final colors = context.appColors;
    final tabs = buildTabs(context);

    ref.listen(
      sportRealtimeProvider(sportType).select((map) => map[matchId]?.statusId),
      (prev, next) {
        if (prev == null || next == null || prev == next) return;
        if (ModalRoute.of(context)?.isCurrent != true) return;
        onStatusChanged();
      },
    );

    return Scaffold(
      backgroundColor: colors.ink,
      body: DefaultTabController(
        length: tabs.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(
              context,
              leagueName: leagueName,
              matchTimestamp: matchTimestamp,
            ),
            Container(
              color: colors.surface,
              child: TabBar(
                labelStyle: AppTextStyles.display(
                  13,
                  context,
                ).copyWith(letterSpacing: 0.04 * 13),
                unselectedLabelStyle: AppTextStyles.display(
                  13,
                  context,
                ).copyWith(letterSpacing: 0.04 * 13),
                labelColor: colors.text,
                unselectedLabelColor: colors.text3,
                indicatorColor: colors.accent,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: colors.line,
                dividerHeight: 0.5,
                tabs: tabs,
              ),
            ),
            Expanded(child: TabBarView(children: buildTabViews(context))),
          ],
        ),
      ),
    );
  }
}
