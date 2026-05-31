import 'package:realtime_chat_engine/core/shared/date_time_json.dart';

class GetPeerReadPositionResModel {
  final String lastReadMessageId;
  final DateTime lastReadAt;

  const GetPeerReadPositionResModel({required this.lastReadAt, required this.lastReadMessageId});

  factory GetPeerReadPositionResModel.fromJson(Map<String, dynamic> json) {
    return GetPeerReadPositionResModel(
      lastReadAt: dateTimeFromJson(json['lastReadAt']),
      lastReadMessageId: json['lastReadMessageId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'lastReadMessageId': lastReadMessageId,
    'lastReadAt': lastReadAt,
  };
}
