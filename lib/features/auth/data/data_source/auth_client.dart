import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';
import 'package:realtime_chat_engine/features/auth/data/models/register_req_model.dart';
import 'package:realtime_chat_engine/features/auth/data/models/register_res_model.dart';

import '../models/login_req_model.dart';
import '../models/login_res_model.dart';

class AuthClient {
  final DioService dioService;


  AuthClient({required this.dioService});

  Future<LoginResModel> login(LoginReqModel reqModel) async {
    try {
      final response = await dioService.dio.post("/auth/login", data: reqModel.toJson());
      return LoginResModel.fromJson(response.data);
    } catch (e, st) {
      throw Exception("[AuthClient.login] -> ${e.toString()} \n $st");
    }
  }


  Future<RegisterResModel> register(RegisterReqModel reqModel) async {
    try {
      final response = await dioService.dio.post("/auth/register", data: reqModel.toJson());
      return RegisterResModel.fromJson(response.data);
    } catch (e, st) {
      throw Exception("[AuthClient.register] -> ${e.toString()} \n $st");
    }
  }
}

final authClientProvider = Provider((ref) => AuthClient(dioService: ref.read(dioServiceProvider)));
