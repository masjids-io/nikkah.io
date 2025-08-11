import 'package:flutter/material.dart';

/// Represents the result of a validation operation
/// Provides structured feedback for better UX
class ValidationResult {
  final bool isValid;
  final String? message;
  final ValidationSeverity severity;
  final String? suggestion;
  final Map<String, dynamic>? metadata;

  const ValidationResult({
    required this.isValid,
    this.message,
    this.severity = ValidationSeverity.error,
    this.suggestion,
    this.metadata,
  });

  /// Create a successful validation result
  factory ValidationResult.success({String? message}) {
    return ValidationResult(
      isValid: true,
      message: message,
      severity: ValidationSeverity.success,
    );
  }

  /// Create an error validation result
  factory ValidationResult.error(String message, {String? suggestion}) {
    return ValidationResult(
      isValid: false,
      message: message,
      severity: ValidationSeverity.error,
      suggestion: suggestion,
    );
  }

  /// Create a warning validation result
  factory ValidationResult.warning(String message, {String? suggestion}) {
    return ValidationResult(
      isValid: false,
      message: message,
      severity: ValidationSeverity.warning,
      suggestion: suggestion,
    );
  }

  /// Create an info validation result
  factory ValidationResult.info(String message) {
    return ValidationResult(
      isValid: true,
      message: message,
      severity: ValidationSeverity.info,
    );
  }

  /// Get the appropriate color for this validation result
  Color get color {
    switch (severity) {
      case ValidationSeverity.success:
        return Colors.green;
      case ValidationSeverity.error:
        return Colors.red;
      case ValidationSeverity.warning:
        return Colors.orange;
      case ValidationSeverity.info:
        return Colors.blue;
    }
  }

  /// Get the appropriate icon for this validation result
  IconData get icon {
    switch (severity) {
      case ValidationSeverity.success:
        return Icons.check_circle;
      case ValidationSeverity.error:
        return Icons.error;
      case ValidationSeverity.warning:
        return Icons.warning;
      case ValidationSeverity.info:
        return Icons.info;
    }
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, message: $message, severity: $severity)';
  }
}

/// Represents the severity level of a validation result
enum ValidationSeverity {
  success,
  error,
  warning,
  info,
}

/// Represents the state of a form field
class FieldValidationState {
  final bool isValid;
  final bool isDirty;
  final bool isFocused;
  final ValidationResult? validationResult;
  final bool isLoading;

  const FieldValidationState({
    this.isValid = true,
    this.isDirty = false,
    this.isFocused = false,
    this.validationResult,
    this.isLoading = false,
  });

  /// Create a clean state
  factory FieldValidationState.clean() {
    return const FieldValidationState();
  }

  /// Create a loading state
  factory FieldValidationState.loading() {
    return const FieldValidationState(isLoading: true);
  }

  /// Create a validated state
  factory FieldValidationState.validated(ValidationResult result) {
    return FieldValidationState(
      isValid: result.isValid,
      isDirty: true,
      validationResult: result,
    );
  }

  /// Create a focused state
  FieldValidationState copyWith({
    bool? isValid,
    bool? isDirty,
    bool? isFocused,
    ValidationResult? validationResult,
    bool? isLoading,
  }) {
    return FieldValidationState(
      isValid: isValid ?? this.isValid,
      isDirty: isDirty ?? this.isDirty,
      isFocused: isFocused ?? this.isFocused,
      validationResult: validationResult ?? this.validationResult,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Check if the field should show validation feedback
  bool get shouldShowFeedback {
    return isDirty && validationResult != null && !isLoading;
  }

  /// Get the display message for the field
  String? get displayMessage {
    if (!shouldShowFeedback) return null;
    return validationResult?.message;
  }

  /// Get the suggestion message for the field
  String? get suggestionMessage {
    if (!shouldShowFeedback) return null;
    return validationResult?.suggestion;
  }
} 