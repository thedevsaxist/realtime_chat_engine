import 'package:realtime_chat_engine/features/home/data/models/delete_messages_req_model.dart';

class DeleteMessagesReqEntity {
  final String messageId;
  final String conversationId;

  DeleteMessagesReqEntity({required this.conversationId, required this.messageId});

  factory DeleteMessagesReqEntity.fromModel(DeleteMessagesReqModel model) {
    return DeleteMessagesReqEntity(conversationId: model.conversationId, messageId: model.messageId);
  }

  DeleteMessagesReqModel toModel() => DeleteMessagesReqModel(conversationId: conversationId, messageId: messageId);
}
