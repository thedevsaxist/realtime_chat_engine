import 'package:riverpod/riverpod.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';
import 'package:realtime_chat_engine/features/home/data/models/conversation_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/get_messages_res_model.dart';
import 'package:realtime_chat_engine/features/chat/data/models/mark_as_read_res_model.dart';
import 'package:realtime_chat_engine/features/chat/data/models/delete_messages_req_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/get_conversations_res_model.dart';
import 'package:realtime_chat_engine/features/chat/data/models/create_conversation_req_model.dart';

class ChatClient {
  final DioService _dioService;

  ChatClient(this._dioService);

  Future<MarkAsReadResModel> markAsRead({
    required String conversationId,
    required String lastMessageId,
  }) async {
    final response = await _dioService.dio.patch(
      "/conversations/$conversationId/read/$lastMessageId",
    );

    return MarkAsReadResModel.fromJson(response.data);
  }

  Future<int> getUnreadCount({required String conversationId}) async {
    final response = await _dioService.dio.get(
      "/conversations/unread",
      queryParameters: {'conversationId': conversationId},
    );

    return response.data['unreadCount'] as int;
  }

  Future<ConversationModel> createConversation(CreateConversationReqModel req) async {
    final response = await _dioService.dio.post("/conversations", data: req.toJson());
    return ConversationModel.fromJson(response.data);
  }

  Future<GetConversationsResModel> getConversations() async {
    final response = await _dioService.dio.get("/conversations");
    return GetConversationsResModel.fromJson(response.data);
  }

  Future<GetMessagesResModel> getMessages(String conversationId) async {
    final response = await _dioService.dio.get(
      "/messages",
      queryParameters: {"conversationId": conversationId},
    );
    return GetMessagesResModel.fromJson(response.data);
  }

  // TODO: implement this on the backend
  Future<void> deleteMessage(DeleteMessagesReqModel req) async {
    await _dioService.dio.delete(
      "/messages/${req.messageId}",
      queryParameters: {"conversationId": req.conversationId},
    );
  }
}

final chatClientProvider = Provider((ref) => ChatClient(ref.read(dioServiceProvider)));
