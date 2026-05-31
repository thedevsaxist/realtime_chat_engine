import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';
import 'package:realtime_chat_engine/core/shared/app_exception.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_client.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_database.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_web_socket.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/repositories/chat_repository.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/conversation_database.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/mark_as_read_res_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/delete_messages_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_conversations_res_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/create_conversation_req_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/read_state_utils.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatClient chatClient;
  final ChatDatabase chatRoom;
  final ChatWebSocket chatWebSocket;
  final ConversationDao _conversationDao;

  ChatRepositoryImpl(this.chatClient, this.chatRoom, this.chatWebSocket, this._conversationDao);

  @override
  Future<GetMessagesResEntity> getMessages(String conversationId, {required String userId}) async {
    try {
      try {
        await syncPeerReadFromServer(conversationId: conversationId);
      } catch (e) {
        debugPrint('syncPeerReadFromServer failed (using local): $e');
      }

      final cachedMessages = await chatRoom.getMessages(conversationId);

      if (cachedMessages.isEmpty) {
        debugPrint("Cache was empty, calling API\n");

        final response = await chatClient.getMessages(conversationId);
        final messageEntity = GetMessagesResEntity.fromModel(response);

        for (MessageEntity message in messageEntity.messages) {
          chatRoom.addMessage(message);
        }

        final withReadState = await applyReadState(
          messages: messageEntity.messages,
          conversationId: conversationId,
          userId: userId,
        );
        return GetMessagesResEntity(messages: withReadState);
      }

      debugPrint("Chat gotten from cache\n");
      final withReadState = await applyReadState(
        messages: cachedMessages,
        conversationId: conversationId,
        userId: userId,
      );
      return GetMessagesResEntity(messages: withReadState);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<MessageEntity>> applyReadState({
    required List<MessageEntity> messages,
    required String conversationId,
    required String userId,
  }) async {
    final readState = await _conversationDao.getReadState(conversationId);
    final peerReadId = readState.lastReadByPeer;
    if (peerReadId == null) return messages;

    final peerReadAt =
        readState.peerReadAt ??
        messages.where((m) => m.id == peerReadId).firstOrNull?.createdAt ??
        await _conversationDao.getMessageCreatedAt(conversationId, peerReadId);

    return applyPeerReadToMessages(
      messages: messages,
      lastReadByPeerMessageId: peerReadId,
      currentUserId: userId,
      peerReadAt: peerReadAt,
    );
  }

  @override
  Future<void> syncPeerReadFromServer({required String conversationId}) async {
    try {
      final peerRead = await chatClient.getPeerReadPosition(conversationId);
      if (peerRead == null) return;

      await savePeerReadReceipt(
        conversationId: conversationId,
        lastMessageId: peerRead.lastReadMessageId,
        lastReadAt: peerRead.lastReadAt.millisecondsSinceEpoch,
      );
    } catch (e, st) {
      throw AppException(
        errorClass: 'ChatRepositoryImpl',
        errorMethod: 'syncPeerReadFromServer',
        message: e.toString(),
        stackTrace: st,
      );
    }
  }

  @override
  Future<String?> getLastReadByMe(String conversationId) async {
    final readState = await _conversationDao.getReadState(conversationId);
    return readState.lastReadByMe;
  }

  @override
  Future<bool> isMessageAtOrAfter({
    required String conversationId,
    required String messageId,
    required String referenceMessageId,
  }) async {
    return _conversationDao.isMessageAtOrAfter(conversationId, messageId, referenceMessageId);
  }

  @override
  Future<void> saveLocalReadPosition({
    required String conversationId,
    required String lastMessageId,
    required int lastReadAt,
  }) async {
    await _conversationDao.setLastReadByMe(conversationId, lastMessageId, lastReadAt);
  }

  @override
  Future<void> savePeerReadReceipt({
    required String conversationId,
    required String lastMessageId,
    required int lastReadAt,
  }) async {
    await _conversationDao.setLastReadByPeer(conversationId, lastMessageId, lastReadAt);
  }

  @override
  Future<ConversationEntity> createConversation(CreateConversationReqEntity req) async {
    try {
      final response = await chatClient.createConversation(req.toModel());
      final result = ConversationEntity.fromModel(response);

      await _conversationDao.insertConversation(result.toModel());
      await _conversationDao.linkUserToConversation(req.participantIds[0], result.id);

      return result;
    } catch (e, st) {
      throw AppException(
        errorClass: "ChatRepositoryImpl",
        errorMethod: "createConversations",
        message: e.toString(),
        stackTrace: st,
      );
    }
  }

  @override
  Future<GetConversationsResEntity> getConversations(String userId) async {
    try {
      final cached = await _conversationDao.getUserConversations(userId);

      if (cached.isNotEmpty) {
        debugPrint("Conversations gotten from cache\n");
        return GetConversationsResEntity(
          conversations: cached.map(ConversationEntity.fromModel).toList(),
        );
      }

      debugPrint("Cache was empty, calling API\n");
      final response = await chatClient.getConversations();
      final entity = GetConversationsResEntity.fromModel(response);

      for (final conv in entity.conversations) {
        await _conversationDao.insertConversation(conv.toModel());
        await _conversationDao.linkUserToConversation(userId, conv.id);
      }

      return entity;
    } catch (e, st) {
      throw AppException(
        errorClass: "ChatRepositoryImpl",
        errorMethod: "getConversations",
        message: e.toString(),
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> cacheMessage(MessageEntity message) async {
    try {
      await chatRoom.addMessage(message);
      await _conversationDao.updateLastMessage(
        message.conversationId,
        message.content,
        message.createdAt.millisecondsSinceEpoch,
      );
    } catch (e, st) {
      throw AppException(
        errorClass: "ChatRepositoryImpl",
        errorMethod: "cacheMessage",
        message: e.toString(),
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteMessages(DeleteMessagesReqEntity req) async {
    try {
      chatRoom.deleteMessage(req.conversationId, req.messageId);
    } catch (e, st) {
      throw AppException(
        errorClass: "ChatRepositoryImpl",
        errorMethod: "deleteMessage",
        message: e.toString(),
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await chatRoom.clearCache();
      await _conversationDao.clearAll();

      debugPrint("Cached Chat history cleared");
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<int> getUnreadCount({required String conversationId, required String userId}) async {
    try {
      // Always fetch remote count — it's the source of truth
      final remoteCount = await chatClient
          .getUnreadCount(conversationId: conversationId)
          .catchError((_) => -1); // -1 signals failure, don't crash

      if (remoteCount >= 0) return remoteCount;

      final localUnreadCount = await _conversationDao.getLocalUnreadCount(
        conversationId,
        userId,
        chatClient.getUnreadCount,
      );
      debugPrint(localUnreadCount.toString());
      return localUnreadCount;
    } catch (e, st) {
      throw AppException(
        errorClass: "ChatRepositoryImpl",
        errorMethod: "getUnreadCount",
        message: e.toString(),
        stackTrace: st,
      );
    }
  }

  @override
  Future<MarkAsReadResEntity> markAsRead({
    required String conversationId,
    required String lastMessageId,
    // required String lastReadAt,
  }) async {
    try {
      final result = await chatClient.markAsRead(
        conversationId: conversationId,
        lastMessageId: lastMessageId,
      );

      if (result.success && result.readAt != null) {
        await saveLocalReadPosition(
          conversationId: conversationId,
          lastMessageId: lastMessageId,
          lastReadAt: result.readAt!.millisecondsSinceEpoch,
        );
      }

      return MarkAsReadResEntity.fromModel(result);
    } catch (e, st) {
      throw AppException(
        errorClass: "ChatRepositoryImpl",
        errorMethod: "markAsRead",
        message: e.toString(),
        stackTrace: st,
      );
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    ref.read(chatClientProvider),
    ref.read(chatDatabaseProvider),
    ref.read(chatWebSocketProvider),
    ref.read(conversationDaoProvider),
  );
});
