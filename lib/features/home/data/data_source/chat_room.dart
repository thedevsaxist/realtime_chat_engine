import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/config/network/hive_service.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';

final chatRoomProvider = Provider<ChatRoom>((ref) => ChatRoom());

class ChatRoom {
  /*
    This essentially stores the data in this structure:
    Map<conversationId, Map<message.id, message>>
  */
  // static final _chatRoomBox = Hive.lazyBox<Map<String, MessageEntity>>(Constants.chatRoomBox);
  static final _chatRoomBox = HiveService.chatBox.isOpen ? HiveService.chatBox : null;

  void addMessage(MessageEntity message) async {
    try {
      // debugPrint("Adding meessage to history");
      await _chatRoomBox?.put(message.id, message);

      // debugPrint("Message added to history");
      // debugPrint("Current state of local storage ${_chatRoomBox?.keys.toList()}");
    } catch (e) {
      debugPrint("Unable to add mesage to chat history$e");
    }
  }

  Future<MessageEntity?> getMessages(String messageId) async {
    // debugPrint("getMessages was called");
    MessageEntity? conversation;
    try {
      conversation = await _chatRoomBox?.get(messageId);

      if (conversation !=
          null /*&& conversation.isNotEmpty
      */ ) {
        debugPrint("Retrieval successful, here's some sample data");
        debugPrint(conversation.content);
      }

      // return conversation;
    } catch (e) {
      debugPrint("Unable to retrieve cached messages\n$e");
    }

    return conversation;
  }

  void deleteMessage(String messageId) {
    _chatRoomBox?.delete(messageId);
  }
}
