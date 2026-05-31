import 'package:realtime_chat_engine/core/shared/date_time_json.dart';

class MarkAsReadResModel {
  final bool success;
  final DateTime? readAt;

  const MarkAsReadResModel({required this.success, this.readAt});

  factory MarkAsReadResModel.fromJson(Map<String, dynamic> json) =>
      MarkAsReadResModel(success: json['success'] as bool, readAt: dateTimeFromJson(json['readAt']));

  Map<String, dynamic> toJson() => {'success': success, 'readAt': readAt};
}
