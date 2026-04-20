import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/services/token_holder_service.dart';
import 'package:sports_app/src/features/auth/data/auth_repository.dart';
import 'package:sports_app/src/features/auth/data/auth_storage_service.dart';
import 'package:sports_app/src/features/auth/domain/models/user_model.dart';

part 'auth_notifier.g.dart';

class AuthState {
  const AuthState({this.token, this.user});

  final String? token;
  final UserModel? user;

  bool get isAuthenticated => token != null && token!.isNotEmpty;
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(authStorageServiceProvider.notifier);
    final tokenHolder = ref.read(tokenHolderProvider);
    final repo = ref.read(authRepositoryProvider.notifier);

    final credentials = await storage.readCredentials();
    if (credentials == null) {
      return const AuthState();
    }

    // Re-login with saved credentials to get a fresh token on every app open
    try {
      final token = await repo.login(
        telephone: credentials.telephone,
        password: credentials.password,
      );
      tokenHolder.value = token;
      await storage.writeToken(token);
      final user = await repo.fetchUser();
      return AuthState(token: token, user: user);
    } catch (_) {
      // Login failed — clear stored session
      await storage.deleteToken();
      await storage.deleteCredentials();
      tokenHolder.value = null;
      return const AuthState();
    }
  }

  Future<void> login({required String telephone, required String password}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider.notifier);
      final storage = ref.read(authStorageServiceProvider.notifier);
      final tokenHolder = ref.read(tokenHolderProvider);

      final token = await repo.login(telephone: telephone, password: password);
      tokenHolder.value = token;
      await storage.writeToken(token);
      await storage.writeCredentials(telephone: telephone, password: password);

      final user = await repo.fetchUser();
      state = AsyncData(AuthState(token: token, user: user));
    } catch (e, st) {
      state = const AsyncData(AuthState());
      rethrow;
    }
  }

  Future<void> register({
    required String nickname,
    required String telephone,
    required String password,
    required String sms,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider.notifier);
      final storage = ref.read(authStorageServiceProvider.notifier);
      final tokenHolder = ref.read(tokenHolderProvider);

      final token = await repo.register(
        nickname: nickname,
        telephone: telephone,
        password: password,
        sms: sms,
      );
      tokenHolder.value = token;
      await storage.writeToken(token);
      await storage.writeCredentials(telephone: telephone, password: password);

      final user = await repo.fetchUser();
      return AuthState(token: token, user: user);
    });
  }

  Future<void> logout() async {
    final tokenHolder = ref.read(tokenHolderProvider);
    final storage = ref.read(authStorageServiceProvider.notifier);

    // Best-effort server logout; proceed with local cleanup regardless
    try {
      await ref.read(authRepositoryProvider.notifier).logout();
    } catch (_) {}

    tokenHolder.value = null;
    await storage.deleteToken();
    await storage.deleteCredentials();
    state = const AsyncData(AuthState());
  }

  Future<void> updateProfile({String? nickname, String? avatarUrl}) async {
    final repo = ref.read(authRepositoryProvider.notifier);
    await repo.updateProfile(nickname: nickname, avatarUrl: avatarUrl);
    final user = await repo.fetchUser();
    final current = state.value;
    if (current != null) {
      state = AsyncData(AuthState(token: current.token, user: user));
    }
  }

  void clearSession() {
    state = const AsyncData(AuthState());
  }

  Future<void> resetPassword({
    required String telephone,
    required String password,
    required String sms,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider.notifier)
          .resetPassword(telephone: telephone, password: password, sms: sms);
      return const AuthState();
    });
  }
}
