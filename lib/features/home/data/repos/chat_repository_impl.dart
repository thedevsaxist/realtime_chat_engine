import 'package:flutter/widgets.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_client.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_database.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_web_socket.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/repositories/chat_repository.dart';
import 'package:riverpod/riverpod.dart';

import '../../domain/entities/create_message_req_entity.dart';
import '../../domain/entities/message_entity.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatClient chatClient;
  final ChatDatabase chatRoom;
  // final ChatRoom chatRoom;
  final ChatWebSocket chatWebSocket;

  ChatRepositoryImpl(this.chatClient, this.chatRoom, this.chatWebSocket);

  @override
  Future<GetMessagesResEntity> getMessages(String conversationId) async {
    try {
      final cachedMessages = await chatRoom.getMessages(conversationId);

      if (cachedMessages.isEmpty) {
        debugPrint("Cache was empty, calling API\n");

        final response = await chatClient.getMessages(conversationId);
        final messageEntity = GetMessagesResEntity.fromModel(response);

        for (MessageEntity message in messageEntity.data["messages"]?.cast<MessageEntity>() ?? []) {
          chatRoom.addMessage(message);
        }

        return messageEntity;
      }

      debugPrint("Chat gotten from cache\n");
      return GetMessagesResEntity(
        status: "success",
        results: cachedMessages.length,
        data: {"messages": cachedMessages},
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> deleteMessages(DeleteMessagesReqEntity req) async {
    try {
      chatRoom.deleteMessage(req.conversationId, req.messageId);
      // await chatClient.deleteMessage(req.toModel());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> clearCache() async {
    try {
      chatRoom.clearCache();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> createMessage(MessageEntity message) async {
    try {
      chatRoom.addMessage(message); // save message to local storage

      final req = CreateMessageReqEntity(
        content: message.content,
        conversationId: message.conversationId,
        senderId: message.senderId,
      ).toModel();

      chatWebSocket.sendMessage(req); // upload message via websocket
    } catch (e) {
      throw Exception(e);
    }
  }
}

final chatRepositoryProvider = Provider((ref) {
  return ChatRepositoryImpl(
    ref.read(chatClientProvider),
    ref.read(chatDatabaseProvider),
    ref.read(chatWebSocketProvider),
  );
});
