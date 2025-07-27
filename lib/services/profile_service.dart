import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  static const String baseUrl = 'https://api.nikkah.io';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Create NikkahProfile model based on the proto
  static Map<String, dynamic> buildNikkahProfileData({
    required String name,
    required String gender,
    required int birthYear,
    required String birthMonth,
    required int birthDay,
  }) {
    return {
      'profile': {
        'name': name,
        'gender': gender,
        'birth_date': {
          'year': birthYear,
          'month': birthMonth,
          'day': birthDay,
        },
      },
    };
  }

  // Get access token from secure storage
  static Future<String?> _getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Create a new Nikkah profile
  static Future<Map<String, dynamic>> createNikkahProfile(
      Map<String, dynamic> profileData) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/v1/nikkah/profiles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Profile creation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get the authenticated user's profile
  static Future<Map<String, dynamic>> getSelfNikkahProfile() async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v1/nikkah/profile'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update the authenticated user's profile
  static Future<Map<String, dynamic>> updateSelfNikkahProfile(
      Map<String, dynamic> profileData) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/v1/nikkah/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Profile update failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // List Nikkah profiles
  static Future<Map<String, dynamic>> listNikkahProfiles({
    int pageSize = 25,
    String? pageToken,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final queryParameters = <String, String>{
        'page_size': pageSize.toString(),
      };
      if (pageToken != null) {
        queryParameters['page_token'] = pageToken;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v1/nikkah/profiles').replace(
          queryParameters: queryParameters,
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to list profiles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get a specific Nikkah profile
  static Future<Map<String, dynamic>> getNikkahProfile(String profileId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v1/nikkah/profiles/$profileId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
