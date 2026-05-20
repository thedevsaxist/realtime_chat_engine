import 'package:realtime_chat_engine/features/chat/data/models/mark_as_read_res_model.dart';

class MarkAsReadResEntity {
  final bool success;

  const MarkAsReadResEntity({required this.success});

  factory MarkAsReadResEntity.fromModel(MarkAsReadResModel model) =>
      MarkAsReadResEntity(success: model.success);

  MarkAsReadResModel toModel() => MarkAsReadResModel(success: success);
}
