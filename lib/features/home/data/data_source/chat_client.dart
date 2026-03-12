import 'package:dio/dio.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';
import 'package:realtime_chat_engine/features/home/data/models/get_messages_res_model.dart';
import 'package:riverpod/riverpod.dart';

class ChatClient {
  final DioService dioService;

  ChatClient(this.dioService);

  Future<GetMessagesResModel> getMessages(String conversationId) async {
    try {
      final response = await dioService.dio.get("/messages", queryParameters: {"conversationId": conversationId});

      final result = response.data as Map<String, dynamic>;

      return GetMessagesResModel.fromJson(result);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}

final chatClientProvider = Provider((ref) => ChatClient(ref.read(dioServiceProvider)));
