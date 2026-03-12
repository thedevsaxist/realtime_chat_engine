import 'package:realtime_chat_engine/features/home/data/data_source/chat_client.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/repositories/chat_repository.dart';
import 'package:riverpod/riverpod.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatClient chatClient;

  ChatRepositoryImpl(this.chatClient);

  @override
  Future<GetMessagesResEntity> getMessages(String conversationId) async {
    try {
      final response = await chatClient.getMessages(conversationId);
      return GetMessagesResEntity.fromModel(response);
    } catch (e) {
      throw Exception(e);
    }
  }
}

final chatRepositoryProvider = Provider((ref) => ChatRepositoryImpl(ref.read(chatClientProvider)));
