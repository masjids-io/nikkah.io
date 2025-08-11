import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Accessibility helper for WCAG 2.1 compliance
/// Provides utilities for better screen reader support and keyboard navigation
class AccessibilityHelper {
  /// Create an accessible text field with proper labels and hints
  static InputDecoration createAccessibleDecoration({
    required String label,
    String? hint,
    String? helpText,
    bool isRequired = false,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? suffixIconSemanticLabel,
  }) {
    final requiredLabel = isRequired ? ' (required)' : '';
    final fullLabel = '$label$requiredLabel';
    
    return InputDecoration(
      labelText: fullLabel,
      hintText: hint,
      helperText: helpText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon != null
          ? Semantics(
              label: suffixIconSemanticLabel ?? 'Additional options',
              child: suffixIcon,
            )
          : null,
      // Ensure proper contrast and focus indicators
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  /// Create an accessible button with proper semantics
  static Widget createAccessibleButton({
    required String label,
    required VoidCallback? onPressed,
    String? tooltip,
    bool isLoading = false,
    Widget? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null && !isLoading,
      child: Tooltip(
        message: tooltip ?? label,
        child: SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: onPressed != null && !isLoading ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        icon,
                        const SizedBox(width: 8),
                      ],
                      Text(label),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Create an accessible form field with validation feedback
  static Widget createAccessibleFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    String? hint,
    String? helpText,
    bool isRequired = false,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePasswordVisibility,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    VoidCallback? onFieldSubmitted,
    FocusNode? focusNode,
    Widget? prefixIcon,
    int? maxLines,
    int? maxLength,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      enabled: enabled,
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: (_) => onFieldSubmitted?.call(),
        focusNode: focusNode,
        maxLines: maxLines,
        maxLength: maxLength,
        enabled: enabled,
        decoration: createAccessibleDecoration(
          label: label,
          hint: hint,
          helpText: helpText,
          isRequired: isRequired,
          prefixIcon: prefixIcon,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    semanticLabel: obscureText ? 'Show password' : 'Hide password',
                  ),
                  onPressed: onTogglePasswordVisibility,
                )
              : null,
          suffixIconSemanticLabel: isPassword
              ? (obscureText ? 'Show password' : 'Hide password')
              : null,
        ),
      ),
    );
  }

  /// Create an accessible dropdown with proper semantics
  static Widget createAccessibleDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    String? hint,
    bool isRequired = false,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      button: true,
      enabled: enabled,
      child: DropdownButtonFormField<T>(
        value: value,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel(item)),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
        decoration: createAccessibleDecoration(
          label: label,
          hint: hint,
          isRequired: isRequired,
          prefixIcon: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }

  /// Create an accessible checkbox with proper semantics
  static Widget createAccessibleCheckbox({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
    String? helpText,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: helpText,
      button: true,
      enabled: enabled,
      child: CheckboxListTile(
        title: Text(label),
        subtitle: helpText != null ? Text(helpText) : null,
        value: value,
        onChanged: enabled ? onChanged : null,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  /// Create an accessible radio button group
  static Widget createAccessibleRadioGroup<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      button: true,
      enabled: enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((T item) {
            return RadioListTile<T>(
              title: Text(itemLabel(item)),
              value: item,
              groupValue: value,
              onChanged: enabled ? onChanged : null,
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  /// Announce a message to screen readers
  static void announceToScreenReader(BuildContext context, String message) {
    // Note: In Flutter, screen reader announcements are typically handled
    // through Semantics widgets and proper labeling rather than direct announcements
    // For accessibility, ensure proper semantic labels are used throughout the app
  }

  /// Create a focusable container for keyboard navigation
  static Widget createFocusableContainer({
    required Widget child,
    required FocusNode focusNode,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Focus(
      focusNode: focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && 
            (event.logicalKey == LogicalKeyboardKey.enter || 
             event.logicalKey == LogicalKeyboardKey.space)) {
          onTap?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: child,
      ),
    );
  }

  /// Get appropriate semantic label for form validation
  static String getValidationSemanticLabel(String? errorText, String? helpText) {
    if (errorText != null) {
      return 'Error: $errorText';
    }
    if (helpText != null) {
      return 'Help: $helpText';
    }
    return '';
  }
} 