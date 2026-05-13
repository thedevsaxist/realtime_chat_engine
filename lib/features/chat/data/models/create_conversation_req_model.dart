class CreateConversationReqModel {
  final List<String> participantIds;

  CreateConversationReqModel({required this.participantIds});

  factory CreateConversationReqModel.fromJson(Map<String, dynamic> json) {
    return CreateConversationReqModel(participantIds: json['participantIds'] as List<String>);
  }

  Map<String, dynamic> toJson() => {"participantIds": participantIds};
}
