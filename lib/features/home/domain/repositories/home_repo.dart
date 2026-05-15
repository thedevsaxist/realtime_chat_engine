import '../entities/search_available_users_res_entity.dart';

abstract class HomeRepo {
  Future<SearchAvailableUsersResEntity> searchAvailableUsers();
}
