class ParticipantModel {
  final String id;
  final String userId;
  final String conversationId;

  ParticipantModel({required this.id, required this.userId, required this.conversationId});

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      conversationId: json['conversationId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'conversationId': conversationId};
}
