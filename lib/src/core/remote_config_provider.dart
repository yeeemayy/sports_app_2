import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ponytail: no config-fetch UI/retry — RemoteConfig.instance already caches
// last-fetched values, so a failed fetch during init just falls back to defaults.
final remoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  throw UnimplementedError('Override remoteConfigProvider in ProviderScope');
});

final predictionSystemEnabledProvider = Provider<bool>((ref) {
  return ref.watch(remoteConfigProvider).getBool('prediction_system_enabled');
});

/// Reads `prediction_redemptions`, a JSON array of `{product, points, date}`
/// objects, from Firebase Remote Config.
final predictionRedemptionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final raw = ref.watch(remoteConfigProvider).getString('prediction_redemptions');
  if (raw.isEmpty) return const [];
  try {
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  } catch (_) {
    // ponytail: malformed remote value — fail safe to empty list rather than crash.
    return const [];
  }
});
