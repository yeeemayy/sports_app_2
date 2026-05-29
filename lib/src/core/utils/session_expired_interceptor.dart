import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Intercepts API responses with code -40001 (session expired).
///
/// Flow:
///  1. Re-login with saved credentials via [reLoginCallback].
///  2. On success: update the token header and retry the original request.
///  3. On failure: call [onExpiredCallback] which clears credentials and kicks
///     the user back to home with a status dialog.
///
/// Concurrent requests that also get -40001 while a refresh is in-flight wait
/// for the same token via a [Completer] instead of triggering multiple logins.
class SessionExpiredInterceptor extends Interceptor {
  final Future<String?> Function(Dio dio) _reLoginCallback;
  final Future<void> Function() _onExpiredCallback;

  Dio? _dio;

  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  SessionExpiredInterceptor({
    required Future<String?> Function(Dio dio) reLoginCallback,
    required Future<void> Function() onExpiredCallback,
  }) : _reLoginCallback = reLoginCallback,
       _onExpiredCallback = onExpiredCallback;

  /// Called by [ApiClient] after the [Dio] instance is created so the
  /// interceptor can fetch and retry requests.
  void setDio(Dio dio) => _dio = dio;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final data = response.data;

    // Not a session-expired payload — pass through.
    if (response.requestOptions.extra['_skipSessionRetry'] == true ||
        data is! Map ||
        data['code'] != -40001) {
      handler.next(response);
      return;
    }

    // A refresh is already in-flight — wait for it then retry.
    if (_isRefreshing) {
      final newToken = await _refreshCompleter!.future;
      if (newToken != null) {
        await _retryRequest(response.requestOptions, handler, newToken);
      } else {
        handler.next(response);
      }
      return;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      final newToken = await _reLoginCallback(_dio!);
      _refreshCompleter!.complete(newToken);

      if (newToken == null) {
        await _onExpiredCallback();
        handler.next(response);
        return;
      }

      await _retryRequest(response.requestOptions, handler, newToken);
    } catch (e) {
      debugPrint('[SessionExpiredInterceptor] re-login error: $e');
      _refreshCompleter!.complete(null);
      await _onExpiredCallback();
      handler.next(response);
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<void> _retryRequest(
    RequestOptions options,
    ResponseInterceptorHandler handler,
    String newToken,
  ) async {
    options.headers['token'] = newToken;
    options.extra['_skipSessionRetry'] = true;
    try {
      handler.resolve(await _dio!.fetch(options));
    } catch (e) {
      handler.reject(e as DioException);
    }
  }
}
