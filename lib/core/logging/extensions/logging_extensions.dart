import '../app_logger.dart';

/// Professional extensions to provide semantic logging across the application.
extension LoggingExtensions on Object {
  /// Log a debug message. Use for verbose development information.
  void logDebug(String message) => appLogger.debug(message);

  /// Log an informational message. Use for general app flow events.
  void logInfo(String message) => appLogger.info(message);

  /// Log a warning message. Use for non-critical issues that require attention.
  void logWarning(String message) => appLogger.warning(message);

  /// Log an error message with optional exception and stack trace.
  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    appLogger.handle(error ?? message, stackTrace, message);
  }
}
