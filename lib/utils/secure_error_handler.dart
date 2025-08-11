import 'package:flutter/foundation.dart';
import '../config/security_config.dart';

/// Secure error handling utility to prevent information leakage
class SecureErrorHandler {
  
  /// Sanitize error messages for user display
  static String sanitizeErrorMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred. Please try again.';
    }

    String errorMessage = error.toString();

    // Remove sensitive information
    errorMessage = _removeSensitiveInfo(errorMessage);
    
    // Remove stack traces and technical details
    errorMessage = _removeTechnicalDetails(errorMessage);
    
    // Sanitize for XSS prevention
    errorMessage = _sanitizeForXSS(errorMessage);

    // Provide generic messages in production
    if (SecurityConfig.isProduction) {
      return _getGenericErrorMessage(errorMessage);
    }

    return errorMessage;
  }

  /// Log error securely without exposing sensitive data
  static void logError(dynamic error, {String? context, StackTrace? stackTrace}) {
    if (!SecurityConfig.isProduction) {
      // In development, log full details
      debugPrint('Error in $context: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    } else {
      // In production, log sanitized error
      final sanitizedError = _removeSensitiveInfo(error.toString());
      debugPrint('Error in $context: $sanitizedError');
    }
  }

  /// Handle network errors securely
  static String handleNetworkError(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }
    
    if (error.toString().contains('HandshakeException')) {
      return 'Secure connection error. Please try again later.';
    }
    
    return 'Network error occurred. Please try again.';
  }

  /// Handle authentication errors securely
  static String handleAuthError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('invalid credentials') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('401')) {
      return 'Invalid email/username or password. Please try again.';
    }
    
    if (errorStr.contains('account locked') ||
        errorStr.contains('too many attempts')) {
      return 'Account temporarily locked due to too many failed attempts. Please try again later.';
    }
    
    if (errorStr.contains('session expired') ||
        errorStr.contains('token expired')) {
      return 'Your session has expired. Please login again.';
    }
    
    return 'Authentication error. Please try again.';
  }

  /// Handle validation errors securely
  static String handleValidationError(dynamic error) {
    final errorStr = error.toString();
    
    // Return the validation message as-is since it's user-friendly
    if (errorStr.contains('required') ||
        errorStr.contains('invalid') ||
        errorStr.contains('must be') ||
        errorStr.contains('Please enter')) {
      return errorStr;
    }
    
    return 'Please check your input and try again.';
  }

  /// Handle API errors securely
  static String handleApiError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('500') || errorStr.contains('internal server error')) {
      return 'Server error occurred. Please try again later.';
    }
    
    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'Requested resource not found.';
    }
    
    if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'Access denied. You do not have permission to perform this action.';
    }
    
    if (errorStr.contains('429') || errorStr.contains('too many requests')) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    
    if (errorStr.contains('422') || errorStr.contains('unprocessable entity')) {
      return 'Invalid request data. Please check your input and try again.';
    }
    
    return 'An error occurred while processing your request. Please try again.';
  }

  /// Remove sensitive information from error messages
  static String _removeSensitiveInfo(String message) {
    // Remove API keys, tokens, passwords
    message = message.replaceAll(RegExp(r'api[_-]?key', caseSensitive: false), '[API_KEY]');
    message = message.replaceAll(RegExp(r'token', caseSensitive: false), '[TOKEN]');
    message = message.replaceAll(RegExp(r'password', caseSensitive: false), '[PASSWORD]');
    message = message.replaceAll(RegExp(r'secret', caseSensitive: false), '[SECRET]');
    
    // Remove file paths
    message = message.replaceAll(RegExp(r'\.dart'), '[FILE_PATH]');
    message = message.replaceAll(RegExp(r'\.kt'), '[FILE_PATH]');
    message = message.replaceAll(RegExp(r'\.swift'), '[FILE_PATH]');
    
    // Remove IP addresses
    message = message.replaceAll(RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'), '[IP_ADDRESS]');
    
    // Remove email addresses
    message = message.replaceAll(RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'), '[EMAIL]');
    
    // Remove phone numbers
    message = message.replaceAll(RegExp(r'\d{3}[-.]?\d{3}[-.]?\d{4}'), '[PHONE]');
    
    return message;
  }

  /// Remove technical details from error messages
  static String _removeTechnicalDetails(String message) {
    // Remove stack traces
    message = message.replaceAll(RegExp(r'#\d+\s+[^\n]+'), '');
    message = message.replaceAll(RegExp(r'at\s+[^\n]+'), '');
    
    // Remove class names and method names
    message = message.replaceAll(RegExp(r'\b[A-Z][a-zA-Z0-9]*\.[a-zA-Z0-9_]*\b'), '[METHOD]');
    
    // Remove line numbers
    message = message.replaceAll(RegExp(r':\d+:\d+'), '');
    
    return message.trim();
  }

  /// Sanitize error message for XSS prevention
  static String _sanitizeForXSS(String message) {
    // Remove HTML tags
    message = message.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Remove script tags
    message = message.replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');
    
    // Remove dangerous attributes
    message = message.replaceAll(RegExp(r'on\\w+'), '');
    
    // Remove javascript protocol
    message = message.replaceAll(RegExp(r'javascript:', caseSensitive: false), '');
    
    // Remove eval calls
    message = message.replaceAll(RegExp(r'eval\s*\([^)]*\)'), '');
    
    return message.trim();
  }

  /// Get generic error message for production
  static String _getGenericErrorMessage(String originalError) {
    final errorLower = originalError.toLowerCase();
    
    if (errorLower.contains('network') || errorLower.contains('connection')) {
      return 'Network error occurred. Please check your connection and try again.';
    }
    
    if (errorLower.contains('authentication') || errorLower.contains('login')) {
      return 'Authentication error. Please try logging in again.';
    }
    
    if (errorLower.contains('validation') || errorLower.contains('invalid')) {
      return 'Please check your input and try again.';
    }
    
    if (errorLower.contains('server') || errorLower.contains('500')) {
      return 'Server error occurred. Please try again later.';
    }
    
    if (errorLower.contains('timeout') || errorLower.contains('timed out')) {
      return 'Request timed out. Please try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  /// Validate error message for security
  static bool isValidErrorMessage(String message) {
    // Check for suspicious patterns
    final suspiciousPatterns = [
      '<script',
      'javascript:',
      'onload=',
      'onerror=',
      'eval(',
      'document.cookie',
      'window.location',
      'alert(',
      'confirm(',
      'prompt(',
    ];

    final lowerMessage = message.toLowerCase();
    return !suspiciousPatterns.any((pattern) => lowerMessage.contains(pattern));
  }

  /// Get user-friendly error title
  static String getErrorTitle(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Connection Error';
    }
    
    if (errorStr.contains('authentication') || errorStr.contains('login')) {
      return 'Authentication Error';
    }
    
    if (errorStr.contains('validation') || errorStr.contains('invalid')) {
      return 'Validation Error';
    }
    
    if (errorStr.contains('server') || errorStr.contains('500')) {
      return 'Server Error';
    }
    
    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'Timeout Error';
    }
    
    return 'Error';
  }

  /// Check if error should be reported
  static bool shouldReportError(dynamic error) {
    if (!SecurityConfig.isProduction) {
      return false; // Don't report errors in development
    }
    
    final errorStr = error.toString().toLowerCase();
    
    // Report server errors, network errors, and unexpected errors
    return errorStr.contains('server') ||
           errorStr.contains('network') ||
           errorStr.contains('unexpected') ||
           errorStr.contains('exception');
  }
} 