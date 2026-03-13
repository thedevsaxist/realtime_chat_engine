import 'package:flutter/widgets.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_client.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_room.dart';
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
      final cachedMessages = await chatRoom.getMessages("c507b58e-6255-41fe-90d5-4dd5033298ea");

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
        results: /*cachedMessages.length*/ 2,
        data: {
          "messages": [cachedMessages],
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }
}

final chatRepositoryProvider = Provider(
  (ref) => ChatRepositoryImpl(ref.read(chatClientProvider), ref.read(chatRoomProvider)),
);
