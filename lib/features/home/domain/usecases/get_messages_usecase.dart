import 'package:realtime_chat_engine/features/home/data/repos/chat_repository_impl.dart';
import 'package:riverpod/riverpod.dart';

import '../entities/get_messages_res_entity.dart';

class GetMessagesUsecase {
  final ChatRepositoryImpl chatRepository;

  GetMessagesUsecase(this.chatRepository);

  Future<GetMessagesResEntity> call(String conversationId) async {
    try {
      return chatRepository.getMessages(conversationId);
    } catch (e) {
      throw Exception(e);
    }
  }
}

final getMessagesUsecaseProvider = Provider((ref) {
  return GetMessagesUsecase(ref.read(chatRepositoryProvider));
});
