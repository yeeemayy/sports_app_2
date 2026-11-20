import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_storage_service.g.dart';

const _kTokenKey = 'auth_token';
const _kUsernameKey = 'auth_username';
const _kPasswordKey = 'auth_password';
const _kRcKeyKey = 'auth_rc_key';
const _kRcTokenKey = 'auth_rc_token';

@Riverpod(keepAlive: true)
class AuthStorageService extends _$AuthStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  void build() {}

  Future<String?> readToken() => _storage.read(key: _kTokenKey);

  Future<void> writeToken(String token) =>
      _storage.write(key: _kTokenKey, value: token);

  Future<void> deleteToken() => _storage.delete(key: _kTokenKey);

  Future<({String username, String password})?> readCredentials() async {
    final username = await _storage.read(key: _kUsernameKey);
    final password = await _storage.read(key: _kPasswordKey);
    if (username == null || password == null) return null;
    return (username: username, password: password);
  }

  Future<void> writeCredentials({
    required String username,
    required String password,
  }) async {
    await _storage.write(key: _kUsernameKey, value: username);
    await _storage.write(key: _kPasswordKey, value: password);
  }

  Future<void> deleteCredentials() async {
    await _storage.delete(key: _kUsernameKey);
    await _storage.delete(key: _kPasswordKey);
  }

  /// RongCloud IM connect credentials from sports_forum's login response —
  /// consumed by `rongcloud_service.dart` to connect anchor chat.
  Future<void> writeRcCredentials({
    required String rcKey,
    required String rcToken,
  }) async {
    await _storage.write(key: _kRcKeyKey, value: rcKey);
    await _storage.write(key: _kRcTokenKey, value: rcToken);
  }

  Future<({String rcKey, String rcToken})?> readRcCredentials() async {
    final rcKey = await _storage.read(key: _kRcKeyKey);
    final rcToken = await _storage.read(key: _kRcTokenKey);
    if (rcKey == null || rcToken == null) return null;
    return (rcKey: rcKey, rcToken: rcToken);
  }

  Future<void> deleteRcCredentials() async {
    await _storage.delete(key: _kRcKeyKey);
    await _storage.delete(key: _kRcTokenKey);
  }
}
