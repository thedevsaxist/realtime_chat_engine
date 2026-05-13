import 'package:realtime_chat_engine/features/home/data/models/participant_model.dart';

class ParticipantEntity {
  final String id;
  final String userId;
  final String conversationId;

  ParticipantEntity({required this.id, required this.userId, required this.conversationId});

  factory ParticipantEntity.fromModel(ParticipantModel model) {
    return ParticipantEntity(
      id: model.id,
      userId: model.userId,
      conversationId: model.conversationId,
    );
  }

  ParticipantModel toModel() =>
      ParticipantModel(id: id, userId: userId, conversationId: conversationId);
}
