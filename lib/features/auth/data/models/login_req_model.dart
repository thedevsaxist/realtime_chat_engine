class LoginReqModel {
  final String email;
  final String password;

  LoginReqModel({required this.email, required this.password});

  factory LoginReqModel.fromJson(Map<String, dynamic> json) {
    return LoginReqModel(email: json['email'], password: json['password']);
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
