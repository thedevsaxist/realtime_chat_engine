class Conversation {
  final String id;
  final int createdAt;
  final String lastMessage;
  final int lastMessageTime;

  Conversation({required this.id, required this.createdAt, required this.lastMessage, required this.lastMessageTime});

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'],
    createdAt: json['createdAt'],
    lastMessage: json['lastMessage'],
    lastMessageTime: json['lastMessageTime'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime,
  };
}
