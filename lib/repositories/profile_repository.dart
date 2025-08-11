import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/nikkah_profile.dart';
import '../models/profile_browse_state.dart';
import '../exceptions/profile_exceptions.dart';

/// Repository interface for profile operations
abstract class ProfileRepository {
  Future<ListNikkahProfilesResponse> listProfiles({
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
  });

  Future<NikkahProfile> getSelfProfile();
  Future<NikkahProfile> getProfile(String profileId);
  Future<void> likeProfile(String likerProfileId, String likedProfileId);
  Future<NikkahProfile> createProfile(Map<String, dynamic> profileData);
  Future<NikkahProfile> updateProfile(String profileId, Map<String, dynamic> profileData);
}

/// Concrete implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  static const String _baseUrl = 'https://api.nikkah.io';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';

  @override
  Future<ListNikkahProfilesResponse> listProfiles({
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
        throw const ProfileAuthenticationException(
          message: 'No access token found. Please login again.',
        );
      }

      final queryParameters = _buildQueryParameters({
        'start': start,
        'limit': limit,
        'page': page,
        'name': name,
        'gender': gender,
        'location.country': country,
        'location.city': city,
        'location.state': state,
        'location.zipCode': zipCode,
        'location.latitude': latitude,
        'location.longitude': longitude,
        'education': education,
        'occupation': occupation,
        'height.cm': heightCm,
        'sect': sect,
        'hobbies': hobbies,
      });

      final response = await http.get(
        Uri.parse('$_baseUrl/v1/nikkah/profiles').replace(
          queryParameters: queryParameters,
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      return _handleHttpResponse<ListNikkahProfilesResponse>(
        response,
        (json) => ListNikkahProfilesResponse.fromJson(json),
        'Failed to list profiles',
      );
    } on ProfileException {
      rethrow;
    } catch (e) {
      throw _handleGenericError(e, 'Failed to list profiles');
    }
  }

  @override
  Future<NikkahProfile> getSelfProfile() async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw const ProfileAuthenticationException(
          message: 'No access token found. Please login again.',
        );
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/v1/nikkah/profile'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      final apiResponse = _handleHttpResponse<NikkahApiResponse>(
        response,
        (json) => NikkahApiResponse.fromJson(json),
        'Failed to get profile',
      );

      if (apiResponse.nikkahProfile == null) {
        throw const ProfileNotFoundException(
          message: 'Profile not found',
        );
      }

      return apiResponse.nikkahProfile!;
    } on ProfileException {
      rethrow;
    } catch (e) {
      throw _handleGenericError(e, 'Failed to get profile');
    }
  }

  @override
  Future<NikkahProfile> getProfile(String profileId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw const ProfileAuthenticationException(
          message: 'No access token found. Please login again.',
        );
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/v1/nikkah/profile/$profileId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      final apiResponse = _handleHttpResponse<NikkahApiResponse>(
        response,
        (json) => NikkahApiResponse.fromJson(json),
        'Failed to get profile',
      );

      if (apiResponse.nikkahProfile == null) {
        throw ProfileNotFoundException(
          message: 'Profile with ID $profileId not found',
        );
      }

      return apiResponse.nikkahProfile!;
    } on ProfileException {
      rethrow;
    } catch (e) {
      throw _handleGenericError(e, 'Failed to get profile');
    }
  }

  @override
  Future<void> likeProfile(String likerProfileId, String likedProfileId) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw const ProfileAuthenticationException(
          message: 'No access token found. Please login again.',
        );
      }

      final likeData = {
        'likerProfileId': likerProfileId,
        'likedProfileId': likedProfileId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/nikkah/likes'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(likeData),
      );

      _handleHttpResponse<NikkahApiResponse>(
        response,
        (json) => NikkahApiResponse.fromJson(json),
        'Failed to like profile',
      );
    } on ProfileException {
      rethrow;
    } catch (e) {
      throw _handleGenericError(e, 'Failed to like profile');
    }
  }

  @override
  Future<NikkahProfile> createProfile(Map<String, dynamic> profileData) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw const ProfileAuthenticationException(
          message: 'No access token found. Please login again.',
        );
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/nikkah/profile'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profileData),
      );

      final apiResponse = _handleHttpResponse<NikkahApiResponse>(
        response,
        (json) => NikkahApiResponse.fromJson(json),
        'Failed to create profile',
      );

      if (apiResponse.nikkahProfile == null) {
        throw const ProfileNotFoundException(
          message: 'Created profile not returned',
        );
      }

      return apiResponse.nikkahProfile!;
    } on ProfileException {
      rethrow;
    } catch (e) {
      throw _handleGenericError(e, 'Failed to create profile');
    }
  }

  @override
  Future<NikkahProfile> updateProfile(String profileId, Map<String, dynamic> profileData) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw const ProfileAuthenticationException(
          message: 'No access token found. Please login again.',
        );
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/v1/nikkah/profile/$profileId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profileData),
      );

      final apiResponse = _handleHttpResponse<NikkahApiResponse>(
        response,
        (json) => NikkahApiResponse.fromJson(json),
        'Failed to update profile',
      );

      if (apiResponse.nikkahProfile == null) {
        throw const ProfileNotFoundException(
          message: 'Updated profile not returned',
        );
      }

      return apiResponse.nikkahProfile!;
    } on ProfileException {
      rethrow;
    } catch (e) {
      throw _handleGenericError(e, 'Failed to update profile');
    }
  }

  /// Helper method to get access token from secure storage
  Future<String?> _getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw ProfileNetworkException(
        message: 'Failed to read access token from secure storage',
        originalError: e,
      );
    }
  }

  /// Helper method to build query parameters
  Map<String, String> _buildQueryParameters(Map<String, dynamic> params) {
    final queryParameters = <String, String>{};
    
    for (final entry in params.entries) {
      final value = entry.value;
      if (value != null) {
        if (value is List) {
          if (value.isNotEmpty) {
            for (final item in value) {
              if (item != null && item.toString().isNotEmpty) {
                queryParameters[entry.key] = item.toString();
              }
            }
          }
        } else if (value.toString().isNotEmpty) {
          queryParameters[entry.key] = value.toString();
        }
      }
    }
    
    return queryParameters;
  }

  /// Helper method to handle HTTP responses
  T _handleHttpResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
    String errorMessage,
  ) {
    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return fromJson(json);
      } catch (e) {
        throw ProfileServerException(
          message: 'Invalid JSON response',
          statusCode: response.statusCode,
          originalError: e,
        );
      }
    } else if (response.statusCode == 401) {
      throw const ProfileAuthenticationException(
        message: 'Authentication failed. Please login again.',
      );
    } else if (response.statusCode == 404) {
      throw const ProfileNotFoundException(
        message: 'Resource not found',
      );
    } else if (response.statusCode == 429) {
      final retryAfter = response.headers['retry-after'];
      Duration? retryAfterDuration;
      if (retryAfter != null) {
        try {
          final seconds = int.parse(retryAfter);
          retryAfterDuration = Duration(seconds: seconds);
        } catch (_) {
          // Ignore parsing errors for retry-after header
        }
      }
      
      throw ProfileRateLimitException(
        message: 'Rate limit exceeded. Please try again later.',
        retryAfter: retryAfterDuration,
      );
    } else if (response.statusCode >= 500) {
      throw ProfileServerException(
        message: 'Server error occurred',
        statusCode: response.statusCode,
      );
    } else {
      throw ProfileServerException(
        message: '$errorMessage: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Helper method to handle generic errors
  ProfileException _handleGenericError(dynamic error, String context) {
    if (error is http.ClientException) {
      return ProfileNetworkException(
        message: '$context: Network connection failed',
        originalError: error,
      );
    } else if (error is FormatException) {
      return ProfileServerException(
        message: '$context: Invalid response format',
        statusCode: 0,
        originalError: error,
      );
    } else {
      return ProfileServerException(
        message: '$context: ${error.toString()}',
        statusCode: 0,
        originalError: error,
      );
    }
  }
} 