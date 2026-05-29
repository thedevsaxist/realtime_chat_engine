import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:realtime_chat_engine/core/config/network/token_refresh_service.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenRefreshService _tokenRefresh;
  Future<void> Function()? onLogout;
  final AuthSecureStorage _authSecureStorage;

  AuthInterceptor(this._authSecureStorage, this._dio, this._tokenRefresh);

  static bool _shouldSkipRefresh(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _authSecureStorage.getToken();

    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint(
      '[AuthInterceptor] onError: ${err.response?.statusCode} ${err.response?.statusMessage}',
    );

    if (err.response?.statusCode != 401) return handler.next(err);
    if (_shouldSkipRefresh(err.requestOptions.path)) return handler.next(err);
    if (err.requestOptions.extra['auth_retry'] == true) return handler.next(err);

    try {
      final newToken = await _tokenRefresh.refresh();
      if (newToken == null) return handler.next(err);

      err.requestOptions.extra['auth_retry'] = true;
      err.requestOptions.headers["Authorization"] = "Bearer $newToken";

      final retryResponse = await _dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (e) {
      debugPrint('[AuthInterceptor] refresh failed: $e');
      await onLogout?.call();
      handler.next(err);
    }
  }
}
