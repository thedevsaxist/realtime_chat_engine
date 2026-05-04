import 'package:realtime_chat_engine/core/shared/date_time_json.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      createdAt: dateTimeFromJson(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
