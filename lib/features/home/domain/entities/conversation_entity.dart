import 'package:realtime_chat_engine/features/home/domain/entities/participant_entity.dart';
import 'package:realtime_chat_engine/features/home/data/models/conversation_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

class ConversationEntity {
  final String id;
  final DateTime createdAt;
  final List<ParticipantEntity>? participants;
  final List<MessageEntity>? messages;

  ConversationEntity({required this.id, required this.createdAt, this.participants, this.messages});

  factory ConversationEntity.fromModel(ConversationModel model) => ConversationEntity(
    id: model.id,
    createdAt: model.createdAt,
    participants: model.participants?.map((e) => ParticipantEntity.fromModel(e)).toList(),
    messages: model.messages?.map((e) => MessageEntity.fromModel(e)).toList(),
  );

  ConversationModel toModel() => ConversationModel(
    id: id,
    createdAt: createdAt,
    participants: participants?.map((p) => p.toModel()).toList(),
    messages: messages?.map((e) => e.toModel()).toList(),
  );
}
