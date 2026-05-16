class AppException implements Exception {
  final String message;
  final String location;
  final StackTrace stackTrace;

  const AppException({
    required String errorClass,
    required String errorMethod,
    required this.message,
    required this.stackTrace,
  }) : location = "[$errorClass -> $errorMethod]";

  @override
  String toString() {
    return "$location : $message \n\n-----------------------------------------------------------[⚠️STACKTRACE]------------------------------------------------------------\n\n$stackTrace";
  }
}
