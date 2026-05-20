import 'package:realtime_chat_engine/features/chat/data/models/read_receipt_model.dart';

class ReadReceiptEntity {
  final String conversationId;
  final String lastMessageId;

  const ReadReceiptEntity({required this.conversationId, required this.lastMessageId});

  factory ReadReceiptEntity.fromModel(ReadReceiptModel model) =>
      ReadReceiptEntity(conversationId: model.conversationId, lastMessageId: model.lastMessageId);

  ReadReceiptModel toModel() =>
      ReadReceiptModel(conversationId: conversationId, lastMessageId: lastMessageId);
}
