import 'package:realtime_chat_engine/features/chat/data/models/create_conversation_res_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';

class CreateConversationResEntity {
  final String status;
  final ConversationEntity conversation;

  CreateConversationResEntity({required this.status, required this.conversation});

  factory CreateConversationResEntity.fromModel(CreateConversationResModel model) {
    return CreateConversationResEntity(
      status: model.status,
      conversation: ConversationEntity.fromModel(model.conversation),
    );
  }

  CreateConversationResModel toModel() {
    return CreateConversationResModel(status: status, conversation: conversation.toModel());
  }
}
