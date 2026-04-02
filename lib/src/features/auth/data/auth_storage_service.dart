import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_storage_service.g.dart';

const _kTokenKey = 'auth_token';
const _kTelephoneKey = 'auth_telephone';
const _kPasswordKey = 'auth_password';

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

  Future<({String telephone, String password})?> readCredentials() async {
    final telephone = await _storage.read(key: _kTelephoneKey);
    final password = await _storage.read(key: _kPasswordKey);
    if (telephone == null || password == null) return null;
    return (telephone: telephone, password: password);
  }

  Future<void> writeCredentials({
    required String telephone,
    required String password,
  }) async {
    await _storage.write(key: _kTelephoneKey, value: telephone);
    await _storage.write(key: _kPasswordKey, value: password);
  }

  Future<void> deleteCredentials() async {
    await _storage.delete(key: _kTelephoneKey);
    await _storage.delete(key: _kPasswordKey);
  }
}
