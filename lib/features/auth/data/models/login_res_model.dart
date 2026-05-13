import 'package:realtime_chat_engine/features/auth/data/models/user_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/conversation_model.dart';

class LoginResModel {
  final String token;
  final String refreshToken;
  final UserModel user;
  final List<ConversationModel> conversations;

  LoginResModel({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.conversations,
  });

  factory LoginResModel.fromJson(Map<String, dynamic> json) {
    return LoginResModel(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      conversations: List<ConversationModel>.from(
        (json['conversations'] as List<dynamic>).map(
          (e) => ConversationModel.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'conversations': conversations.map((e) => e.toJson()).toList(),
    };
  }
}
