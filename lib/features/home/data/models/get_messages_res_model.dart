import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';

class GetMessagesResModel {
  final String status;
  final int results;
  final Map<String, List<MessageModel>> data;

  const GetMessagesResModel({required this.status, required this.results, required this.data});

  factory GetMessagesResModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] as Map<String, dynamic>;

    return GetMessagesResModel(
      status: json["status"],
      results: json["results"],
      data: data.map((key, value) {
        final messages = value as List<dynamic>;
        return MapEntry(key, messages.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList());
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {"status": status, "results": results, "data": data};
  }
}
