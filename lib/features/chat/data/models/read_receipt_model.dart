class ReadReceiptModel {
  final String conversationId;
  final String lastMessageId;

  const ReadReceiptModel({required this.conversationId, required this.lastMessageId});

  factory ReadReceiptModel.fromJson(Map<String, dynamic> json) => ReadReceiptModel(
    conversationId: json['conversationId'] as String,
    lastMessageId: json['lastMessageId'] as String,
  );

  Map<String, dynamic> toJson() => {
    'conversationId': conversationId,
    'lastMessageId': lastMessageId,
  };
}
