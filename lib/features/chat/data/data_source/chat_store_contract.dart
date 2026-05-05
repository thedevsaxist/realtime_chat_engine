import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

abstract class ChatStoreContract {
  Future<void> addMessage(MessageEntity message);
  Future<List<MessageEntity>> getMessages(String conversationId);
  Future<void> deleteMessage(String conversationId, String messageId);
  Future<void> clearCache();
}
