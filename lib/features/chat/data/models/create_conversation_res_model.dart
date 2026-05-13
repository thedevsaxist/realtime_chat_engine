import 'package:realtime_chat_engine/features/home/data/models/conversation_model.dart';

class CreateConversationResModel {
  final String status;
  final ConversationModel conversation;

  CreateConversationResModel({required this.status, required this.conversation});

  factory CreateConversationResModel.fromJson(Map<String, dynamic> json) {
    return CreateConversationResModel(
      status: json['status'] as String,
      conversation: ConversationModel.fromJson(json['conversation']),
    );
  }

  Map<String, dynamic> toJson() => {"status": status, "conversation": conversation.toJson()};
}
