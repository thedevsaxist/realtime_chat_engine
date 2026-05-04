import 'package:realtime_chat_engine/features/auth/data/models/register_req_model.dart';

class RegisterReqEntity {
  final String email;
  final String firstName;
  final String lastName;
  final String password;

  RegisterReqEntity({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });

  factory RegisterReqEntity.fromModel(RegisterReqModel model) {
    return RegisterReqEntity(
      email: model.email,
      firstName: model.firstName,
      lastName: model.lastName,
      password: model.password,
    );
  }

  RegisterReqModel toModel() {
    return RegisterReqModel(
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
    );
  }
}
