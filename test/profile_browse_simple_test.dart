import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/models/profile_browse_state.dart';
import 'package:nikkah_io/models/nikkah_profile.dart';
import 'package:nikkah_io/exceptions/profile_exceptions.dart';

void main() {
  group('Profile Browse State Tests', () {
    test('should create initial state', () {
      const state = ProfileBrowseInitial();
      expect(state, isA<ProfileBrowseState>());
    });

    test('should create loading state', () {
      const state = ProfileBrowseLoading();
      expect(state, isA<ProfileBrowseState>());
    });

    test('should create success state with profiles', () {
      final profiles = [
        NikkahProfile(id: '1', name: 'John Doe'),
        NikkahProfile(id: '2', name: 'Jane Smith'),
      ];

      final state = ProfileBrowseSuccess(
        profiles: profiles,
        currentPage: 1,
        totalPages: 2,
        hasMoreProfiles: true,
      );

      expect(state, isA<ProfileBrowseState>());
      expect(state.profiles, hasLength(2));
      expect(state.currentPage, 1);
      expect(state.totalPages, 2);
      expect(state.hasMoreProfiles, true);
    });

    test('should create error state', () {
      const state = ProfileBrowseError(
        message: 'Test error',
        errorType: ProfileBrowseErrorType.network,
      );

      expect(state, isA<ProfileBrowseState>());
      expect(state.message, 'Test error');
      expect(state.errorType, ProfileBrowseErrorType.network);
    });

    test('should create empty state', () {
      const state = ProfileBrowseEmpty(
        message: 'No profiles found',
        activeFilters: {'gender': 'MALE'},
        searchQuery: 'test',
      );

      expect(state, isA<ProfileBrowseState>());
      expect(state.message, 'No profiles found');
      expect(state.activeFilters, {'gender': 'MALE'});
      expect(state.searchQuery, 'test');
    });
  });

  group('Profile Browse Error Type Tests', () {
    test('should provide user-friendly network error message', () {
      const errorType = ProfileBrowseErrorType.network;
      expect(
        errorType.userFriendlyMessage,
        'Network connection error. Please check your internet connection and try again.',
      );
    });

    test('should provide user-friendly authentication error message', () {
      const errorType = ProfileBrowseErrorType.authentication;
      expect(
        errorType.userFriendlyMessage,
        'Authentication error. Please log in again.',
      );
    });

    test('should provide user-friendly server error message', () {
      const errorType = ProfileBrowseErrorType.server;
      expect(
        errorType.userFriendlyMessage,
        'Server error. Please try again later.',
      );
    });

    test('should provide user-friendly unknown error message', () {
      const errorType = ProfileBrowseErrorType.unknown;
      expect(
        errorType.userFriendlyMessage,
        'An unexpected error occurred. Please try again.',
      );
    });
  });

  group('Profile Browse Success State Tests', () {
    test('should copy with new values', () {
      final profiles = [NikkahProfile(id: '1', name: 'John Doe')];

      final originalState = ProfileBrowseSuccess(
        profiles: profiles,
        currentPage: 1,
        totalPages: 2,
        hasMoreProfiles: true,
      );

      final newState = originalState.copyWith(
        currentPage: 2,
        hasMoreProfiles: false,
      );

      expect(newState.profiles, equals(profiles));
      expect(newState.currentPage, 2);
      expect(newState.totalPages, 2);
      expect(newState.hasMoreProfiles, false);
    });

    test('should maintain original values when copying without parameters', () {
      final profiles = [NikkahProfile(id: '1', name: 'John Doe')];

      final originalState = ProfileBrowseSuccess(
        profiles: profiles,
        currentPage: 1,
        totalPages: 2,
        hasMoreProfiles: true,
      );

      final newState = originalState.copyWith();

      expect(newState.profiles, equals(profiles));
      expect(newState.currentPage, 1);
      expect(newState.totalPages, 2);
      expect(newState.hasMoreProfiles, true);
    });
  });

  group('Profile Exception Tests', () {
    test('should create network exception', () {
      const exception = ProfileNetworkException(
        message: 'Network error',
        code: 'NETWORK_001',
      );

      expect(exception.message, 'Network error');
      expect(exception.code, 'NETWORK_001');
      expect(exception.toString(), 'ProfileNetworkException: Network error');
    });

    test('should create authentication exception', () {
      const exception = ProfileAuthenticationException(
        message: 'Auth failed',
        code: 'AUTH_001',
      );

      expect(exception.message, 'Auth failed');
      expect(exception.code, 'AUTH_001');
      expect(
          exception.toString(), 'ProfileAuthenticationException: Auth failed');
    });

    test('should create server exception with status code', () {
      const exception = ProfileServerException(
        message: 'Server error',
        statusCode: 500,
        code: 'SERVER_001',
      );

      expect(exception.message, 'Server error');
      expect(exception.statusCode, 500);
      expect(exception.code, 'SERVER_001');
      expect(exception.toString(), 'ProfileServerException(500): Server error');
    });

    test('should create validation exception with errors', () {
      const exception = ProfileValidationException(
        message: 'Validation failed',
        validationErrors: {'field': 'Required'},
        code: 'VALID_001',
      );

      expect(exception.message, 'Validation failed');
      expect(exception.validationErrors, {'field': 'Required'});
      expect(exception.code, 'VALID_001');
      expect(
        exception.toString(),
        'ProfileValidationException: Validation failed - Errors: {field: Required}',
      );
    });

    test('should create rate limit exception with retry after', () {
      const exception = ProfileRateLimitException(
        message: 'Rate limited',
        retryAfter: Duration(seconds: 60),
        code: 'RATE_001',
      );

      expect(exception.message, 'Rate limited');
      expect(exception.retryAfter, const Duration(seconds: 60));
      expect(exception.code, 'RATE_001');
      expect(
        exception.toString(),
        'ProfileRateLimitException: Rate limited (Retry after: 0:01:00.000000)',
      );
    });
  });
}
