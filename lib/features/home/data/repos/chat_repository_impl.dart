import 'package:flutter/widgets.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_client.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_room.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/create_message_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/create_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/repositories/chat_repository.dart';
import 'package:riverpod/riverpod.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatClient chatClient;
  final ChatRoom chatRoom;

  ChatRepositoryImpl(this.chatClient, this.chatRoom);

  @override
  Future<GetMessagesResEntity> getMessages(String conversationId) async {
    try {
      final cachedMessages = await chatRoom.getMessages(conversationId);

      if (cachedMessages == null /*|| cachedMessages.isEmpty*/ ) {
        debugPrint("Cache was empty, calling API\n");

        final response = await chatClient.getMessages(conversationId);
        final messageEntity = GetMessagesResEntity.fromModel(response);

        for (var message in messageEntity.data["messages"] as List) {
          chatRoom.addMessage(message);
        }

        return messageEntity;
      }

      debugPrint("Chat gotten from cache\n");
      return GetMessagesResEntity(
        status: "success",
        results: cachedMessages.messages.length,
        data: {"messages": cachedMessages.messages},
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

  @override
  Future<CreateMessageResEntity> createMessage(CreateMessageReqEntity req) async {
    try {
      final response = await chatClient.createMessage(req.toModel());
      final entity = CreateMessageResEntity.fromModel(response);

      final data = entity.data;
      chatRoom.addMessage(data);

      return entity;
    } catch (e) {
      throw Exception(e);
    }
  }
}

final chatRepositoryProvider = Provider(
  (ref) => ChatRepositoryImpl(ref.read(chatClientProvider), ref.read(chatRoomProvider)),
);
