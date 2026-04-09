import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/features/event/data/event_repository.dart';
import 'package:sports_app/src/features/event/domain/models/basketball_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/match_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/tennis_realtime_data.dart';

part 'realtime_providers.g.dart';

@riverpod
class FootballRealtime extends _$FootballRealtime {
  Timer? _timer;
  final Map<String, Set<String>> _sources = {};

  Set<String> get _allIds => _sources.values.expand((s) => s).toSet();

  @override
  Map<String, MatchRealtimeData> build() {
    ref.onDispose(() => _timer?.cancel());
    return {};
  }

  void setWatchedIds(String source, List<String> ids) {
    final newSet = ids.toSet();
    final existing = _sources[source];
    if (existing != null && existing.length == newSet.length && existing.containsAll(newSet))
      return;
    _sources[source] = newSet;
    _restartTimer();
  }

  void clearSource(String source) {
    if (!_sources.containsKey(source)) return;
    _sources.remove(source);
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (_allIds.isEmpty) return;
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _poll());
  }

  Future<void> _poll() async {
    if (_allIds.isEmpty) return;
    try {
      final data = await ref.read(eventRepositoryProvider.notifier).getRealtimeMatches();
      state = {for (final d in data) d.id: d};
    } catch (_) {}
  }
}

@riverpod
class BasketballRealtime extends _$BasketballRealtime {
  Timer? _timer;
  final Map<String, Set<String>> _sources = {};

  Set<String> get _allIds => _sources.values.expand((s) => s).toSet();

  @override
  Map<String, BasketballRealtimeData> build() {
    ref.onDispose(() => _timer?.cancel());
    return {};
  }

  void setWatchedIds(String source, List<String> ids) {
    final newSet = ids.toSet();
    final existing = _sources[source];
    if (existing != null && existing.length == newSet.length && existing.containsAll(newSet))
      return;
    _sources[source] = newSet;
    _restartTimer();
  }

  void clearSource(String source) {
    if (!_sources.containsKey(source)) return;
    _sources.remove(source);
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (_allIds.isEmpty) return;
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  Future<void> _poll() async {
    if (_allIds.isEmpty) return;
    try {
      final data = await ref.read(eventRepositoryProvider.notifier).getBasketballRealtimeMatches();
      state = {for (final d in data) d.id: d};
    } catch (_) {}
  }
}

@riverpod
class TennisRealtime extends _$TennisRealtime {
  Timer? _timer;
  final Map<String, Set<String>> _sources = {};

  Set<String> get _allIds => _sources.values.expand((s) => s).toSet();

  @override
  Map<String, TennisRealtimeData> build() {
    ref.onDispose(() => _timer?.cancel());
    return {};
  }

  void setWatchedIds(String source, List<String> ids) {
    final newSet = ids.toSet();
    final existing = _sources[source];
    if (existing != null && existing.length == newSet.length && existing.containsAll(newSet))
      return;
    _sources[source] = newSet;
    _restartTimer();
  }

  void clearSource(String source) {
    if (!_sources.containsKey(source)) return;
    _sources.remove(source);
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (_allIds.isEmpty) return;
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  Future<void> _poll() async {
    if (_allIds.isEmpty) return;
    try {
      final data = await ref.read(eventRepositoryProvider.notifier).getTennisRealtimeMatches();
      state = {for (final d in data) d.id: d};
    } catch (_) {}
  }
}
