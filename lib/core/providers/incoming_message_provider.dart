import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_web_socket.dart';

final incomingMessageProvider = StreamProvider<MessageEntity>((ref) {
  final ws = ref.watch(chatWebSocketProvider);

  return ws.messageStream.where((data) => data['event'] == 'message').map((data) {
    final model = MessageModel.fromJson(data['data'] as Map<String, dynamic>);

    return MessageEntity.fromModel(model);
  });
});
