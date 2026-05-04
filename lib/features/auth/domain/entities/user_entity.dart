import 'package:realtime_chat_engine/features/auth/data/models/user_model.dart';

class UserEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
  });

  factory UserEntity.fromModel(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      firstName: model.firstName,
      lastName: model.lastName,
      createdAt: model.createdAt,
    );
  }

  UserModel toModel() {
    return UserModel(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      createdAt: createdAt,
    );
  }
}
