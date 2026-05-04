class RegisterReqModel {
  final String email;
  final String firstName;
  final String lastName;
  final String password;

  RegisterReqModel({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });

  factory RegisterReqModel.fromJson(Map<String, dynamic> json) {
    return RegisterReqModel(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
    };
  }
}
