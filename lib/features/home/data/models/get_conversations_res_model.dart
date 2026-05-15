import 'package:realtime_chat_engine/features/home/data/models/conversation_model.dart';

class GetConversationsResModel {
  final List<ConversationModel> conversations;

  GetConversationsResModel({required this.conversations});

  factory GetConversationsResModel.fromJson(Map<String, dynamic> json) {
    return GetConversationsResModel(
      conversations: (json['conversations'] as List<dynamic>)
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
