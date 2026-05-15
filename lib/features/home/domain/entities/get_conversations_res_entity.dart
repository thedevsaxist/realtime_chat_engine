import 'package:realtime_chat_engine/features/home/data/models/get_conversations_res_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';

class GetConversationsResEntity {
  final List<ConversationEntity> conversations;

  GetConversationsResEntity({required this.conversations});

  factory GetConversationsResEntity.fromModel(GetConversationsResModel model) {
    return GetConversationsResEntity(
      conversations: model.conversations.map(ConversationEntity.fromModel).toList(),
    );
  }
}
