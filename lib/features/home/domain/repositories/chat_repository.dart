import 'package:realtime_chat_engine/features/home/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<GetMessagesResEntity> getMessages(String conversationId);
  Future<void> createMessage(MessageEntity message);
  Future<void> deleteMessages(DeleteMessagesReqEntity req);
  Future<void> clearCache();
}
