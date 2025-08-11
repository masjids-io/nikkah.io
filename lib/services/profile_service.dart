import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/nikkah_profile.dart';

class ProfileService {
  static const String baseUrl = 'https://api.nikkah.io';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get access token from secure storage
  static Future<String?> _getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Create a new Nikkah profile
  static Future<NikkahApiResponse> createNikkahProfile(
      Map<String, dynamic> profileData) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/v1/nikkah/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Profile creation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get the authenticated user's profile
  static Future<NikkahApiResponse> getSelfNikkahProfile() async {
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
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update the authenticated user's profile
  static Future<NikkahApiResponse> updateSelfNikkahProfile(
      String profileId, Map<String, dynamic> profileData) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/v1/nikkah/profile/$profileId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Profile update failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // List Nikkah profiles with filtering options
  static Future<NikkahApiResponse> listNikkahProfiles({
    int? start,
    int? limit,
    int? page,
    String? name,
    String? gender,
    String? country,
    String? city,
    String? state,
    String? zipCode,
    int? latitude,
    int? longitude,
    String? education,
    String? occupation,
    int? heightCm,
    String? sect,
    List<String>? hobbies,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final queryParameters = <String, String>{};
      
      if (start != null) queryParameters['start'] = start.toString();
      if (limit != null) queryParameters['limit'] = limit.toString();
      if (page != null) queryParameters['page'] = page.toString();
      if (name != null && name.isNotEmpty) queryParameters['name'] = name;
      if (gender != null && gender != 'GENDER_UNSPECIFIED') queryParameters['gender'] = gender;
      if (country != null && country.isNotEmpty) queryParameters['location.country'] = country;
      if (city != null && city.isNotEmpty) queryParameters['location.city'] = city;
      if (state != null && state.isNotEmpty) queryParameters['location.state'] = state;
      if (zipCode != null && zipCode.isNotEmpty) queryParameters['location.zipCode'] = zipCode;
      if (latitude != null) queryParameters['location.latitude'] = latitude.toString();
      if (longitude != null) queryParameters['location.longitude'] = longitude.toString();
      if (education != null && education != 'EDUCATION_UNSPECIFIED') queryParameters['education'] = education;
      if (occupation != null && occupation.isNotEmpty) queryParameters['occupation'] = occupation;
      if (heightCm != null) queryParameters['height.cm'] = heightCm.toString();
      if (sect != null && sect != 'SECT_UNSPECIFIED') queryParameters['sect'] = sect;
      if (hobbies != null && hobbies.isNotEmpty) {
        for (final hobby in hobbies) {
          if (hobby != 'HOBBIES_UNSPECIFIED') {
            queryParameters['hobbies'] = hobby;
          }
        }
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
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to list profiles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get a specific Nikkah profile
  static Future<NikkahApiResponse> getNikkahProfile(String profileId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v1/nikkah/profile/$profileId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Like a profile
  static Future<NikkahApiResponse> initiateNikkahLike(Map<String, dynamic> likeData) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/v1/nikkah/likes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(likeData),
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to like profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get a specific like
  static Future<NikkahApiResponse> getNikkahLike(String likeId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v1/nikkah/likes/$likeId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get like: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Cancel a like
  static Future<NikkahApiResponse> cancelNikkahLike(String likeId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/v1/nikkah/likes/$likeId/cancel'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to cancel like: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Complete a like (when both parties like each other)
  static Future<NikkahApiResponse> completeNikkahLike(String likeId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/v1/nikkah/likes/$likeId/complete'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to complete like: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get a match
  static Future<NikkahApiResponse> getNikkahMatch(String matchId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v1/nikkah/match/$matchId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get match: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Accept a match invite
  static Future<NikkahApiResponse> acceptNikkahMatchInvite(String matchId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/v1/nikkah/match/$matchId/accept'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to accept match: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Reject a match invite
  static Future<NikkahApiResponse> rejectNikkahMatchInvite(String matchId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/v1/nikkah/match/$matchId/reject'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to reject match: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // End a match
  static Future<NikkahApiResponse> endNikkahMatch(String matchId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/v1/nikkah/match/$matchId/end'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return NikkahApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to end match: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Helper method to build profile data for creation/update
  static Map<String, dynamic> buildNikkahProfileData({
    required String name,
    required String gender,
    required int birthYear,
    required String birthMonth,
    required int birthDay,
    String? country,
    String? city,
    String? state,
    String? zipCode,
    int? latitude,
    int? longitude,
    String? education,
    String? occupation,
    int? heightCm,
    String? sect,
    List<String>? hobbies,
  }) {
    final profileData = <String, dynamic>{
      'name': name,
      'gender': gender,
      'birthDate': {
        'year': birthYear,
        'month': birthMonth,
        'day': birthDay,
      },
    };

    if (country != null || city != null || state != null || zipCode != null || latitude != null || longitude != null) {
      profileData['location'] = <String, dynamic>{};
      if (country != null) profileData['location']['country'] = country;
      if (city != null) profileData['location']['city'] = city;
      if (state != null) profileData['location']['state'] = state;
      if (zipCode != null) profileData['location']['zipCode'] = zipCode;
      if (latitude != null) profileData['location']['latitude'] = latitude;
      if (longitude != null) profileData['location']['longitude'] = longitude;
    }

    if (education != null) profileData['education'] = education;
    if (occupation != null) profileData['occupation'] = occupation;
    if (heightCm != null) profileData['height'] = {'cm': heightCm};
    if (sect != null) profileData['sect'] = sect;
    if (hobbies != null) profileData['hobbies'] = hobbies;

    return {'profile': profileData};
  }
}
