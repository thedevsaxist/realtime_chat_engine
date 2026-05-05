import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/home_client.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/search_available_users_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/search_available_users_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/repositories/home_repo.dart';

class HomeRepositoryImpl extends HomeRepo {
  final HomeClient _homeClient;

  HomeRepositoryImpl(this._homeClient);

  @override
  Future<SearchAvailableUsersResEntity> searchAvailableUsers(
    SearchAvailableUsersReqEntity req,
  ) async {
    try {
      final response = await _homeClient.searchAvailableUsers(req.toModel());
      return SearchAvailableUsersResEntity.fromModel(response);
    } catch (e, st) {
      throw Exception("[HomeRepositoryImpl.searchAvailableUsers] -> ${e.toString()} \n $st");
    }
  }
}

final homeRepositoryProvider = Provider<HomeRepo>((ref) => HomeRepositoryImpl(ref.read(homeClientProvider)));
