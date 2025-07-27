import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl =
      'https://api.nikkah.io'; // Update with your actual API URL
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // User model based on the proto
  static Map<String, dynamic> createUser({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String gender = 'GENDER_UNSPECIFIED',
  }) {
    return {
      'user': {
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber ?? '',
        'gender': gender,
      },
      'password': password,
    };
  }

  // Register user
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    String? email,
    String? username,
    required String password,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'password': password,
      };

      if (email != null) {
        requestBody['email'] = email;
      } else if (username != null) {
        requestBody['username'] = username;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/users/authenticate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store tokens securely
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(
            key: 'refresh_token', value: data['refresh_token']);
        await _storage.write(key: 'user_id', value: data['user_id'].toString());

        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v1/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Refresh token
  static Future<String> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/users/refresh_token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['access_token']);
        return data['access_token'];
      } else {
        throw Exception('Token refresh failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Logout
  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_id');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  // Get stored access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }
}
