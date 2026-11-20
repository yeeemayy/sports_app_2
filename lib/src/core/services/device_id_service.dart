import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A random, unguessable id identifying this install (not tied to any user
/// account). Used as the Firestore document key for syncing the watchlist
/// under loose security rules, without requiring the user to sign in.
class DeviceIdService {
  static const _key = 'device_id';

  Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await prefs.setString(_key, id);
    return id;
  }
}
