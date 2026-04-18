import 'package:realtime_chat_engine/features/home/domain/entities/create_message_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/create_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';

abstract class ChatRepository {
  Future<GetMessagesResEntity> getMessages(String conversationId);
  Future<CreateMessageResEntity> createMessage(CreateMessageReqEntity req);
  Future<void> deleteMessages(DeleteMessagesReqEntity req);
}
