import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/exceptions/app_exception.dart';
import 'package:sports_app/src/core/services/api_service.dart';
import 'package:sports_app/src/features/auth/domain/models/user_model.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
class AuthRepository extends _$AuthRepository {
  @override
  void build() {}

  Future<String> login({required String telephone, required String password}) async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final response = await dio.post(
      '/auth/login',
      data: {'telephone': telephone, 'password': password},
    );
    final json = response.data as Map<String, dynamic>;
    if (json['code'] != 1) throw AppException(json['msg'] ?? 'common.error.unexpected'.tr());
    return (json['data'] as Map<String, dynamic>)['token'] as String;
  }

  Future<String> register({
    required String nickname,
    required String telephone,
    required String password,
    required String sms,
  }) async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final response = await dio.post(
      '/auth/register',
      data: {'nickname': nickname, 'telephone': telephone, 'password': password, 'sms': sms},
    );
    final json = response.data as Map<String, dynamic>;
    if (json['code'] != 1) throw AppException(json['msg'] ?? 'Registration failed');
    return (json['data'] as Map<String, dynamic>)['token'] as String;
  }

  Future<void> resetPassword({
    required String telephone,
    required String password,
    required String sms,
  }) async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final response = await dio.post(
      '/auth/forget',
      data: {'telephone': telephone, 'password': password, 'sms': sms},
    );
    final json = response.data as Map<String, dynamic>;
    if (json['code'] != 1) throw AppException(json['msg'] ?? 'Reset failed');
  }

  Future<void> requestSms({required String telephone, required int scene}) async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final response = await dio.get(
      // '/auth/sms',
      '/auth/sms-dev-test',
      queryParameters: {'telephone': telephone, 'scene': scene},
    );
    final json = response.data as Map<String, dynamic>;
    if (json['code'] != 1) throw AppException(json['msg'] ?? 'SMS send failed');
  }

  Future<UserModel> fetchUser() async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final response = await dio.get('/users');
    final json = response.data as Map<String, dynamic>;
    log('[Fetch User] raw response: $json');
    if (json['code'] != 1) throw AppException(json['msg'] ?? 'Failed to fetch user');
    return UserModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<String> uploadAvatar(String filePath) async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await dio.post('/upload', data: formData);
    final json = response.data as Map<String, dynamic>;
    if (json['code'] != 1) throw AppException(json['msg'] ?? 'Upload failed');
    return (json['data'] as Map<String, dynamic>)['imgUrl'] as String;
  }

  Future<void> updateProfile({String? nickname, String? avatarUrl}) async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    final response = await dio.put('/users', data: data);
    final json = response.data as Map<String, dynamic>;
    if (json['code'] != 1) throw AppException(json['msg'] ?? 'Update failed');
  }

  Future<void> logout() async {
    final dio = ref.read(apiServiceProvider).httpClient;
    final response = await dio.delete('/users/logout');
    final json = response.data as Map<String, dynamic>;
    if (json['code'] != 1) throw AppException(json['msg'] ?? 'Logout failed');
  }
}
