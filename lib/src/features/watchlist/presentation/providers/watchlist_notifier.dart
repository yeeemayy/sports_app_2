import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/watchlist/data/notification_service.dart';
import 'package:sports_app/src/features/watchlist/data/watchlist_service.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';

final watchlistServiceProvider = Provider<WatchlistService>(
  (_) => WatchlistService(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService(),
);

final watchlistNotifierProvider =
    AsyncNotifierProvider<WatchlistNotifier, List<WatchlistEntry>>(
      WatchlistNotifier.new,
    );

class WatchlistNotifier extends AsyncNotifier<List<WatchlistEntry>> {
  WatchlistService get _service => ref.read(watchlistServiceProvider);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  @override
  Future<List<WatchlistEntry>> build() => _service.loadAll();

  Future<void> add(WatchlistEntry entry) async {
    await _service.add(entry);
    await _notifications.scheduleMatchReminder(entry);
    final current = state.valueOrNull ?? [];
    final updated = [...current, entry]
      ..sort((a, b) => a.matchTimeMs.compareTo(b.matchTimeMs));
    state = AsyncData(updated);
  }

  Future<void> remove(String matchId) async {
    await _service.remove(matchId);
    await _notifications.cancelMatchReminder(matchId);
    state = AsyncData(
      (state.valueOrNull ?? [])
          .where((e) => e.matchId != matchId)
          .toList(),
    );
  }

  bool isWatchlisted(String matchId) =>
      state.valueOrNull?.any((e) => e.matchId == matchId) ?? false;
}
