import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure configuration management for sensitive data
class SecurityConfig {
  // Environment-based configuration
  static const String _env =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  // API Configuration
  static String get apiBaseUrl {
    if (kReleaseMode) {
      // Production environment
      return const String.fromEnvironment('API_BASE_URL',
          defaultValue: 'https://api.nikkah.io');
    } else {
      // Development environment
      return const String.fromEnvironment('API_BASE_URL',
          defaultValue: 'https://dev-api.nikkah.io');
    }
  }

  static String get wsBaseUrl {
    if (kReleaseMode) {
      return const String.fromEnvironment('WS_BASE_URL',
          defaultValue: 'wss://api.nikkah.io/ws');
    } else {
      return const String.fromEnvironment('WS_BASE_URL',
          defaultValue: 'wss://dev-api.nikkah.io/ws');
    }
  }

  // Security Configuration
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxMessagesPerMinute = 30;
  static const int maxProfileViewsPerHour = 100;

  // Content Security
  static const int maxFileUploadSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxMessageLength = 1000;
  static const int maxBioLength = 500;

  // Privacy Settings
  static const bool enableLocationTracking = false;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  /// Get environment-specific configuration
  static Map<String, dynamic> getEnvironmentConfig() {
    switch (_env) {
      case 'production':
        return {
          'apiBaseUrl': apiBaseUrl,
          'wsBaseUrl': wsBaseUrl,
          'enableDebugLogging': false,
          'enableErrorReporting': true,
          'enableAnalytics': enableAnalytics,
        };
      case 'staging':
        return {
          'apiBaseUrl': apiBaseUrl,
          'wsBaseUrl': wsBaseUrl,
          'enableDebugLogging': true,
          'enableErrorReporting': true,
          'enableAnalytics': false,
        };
      case 'development':
      default:
        return {
          'apiBaseUrl': apiBaseUrl,
          'wsBaseUrl': wsBaseUrl,
          'enableDebugLogging': true,
          'enableErrorReporting': false,
          'enableAnalytics': false,
        };
    }
  }

  /// Check if running in production
  static bool get isProduction => kReleaseMode && _env == 'production';

  /// Check if running in development
  static bool get isDevelopment => !kReleaseMode || _env == 'development';

  /// Get secure storage options
  static Map<String, dynamic> getSecureStorageOptions() {
    return {
      'aOptions': Platform.isAndroid
          ? const AndroidOptions(
              encryptedSharedPreferences: true,
            )
          : null,
      'iOptions': Platform.isIOS
          ? const IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            )
          : null,
      'webOptions': kIsWeb
          ? const WebOptions(
              dbName: 'nikkah_secure_storage',
              publicKey: 'nikkah_public_key',
            )
          : null,
    };
  }

  /// Get security headers for web
  static Map<String, String> getSecurityHeaders() {
    return {
      'Content-Security-Policy':
          "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https: wss:; frame-ancestors 'none';",
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Referrer-Policy': 'strict-origin-when-cross-origin',
      'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    };
  }

  /// Validate API response for security
  static bool isValidApiResponse(Map<String, dynamic> response) {
    // Check for required fields
    if (!response.containsKey('status') || !response.containsKey('data')) {
      return false;
    }

    // Check for suspicious content
    final data = response['data'];
    if (data is String && _containsSuspiciousContent(data)) {
      return false;
    }

    return true;
  }

  /// Check for suspicious content in responses
  static bool _containsSuspiciousContent(String content) {
    final suspiciousPatterns = [
      '<script',
      'javascript:',
      'onload=',
      'onerror=',
      'eval(',
      'document.cookie',
      'window.location',
    ];

    final lowerContent = content.toLowerCase();
    return suspiciousPatterns.any((pattern) => lowerContent.contains(pattern));
  }

  /// Get rate limiting configuration
  static Map<String, int> getRateLimits() {
    return {
      'login': maxLoginAttempts,
      'register': 3,
      'messages': maxMessagesPerMinute,
      'profile_views': maxProfileViewsPerHour,
      'api_requests': maxRequestsPerMinute,
    };
  }

  /// Get file upload restrictions
  static Map<String, dynamic> getFileUploadRestrictions() {
    return {
      'maxSize': maxFileUploadSize,
      'allowedImageTypes': allowedImageTypes,
      'allowedDocumentTypes': allowedDocumentTypes,
      'maxFilesPerUpload': 5,
    };
  }
}
