import 'package:realtime_chat_engine/core/config/network/dio_service.dart';
import 'package:realtime_chat_engine/features/chat/data/models/delete_messages_req_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/get_conversations_res_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/get_messages_res_model.dart';
import 'package:riverpod/riverpod.dart';

import '../models/create_conversation_req_model.dart';
import '../models/create_conversation_res_model.dart';

class ChatClient {
  final DioService dioService;

  ChatClient(this.dioService);

  // Future<CreateMessageResModel> createMessage(CreateMessageReqModel req) async {
  //   try {
  //     final response = await dioService.dio.post("/messages", data: req.toJson());
  //     final result = response.data as Map<String, dynamic>;

  //     return CreateMessageResModel.fromJson(result);
  //   } on DioException catch (e) {
  //     throw Exception(e.message);
  //   }
  // }

  Future<CreateConversationResModel> createConversation(CreateConversationReqModel req) async {
    final response = await dioService.dio.post("/conversations", data: req.toJson());
    return CreateConversationResModel.fromJson(response.data);
  }

  Future<GetConversationsResModel> getConversations(String userId) async {
    final response = await dioService.dio.get(
      "/conversations",
      queryParameters: {"userId": userId},
    );
    return GetConversationsResModel.fromJson(response.data);
  }

  Future<GetMessagesResModel> getMessages(String conversationId) async {
    final response = await dioService.dio.get(
      "/messages",
      queryParameters: {"conversationId": conversationId},
    );
    return GetMessagesResModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteMessage(DeleteMessagesReqModel req) async {
    await dioService.dio.delete(
      "/messages/${req.messageId}",
      queryParameters: {"conversationId": req.conversationId},
    );
  }
}

final chatClientProvider = Provider((ref) => ChatClient(ref.read(dioServiceProvider)));
