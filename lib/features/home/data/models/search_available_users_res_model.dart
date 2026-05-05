import 'package:realtime_chat_engine/features/auth/data/models/user_model.dart';

class SearchAvailableUsersResModel {
  final List<UserModel> users;

  SearchAvailableUsersResModel({required this.users});

  factory SearchAvailableUsersResModel.fromJson(Map<String, dynamic> json) {
    return SearchAvailableUsersResModel(
      users: (json["users"] as List<dynamic>)
          .map((user) => UserModel.fromJson(Map<String, dynamic>.from(user as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {"users": users.map((user) => user.toJson()).toList()};
}
