import 'package:realtime_chat_engine/features/chat/data/models/create_message_res_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

class CreateMessageResEntity {
  final String status;
  final MessageEntity data;

  const CreateMessageResEntity({required this.status, required this.data});

  factory CreateMessageResEntity.fromModel(CreateMessageResModel model) {
    return CreateMessageResEntity(
      status: model.status,
      data:  MessageEntity.fromModel(model.data),
    );
  }

  CreateMessageResModel toModel() => CreateMessageResModel(
    data: data.toModel(),
    status: status,
  );
}
