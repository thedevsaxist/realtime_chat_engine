import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:realtime_chat_engine/core/config/network/hive_service.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';

part 'chat_room.g.dart';

final chatRoomProvider = Provider<ChatRoom>((ref) => ChatRoom());

@HiveType(typeId: 1)
class ChatRoomModel {
  @HiveField(0)
  final String conversationId;

  @HiveField(1)
  final List<MessageEntity> messages;

  ChatRoomModel({required this.conversationId, required this.messages});
}

class ChatRoom {
  /*
    This essentially stores the data in this structure:
    Map<conversationId, List<messages>>
  */
  static final _chatRoomBox = HiveService.chatBox.isOpen ? HiveService.chatBox : null;

  void addMessage(MessageEntity message) async {
    try {
      // debugPrint("Adding meessage to history");
      await _chatRoomBox?.put(
        message.conversationId,
        ChatRoomModel(conversationId: message.conversationId, messages: [message]),
      );

      // debugPrint("Message added to history");
      // debugPrint("Current state of local storage ${_chatRoomBox?.keys.toList()}");
    } catch (e) {
      debugPrint("Unable to add mesage to chat history$e");
    }
  }

  Future<ChatRoomModel?> getMessages(String conversationId) async {
    // debugPrint("getMessages was called");
    ChatRoomModel? conversation;
    try {
      conversation = await _chatRoomBox?.get(conversationId);

      if (conversation != null && conversation.messages.isNotEmpty) {
        debugPrint("Retrieval successful, here's some sample data");
      }
    } catch (e) {
      debugPrint("Unable to retrieve cached messages\n$e");
    }

    return conversation;
  }

  void deleteMessage(String conversationId, String messageId) async {
    final targetConversation = await _chatRoomBox?.get(conversationId);
    final target = targetConversation?.messages.indexWhere((m) => m.id == messageId);

    if (target != -1 && target != null) {
      targetConversation?.messages.removeAt(target);
    }
  }
}
