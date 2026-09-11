enum PrinterError {
  none,
  notConnected,
  outOfPaper,
  offline,
  timeout,
  unknown,
}

class PrintResult {
  final bool success;
  final PrinterError error;
  final String? message;

  const PrintResult({
    required this.success,
    this.error = PrinterError.none,
    this.message,
  });

  // ✅ Métodos de fábrica (CORRECTOS)
  factory PrintResult.success() {
    return const PrintResult(success: true);
  }

  factory PrintResult.failure(PrinterError error, [String? message]) {
    return PrintResult(
      success: false,
      error: error,
      message: message,
    );
  }
}