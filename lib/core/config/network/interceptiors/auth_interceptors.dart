import 'package:dio/dio.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final AuthSecureStorage _authSecureStorage;

  AuthInterceptor(this._authSecureStorage);
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    super.onRequest(options, handler);

    final token = await _authSecureStorage.getToken();
    options.headers["Authorization"] = "Bearer $token";
  }
}

