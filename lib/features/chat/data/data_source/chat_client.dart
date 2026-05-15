import 'package:realtime_chat_engine/core/config/network/dio_service.dart';
import 'package:realtime_chat_engine/features/chat/data/models/create_conversation_req_model.dart';
import 'package:realtime_chat_engine/features/chat/data/models/delete_messages_req_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/conversation_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/get_conversations_res_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/get_messages_res_model.dart';
import 'package:riverpod/riverpod.dart';

class ChatClient {
  final DioService dioService;

  ChatClient(this.dioService);

  Future<ConversationModel> createConversation(CreateConversationReqModel req) async {
    final response = await dioService.dio.post("/conversations", data: req.toJson());
    return ConversationModel.fromJson(response.data);
  }

  Future<GetConversationsResModel> getConversations() async {
    final response = await dioService.dio.get("/conversations");
    return GetConversationsResModel.fromJson(response.data);
  }

  Future<GetMessagesResModel> getMessages(String conversationId) async {
    final response = await dioService.dio.get(
      "/messages",
      queryParameters: {"conversationId": conversationId},
    );
    return GetMessagesResModel.fromJson(response.data);
  }

  // TODO: implement this on the backend
  Future<void> deleteMessage(DeleteMessagesReqModel req) async {
    await dioService.dio.delete(
      "/messages/${req.messageId}",
      queryParameters: {"conversationId": req.conversationId},
    );
  }
}

final chatClientProvider = Provider((ref) => ChatClient(ref.read(dioServiceProvider)));
