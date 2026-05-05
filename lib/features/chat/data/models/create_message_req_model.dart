class CreateMessageReqModel {
  final String conversationId;
  final String senderId;
  final String content;

  CreateMessageReqModel({required this.conversationId, required this.senderId, required this.content});

  factory CreateMessageReqModel.fromJson(Map<String, dynamic> json) {
    return CreateMessageReqModel(
      conversationId: json["conversationId"],
      senderId: json["senderId"],
      content: json["content"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"conversationId": conversationId, "senderId": senderId, "content": content};
  }
}
