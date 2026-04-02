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

    final savedToken = await storage.readToken();
    if (savedToken == null || savedToken.isEmpty) {
      return const AuthState();
    }

    // Restore token so authenticated requests work immediately
    tokenHolder.value = savedToken;

    try {
      final user = await ref.read(authRepositoryProvider.notifier).fetchUser();
      return AuthState(token: savedToken, user: user);
    } catch (_) {
      // Token expired or invalid — clear it
      await storage.deleteToken();
      tokenHolder.value = null;
      return const AuthState();
    }
  }

  Future<void> login({
    required String telephone,
    required String password,
  }) async {
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
    state = const AsyncData(AuthState());
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
      await ref.read(authRepositoryProvider.notifier).resetPassword(
        telephone: telephone,
        password: password,
        sms: sms,
      );
      return const AuthState();
    });
  }
}
