import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/features/event/data/event_repository.dart';
import 'package:sports_app/src/features/event/domain/models/sport_realtime_data.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';
import 'package:sports_app/src/features/event/domain/sport_config.dart';

part 'realtime_providers.g.dart';

/// Shared polling logic for realtime sports data notifiers.
///
/// Consumers call [setWatchedIds] with a named source and a list of IDs to
/// watch. Call [clearSource] to stop polling for those IDs. The timer is
/// restarted whenever the union of all watched IDs changes.
// ignore: invalid_use_of_internal_member
mixin RealtimePollMixin<T extends SportRealtimeData>
    on BuildlessAutoDisposeNotifier<Map<String, T>> {
  Timer? _pollTimer;
  final Map<String, Set<String>> _sources = {};

  Set<String> get _allIds => _sources.values.expand((s) => s).toSet();

  /// How often to poll the realtime endpoint.
  Duration get pollInterval;

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
      state = {for (final d in data) d.id: d};
    } catch (_) {}
  }
}

/// Generic realtime provider family keyed by [SportType].
///
/// Replaces the 6 sport-specific notifier classes. Stores typed
/// [SportRealtimeData] values; consumers cast to the expected sport type:
///
/// ```dart
/// final rt = ref.watch(
///   sportRealtimeProvider(SportType.basketball)
///     .select((map) => map[matchId] as BasketballRealtimeData?),
/// );
/// ```
@riverpod
class SportRealtime extends _$SportRealtime with RealtimePollMixin<SportRealtimeData> {
  @override
  Duration get pollInterval => arg.config.pollInterval;

  @override
  Future<List<SportRealtimeData>> fetchData() =>
      ref.read(eventRepositoryProvider.notifier).getTypedRealtime(arg);

  @override
  Map<String, SportRealtimeData> build(SportType arg) => initRealtime();
}
