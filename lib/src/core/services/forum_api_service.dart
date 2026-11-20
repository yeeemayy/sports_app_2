import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/community/data/community_repository.dart';
import '../config/env_config.dart';
import '../utils/logger_interceptor.dart';
import 'api_client.dart';
import 'token_holder_service.dart';

Dio _buildForumApiService(TokenHolder tokenHolder) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.forumApiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = tokenHolder.value;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(LoggerInterceptor());
  }
  return dio;
}

/// sports_forum Dio instance — the app's one auth surface (login/register/
/// profile) and the Community tab's backing API, authenticated as the
/// signed-in user via the shared [tokenHolderProvider].
final forumApiServiceProvider = Provider<Dio>((ref) => _buildForumApiService(ref.watch(tokenHolderProvider)));

/// sports_forum repository — backs both the main app's auth (see
/// `auth_notifier.dart`) and the Community feature (posts/comments/hashtags/
/// notifications).
final communityRepositoryProvider =
    Provider<CommunityRepository>((ref) => CommunityRepository(ref.watch(forumApiServiceProvider)));
