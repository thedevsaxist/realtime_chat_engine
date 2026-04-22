class LoginResModel {
  final String token;
  final String userId;
  final List<String> conversationIds;

  LoginResModel({required this.token, required this.userId, required this.conversationIds});

  factory LoginResModel.fromJson(Map<String, dynamic> json) {
    return LoginResModel(
      token: json['token'],
      userId: json['userId'],
      conversationIds: json['conversationIds'].cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'userId': userId, 'conversationIds': conversationIds};
  }
}
