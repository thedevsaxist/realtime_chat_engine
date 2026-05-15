import 'package:realtime_chat_engine/features/home/data/models/get_messages_res_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

class GetMessagesResEntity {
  final List<MessageEntity> messages;

  const GetMessagesResEntity({required this.messages});

  factory GetMessagesResEntity.fromModel(GetMessagesResModel model) {
    return GetMessagesResEntity(
      messages: model.messages.map(MessageEntity.fromModel).toList(),
    );
  }
}
