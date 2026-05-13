import 'package:realtime_chat_engine/features/chat/domain/entities/create_conversation_req_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/create_conversation_res_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_conversations_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<GetMessagesResEntity> getMessages(String conversationId);
  Future<void> createMessage(MessageEntity message);
  Future<void> deleteMessages(DeleteMessagesReqEntity req);
  Future<void> clearCache();

  Future<CreateConversationResEntity> createConversation({
    required CreateConversationReqEntity req,
    required String userId,
  });

  Future<GetConversationsResEntity> getConversations(String userId);
}
