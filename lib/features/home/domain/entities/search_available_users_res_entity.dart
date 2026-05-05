import 'package:realtime_chat_engine/features/auth/domain/entities/user_entity.dart';
import 'package:realtime_chat_engine/features/home/data/models/search_available_users_res_model.dart';

class SearchAvailableUsersResEntity {
  final List<UserEntity> users;

  SearchAvailableUsersResEntity({required this.users});

  factory SearchAvailableUsersResEntity.fromModel(SearchAvailableUsersResModel model) {
    return SearchAvailableUsersResEntity(
      users: model.users.map((users) => UserEntity.fromModel(users)).toList(),
    );
  }

  SearchAvailableUsersResModel toModel() =>
      SearchAvailableUsersResModel(users: users.map((user) => user.toModel()).toList());
}
