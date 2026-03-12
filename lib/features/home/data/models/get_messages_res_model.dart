class GetMessagesResModel {
  final String status;
  final int results;
  final Map<String, List<Message>> data;

  const GetMessagesResModel({required this.status, required this.results, required this.data});

  factory GetMessagesResModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] as Map<String, dynamic>;

    return GetMessagesResModel(
      status: json["status"],
      results: json["results"],
      data: data.map((key, value) {
        final messages = value as List<dynamic>;
        return MapEntry(key, messages.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList());
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {"status": status, "results": results, "data": data};
  }
}

class Message {
  final String id;
  final String content;
  final String senderId;
  final String conversationId;
  final String createdAt;

  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.conversationId,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
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
