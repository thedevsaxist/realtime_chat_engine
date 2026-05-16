import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final Dio _refreshDio;
  late final VoidCallback onLogout;
  final AuthSecureStorage _authSecureStorage;

  AuthInterceptor(this._authSecureStorage, this._dio, this._refreshDio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _authSecureStorage.getToken();

    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }

    debugPrint('Final headers: ${options.headers}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('[AuthInterceptor] onError: ${err.response?.statusCode}');

    if (err.response?.statusCode != 401) return handler.next(err);
    if (err.requestOptions.path.contains('/auth/login') ||
        err.requestOptions.path.contains('/auth/register')) {
      return handler.next(err);
    }

    final refreshToken = await _authSecureStorage.getRefreshToken();
    debugPrint('[AuthInterceptor] refreshToken from storage: $refreshToken');

    if (refreshToken == null) return handler.next(err);

    try {
      debugPrint('[AuthInterceptor] calling /auth/refresh...');

      final response = await _refreshDio.post(
        "/auth/refresh",
        data: {"refreshToken": refreshToken},
      );

      debugPrint('\n\n[AuthInterceptor] refresh response: ${response.data}');

      final newToken = response.data["token"] as String;
      final newRefresh = response.data["refreshToken"] as String;

      await _authSecureStorage.saveToken(newToken, newRefresh);

      err.requestOptions.headers["Authorization"] = "Bearer $newToken";

      final retryResponse = await _dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (e) {
      debugPrint('[AuthInterceptor] refresh failed: $e');
      onLogout();
      handler.next(err);
    }
  }
}
