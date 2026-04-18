class MessageModel {
  final String id;
  final String content;
  final String senderId;
  final String conversationId;
  final String createdAt;

  const MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.conversationId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"],
      content: json["content"],
      senderId: json["senderId"],
      conversationId: json["conversationId"],
      createdAt: json["createdAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "content": content,
      "senderId": senderId,
      "conversationId": conversationId,
      "createdAt": createdAt,
    };
  }
}
