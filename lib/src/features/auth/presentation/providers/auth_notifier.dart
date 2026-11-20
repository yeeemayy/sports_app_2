import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/core/services/forum_api_service.dart';
import 'package:shenghaotiyu/src/core/services/token_holder_service.dart';
import 'package:shenghaotiyu/src/features/auth/data/auth_storage_service.dart';
import 'package:shenghaotiyu/src/features/community/domain/models/community_post.dart';

part 'auth_notifier.g.dart';

class AuthState {
  const AuthState({this.token, this.user, this.rcKey, this.rcToken});

  final String? token;
  final CommunityAuthor? user;

  /// RongCloud IM connect credentials from sports_forum's `/login` response —
  /// only populated right after a fresh login; a restored session leaves
  /// these null and `rongcloud_service.dart` falls back to secure storage.
  final String? rcKey;
  final String? rcToken;

  bool get isAuthenticated => token != null && token!.isNotEmpty;
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(authStorageServiceProvider.notifier);
    final tokenHolder = ref.read(tokenHolderProvider);
    final repo = ref.read(communityRepositoryProvider);

    final credentials = await storage.readCredentials();
    if (credentials == null) {
      return const AuthState();
    }

    // Re-login with saved credentials to get a fresh token on every app open
    try {
      final response = await repo.login(
        username: credentials.username,
        password: credentials.password,
      );
      tokenHolder.value = response.token;
      await storage.writeToken(response.token);
      await storage.writeRcCredentials(
        rcKey: response.rcKey,
        rcToken: response.rcToken,
      );
      return AuthState(
        token: response.token,
        user: response.user,
        rcKey: response.rcKey,
        rcToken: response.rcToken,
      );
    } catch (_) {
      // Login failed — clear stored session
      await storage.deleteToken();
      await storage.deleteCredentials();
      await storage.deleteRcCredentials();
      tokenHolder.value = null;
      return const AuthState();
    }
  }

  Future<void> login({required String username, required String password}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(communityRepositoryProvider);
      final storage = ref.read(authStorageServiceProvider.notifier);
      final tokenHolder = ref.read(tokenHolderProvider);

      final response = await repo.login(username: username, password: password);
      tokenHolder.value = response.token;
      await storage.writeToken(response.token);
      await storage.writeCredentials(username: username, password: password);
      await storage.writeRcCredentials(
        rcKey: response.rcKey,
        rcToken: response.rcToken,
      );

      state = AsyncData(
        AuthState(
          token: response.token,
          user: response.user,
          rcKey: response.rcKey,
          rcToken: response.rcToken,
        ),
      );
    } catch (e) {
      state = const AsyncData(AuthState());
      rethrow;
    }
  }

  Future<void> register({
    required String username,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(communityRepositoryProvider);
      final storage = ref.read(authStorageServiceProvider.notifier);
      final tokenHolder = ref.read(tokenHolderProvider);

      final token = await repo.register(username: username, password: password, name: name);
      tokenHolder.value = token;
      await storage.writeToken(token);
      await storage.writeCredentials(username: username, password: password);

      final user = await repo.fetchCurrentUser();
      state = AsyncData(AuthState(token: token, user: user));
    } catch (e) {
      state = const AsyncData(AuthState());
      rethrow;
    }
  }

  Future<void> logout() async {
    final tokenHolder = ref.read(tokenHolderProvider);
    final storage = ref.read(authStorageServiceProvider.notifier);

    // Best-effort server logout; proceed with local cleanup regardless
    try {
      await ref.read(communityRepositoryProvider).logout();
    } catch (_) {}

    tokenHolder.value = null;
    await storage.deleteToken();
    await storage.deleteCredentials();
    await storage.deleteRcCredentials();
    state = const AsyncData(AuthState());
  }

  Future<void> updateProfile({String? nickname, String? bio}) async {
    final repo = ref.read(communityRepositoryProvider);
    await repo.updateProfile(name: nickname, bio: bio);
    final user = await repo.fetchCurrentUser();
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        AuthState(
          token: current.token,
          user: user,
          rcKey: current.rcKey,
          rcToken: current.rcToken,
        ),
      );
    }
  }

  Future<void> deleteAccount() async {
    final tokenHolder = ref.read(tokenHolderProvider);
    final storage = ref.read(authStorageServiceProvider.notifier);

    await ref.read(communityRepositoryProvider).deleteAccount();

    tokenHolder.value = null;
    await storage.deleteToken();
    await storage.deleteCredentials();
    await storage.deleteRcCredentials();
    state = const AsyncData(AuthState());
  }

  void clearSession() {
    state = const AsyncData(AuthState());
  }
}
