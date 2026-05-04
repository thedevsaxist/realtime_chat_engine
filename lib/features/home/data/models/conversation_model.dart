import 'package:realtime_chat_engine/core/shared/date_time_json.dart';
import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';

class ConversationModel {
  final String id;
  final DateTime createdAt;
  final List<MessageModel> messages;

  ConversationModel({required this.id, required this.createdAt, required this.messages});

  factory ConversationModel.fromJson(Map<String, dynamic> json) => ConversationModel(
    id: json['id'] as String,
    createdAt: dateTimeFromJson(json['createdAt']),
    messages:
        (json['messages'] as List<dynamic>?)
            ?.map((m) => MessageModel.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}
