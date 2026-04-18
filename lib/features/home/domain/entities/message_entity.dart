import 'package:hive_ce/hive.dart';
import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';

part 'message_entity.g.dart';

@HiveType(typeId: 0)
class MessageEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String conversationId;

  @HiveField(4)
  final String createdAt;

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
