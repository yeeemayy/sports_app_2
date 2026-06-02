import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';

class WatchlistService {
  static const _key = 'watchlist_entries';

  Future<List<WatchlistEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map(WatchlistEntry.tryFromRaw)
        .whereType<WatchlistEntry>()
        .toList();
  }

  Future<void> add(WatchlistEntry entry) async {
    final list = await loadAll();
    if (list.any((e) => e.matchId == entry.matchId)) return;
    list.add(entry);
    await _save(list);
  }

  Future<void> remove(String matchId) async {
    final list = await loadAll();
    list.removeWhere((e) => e.matchId == matchId);
    await _save(list);
  }

  Future<void> _save(List<WatchlistEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, entries.map((e) => e.toRaw()).toList());
  }
}
