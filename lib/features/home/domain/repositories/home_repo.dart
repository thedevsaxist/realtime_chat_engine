import '../entities/search_available_users_req_entity.dart';
import '../entities/search_available_users_res_entity.dart';

abstract class HomeRepo {
  Future<SearchAvailableUsersResEntity> searchAvailableUsers(SearchAvailableUsersReqEntity req);
}
