import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';

class GetMessagesResModel {
  final List<MessageModel> messages;

  const GetMessagesResModel({required this.messages});

  factory GetMessagesResModel.fromJson(Map<String, dynamic> json) {
    return GetMessagesResModel(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {'messages': messages.map((m) => m.toJson()).toList()};
}
