import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/features/watchlist/data/notification_service.dart';
import 'package:shenghaotiyu/src/features/watchlist/data/watchlist_cloud_service.dart';
import 'package:shenghaotiyu/src/features/watchlist/data/watchlist_service.dart';
import 'package:shenghaotiyu/src/features/watchlist/domain/watchlist_entry.dart';

final watchlistServiceProvider = Provider<WatchlistService>(
  (_) => WatchlistService(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService(),
);

/// Overridden in `main.dart` with the device id resolved before `runApp`
/// (same pattern as `sharedPreferencesProvider`).
final deviceIdProvider = Provider<String>(
  (ref) => throw UnimplementedError('deviceIdProvider not overridden'),
);

final watchlistCloudServiceProvider = Provider<WatchlistCloudService>(
  (ref) => WatchlistCloudService(ref.watch(deviceIdProvider)),
);

final watchlistNotifierProvider =
    AsyncNotifierProvider<WatchlistNotifier, List<WatchlistEntry>>(
      WatchlistNotifier.new,
    );

class WatchlistNotifier extends AsyncNotifier<List<WatchlistEntry>> {
  WatchlistService get _service => ref.read(watchlistServiceProvider);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);
  WatchlistCloudService get _cloud => ref.read(watchlistCloudServiceProvider);

  @override
  Future<List<WatchlistEntry>> build() async {
    final local = await _service.loadAll();
    try {
      final remote = await _cloud.fetchAll();
      final merged = {for (final e in local) e.matchId: e};
      for (final e in remote) {
        merged.putIfAbsent(e.matchId, () => e);
      }
      final mergedList = merged.values.toList()
        ..sort((a, b) => a.matchTimeMs.compareTo(b.matchTimeMs));
      if (mergedList.length != local.length) {
        for (final e in mergedList) {
          await _service.add(e);
        }
      }
      return mergedList;
    } catch (e) {
      // Best-effort: cloud sync must not block showing the local watchlist.
      debugPrint('WatchlistCloudService.fetchAll failed: $e');
      return local;
    }
  }

  Future<void> add(WatchlistEntry entry) async {
    await _service.add(entry);
    await _notifications.scheduleMatchReminder(entry);
    final current = state.valueOrNull ?? [];
    final updated = [...current, entry]
      ..sort((a, b) => a.matchTimeMs.compareTo(b.matchTimeMs));
    state = AsyncData(updated);
    _mirrorToCloud(updated);
  }

  Future<void> remove(String matchId) async {
    await _service.remove(matchId);
    await _notifications.cancelMatchReminder(matchId);
    final updated = (state.valueOrNull ?? [])
        .where((e) => e.matchId != matchId)
        .toList();
    state = AsyncData(updated);
    _mirrorToCloud(updated);
  }

  bool isWatchlisted(String matchId) =>
      state.valueOrNull?.any((e) => e.matchId == matchId) ?? false;

  void _mirrorToCloud(List<WatchlistEntry> entries) {
    unawaited(
      _cloud.writeAll(entries).catchError((e, st) {
        debugPrint('WatchlistCloudService.writeAll failed: $e');
      }),
    );
  }
}
