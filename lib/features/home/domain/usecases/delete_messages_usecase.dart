import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/home/data/repos/chat_repository_impl.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/delete_messages_req_entity.dart';

class DeleteMessagesUsecase {
  final ChatRepositoryImpl chatRepository;

  DeleteMessagesUsecase(this.chatRepository);

  Future<void> call(String messageId, String conversationId) async {
    try {
      final request = DeleteMessagesReqEntity(conversationId: conversationId, messageId: messageId);
      chatRepository.deleteMessages(request);
    } catch (e) {
      throw Exception(e);
    }
  }
}

final deleteMessageUsecaseProvider = Provider((ref) {
  return DeleteMessagesUsecase(ref.read(chatRepositoryProvider));
});
