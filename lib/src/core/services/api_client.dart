import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sports_app/src/core/config/env_config.dart';
import 'package:sports_app/src/core/utils/logger_interceptor.dart';

class ApiClient {
  late final Dio httpClient;

  ApiClient() {
    httpClient = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    httpClient.interceptors.add(_SigningInterceptor(EnvConfig.secretKey));

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
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
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
    options.headers['client'] = client;

    handler.next(options);
  }

  String _randomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
