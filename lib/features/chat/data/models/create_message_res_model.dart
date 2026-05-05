import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';

class CreateMessageResModel {
  final String status;
  final MessageModel data;

  const CreateMessageResModel({required this.status, required this.data});

  factory CreateMessageResModel.fromJson(Map<String, dynamic> json) {
    // final data = json["data"] as Map<String, dynamic>;

    return CreateMessageResModel(
      status: json["status"],
      data: MessageModel.fromJson(json["data"] as Map<String, dynamic>)

    );
  }

  Map<String, dynamic> toJson() {
    return {"status": status, "data": data};
  }
}
