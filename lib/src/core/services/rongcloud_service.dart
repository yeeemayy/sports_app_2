import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/features/anchor/data/anchor_api_client.dart';
import 'package:shenghaotiyu/src/features/auth/data/auth_storage_service.dart';
import 'package:shenghaotiyu/src/features/auth/presentation/providers/auth_notifier.dart';

/// RongCloud IM connect credentials (`rcKey` = app key, `rcToken` = connect
/// token) for the anchor chatroom identified by [cid].
///
/// Signed-in users get `rc_key`/`rc_token` from the unified sports_forum
/// login. Signed-out viewers fall back to the anchor-scoped `/auth/im?cid=`
/// guest endpoint, which hands out a temporary read-only RongCloud identity
/// (negative guest id) so they can still watch the chatroom without an
/// account; sending remains gated to signed-in users (see `_ChatInputBar`).
final rongCloudCredentialsProvider =
    FutureProvider.autoDispose.family<({String rcKey, String rcToken})?, int>((
  ref,
  cid,
) async {
  final authState = ref.watch(authNotifierProvider).valueOrNull;
  if (authState != null && authState.isAuthenticated) {
    final storage = ref.read(authStorageServiceProvider.notifier);
    return storage.readRcCredentials();
  }

  final guestToken = await ref.read(anchorApiClientProvider).fetchImToken(cid);
  return (rcKey: guestToken.appKey, rcToken: guestToken.token);
});
