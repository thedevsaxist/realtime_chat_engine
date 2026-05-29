import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/shared/message_bus.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/read_receipt_entity.dart';
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

final chatControllerProvider = StateNotifierProvider.family
    .autoDispose<ChatController, ChatData, String>(
      (ref, conversationId) => ChatController(ref, conversationId),
    );

// unread count — family so each conversation has its own count
final unreadCountProvider = FutureProvider.family.autoDispose<int, String>((ref, conversationId) {
  final unreadCount = ref
      .read(chatRepositoryProvider)
      .getUnreadCount(conversationId: conversationId);

  debugPrint(unreadCount.toString());
  return unreadCount;
});

class ChatController extends StateNotifier<ChatData> {
  final Ref ref;
  final String conversationId;
  String? _userId;
  String? _lastMarkedMessageId;
  static const _uuid = Uuid();
  late final ChatRepository _chatRepository;
  late final ChatWebSocket _chatWebSocket;
  late final AuthLocalStorage _authLocalStorage;

  ChatController(this.ref, this.conversationId) : super(ChatData.initial()) {
    _chatWebSocket = ref.read(chatWebSocketProvider);
    _chatRepository = ref.read(chatRepositoryProvider);
    _authLocalStorage = ref.read(authLocalStorageProvider);

    ref.listen(incomingMessageProvider, (_, next) {
      next.whenData(_handleIncoming);
    });

    ref.listen(incomingReadReceiptProvider, (_, next) {
      next.whenData(_handleReadReceipt);
    });

    _init();
  }

  void _init() async {
    final user = await _authLocalStorage.getUser();

    if (user == null) {
      debugPrint("UserModel not found");
      return;
    }

    _userId = user.id;
    if (_userId == null) {
      debugPrint("User id was null");
      return;
    }

    _chatRepository
        .getMessages(conversationId)
        .then((value) {
          state = state.copyWith(messages: value.messages, user: user);
          markLatestAsRead();
        })
        .onError((error, stackTrace) {
          debugPrint(error.toString());
          state = state.copyWith(messages: [], user: user);
        });
  }

  /// Latest message with a server-persisted id (skips unacked optimistic sends).
  String? get latestPersistedMessageId {
    MessageEntity? latest;
    for (final message in state.messages) {
      if (_isPendingMessage(message)) continue;
      if (latest == null || message.createdAt.isAfter(latest.createdAt)) {
        latest = message;
      }
    }
    return latest?.id;
  }

  bool _isPendingMessage(MessageEntity message) {
    return state.messages.any((other) => other.tempId == message.id);
  }

  void _handleIncoming(MessageEntity incoming) {
    if (incoming.conversationId != conversationId) return;

    final optimisticIndex = state.messages.indexWhere((m) => m.id == incoming.tempId);

    if (optimisticIndex != -1) {
      final updated = [...state.messages];
      updated[optimisticIndex] = incoming;

      _chatRepository.cacheMessage(incoming);
      state = state.copyWith(messages: updated);
    } else if (!state.messages.any((m) => m.id == incoming.id)) {
      _chatRepository.cacheMessage(incoming);
      state = state.copyWith(messages: [...state.messages, incoming]);
    }
  }

  void _handleReadReceipt(ReadReceiptEntity receipt) {
    // ignore receipts for other conversations
    if (receipt.conversationId != conversationId) return;

    // mark all messages up to lastMessageId as read
    final updated = state.messages.map((m) {
      final isRead =
          m.createdAt.isBefore(
            state.messages
                .firstWhere((msg) => msg.id == receipt.lastMessageId, orElse: () => m)
                .createdAt,
          ) ||
          m.id == receipt.lastMessageId;

      return m.copyWith(isRead: isRead);
    }).toList();

    state = state.copyWith(messages: updated);
  }

  void sendMessage(String message) {
    try {
      final tempId = _uuid.v4();
      final payload = MessageEntity(
        id: tempId,
        content: message,
        senderId: _userId!,
        conversationId: conversationId,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(messages: [...state.messages, payload]);

      _chatWebSocket.sendMessage(
        conversationId: conversationId,
        senderId: _userId!,
        content: message,
        tempId: tempId,
      );
    } catch (e) {
      debugPrint("Couldn't send message $e");
    }
  }

  Future<void> markLatestAsRead() async {
    final lastMessageId = latestPersistedMessageId;
    if (lastMessageId == null || lastMessageId == _lastMarkedMessageId) return;

    try {
      final result = await _chatRepository.markAsRead(
        conversationId: conversationId,
        lastMessageId: lastMessageId,
      );

      if (result.success) {
        _lastMarkedMessageId = lastMessageId;
        ref.invalidate(unreadCountProvider(conversationId));
      }
    } catch (e, st) {
      debugPrint('markLatestAsRead failed: $e\n$st');
    }
  }

  void deleteMessage(String messageId) {
    try {
      final request = DeleteMessagesReqEntity(conversationId: conversationId, messageId: messageId);
      _chatRepository.deleteMessages(request);
      state = state.copyWith(messages: state.messages.where((m) => m.id != messageId).toList());
    } catch (e) {
      debugPrint("Couldn't delete message $e");
    }
  }
}
