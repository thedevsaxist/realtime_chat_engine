import 'package:realtime_chat_engine/features/auth/data/models/user_model.dart';

class RegisterResModel {
  final String token;
  final UserModel user;

  RegisterResModel({required this.token, required this.user});

  factory RegisterResModel.fromJson(Map<String, dynamic> json) {
    return RegisterResModel(
      token: json['token'] as String,
      user: UserModel.fromJson(
        Map<String, dynamic>.from(json['user'] as Map),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user};
  }
}
