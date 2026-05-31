import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/chat/data/models/read_receipt_model.dart';
import 'package:realtime_chat_engine/features/chat/data/repo/chat_repository_impl.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/read_receipt_entity.dart';
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

final incomingReadReceiptProvider = StreamProvider<ReadReceiptEntity>((ref) {
  final ws = ref.watch(chatWebSocketProvider);

  return ws.messageStream.where((data) => data['event'] == 'read_receipt').map((data) {
    final model = ReadReceiptModel.fromJson(data['data'] as Map<String, dynamic>);
    return ReadReceiptEntity.fromModel(model);
  });
});

/// Persists peer read receipts while the app is running (even off the chat screen).
final readReceiptSyncProvider = Provider<void>((ref) {
  ref.listen(incomingReadReceiptProvider, (_, next) {
    next.whenData((receipt) {
      ref.read(chatRepositoryProvider).savePeerReadReceipt(
        conversationId: receipt.conversationId,
        lastMessageId: receipt.lastMessageId,
        lastReadAt: receipt.readAt,
      );
    });
  });
});
