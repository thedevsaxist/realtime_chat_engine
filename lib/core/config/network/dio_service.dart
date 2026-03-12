import 'package:dio/dio.dart';
import 'package:realtime_chat_engine/core/config/network/interceptiors/logging_interceptor.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:riverpod/riverpod.dart';

class DioService {
  final Dio _dio;

  DioService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: Constants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    _dio.interceptors.add(LoggingInterceptor());
  }

  Dio get dio => _dio;
}

final dioServiceProvider = Provider((ref) => DioService());
