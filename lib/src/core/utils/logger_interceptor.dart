import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sports_app/src/core/config/env_config.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[API] → ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('[API] → query: ${options.queryParameters}');
    }
    if (options.data != null) {
      debugPrint('[API] → data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[API] ← ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('[Raw Response - ${response.requestOptions.uri.path}] ← ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[API] ✕ ${err.requestOptions.uri} — ${err.message}');
    handler.next(err);
  }
}
