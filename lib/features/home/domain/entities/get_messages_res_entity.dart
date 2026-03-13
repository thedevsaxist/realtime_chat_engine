import 'package:hive_ce/hive.dart';
import 'package:realtime_chat_engine/features/home/data/models/get_messages_res_model.dart';

part 'get_messages_res_entity.g.dart';

class GetMessagesResEntity {
  final String status;
  final int results;
  final Map<String, List<MessageEntity>> data;

  const GetMessagesResEntity({required this.status, required this.results, required this.data});

  factory GetMessagesResEntity.fromModel(GetMessagesResModel model) {
    return GetMessagesResEntity(
      status: model.status,
      results: model.results,
      data: model.data.map((key, value) => MapEntry(key, value.map((e) => MessageEntity.fromModel(e)).toList())),
    );
  }

  GetMessagesResModel toModel() {
    return GetMessagesResModel(
      status: status,
      results: results,
      data: data.map((key, value) => MapEntry(key, value.map((e) => e.toModel()).toList())),
    );
  }
}

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

  factory MessageEntity.fromModel(Message model) {
    return MessageEntity(
      id: model.id,
      content: model.content,
      senderId: model.senderId,
      conversationId: model.conversationId,
      createdAt: model.createdAt,
    );
  }

  Message toModel() {
    return Message(id: id, content: content, senderId: senderId, conversationId: conversationId, createdAt: createdAt);
  }
}
