import 'package:realtime_chat_engine/features/home/data/models/create_message_req_model.dart';

class CreateMessageReqEntity {
  final String conversationId;
  final String senderId;
  final String content;

  const CreateMessageReqEntity({required this.content, required this.conversationId, required this.senderId});

  factory CreateMessageReqEntity.fromModel(CreateMessageReqModel model) {
    return CreateMessageReqEntity(
      conversationId: model.conversationId,
      senderId: model.senderId,
      content: model.content,
    );
  }

  CreateMessageReqModel toModel() =>
      CreateMessageReqModel(conversationId: conversationId, senderId: senderId, content: content);
}
