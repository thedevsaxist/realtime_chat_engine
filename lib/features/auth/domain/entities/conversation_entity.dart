import 'package:realtime_chat_engine/features/home/data/models/conversation_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

class ConversationEntity {
  final String id;
  final DateTime createdAt;
  final List<MessageEntity> messages;

  ConversationEntity({
    required this.id,
    required this.createdAt,
    required this.messages,
  });

  factory ConversationEntity.fromModel(ConversationModel model) =>
      ConversationEntity(
        id: model.id,
        createdAt: model.createdAt,
        messages: model.messages
            .map((e) => MessageEntity.fromModel(e))
            .toList(),
      );

  ConversationModel toModel() => ConversationModel(
    id: id,
    createdAt: createdAt,
    messages: messages.map((e) => e.toModel()).toList(),
  );
}
