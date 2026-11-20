import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/models/community_post.dart';

/// Community authenticates via the app's single unified sports_forum-backed
/// auth/session (see `auth_notifier.dart`) — these are thin read-only views
/// over it, kept under the Community feature's own names since Community
/// screens only ever need to check/react to login state, never manage it
/// directly (see `ensureCommunityLoggedIn`, which pushes the app's shared
/// login screen).
final communityAuthControllerProvider = Provider<AsyncValue<CommunityAuthor?>>((ref) {
  return ref.watch(authNotifierProvider).whenData((s) => s.user);
});

/// Convenience: true once a user is signed in (drives auth-gated
/// actions/UI within the Community feature).
final isCommunityLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(communityAuthControllerProvider).valueOrNull != null;
});
