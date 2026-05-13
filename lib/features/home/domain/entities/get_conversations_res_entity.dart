import 'package:realtime_chat_engine/features/home/data/models/get_conversations_res_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';

class GetConversationsResEntity {
  final String status;
  final List<ConversationEntity> conversations;

  GetConversationsResEntity({required this.status, required this.conversations});

  factory GetConversationsResEntity.fromModel(GetConversationsResModel model) {
    return GetConversationsResEntity(
      status: model.status,
      conversations: model.conversations.map(ConversationEntity.fromModel).toList(),
    );
  }
}
