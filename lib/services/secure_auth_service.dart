import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/security_config.dart';
import '../utils/input_validator.dart';

/// Secure authentication service with comprehensive security measures
class SecureAuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Session management
  static String? _currentUserId;
  static String? _currentAccessToken;
  static DateTime? _lastTokenRefresh;
  static int _loginAttempts = 0;
  static DateTime? _lockoutUntil;

  // Rate limiting
  static final Map<String, List<DateTime>> _requestTimestamps = {};
  static final Map<String, int> _requestCounts = {};

  /// Initialize secure authentication service
  static Future<void> initialize() async {
    // Clear any expired sessions
    await _cleanupExpiredSessions();

    // Check for existing valid session
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      final isValid = await _validateToken(token);
      if (isValid) {
        _currentAccessToken = token;
        _currentUserId = await _storage.read(key: 'user_id');
        _lastTokenRefresh = DateTime.now();
      } else {
        await logout();
      }
    }
  }

  /// Secure user registration with comprehensive validation
  static Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String gender = 'GENDER_UNSPECIFIED',
  }) async {
    // Rate limiting check
    if (!_checkRateLimit('register')) {
      throw Exception(
          'Too many registration attempts. Please try again later.');
    }

    // Input validation
    final emailError = InputValidator.validateEmail(email);
    if (emailError != null) throw Exception(emailError);

    final usernameError = InputValidator.validateUsername(username);
    if (usernameError != null) throw Exception(usernameError);

    final passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) throw Exception(passwordError);

    final firstNameError = InputValidator.validateName(firstName);
    if (firstNameError != null) throw Exception(firstNameError);

    final lastNameError = InputValidator.validateName(lastName);
    if (lastNameError != null) throw Exception(lastNameError);

    if (phoneNumber != null) {
      final phoneError = InputValidator.validatePhone(phoneNumber);
      if (phoneError != null) throw Exception(phoneError);
    }

    final genderError = InputValidator.validateGender(gender);
    if (genderError != null) throw Exception(genderError);

    // Sanitize inputs
    final sanitizedData = {
      'user': {
        'email': email.trim().toLowerCase(),
        'username': username.trim(),
        'first_name': InputValidator.sanitizeText(firstName.trim()),
        'last_name': InputValidator.sanitizeText(lastName.trim()),
        'phone_number': phoneNumber?.trim() ?? '',
        'gender': gender,
      },
      'password': password, // Will be hashed on server
    };

    try {
      final response = await http.post(
        Uri.parse('${SecurityConfig.apiBaseUrl}/v1/users'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Nikkah.io/1.0.0',
          'X-Request-ID': _generateRequestId(),
        },
        body: jsonEncode(sanitizedData),
      );

      _recordRequest('register');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Validate response for security
        if (!SecurityConfig.isValidApiResponse(responseData)) {
          throw Exception('Invalid response from server');
        }

        return responseData;
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Secure login with rate limiting and session management
  static Future<Map<String, dynamic>> login({
    String? email,
    String? username,
    required String password,
  }) async {
    // Check lockout status
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remainingTime = _lockoutUntil!.difference(DateTime.now());
      throw Exception(
          'Account temporarily locked. Try again in ${remainingTime.inMinutes} minutes.');
    }

    // Rate limiting check
    if (!_checkRateLimit('login')) {
      _loginAttempts++;
      if (_loginAttempts >= SecurityConfig.maxLoginAttempts) {
        _lockoutUntil = DateTime.now().add(SecurityConfig.lockoutDuration);
        throw Exception(
            'Too many login attempts. Account locked for ${SecurityConfig.lockoutDuration.inMinutes} minutes.');
      }
      throw Exception('Too many login attempts. Please try again later.');
    }

    // Input validation
    if (email != null) {
      final emailError = InputValidator.validateEmail(email);
      if (emailError != null) throw Exception(emailError);
    }

    if (username != null) {
      final usernameError = InputValidator.validateUsername(username);
      if (usernameError != null) throw Exception(usernameError);
    }

    final passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) throw Exception(passwordError);

    try {
      final Map<String, dynamic> requestBody = {
        'password': password,
      };

      if (email != null) {
        requestBody['email'] = email.trim().toLowerCase();
      } else if (username != null) {
        requestBody['username'] = username.trim();
      }

      final response = await http.post(
        Uri.parse('${SecurityConfig.apiBaseUrl}/users/authenticate'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Nikkah.io/1.0.0',
          'X-Request-ID': _generateRequestId(),
        },
        body: jsonEncode(requestBody),
      );

      _recordRequest('login');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validate response for security
        if (!SecurityConfig.isValidApiResponse(data)) {
          throw Exception('Invalid response from server');
        }

        // Store tokens securely
        await _storeTokens(data);

        // Reset login attempts on successful login
        _loginAttempts = 0;
        _lockoutUntil = null;

        return data;
      } else {
        _loginAttempts++;
        throw Exception('Login failed: Invalid credentials');
      }
    } catch (e) {
      _loginAttempts++;
      throw Exception('Network error: $e');
    }
  }

  /// Get current user with token validation
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await _getValidToken();
    if (token == null) {
      throw Exception('No valid access token found');
    }

    try {
      final response = await http.get(
        Uri.parse('${SecurityConfig.apiBaseUrl}/v1/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'User-Agent': 'Nikkah.io/1.0.0',
          'X-Request-ID': _generateRequestId(),
        },
      );

      _recordRequest('api_requests');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validate response for security
        if (!SecurityConfig.isValidApiResponse(data)) {
          throw Exception('Invalid response from server');
        }

        return data;
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        await _refreshToken();
        return getCurrentUser(); // Retry with new token
      } else {
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Refresh access token securely
  static Future<String> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }

    try {
      final response = await http.post(
        Uri.parse('${SecurityConfig.apiBaseUrl}/users/refresh_token'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Nikkah.io/1.0.0',
          'X-Request-ID': _generateRequestId(),
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validate response for security
        if (!SecurityConfig.isValidApiResponse(data)) {
          throw Exception('Invalid response from server');
        }

        await _storeTokens(data);
        return data['access_token'];
      } else {
        // Refresh token expired, force logout
        await logout();
        throw Exception('Session expired. Please login again.');
      }
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  /// Secure logout with session cleanup
  static Future<void> logout() async {
    try {
      // Revoke tokens on server if possible
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        await http.post(
          Uri.parse('${SecurityConfig.apiBaseUrl}/users/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'User-Agent': 'Nikkah.io/1.0.0',
          },
        );
      }
    } catch (e) {
      // Continue with local cleanup even if server logout fails
    }

    // Clear local session data
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'session_data');

    // Reset session state
    _currentUserId = null;
    _currentAccessToken = null;
    _lastTokenRefresh = null;
    _loginAttempts = 0;
    _lockoutUntil = null;
  }

  /// Check if user is logged in with valid session
  static Future<bool> isLoggedIn() async {
    final token = await _getValidToken();
    return token != null;
  }

  /// Get stored access token with validation
  static Future<String?> getAccessToken() async {
    return await _getValidToken();
  }

  /// Get current user ID
  static String? get currentUserId => _currentUserId;

  /// Store tokens securely
  static Future<void> _storeTokens(Map<String, dynamic> data) async {
    await _storage.write(key: 'access_token', value: data['access_token']);
    await _storage.write(key: 'refresh_token', value: data['refresh_token']);
    await _storage.write(key: 'user_id', value: data['user_id'].toString());
    await _storage.write(
        key: 'session_data',
        value: jsonEncode({
          'created_at': DateTime.now().toIso8601String(),
          'expires_at': DateTime.now()
              .add(SecurityConfig.sessionTimeout)
              .toIso8601String(),
        }));

    _currentAccessToken = data['access_token'];
    _currentUserId = data['user_id'].toString();
    _lastTokenRefresh = DateTime.now();
  }

  /// Get valid token with automatic refresh
  static Future<String?> _getValidToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;

    // Check if token needs refresh
    if (_lastTokenRefresh != null) {
      final timeSinceRefresh = DateTime.now().difference(_lastTokenRefresh!);
      if (timeSinceRefresh > SecurityConfig.tokenRefreshThreshold) {
        try {
          await _refreshToken();
          return await _storage.read(key: 'access_token');
        } catch (e) {
          return null;
        }
      }
    }

    return token;
  }

  /// Validate token with server
  static Future<bool> _validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${SecurityConfig.apiBaseUrl}/v1/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'User-Agent': 'Nikkah.io/1.0.0',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Refresh token internally
  static Future<void> _refreshToken() async {
    final newToken = await refreshToken();
    _currentAccessToken = newToken;
    _lastTokenRefresh = DateTime.now();
  }

  /// Cleanup expired sessions
  static Future<void> _cleanupExpiredSessions() async {
    final sessionData = await _storage.read(key: 'session_data');
    if (sessionData != null) {
      try {
        final session = jsonDecode(sessionData);
        final expiresAt = DateTime.parse(session['expires_at']);
        if (DateTime.now().isAfter(expiresAt)) {
          await logout();
        }
      } catch (e) {
        // Invalid session data, clear it
        await logout();
      }
    }
  }

  /// Rate limiting implementation
  static bool _checkRateLimit(String endpoint) {
    final now = DateTime.now();
    final timestamps = _requestTimestamps[endpoint] ?? [];

    // Remove timestamps older than 1 minute
    timestamps
        .removeWhere((timestamp) => now.difference(timestamp).inMinutes >= 1);

    final limit = SecurityConfig.getRateLimits()[endpoint] ?? 60;

    if (timestamps.length >= limit) {
      return false;
    }

    timestamps.add(now);
    _requestTimestamps[endpoint] = timestamps;
    return true;
  }

  /// Record request for rate limiting
  static void _recordRequest(String endpoint) {
    final now = DateTime.now();
    final timestamps = _requestTimestamps[endpoint] ?? [];
    timestamps.add(now);
    _requestTimestamps[endpoint] = timestamps;
  }

  /// Generate unique request ID
  static String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_currentUserId ?? 'anonymous'}';
  }
}
