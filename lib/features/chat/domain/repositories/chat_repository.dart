import 'package:realtime_chat_engine/features/chat/domain/entities/create_conversation_req_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_conversations_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<GetConversationsResEntity> getConversations();
  Future<GetMessagesResEntity> getMessages(String conversationId);
  Future<ConversationEntity> createConversation(CreateConversationReqEntity req);

  Future<void> clearCache();
  Future<void> cacheMessage(MessageEntity message);
  Future<void> deleteMessages(DeleteMessagesReqEntity req);
}
