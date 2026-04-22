import '../../data/models/login_res_model.dart';

class LoginResEntity {
  final String token;
  final String userId;
  final List<String> conversationIds;

  LoginResEntity({required this.token, required this.userId, required this.conversationIds});

  factory LoginResEntity.fromModel(LoginResModel model) {
    return LoginResEntity(token: model.token, userId: model.userId, conversationIds: model.conversationIds);
  }

  LoginResModel toModel() {
    return LoginResModel(token: token, userId: userId, conversationIds: conversationIds);
  }
}
