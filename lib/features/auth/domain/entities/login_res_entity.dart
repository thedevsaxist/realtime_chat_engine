import 'package:realtime_chat_engine/features/auth/domain/entities/conversation_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/user_entity.dart';
import 'package:realtime_chat_engine/features/auth/data/models/login_res_model.dart';

class LoginResEntity {
  final String token;
  final UserEntity user;
  final List<ConversationEntity> conversations;

  LoginResEntity({required this.token, required this.user, required this.conversations});

  factory LoginResEntity.fromModel(LoginResModel model) {
    return LoginResEntity(
      token: model.token,
      user: UserEntity.fromModel(model.user),
      conversations: model.conversations.map((e) => ConversationEntity.fromModel(e)).toList(),
    );
  }

  LoginResModel toModel() {
    return LoginResModel(token: token, user: user.toModel(), conversations: conversations.map((e) => e.toModel()).toList());
  }
}
