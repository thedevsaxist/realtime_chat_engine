class User {
  final String id;
  final List<String> conversationIds;

  User({required this.id, required this.conversationIds});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], conversationIds: json['conversationIds'].cast<String>());
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'conversationIds': conversationIds};
  }
}
