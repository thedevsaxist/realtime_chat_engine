class ReadReceiptModel {
  final String conversationId;
  final String lastMessageId;
  final int readAt;

  const ReadReceiptModel({required this.conversationId, required this.lastMessageId, required this.readAt,
  });

  factory ReadReceiptModel.fromJson(Map<String, dynamic> json) => ReadReceiptModel(
    conversationId: json['conversationId'] as String,
    lastMessageId: json['lastMessageId'] as String,
    readAt: json['readAt'] as int,
  );

  Map<String, dynamic> toJson() => {
    'conversationId': conversationId,
    'lastMessageId': lastMessageId,
    'readAt': readAt,
  };
}
