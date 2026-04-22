import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_web_socket.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';
import 'package:realtime_chat_engine/features/home/data/repos/chat_repository_impl.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/repositories/chat_repository.dart';
import 'package:riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

final chatControllerProvider = StateNotifierProvider((ref) => ChatController(ref));

class ChatController extends StateNotifier<List<MessageEntity>> {
  final userId = "user-2";
  final conversationId = Constants.conversationId;
  final Ref ref;
  ChatRepository? _chatRepository;
  ChatWebSocket? _chatWebSocket;

  ChatController(this.ref) : super([]) {
    _chatRepository = ref.watch(chatRepositoryProvider);
    _chatWebSocket = ref.watch(chatWebSocketProvider);

    _init();
  }

  void _init() {
    _chatRepository
        ?.getMessages(conversationId)
        .then((value) {
          state = value.data["messages"]!;
          debugPrint(state.length.toString());
        })
        .onError((error, stackTrace) {
          debugPrint(error.toString());
          state = [];
        });

    _chatWebSocket?.connect(conversationId);
  }

  void sendMessage(String message) {
    try {
      final payload = MessageEntity(
        id: Uuid().v4(),
        content: message,
        senderId: userId,
        conversationId: conversationId,
        createdAt: DateTime.now().toIso8601String(),
      );

      state = [...state, payload];

      _chatRepository?.createMessage(payload);
    } catch (e) {
      debugPrint("Couldn't send message $e");
    }
  }

  void deleteMessage(String messageId) {
    try {
      final request = DeleteMessagesReqEntity(conversationId: conversationId, messageId: messageId);
      _chatRepository?.deleteMessages(request);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Couldn't delete message $e");
    }
  }
}
