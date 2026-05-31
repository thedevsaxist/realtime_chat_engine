import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/chat/data/models/read_receipt_model.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_web_socket.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/read_receipt_entity.dart';

final incomingReadReceiptProvider = StreamProvider<ReadReceiptEntity>((ref) {
  final ws = ref.watch(chatWebSocketProvider);

  return ws.messageStream.where((data) => data['event'] == 'read_receipt').map((data) {
    final model = ReadReceiptModel.fromJson(data['data'] as Map<String, dynamic>);
    return ReadReceiptEntity.fromModel(model);
  });
});
