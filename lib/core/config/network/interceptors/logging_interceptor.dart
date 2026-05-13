import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);

    debugPrint("REQUEST:\n${options.method} ${options.baseUrl}${options.path}");
    
    if (options.headers.isNotEmpty){
      debugPrint("Headers:\n${options.headers}");
    }

    if (options.data != null){
      debugPrint("Data:\n${options.data}");
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);

    debugPrint("\nRESPONSE:\n${response.statusCode} ${response.data}");
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);

    debugPrint("\nERROR:\n${err.response?.statusCode} ${err.message}");
  }
}
