import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';

class MessageEntity {
  final String id;
  final String? tempId;
  final String content;
  final String senderId;
  final String conversationId;
  final DateTime createdAt;

  MessageEntity({
    required this.id,
    this.tempId,
    required this.content,
    required this.senderId,
    required this.conversationId,
    required this.createdAt,
  });

  factory MessageEntity.fromModel(MessageModel model) {
    return MessageEntity(
      id: model.id,
      tempId: model.tempId,
      content: model.content,
      senderId: model.senderId,
      conversationId: model.conversationId,
      createdAt: model.createdAt,
    );
  }

  MessageModel toModel() {
    return MessageModel(
      id: id,
      tempId: tempId,
      content: content,
      senderId: senderId,
      conversationId: conversationId,
      createdAt: createdAt,
    );
  }
}
