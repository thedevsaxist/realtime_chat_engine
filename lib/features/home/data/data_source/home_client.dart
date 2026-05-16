import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/shared/app_exception.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';
import 'package:realtime_chat_engine/features/home/data/models/search_available_users_res_model.dart';

class HomeClient {
  final DioService _dioService;

  HomeClient(this._dioService);

  Future<SearchAvailableUsersResModel> searchAvailableUsers() async {
    try {
      final response = await _dioService.dio.get("/search-users");

      return SearchAvailableUsersResModel.fromJson(response.data);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 404) return SearchAvailableUsersResModel(users: []);

      throw AppException(
        errorClass: 'HomeClient',
        errorMethod: 'searchAvailableUsers',
        message: e.toString(),
        stackTrace: st,
      );
    } catch (e, st) {
      throw AppException(
        errorClass: 'HomeClient',
        errorMethod: 'searchAvailableUsers',
        message: e.toString(),
        stackTrace: st,
      );
    }
  }
}

final homeClientProvider = Provider((ref) => HomeClient(ref.read(dioServiceProvider)));
