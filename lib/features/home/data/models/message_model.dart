import 'package:realtime_chat_engine/core/shared/date_time_json.dart';

class MessageModel {
  final String id;
  final String content;
  final String senderId;
  final String conversationId;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.conversationId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      conversationId: json['conversationId'] as String,
      createdAt: dateTimeFromJson(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'conversationId': conversationId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
