import 'package:hive_ce/hive.dart';
import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';

class MessageEntity extends HiveObject {
  late String id;
  late String content;
  late String senderId;
  late String conversationId;
  late String createdAt;

  MessageEntity({
    required this.id,
    required this.content,
    required this.senderId,
    required this.conversationId,
    required this.createdAt,
  });

  factory MessageEntity.fromModel(MessageModel model) {
    return MessageEntity(
      id: model.id,
      content: model.content,
      senderId: model.senderId,
      conversationId: model.conversationId,
      createdAt: model.createdAt,
    );
  }

  MessageModel toModel() {
    return MessageModel(
      id: id,
      content: content,
      senderId: senderId,
      conversationId: conversationId,
      createdAt: createdAt,
    );
  }
}
