import 'package:realtime_chat_engine/features/home/data/models/participant_model.dart';

class ParticipantEntity {
  final String userId;
  final String firstName;
  final String lastName;

  ParticipantEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  factory ParticipantEntity.fromModel(ParticipantModel model) {
    return ParticipantEntity(
      userId: model.userId,
      firstName: model.firstName,
      lastName: model.lastName,
    );
  }

  ParticipantModel toModel() => ParticipantModel(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
  );
}
