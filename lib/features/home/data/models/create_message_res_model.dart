class CreateMessageResModel {
  final String conversationId;
  final String senderId;
  final String content;

  const CreateMessageResModel({
    required this.conversationId,
    required this.senderId,
    required this.content,
  });

  factory CreateMessageResModel.fromJson(Map<String, dynamic> json) {
    return CreateMessageResModel(
      conversationId: json["conversationId"],
      senderId: json["senderId"],
      content: json["content"],
    );
  } 

  Map<String, dynamic> toJson() {
    return {
      "conversationId": conversationId,
      "senderId": senderId,
      "content": content,
    };
  }
}
