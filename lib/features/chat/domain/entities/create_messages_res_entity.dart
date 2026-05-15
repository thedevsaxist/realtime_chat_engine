import 'package:realtime_chat_engine/features/chat/data/models/create_message_res_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

class CreateMessageResEntity {
  final MessageEntity message;

  const CreateMessageResEntity({required this.message});

  factory CreateMessageResEntity.fromModel(CreateMessageResModel model) {
    return CreateMessageResEntity(
      message: MessageEntity.fromModel(model.message),
    );
  }

  CreateMessageResModel toModel() => CreateMessageResModel(message: message.toModel());
}
