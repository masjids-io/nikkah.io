/// Base exception class for profile-related errors
abstract class ProfileException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const ProfileException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'ProfileException: $message';
}

/// Exception thrown when network operations fail
class ProfileNetworkException extends ProfileException {
  const ProfileNetworkException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  @override
  String toString() => 'ProfileNetworkException: $message';
}

/// Exception thrown when authentication fails
class ProfileAuthenticationException extends ProfileException {
  const ProfileAuthenticationException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  @override
  String toString() => 'ProfileAuthenticationException: $message';
}

/// Exception thrown when server returns an error
class ProfileServerException extends ProfileException {
  final int statusCode;

  const ProfileServerException({
    required String message,
    required this.statusCode,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  @override
  String toString() => 'ProfileServerException($statusCode): $message';
}

/// Exception thrown when validation fails
class ProfileValidationException extends ProfileException {
  final Map<String, String> validationErrors;

  const ProfileValidationException({
    required String message,
    required this.validationErrors,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  @override
  String toString() => 'ProfileValidationException: $message - Errors: $validationErrors';
}

/// Exception thrown when a profile is not found
class ProfileNotFoundException extends ProfileException {
  const ProfileNotFoundException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  @override
  String toString() => 'ProfileNotFoundException: $message';
}

/// Exception thrown when rate limiting occurs
class ProfileRateLimitException extends ProfileException {
  final Duration? retryAfter;

  const ProfileRateLimitException({
    required String message,
    this.retryAfter,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  @override
  String toString() => 'ProfileRateLimitException: $message${retryAfter != null ? ' (Retry after: $retryAfter)' : ''}';
} 