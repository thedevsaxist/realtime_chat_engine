import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_web_socket.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

final incomingMessageProvider = StreamProvider<MessageEntity>((ref) {
  final ws = ref.watch(chatWebSocketProvider);
  return ws.messageStream
      .where((data) => data['event'] == 'message')
      .map((data) {
        final raw = data['data'] as Map<String, dynamic>;
        return MessageEntity(
          id: raw['id'],
          content: raw['content'],
          senderId: raw['senderId'],
          conversationId: raw['conversationId'],
          createdAt: DateTime.parse(raw['createdAt']),
        );
      });
});
