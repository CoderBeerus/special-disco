class AppException implements Exception {
  AppException(this.userMessage, {this.debugMessage});

  final String userMessage;
  final String? debugMessage;

  @override
  String toString() => debugMessage ?? userMessage;
}
