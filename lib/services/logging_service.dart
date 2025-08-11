import 'package:flutter/foundation.dart';

/// Log levels for structured logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Logging service for structured logging
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  /// Current log level
  LogLevel _logLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Set the current log level
  void setLogLevel(LogLevel level) {
    _logLevel = level;
  }

  /// Log a debug message
  void debug(String message, {String? tag, Map<String, dynamic>? context}) {
    _log(LogLevel.debug, message, tag: tag, context: context);
  }

  /// Log an info message
  void info(String message, {String? tag, Map<String, dynamic>? context}) {
    _log(LogLevel.info, message, tag: tag, context: context);
  }

  /// Log a warning message
  void warning(String message, {String? tag, Map<String, dynamic>? context}) {
    _log(LogLevel.warning, message, tag: tag, context: context);
  }

  /// Log an error message
  void error(String message,
      {String? tag,
      Map<String, dynamic>? context,
      Object? error,
      StackTrace? stackTrace}) {
    _log(LogLevel.error, message,
        tag: tag, context: context, error: error, stackTrace: stackTrace);
  }

  /// Log a fatal message
  void fatal(String message,
      {String? tag,
      Map<String, dynamic>? context,
      Object? error,
      StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message,
        tag: tag, context: context, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Check if we should log this level
    if (level.index < _logLevel.index) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.name.toUpperCase();
    final tagString = tag != null ? '[$tag]' : '';

    // Build log message
    final logMessage = '$timestamp $levelString$tagString: $message';

    // Add context if provided
    final fullMessage = context != null && context.isNotEmpty
        ? '$logMessage | Context: $context'
        : logMessage;

    // Log to console
    if (kDebugMode) {
      print(fullMessage);

      // Log error details if provided
      if (error != null) {
        print('Error: $error');
      }

      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }

    // In production, you might want to send logs to a service like Firebase Analytics, Crashlytics, etc.
    _sendToAnalytics(level, message,
        tag: tag, context: context, error: error, stackTrace: stackTrace);
  }

  /// Send logs to analytics service (placeholder for production implementation)
  void _sendToAnalytics(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // TODO: Implement analytics service integration
    // Examples:
    // - Firebase Analytics
    // - Crashlytics
    // - Custom analytics service

    if (level == LogLevel.error || level == LogLevel.fatal) {
      // Send error reports
      _sendErrorReport(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Send error reports (placeholder for production implementation)
  void _sendErrorReport(String message,
      {Object? error, StackTrace? stackTrace}) {
    // TODO: Implement error reporting service
    // Examples:
    // - Firebase Crashlytics
    // - Sentry
    // - Custom error reporting service
  }
}

/// Global logging service instance
final logger = LoggingService();

/// Extension for easy logging on any class
extension LoggingExtension on Object {
  void logDebug(String message, {Map<String, dynamic>? context}) {
    logger.debug(message, tag: runtimeType.toString(), context: context);
  }

  void logInfo(String message, {Map<String, dynamic>? context}) {
    logger.info(message, tag: runtimeType.toString(), context: context);
  }

  void logWarning(String message, {Map<String, dynamic>? context}) {
    logger.warning(message, tag: runtimeType.toString(), context: context);
  }

  void logError(String message,
      {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {
    logger.error(message,
        tag: runtimeType.toString(),
        context: context,
        error: error,
        stackTrace: stackTrace);
  }

  void logFatal(String message,
      {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {
    logger.fatal(message,
        tag: runtimeType.toString(),
        context: context,
        error: error,
        stackTrace: stackTrace);
  }
}
