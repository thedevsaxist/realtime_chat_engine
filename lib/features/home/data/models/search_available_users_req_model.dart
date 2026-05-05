class SearchAvailableUsersReqModel {
  final String userId;

  SearchAvailableUsersReqModel({required this.userId});

  factory SearchAvailableUsersReqModel.fromJson(Map<String, dynamic> json) {
    return SearchAvailableUsersReqModel(userId: json["userId"] as String);
  }

  Map<String, dynamic> toJson() => {"userId": userId};
}
