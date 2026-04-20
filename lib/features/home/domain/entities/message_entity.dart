import 'package:hive_ce/hive.dart';
import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';

part 'message_entity.g.dart';

@HiveType(typeId: 0)
class MessageEntity extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String content;

  @HiveField(2)
  late String senderId;

  @HiveField(3)
  late String conversationId;

  @HiveField(4)
  late String createdAt;

  MessageEntity.empty();

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
