import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_client.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_database.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_web_socket.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/repositories/chat_repository.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/conversation_database.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_conversations_res_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/create_conversation_req_entity.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatClient chatClient;
  final ChatDatabase chatRoom;
  final ChatWebSocket chatWebSocket;
  final ConversationDao _conversationDao;

  ChatRepositoryImpl(this.chatClient, this.chatRoom, this.chatWebSocket, this._conversationDao);

  @override
  Future<GetMessagesResEntity> getMessages(String conversationId) async {
    try {
      final cachedMessages = await chatRoom.getMessages(conversationId);

      if (cachedMessages.isEmpty) {
        debugPrint("Cache was empty, calling API\n");

        final response = await chatClient.getMessages(conversationId);
        final messageEntity = GetMessagesResEntity.fromModel(response);

        for (MessageEntity message in messageEntity.messages) {
          chatRoom.addMessage(message);
        }

        return messageEntity;
      }

      debugPrint("Chat gotten from cache\n");
      return GetMessagesResEntity(messages: cachedMessages);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<ConversationEntity> createConversation(CreateConversationReqEntity req) async {
    try {
      final response = await chatClient.createConversation(req.toModel());
      final result = ConversationEntity.fromModel(response);

      await _conversationDao.insertConversation(result.toModel());
      await _conversationDao.linkUserToConversation(req.participantIds[0], result.id);

      return result;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<GetConversationsResEntity> getConversations() async {
    try {
      final response = await chatClient.getConversations();
      final entity = GetConversationsResEntity.fromModel(response);

      final updatedConversations = await Future.wait(
        entity.conversations.map((conv) async {
          final localMessages = await chatRoom.getMessages(conv.id);
          if (localMessages.isEmpty) return conv;

          final apiLatest = conv.messages?.isNotEmpty == true
              ? conv.messages!.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b).createdAt
              : DateTime.fromMillisecondsSinceEpoch(0);

          final localLatest = localMessages
              .reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
              .createdAt;

          if (localLatest.isAfter(apiLatest)) {
            return ConversationEntity(
              id: conv.id,
              createdAt: conv.createdAt,
              participants: conv.participants,
              messages: localMessages,
            );
          }
          return conv;
        }),
      );

      return GetConversationsResEntity(conversations: updatedConversations);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> cacheMessage(MessageEntity message) async {
    try {
      await chatRoom.addMessage(message);
      await _conversationDao.updateLastMessage(
        message.conversationId,
        message.content,
        message.createdAt.millisecondsSinceEpoch,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteMessages(DeleteMessagesReqEntity req) async {
    try {
      chatRoom.deleteMessage(req.conversationId, req.messageId);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await chatRoom.clearCache();
      await _conversationDao.clearAll();
    } catch (e) {
      throw Exception(e);
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    ref.read(chatClientProvider),
    ref.read(chatDatabaseProvider),
    ref.read(chatWebSocketProvider),
    ref.read(conversationDaoProvider),
  );
});
