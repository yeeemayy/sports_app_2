import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shenghaotiyu/src/features/watchlist/domain/watchlist_entry.dart';

/// Mirrors the watchlist to Firestore so it survives reinstalls and syncs
/// across a user's devices, keyed by [DeviceIdService]'s id rather than an
/// account. SharedPreferences via [WatchlistService] stays the offline-first
/// source of truth; this is a best-effort mirror that callers should not let
/// block on network.
class WatchlistCloudService {
  WatchlistCloudService(this._deviceId);

  final String _deviceId;

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('watchlistEntries').doc(_deviceId);

  Future<List<WatchlistEntry>> fetchAll() async {
    final snapshot = await _doc.get();
    final entries = snapshot.data()?['entries'] as List<dynamic>?;
    if (entries == null) return [];
    return entries
        .map((e) => WatchlistEntry.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> writeAll(List<WatchlistEntry> entries) => _doc.set({
    'entries': entries.map((e) => e.toJson()).toList(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
