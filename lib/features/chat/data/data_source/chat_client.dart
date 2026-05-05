import 'package:dio/dio.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';
import 'package:realtime_chat_engine/features/chat/data/models/delete_messages_req_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/get_messages_res_model.dart';
import 'package:riverpod/riverpod.dart';

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

  Future<GetMessagesResModel> getMessages(String conversationId) async {
    try {
      final response = await dioService.dio.get("/messages", queryParameters: {"conversationId": conversationId});

      final result = response.data as Map<String, dynamic>;

      return GetMessagesResModel.fromJson(result);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> deleteMessage(DeleteMessagesReqModel req) async {
    try {
      await dioService.dio.delete(
        "/messages/${req.messageId}",
        queryParameters: {"conversationId": req.conversationId},
      );
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}

final chatClientProvider = Provider((ref) => ChatClient(ref.read(dioServiceProvider)));
