import 'package:dio/dio.dart';
import 'package:realtime_chat_engine/core/config/network/interceptors/logging_interceptor.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';
import 'package:riverpod/riverpod.dart';

import 'interceptors/auth_interceptors.dart';

class DioService {
  final Dio _dio;
  final AuthSecureStorage _authSecureStorage;

  DioService(this._authSecureStorage)
    : _dio = Dio(
        BaseOptions(
          baseUrl: Constants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    final refreshDio = Dio(BaseOptions(baseUrl: Constants.baseUrl));
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(AuthInterceptor(_authSecureStorage, _dio, refreshDio));
  }

  Dio get dio => _dio;
}

final dioServiceProvider = Provider((ref) => DioService(ref.read(authSecureStorageProvider)));
