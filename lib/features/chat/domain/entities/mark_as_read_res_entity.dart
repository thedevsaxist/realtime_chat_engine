import 'package:realtime_chat_engine/features/chat/data/models/mark_as_read_res_model.dart';

class MarkAsReadResEntity {
  final bool success;
  final DateTime? readAt;

  const MarkAsReadResEntity({required this.success, this.readAt});

  factory MarkAsReadResEntity.fromModel(MarkAsReadResModel model) =>
      MarkAsReadResEntity(success: model.success, readAt: model.readAt);

  MarkAsReadResModel toModel() => MarkAsReadResModel(success: success, readAt: readAt);
}
