import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';

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
}

final authClientProvider = Provider((ref) => AuthClient(dioService: ref.read(dioServiceProvider)));
