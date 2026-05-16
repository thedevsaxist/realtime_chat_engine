import 'package:dio/dio.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';
import 'package:realtime_chat_engine/core/shared/app_exception.dart';
import 'package:realtime_chat_engine/features/auth/data/models/login_req_model.dart';
import 'package:realtime_chat_engine/features/auth/data/models/login_res_model.dart';
import 'package:realtime_chat_engine/features/auth/data/models/register_req_model.dart';
import 'package:realtime_chat_engine/features/auth/data/models/register_res_model.dart';

class AuthClient {
  final DioService dioService;

  AuthClient({required this.dioService});

  Future<LoginResModel> login(LoginReqModel reqModel) async {
    final response = await dioService.dio.post("/auth/login", data: reqModel.toJson());
    return LoginResModel.fromJson(response.data);
  }

  Future<Result<RegisterResModel, AppException>> register(RegisterReqModel reqModel) async {
    try {
      final response = await dioService.dio.post("/auth/register", data: reqModel.toJson());
      return Success(RegisterResModel.fromJson(response.data));
    } on DioException catch (e, st) {
      return Error(AppException(
        errorClass: 'AuthClient',
        errorMethod: 'register',
        message: e.response?.statusCode == 409 ? 'user_already_exists' : '$e',
        stackTrace: st,
      ));
    }
  }
}

final authClientProvider = Provider((ref) => AuthClient(dioService: ref.read(dioServiceProvider)));
