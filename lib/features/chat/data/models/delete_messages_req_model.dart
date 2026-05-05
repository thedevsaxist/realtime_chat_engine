class DeleteMessagesReqModel {
  final String messageId;
  final String conversationId;

  DeleteMessagesReqModel({required this.conversationId, required this.messageId});

  factory DeleteMessagesReqModel.fromJson(Map<String, dynamic> json) {
    return DeleteMessagesReqModel(conversationId: json["conversationId"], messageId: json["messageId"]);
  }

  Map<String, dynamic> toJson() => {"conversationId": conversationId, "messageId": messageId};
}
