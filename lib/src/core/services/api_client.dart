import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shenghaotiyu/src/core/config/env_config.dart';
import 'package:shenghaotiyu/src/core/utils/logger_interceptor.dart';
import 'package:shenghaotiyu/src/core/utils/session_expired_interceptor.dart';

typedef ApiClientException = DioException;
typedef ApiClientResponse<T> = Response<T>;

extension ApiClientExceptionX on ApiClientException {
  /// Returns a single error message from the response.
  /// Checks for 'error' or 'message' fields.
  String? get responseMessage {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      return (data['msg']) as String?;
    }
    return null;
  }

  /// Returns the best available error message.
  String get displayMessage {
    return responseMessage ?? 'An unexpected error occurred';
  }
}

/// Mutable holder for the current sports_forum auth token.
/// Updated by AuthNotifier on login/logout; read by `forum_api_service.dart`.
class TokenHolder {
  String? value;
}

/// zb v5 (`EnvConfig.apiUrl`) requests carry no user auth — the endpoints
/// this client serves (anchor detail, banner, guest IM token) don't need it,
/// and zb's own login flow was removed when auth moved entirely to
/// sports_forum. Only the HMAC signing headers below are attached.
class ApiClient {
  late final Dio httpClient;

  ApiClient(SessionExpiredInterceptor sessionExpiredInterceptor) {
    httpClient = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    httpClient.interceptors.add(_SigningInterceptor(EnvConfig.secretKey));

    // Provide the Dio instance so the interceptor can retry requests.
    sessionExpiredInterceptor.setDio(httpClient);
    httpClient.interceptors.add(sessionExpiredInterceptor);

    if (kDebugMode) {
      httpClient.interceptors.add(LoggerInterceptor());
    }
  }
}

class _SigningInterceptor extends Interceptor {
  final String _secretKey;

  _SigningInterceptor(this._secretKey);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final random = _randomString(32);
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final source = random + timestamp;

    final key = utf8.encode(_secretKey);
    final msg = utf8.encode(source);
    // Digest.toString() returns the lowercase hex string — matches CryptoJS .toString(crypto.digest)
    final hexString = Hmac(sha256, key).convert(msg).toString();
    final sign = base64Encode(utf8.encode(hexString));

    // Mobile-only: dart:io Platform is not available on Flutter Web
    final client = Platform.isIOS ? 'ios' : 'android';

    options.headers['time'] = timestamp;
    options.headers['random'] = random;
    options.headers['sign'] = sign;
    options.headers['app'] = EnvConfig.appName;
    options.headers['client'] = client;

    handler.next(options);
  }

  String _randomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
