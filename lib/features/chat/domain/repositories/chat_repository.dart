import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/mark_as_read_res_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_conversations_res_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/create_conversation_req_entity.dart';

abstract class ChatRepository {
  Future<MarkAsReadResEntity> markAsRead({
    required String conversationId,
    required String lastMessageId,
    // required String lastReadAt,
  });

  Future<int> getUnreadCount({required String conversationId, required String userId});
  Future<GetMessagesResEntity> getMessages(String conversationId, {required String userId});

  Future<List<MessageEntity>> applyReadState({
    required List<MessageEntity> messages,
    required String conversationId,
    required String userId,
  });

  Future<String?> getLastReadByMe(String conversationId);

  Future<bool> isMessageAtOrAfter({
    required String conversationId,
    required String messageId,
    required String referenceMessageId,
  });

  Future<void> saveLocalReadPosition({
    required String conversationId,
    required String lastMessageId,
    required int lastReadAt,
  });

  Future<void> savePeerReadReceipt({
    required String conversationId,
    required String lastMessageId,
    required int lastReadAt,
  });

  Future<void> syncPeerReadFromServer({required String conversationId});
  Future<GetConversationsResEntity> getConversations(String userId);
  Future<ConversationEntity> createConversation(CreateConversationReqEntity req);

  Future<void> clearCache();
  Future<void> cacheMessage(MessageEntity message);
  Future<void> deleteMessages(DeleteMessagesReqEntity req);
}
