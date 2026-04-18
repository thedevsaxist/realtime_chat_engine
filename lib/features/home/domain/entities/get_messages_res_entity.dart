import 'package:realtime_chat_engine/features/home/data/models/get_messages_res_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

class GetMessagesResEntity {
  final String status;
  final int results;
  final Map<String, List<MessageEntity>> data;

  const GetMessagesResEntity({required this.status, required this.results, required this.data});

  factory GetMessagesResEntity.fromModel(GetMessagesResModel model) {
    return GetMessagesResEntity(
      status: model.status,
      results: model.results,
      data: model.data.map((key, value) => MapEntry(key, value.map((e) => MessageEntity.fromModel(e)).toList())),
    );
  }

  GetMessagesResModel toModel() {
    return GetMessagesResModel(
      status: status,
      results: results,
      data: data.map((key, value) => MapEntry(key, value.map((e) => e.toModel()).toList())),
    );
  }
}
