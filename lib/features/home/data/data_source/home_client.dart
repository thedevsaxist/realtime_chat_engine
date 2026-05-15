import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';

import '../models/search_available_users_res_model.dart';

class HomeClient {
  final DioService _dioService;

  HomeClient(this._dioService);

  Future<SearchAvailableUsersResModel> searchAvailableUsers() async {
    try {
      final response = await _dioService.dio.get("/search-users");
      return SearchAvailableUsersResModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return SearchAvailableUsersResModel(users: []);
      throw Exception("[HomeClient.searchAvailableUsers] -> ${e.toString()}");
    } catch (e, st) {
      throw Exception("[HomeClient.searchAvailableUsers] -> ${e.toString()} \n $st");
    }
  }
}

final homeClientProvider = Provider((ref) => HomeClient(ref.read(dioServiceProvider)));
