import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';

abstract class ChatRepository {
  Future<GetMessagesResEntity> getMessages(String conversationId); 
}