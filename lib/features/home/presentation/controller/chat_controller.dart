import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_web_socket.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';
import 'package:realtime_chat_engine/features/home/data/repos/chat_repository_impl.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/repositories/chat_repository.dart';
import 'package:riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/data/models/user_model.dart';

class ChatData {
  final List<MessageEntity> messages;
  final UserModel user;

  ChatData({required this.messages, required this.user});

  factory ChatData.initial() {
    return ChatData(
      messages: [],
      user: UserModel(
        id: '',
        email: '',
        firstName: '',
        lastName: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
  }

  ChatData copyWith({List<MessageEntity>? messages, UserModel? user}) {
    return ChatData(
      messages: messages ?? this.messages,
      user: user ?? this.user,
    );
  }
}

final chatControllerProvider =
    StateNotifierProvider.family<ChatController, ChatData, String>(
      (ref, conversationId) => ChatController(ref, conversationId),
    );

class ChatController extends StateNotifier<ChatData> {
  // final userId = "user-2";
  // final conversationId = Constants.conversationId;
  final Ref ref;
  final String conversationId;
  String? _userId;
  ChatRepository? _chatRepository;
  ChatWebSocket? _chatWebSocket;
  AuthLocalStorage? _authLocalStorage;

  ChatController(this.ref, this.conversationId) : super(ChatData.initial()) {
    _chatRepository = ref.watch(chatRepositoryProvider);
    _chatWebSocket = ref.watch(chatWebSocketProvider);

    _init();
  }

  void _init() async {
    final user = await _authLocalStorage?.getUser();

    if (user == null) {
      debugPrint("UserModel not found");
      return;
    }

    _userId = user.id;

    _chatRepository
        ?.getMessages(conversationId)
        .then((value) {
          final messages = value.data["messages"]!;
          state = state.copyWith(messages: messages, user: user);
          debugPrint(state.messages.length.toString());
        })
        .onError((error, stackTrace) {
          debugPrint(error.toString());
          state = state.copyWith(messages: []);
        });

    _chatWebSocket?.connect(conversationId);
  }

  void sendMessage(String message) {
    try {
      final payload = MessageEntity(
        id: Uuid().v4(),
        content: message,
        senderId: _userId!,
        conversationId: conversationId,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(messages: [...state.messages, payload]);

      _chatRepository?.createMessage(payload);
    } catch (e) {
      debugPrint("Couldn't send message $e");
    }
  }

  void deleteMessage(String messageId) {
    try {
      final request = DeleteMessagesReqEntity(
        conversationId: conversationId,
        messageId: messageId,
      );
      _chatRepository?.deleteMessages(request);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Couldn't delete message $e");
    }
  }
}
