import '../../data/models/login_req_model.dart';

class LoginReqEntity {
  final String email;
  final String password;

  LoginReqEntity({required this.email, required this.password});

  factory LoginReqEntity.fromModel(LoginReqModel model) {
    return LoginReqEntity(email: model.email, password: model.password);
  }

  LoginReqModel toModel() {
    return LoginReqModel(email: email, password: password);
  }
}
