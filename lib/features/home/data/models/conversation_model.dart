import 'package:realtime_chat_engine/core/shared/date_time_json.dart';
import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/participant_model.dart';

class ConversationModel {
  final String id;
  final DateTime createdAt;
  final List<ParticipantModel>? participants;
  final List<MessageModel>? messages;

  ConversationModel({required this.id, required this.createdAt, this.messages, this.participants});

  factory ConversationModel.fromJson(Map<String, dynamic> json) => ConversationModel(
    id: json['id'] as String,
    createdAt: dateTimeFromJson(json['createdAt']),
    participants:
        (json['participants'] as List<dynamic>?)
            ?.map((p) => ParticipantModel.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList() ??
        [],
    messages:
        (json['messages'] as List<dynamic>?)
            ?.map((m) => MessageModel.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'participants': participants?.map((p) => p.toJson()).toList(),
    'messages': messages?.map((m) => m.toJson()).toList(),
  };
}
