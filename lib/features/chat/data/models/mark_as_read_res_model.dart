class MarkAsReadResModel {
  final bool success;

  const MarkAsReadResModel({required this.success});

  factory MarkAsReadResModel.fromJson(Map<String, dynamic> json) =>
      MarkAsReadResModel(success: json['success'] as bool);

  Map<String, dynamic> toJson() => {'success': success};
}
