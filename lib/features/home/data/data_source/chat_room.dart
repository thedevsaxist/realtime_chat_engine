import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:realtime_chat_engine/core/config/network/hive_service.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

final chatRoomProvider = Provider<ChatRoom>((ref) => ChatRoom());

class ChatRoom {
  /*
    This essentially stores the data in this structure:
    Map<conversationId, List<messages>>
  */
  static Box get _chatRoomBox => HiveService.chatBox;

  Future<void> addMessage(MessageEntity message) async {
    try {
      debugPrint('box name: ${Constants.chatRoomBox}');
      debugPrint('box is open: ${_chatRoomBox.isOpen}');
      debugPrint('box path: ${_chatRoomBox.path}');

      final result = await _chatRoomBox.get(message.conversationId);
      final conversation = result != null ? List<MessageEntity>.from(result as List) : <MessageEntity>[];
      
      conversation.add(message);

      // debugPrint(conversation.length.toString());

      await _chatRoomBox.put(message.conversationId, conversation);

      final verify = await _chatRoomBox.get(message.conversationId);

      debugPrint('verify after put: $verify, length: ${(verify as List?)?.length}');
    } catch (e) {
      debugPrint("Unable to add mesage to chat history $e");
    }
  }

  Future<List<MessageEntity>> getMessages(String conversationId) async {
    try {
      final conversation = await _chatRoomBox.get(conversationId);
      if (conversation != null) {
        return List<MessageEntity>.from(conversation as List);
      }
    } catch (e) {
      debugPrint("Unable to retrieve cached messages\n$e");
    }

    return [];
  }

  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      final result = await _chatRoomBox.get(conversationId);
      if (result != null) {
        final targetConversation = List<MessageEntity>.from(result as List);
        targetConversation.removeWhere((m) => m.id == messageId);
        await _chatRoomBox.put(conversationId, targetConversation);
      }
    } catch (e) {
      debugPrint("Unable to delete message\n$e");
    }
  }

  Future<void> clearCache() async {
    try {
      await _chatRoomBox.clear();
      debugPrint("All messages deleted");
    } catch (e) {
      debugPrint("Unable to clear cache\n$e");
    }
  }
}
