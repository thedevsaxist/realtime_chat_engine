import '../../data/models/login_req_model.dart';

class LoginReqEntity {
  final String userId;
  final String password;

  LoginReqEntity({required this.userId, required this.password});

  factory LoginReqEntity.fromModel(LoginReqModel model) {
    return LoginReqEntity(userId: model.userId, password: model.password);
  }

  LoginReqModel toModel() {
    return LoginReqModel(userId: userId, password: password);
  }
}
