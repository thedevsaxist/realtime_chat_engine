import 'package:realtime_chat_engine/features/home/data/models/conversation.dart';

import '../../data/models/login_res_model.dart';

class LoginResEntity {
  final String token;
  final String userId;
  final List<String> conversationIds;

  LoginResEntity({required this.token, required this.userId, required this.conversationIds});

  factory LoginResEntity.fromModel(LoginResModel model) {
    return LoginResEntity(
      token: model.token,
      userId: model.userId,
      conversationIds: model.conversations.map((e) => e.id).toList(),
    );
  }

  LoginResModel toModel() {
    return LoginResModel(
      token: token,
      userId: userId,
      conversations: conversationIds
          .map((e) => Conversation(id: e, createdAt: 0, lastMessage: "", lastMessageTime: 0))
          .toList(),
    );
  }
}
