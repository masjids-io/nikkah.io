import 'package:flutter/foundation.dart';

/// Environment types
enum Environment {
  development,
  staging,
  production,
}

/// Application configuration
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  /// Current environment
  Environment _environment = Environment.development;

  /// API base URL
  String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.nikkah.io';
      case Environment.staging:
        return 'https://staging-api.nikkah.io';
      case Environment.production:
        return 'https://api.nikkah.io';
    }
  }

  /// API version
  String get apiVersion => 'v1';

  /// Full API URL
  String get fullApiUrl => '$apiBaseUrl/$apiVersion';

  /// Connection timeout duration
  Duration get connectionTimeout => const Duration(seconds: 30);

  /// Receive timeout duration
  Duration get receiveTimeout => const Duration(seconds: 30);

  /// Search debounce duration
  Duration get searchDebounceDuration => const Duration(milliseconds: 500);

  /// Page size for pagination
  int get pageSize => 10;

  /// Maximum retry attempts for network requests
  int get maxRetryAttempts => 3;

  /// Retry delay duration
  Duration get retryDelay => const Duration(seconds: 2);

  /// Cache duration for profiles
  Duration get profileCacheDuration => const Duration(minutes: 5);

  /// Enable debug logging
  bool get enableDebugLogging => kDebugMode;

  /// Enable analytics
  bool get enableAnalytics => !kDebugMode;

  /// Enable crash reporting
  bool get enableCrashReporting => !kDebugMode;

  /// Set the current environment
  void setEnvironment(Environment environment) {
    _environment = environment;
  }

  /// Get current environment
  Environment get environment => _environment;

  /// Check if running in development mode
  bool get isDevelopment => _environment == Environment.development;

  /// Check if running in staging mode
  bool get isStaging => _environment == Environment.staging;

  /// Check if running in production mode
  bool get isProduction => _environment == Environment.production;

  /// Get environment-specific settings
  Map<String, dynamic> get environmentSettings {
    switch (_environment) {
      case Environment.development:
        return {
          'enableDebugLogging': true,
          'enableAnalytics': false,
          'enableCrashReporting': false,
          'connectionTimeout': 30,
          'receiveTimeout': 30,
        };
      case Environment.staging:
        return {
          'enableDebugLogging': true,
          'enableAnalytics': true,
          'enableCrashReporting': true,
          'connectionTimeout': 30,
          'receiveTimeout': 30,
        };
      case Environment.production:
        return {
          'enableDebugLogging': false,
          'enableAnalytics': true,
          'enableCrashReporting': true,
          'connectionTimeout': 30,
          'receiveTimeout': 30,
        };
    }
  }
}

/// Global app config instance
final appConfig = AppConfig(); 