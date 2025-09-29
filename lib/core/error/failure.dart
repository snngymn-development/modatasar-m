class Failure {
  final String message;
  final String? code;
  final StackTrace? stack;
  final dynamic originalError;

  const Failure(this.message, {this.code, this.stack, this.originalError});

  @override
  String toString() {
    return 'Failure(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}
