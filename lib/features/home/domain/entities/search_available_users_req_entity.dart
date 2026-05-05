import 'package:realtime_chat_engine/features/home/data/models/search_available_users_req_model.dart';

class SearchAvailableUsersReqEntity {
  final String userId;

  SearchAvailableUsersReqEntity({required this.userId});

  factory SearchAvailableUsersReqEntity.fromModel(SearchAvailableUsersReqModel model) {
    return SearchAvailableUsersReqEntity(userId: model.userId);
  }

  SearchAvailableUsersReqModel toModel() => SearchAvailableUsersReqModel(userId: userId);
}
