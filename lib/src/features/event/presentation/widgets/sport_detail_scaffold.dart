import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/presentation/providers/realtime_providers.dart';
import 'package:sports_app/src/features/event/presentation/widgets/match_detail_appbar.dart';

/// Base state for all sport detail screens.
///
/// Subclasses provide sport-specific providers and tab content.
/// The shared lifecycle (realtime registration, events timer, status listener)
/// and the outer scaffold shell are handled here.
abstract class SportDetailScaffoldState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  Timer? _eventsTimer;

  // ── Abstract interface ──────────────────────────────────────────────────────

  String get matchId;
  SportType get sportType;
  Duration get eventsRefreshInterval;

  /// Invalidate the sport's events provider(s). Called on each timer tick.
  void onEventsTimerTick();

  /// Invalidate the sport's detail + events providers. Called when status changes.
  void onStatusChanged();

  /// Called within [build]. Must call ref.watch for the detail provider and
  /// return (leagueName, matchTimestamp) for the AppBar.
  (String?, int?) watchDetail();

  /// Sport-specific match header widget shown above the tab bar.
  Widget buildHeader(BuildContext context);

  /// Tab bar tab definitions.
  List<Tab> buildTabs(BuildContext context);

  /// Tab view children — must be the same length as [buildTabs].
  List<Widget> buildTabViews(BuildContext context);

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(sportRealtimeProvider(sportType).notifier)
          .setWatchedIds('detail:$matchId', [matchId]);
    });
    _eventsTimer = Timer.periodic(eventsRefreshInterval, (_) {
      if (!mounted) return;
      onEventsTimerTick();
    });
  }

  @override
  void dispose() {
    _eventsTimer?.cancel();
    ref
        .read(sportRealtimeProvider(sportType).notifier)
        .clearSource('detail:$matchId');
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final (leagueName, matchTimestamp) = watchDetail();

    ref.listen(
      sportRealtimeProvider(sportType).select((map) => map[matchId]?.statusId),
      (prev, next) {
        if (prev == null || next == null || prev == next) return;
        onStatusChanged();
      },
    );

    final tabs = buildTabs(context);

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: MatchDetailAppBar(
          leagueName: leagueName ?? '',
          matchTimestamp: matchTimestamp,
        ),
        body: Column(
          children: [
            buildHeader(context),
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.pink,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.pink,
                indicatorWeight: 2,
                tabs: tabs,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: buildTabViews(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
