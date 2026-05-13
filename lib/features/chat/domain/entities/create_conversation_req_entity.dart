import 'package:realtime_chat_engine/features/chat/data/models/create_conversation_req_model.dart';

class CreateConversationReqEntity {
  final List<String> participantIds;

  CreateConversationReqEntity({required this.participantIds});

  factory CreateConversationReqEntity.fromModel(CreateConversationReqModel model) {
    return CreateConversationReqEntity(participantIds: model.participantIds);
  }

  CreateConversationReqModel toModel() =>
      CreateConversationReqModel(participantIds: participantIds);
}
