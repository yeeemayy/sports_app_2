import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/core/config/env_config.dart';
import 'package:shenghaotiyu/src/core/services/api_client.dart';
import 'package:shenghaotiyu/src/core/services/token_holder_service.dart';
import 'package:shenghaotiyu/src/core/utils/logger_interceptor.dart';
import 'package:shenghaotiyu/src/core/utils/session_expired_interceptor.dart';
import 'package:shenghaotiyu/src/features/auth/data/auth_storage_service.dart';
import 'package:shenghaotiyu/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shenghaotiyu/src/routes/app_router.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';
import 'package:shenghaotiyu/src/shared_widgets/custom_status_dialog.dart';

part 'api_service.g.dart';

@Riverpod(keepAlive: true)
Dio newsApiService(NewsApiServiceRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.newsApiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(LoggerInterceptor());
  }
  return dio;
}

@Riverpod(keepAlive: true)
Dio sportsApiService(SportsApiServiceRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.aiscoreSportUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(LoggerInterceptor());
  }
  return dio;
}

@Riverpod(keepAlive: true)
ApiClient apiService(ApiServiceRef ref) {
  final holder = ref.watch(tokenHolderProvider);

  final interceptor = SessionExpiredInterceptor(
    reLoginCallback: (Dio dio) async {
      final storage = ref.read(authStorageServiceProvider.notifier);
      final credentials = await storage.readCredentials();
      if (credentials == null) return null;

      try {
        final response = await dio.post(
          '/auth/login',
          data: {
            'telephone': credentials.telephone,
            'password': credentials.password,
          },
          options: Options(extra: {'_skipSessionRetry': true}),
        );
        final json = response.data as Map<String, dynamic>;
        if (json['code'] != 1) return null;

        final token = (json['data'] as Map<String, dynamic>)['token'] as String;
        holder.value = token;
        await storage.writeToken(token);
        return token;
      } catch (_) {
        return null;
      }
    },
    onExpiredCallback: () async {
      final storage = ref.read(authStorageServiceProvider.notifier);
      await storage.deleteToken();
      await storage.deleteCredentials();
      holder.value = null;
      ref.read(authNotifierProvider.notifier).clearSession();

      final context = rootNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      await showCustomStatusDialog(
        context: context,
        title: 'session.expired_title'.tr(),
        description: 'session.expired_description'.tr(),
        buttonText: 'session.ok'.tr(),
        dialogType: DialogType.fail,
        showCloseButton: false,
        // onButtonPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        onButtonPressed: () {
          context.pop();
          context.go(AppRoutes.home);
        },
      );

      // final navContext = navigatorKey.currentContext;
      // if (navContext != null && navContext.mounted) {
      //   GoRouter.of(navContext).go('/home');
      // }
    },
  );

  return ApiClient(holder, interceptor);
}
