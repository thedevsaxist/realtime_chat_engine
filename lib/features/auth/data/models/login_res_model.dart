import 'package:realtime_chat_engine/features/home/data/models/conversation.dart';

class LoginResModel {
  final String token;
  final String userId;
  final List<Conversation> conversations;

  LoginResModel({required this.token, required this.userId, required this.conversations});

  factory LoginResModel.fromJson(Map<String, dynamic> json) {
    return LoginResModel(
      token: json['token'],
      userId: json['userId'],
      conversations: List<Conversation>.from(json['conversations'].map((e) => Conversation.fromJson(e))),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'userId': userId, 'conversations': conversations};
  }
}
