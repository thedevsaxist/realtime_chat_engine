import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';

class CreateMessageResModel {
  final MessageModel message;

  const CreateMessageResModel({required this.message});

  factory CreateMessageResModel.fromJson(Map<String, dynamic> json) {
    return CreateMessageResModel(
      message: MessageModel.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => message.toJson();
}
