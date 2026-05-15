class ParticipantModel {
  final String userId;
  final String firstName;
  final String lastName;

  ParticipantModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
  };
}
