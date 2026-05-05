import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';

import '../models/search_available_users_req_model.dart';
import '../models/search_available_users_res_model.dart';

class HomeClient {
  final DioService _dioService;

  HomeClient(this._dioService);

  Future<SearchAvailableUsersResModel> searchAvailableUsers(
    SearchAvailableUsersReqModel req,
  ) async {
    try {
      final response = await _dioService.dio.get("/users", data: req.toJson());
      return SearchAvailableUsersResModel.fromJson(response.data);
    } catch (e, st) {
      throw Exception("[HomeClient.searchAvailableUsers] -> ${e.toString()} \n $st");
    }
  }
}

final homeClientProvider = Provider((ref) => HomeClient(ref.read(dioServiceProvider)));
