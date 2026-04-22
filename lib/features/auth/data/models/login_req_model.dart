class LoginReqModel {
  final String userId;
  final String password;

  LoginReqModel({required this.userId, required this.password});

  factory LoginReqModel.fromJson(Map<String, dynamic> json) {
    return LoginReqModel(userId: json['userId'], password: json['password']);
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'password': password};
  }
}
