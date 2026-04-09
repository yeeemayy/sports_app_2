import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/features/event/data/event_repository.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/match_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_realtime_data.dart';

part 'realtime_providers.g.dart';

/// Shared polling logic for realtime sports data notifiers.
///
/// Consumers call [setWatchedIds] with a named source and a list of IDs to
/// watch. Call [clearSource] to stop polling for those IDs. The timer is
/// restarted whenever the union of all watched IDs changes.
mixin RealtimePollMixin<T> on AutoDisposeNotifier<Map<String, T>> {
  Timer? _pollTimer;
  final Map<String, Set<String>> _sources = {};

  Set<String> get _allIds => _sources.values.expand((s) => s).toSet();

  /// How often to poll the realtime endpoint.
  Duration get pollInterval;

  /// Returns the unique match ID for a realtime data item.
  String idOf(T item);

  /// Fetches a fresh snapshot from the repository.
  Future<List<T>> fetchData();

  /// Wire up dispose handling. Call from [build].
  Map<String, T> initRealtime() {
    ref.onDispose(() => _pollTimer?.cancel());
    return {};
  }

  void setWatchedIds(String source, List<String> ids) {
    final newSet = ids.toSet();
    final existing = _sources[source];
    if (existing != null && existing.length == newSet.length && existing.containsAll(newSet)) return;
    _sources[source] = newSet;
    _restartTimer();
  }

  void clearSource(String source) {
    if (!_sources.containsKey(source)) return;
    _sources.remove(source);
    _restartTimer();
  }

  void _restartTimer() {
    _pollTimer?.cancel();
    if (_allIds.isEmpty) return;
    _poll();
    _pollTimer = Timer.periodic(pollInterval, (_) => _poll());
  }

  Future<void> _poll() async {
    if (_allIds.isEmpty) return;
    try {
      final data = await fetchData();
      state = {for (final d in data) idOf(d): d};
    } catch (_) {}
  }
}

@riverpod
class FootballRealtime extends _$FootballRealtime with RealtimePollMixin<MatchRealtimeData> {
  @override
  Duration get pollInterval => const Duration(seconds: 1);

  @override
  String idOf(MatchRealtimeData item) => item.id;

  @override
  Future<List<MatchRealtimeData>> fetchData() =>
      ref.read(eventRepositoryProvider.notifier).getRealtimeMatches();

  @override
  Map<String, MatchRealtimeData> build() => initRealtime();
}

@riverpod
class BasketballRealtime extends _$BasketballRealtime with RealtimePollMixin<BasketballRealtimeData> {
  @override
  Duration get pollInterval => const Duration(seconds: 2);

  @override
  String idOf(BasketballRealtimeData item) => item.id;

  @override
  Future<List<BasketballRealtimeData>> fetchData() =>
      ref.read(eventRepositoryProvider.notifier).getBasketballRealtimeMatches();

  @override
  Map<String, BasketballRealtimeData> build() => initRealtime();
}

@riverpod
class TennisRealtime extends _$TennisRealtime with RealtimePollMixin<TennisRealtimeData> {
  @override
  Duration get pollInterval => const Duration(seconds: 2);

  @override
  String idOf(TennisRealtimeData item) => item.id;

  @override
  Future<List<TennisRealtimeData>> fetchData() =>
      ref.read(eventRepositoryProvider.notifier).getTennisRealtimeMatches();

  @override
  Map<String, TennisRealtimeData> build() => initRealtime();
}
