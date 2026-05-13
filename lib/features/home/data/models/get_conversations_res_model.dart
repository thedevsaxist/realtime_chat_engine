import 'package:realtime_chat_engine/features/home/data/models/conversation_model.dart';

class GetConversationsResModel {
  final String status;
  final List<ConversationModel> conversations;

  GetConversationsResModel({required this.status, required this.conversations});

  factory GetConversationsResModel.fromJson(Map<String, dynamic> json) {
    return GetConversationsResModel(
      status: json['status'] as String,
      conversations:
          (json['conversations'] as List<dynamic>)
              .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}
