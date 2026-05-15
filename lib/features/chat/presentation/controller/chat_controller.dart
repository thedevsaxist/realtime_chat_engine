import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/shared/message_bus.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';
import 'package:realtime_chat_engine/features/chat/data/repo/chat_repository_impl.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/repositories/chat_repository.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_web_socket.dart';
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
    return ChatData(messages: messages ?? this.messages, user: user ?? this.user);
  }
}

final chatControllerProvider = StateNotifierProvider.family<ChatController, ChatData, String>(
  (ref, conversationId) => ChatController(ref, conversationId),
);

class ChatController extends StateNotifier<ChatData> {
  final Ref ref;
  final String conversationId;
  String? _userId;
  ChatRepository? _chatRepository;
  ChatWebSocket? _chatWebSocket;
  AuthLocalStorage? _authLocalStorage;

  ChatController(this.ref, this.conversationId) : super(ChatData.initial()) {
    _chatWebSocket = ref.read(chatWebSocketProvider);
    _chatRepository = ref.read(chatRepositoryProvider);
    _authLocalStorage = ref.read(authLocalStorageProvider);

    ref.listen(incomingMessageProvider, (_, next) {
      next.whenData(_handleIncoming);
    });

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
          state = state.copyWith(messages: value.messages, user: user);
          debugPrint(state.messages.length.toString());
        })
        .onError((error, stackTrace) {
          debugPrint(error.toString());
          state = state.copyWith(messages: [], user: user);
        });
  }

  void _handleIncoming(MessageEntity incoming) {
    if (incoming.conversationId != conversationId) return;
    final optimisticIndex = state.messages.indexWhere(
      (m) =>
          m.id != incoming.id && m.senderId == incoming.senderId && m.content == incoming.content,
    );
    if (optimisticIndex != -1) {
      final updated = [...state.messages];
      updated[optimisticIndex] = incoming;
      _chatRepository?.cacheMessage(incoming);
      state = state.copyWith(messages: updated);
    } else if (!state.messages.any((m) => m.id == incoming.id)) {
      _chatRepository?.cacheMessage(incoming);
      state = state.copyWith(messages: [...state.messages, incoming]);
    }
  }

  void sendMessage(String message) {
    try {
      final tempId = Uuid().v4();
      final payload = MessageEntity(
        id: tempId,
        content: message,
        senderId: _userId!,
        conversationId: conversationId,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(messages: [...state.messages, payload]);

      _chatWebSocket?.sendMessage(
        conversationId: conversationId,
        senderId: _userId!,
        content: message,
      );
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
