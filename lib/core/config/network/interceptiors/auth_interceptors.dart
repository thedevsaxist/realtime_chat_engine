import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final AuthSecureStorage _authSecureStorage;

  AuthInterceptor(this._authSecureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _authSecureStorage.getToken();
    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }
    debugPrint('Final headers: ${options.headers}');
    handler.next(options);
  }
}
