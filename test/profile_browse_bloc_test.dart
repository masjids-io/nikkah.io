import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/business/profile_browse_bloc.dart';
import 'package:nikkah_io/models/nikkah_profile.dart';
import 'package:nikkah_io/models/profile_browse_state.dart';
import 'package:nikkah_io/repositories/profile_repository.dart';
import 'package:nikkah_io/exceptions/profile_exceptions.dart';

// Simple mock implementation for testing
class MockProfileRepository implements ProfileRepository {
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
    // Default implementation - can be overridden in tests
    return ListNikkahProfilesResponse(
      profiles: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 1,
    );
  }

  @override
  Future<NikkahProfile> getSelfProfile() async {
    return NikkahProfile(id: 'self', name: 'Current User');
  }

  @override
  Future<NikkahProfile> getProfile(String profileId) async {
    return NikkahProfile(id: profileId, name: 'Test User');
  }

  @override
  Future<void> likeProfile(String likerProfileId, String likedProfileId) async {
    // Default implementation
  }

  @override
  Future<NikkahProfile> createProfile(Map<String, dynamic> profileData) async {
    return NikkahProfile(id: 'new', name: 'New User');
  }

  @override
  Future<NikkahProfile> updateProfile(String profileId, Map<String, dynamic> profileData) async {
    return NikkahProfile(id: profileId, name: 'Updated User');
  }
}

void main() {
  group('ProfileBrowseBloc Tests', () {
    late MockProfileRepository mockRepository;
    late ProfileBrowseBloc bloc;

    setUp(() {
      mockRepository = MockProfileRepository();
      bloc = ProfileBrowseBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.dispose();
    });

    group('Initial State', () {
      test('should have initial state', () {
        expect(bloc.state, isA<ProfileBrowseInitial>());
        expect(bloc.isLoading, false);
        expect(bloc.hasError, false);
        expect(bloc.profiles, isEmpty);
      });
    });

    group('Basic Functionality', () {
      test('should handle search query updates', () {
        bloc.searchProfiles('test query');
        expect(bloc.searchQuery, 'test query');
      });

      test('should handle filter application', () async {
        final filters = {'gender': 'MALE'};
        await bloc.applyFilters(filters);
        expect(bloc.activeFilters, equals(filters));
      });

      test('should clear filters when requested', () async {
        final filters = {'gender': 'MALE'};
        await bloc.applyFilters(filters);
        await bloc.clearFilters();
        expect(bloc.activeFilters, isNull);
      });
    });

      test('should emit error state when repository throws exception', () async {
        // Arrange
        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenThrow(const ProfileNetworkException(
          message: 'Network error',
        ));

        // Act
        await bloc.loadProfiles();

        // Assert
        expect(bloc.state, isA<ProfileBrowseError>());
        expect(bloc.hasError, true);
        expect(bloc.errorType, ProfileBrowseErrorType.network);
        expect(bloc.isLoading, false);
      });

      test('should emit empty state when no profiles are returned', () async {
        // Arrange
        final mockResponse = ListNikkahProfilesResponse(
          profiles: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 1,
        );

        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenAnswer((_) async => mockResponse);

        // Act
        await bloc.loadProfiles();

        // Assert
        expect(bloc.state, isA<ProfileBrowseEmpty>());
        expect(bloc.profiles, isEmpty);
        expect(bloc.isLoading, false);
        expect(bloc.hasError, false);
      });
    });

    group('Search Profiles', () {
      test('should debounce search requests', () async {
        // Arrange
        final mockResponse = ListNikkahProfilesResponse(
          profiles: [NikkahProfile(id: '1', name: 'John Doe')],
          totalCount: 1,
          currentPage: 1,
          totalPages: 1,
        );

        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: 'John',
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenAnswer((_) async => mockResponse);

        // Act
        bloc.searchProfiles('J');
        bloc.searchProfiles('Jo');
        bloc.searchProfiles('Joh');
        bloc.searchProfiles('John');

        // Wait for debounce timer
        await Future.delayed(const Duration(milliseconds: 600));

        // Assert
        verify(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: 'John',
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).called(1);
      });

      test('should perform immediate search when requested', () async {
        // Arrange
        final mockResponse = ListNikkahProfilesResponse(
          profiles: [NikkahProfile(id: '1', name: 'John Doe')],
          totalCount: 1,
          currentPage: 1,
          totalPages: 1,
        );

        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: 'John',
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenAnswer((_) async => mockResponse);

        // Act
        bloc.searchProfiles('John');
        await bloc.performImmediateSearch();

        // Assert
        verify(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: 'John',
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).called(1);
      });
    });

    group('Apply Filters', () {
      test('should apply filters and reload profiles', () async {
        // Arrange
        final filters = {
          'gender': 'MALE',
          'location': 'New York',
          'education': 'BACHELORS',
          'sect': 'SUNNI',
        };

        final mockResponse = ListNikkahProfilesResponse(
          profiles: [NikkahProfile(id: '1', name: 'John Doe')],
          totalCount: 1,
          currentPage: 1,
          totalPages: 1,
        );

        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: 'MALE',
          city: 'New York',
          education: 'BACHELORS',
          sect: 'SUNNI',
        )).thenAnswer((_) async => mockResponse);

        // Act
        await bloc.applyFilters(filters);

        // Assert
        expect(bloc.activeFilters, equals(filters));
        expect(bloc.state, isA<ProfileBrowseSuccess>());
        expect(bloc.profiles, hasLength(1));
      });

      test('should clear filters when requested', () async {
        // Arrange
        final filters = {'gender': 'MALE'};
        final mockResponse = ListNikkahProfilesResponse(
          profiles: [NikkahProfile(id: '1', name: 'John Doe')],
          totalCount: 1,
          currentPage: 1,
          totalPages: 1,
        );

        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenAnswer((_) async => mockResponse);

        // Act
        await bloc.applyFilters(filters);
        await bloc.clearFilters();

        // Assert
        expect(bloc.activeFilters, isNull);
        expect(bloc.state, isA<ProfileBrowseSuccess>());
      });
    });

    group('Load More Profiles', () {
      test('should load more profiles when pagination is available', () async {
        // Arrange - First page
        final firstPageResponse = ListNikkahProfilesResponse(
          profiles: [NikkahProfile(id: '1', name: 'John Doe')],
          totalCount: 2,
          currentPage: 1,
          totalPages: 2,
        );

        final secondPageResponse = ListNikkahProfilesResponse(
          profiles: [NikkahProfile(id: '2', name: 'Jane Smith')],
          totalCount: 2,
          currentPage: 2,
          totalPages: 2,
        );

        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenAnswer((_) async => firstPageResponse);

        when(mockRepository.listProfiles(
          page: 2,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenAnswer((_) async => secondPageResponse);

        // Act
        await bloc.loadProfiles();
        await bloc.loadMoreProfiles();

        // Assert
        expect(bloc.profiles, hasLength(2));
        expect(bloc.currentPage, 2);
        expect(bloc.totalPages, 2);
        expect(bloc.hasMoreProfiles, false);
      });

      test('should not load more when no more profiles available', () async {
        // Arrange
        final mockResponse = ListNikkahProfilesResponse(
          profiles: [NikkahProfile(id: '1', name: 'John Doe')],
          totalCount: 1,
          currentPage: 1,
          totalPages: 1,
        );

        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenAnswer((_) async => mockResponse);

        // Act
        await bloc.loadProfiles();
        await bloc.loadMoreProfiles();

        // Assert
        expect(bloc.profiles, hasLength(1));
        expect(bloc.hasMoreProfiles, false);
        verifyNever(mockRepository.listProfiles(
          page: 2,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        ));
      });
    });

    group('Like Profile', () {
      test('should like profile successfully', () async {
        // Arrange
        final selfProfile = NikkahProfile(id: 'self', name: 'Current User');
        final targetProfile = NikkahProfile(id: 'target', name: 'Target User');

        when(mockRepository.getSelfProfile())
            .thenAnswer((_) async => selfProfile);
        when(mockRepository.likeProfile('self', 'target'))
            .thenAnswer((_) async {});

        // Act
        await bloc.likeProfile(targetProfile);

        // Assert
        verify(mockRepository.getSelfProfile()).called(1);
        verify(mockRepository.likeProfile('self', 'target')).called(1);
      });

      test('should throw validation exception when profile ID is null', () async {
        // Arrange
        final targetProfile = NikkahProfile(id: null, name: 'Target User');

        // Act & Assert
        expect(
          () => bloc.likeProfile(targetProfile),
          throwsA(isA<ProfileValidationException>()),
        );
      });

      test('should handle authentication exception', () async {
        // Arrange
        final targetProfile = NikkahProfile(id: 'target', name: 'Target User');

        when(mockRepository.getSelfProfile())
            .thenThrow(const ProfileAuthenticationException(
          message: 'Authentication failed',
        ));

        // Act & Assert
        expect(
          () => bloc.likeProfile(targetProfile),
          throwsA(isA<ProfileAuthenticationException>()),
        );
      });
    });

    group('Error Handling', () {
      test('should handle network exceptions', () async {
        // Arrange
        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenThrow(const ProfileNetworkException(
          message: 'Network error',
        ));

        // Act
        await bloc.loadProfiles();

        // Assert
        expect(bloc.errorType, ProfileBrowseErrorType.network);
        expect(bloc.hasError, true);
      });

      test('should handle server exceptions', () async {
        // Arrange
        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenThrow(const ProfileServerException(
          message: 'Server error',
          statusCode: 500,
        ));

        // Act
        await bloc.loadProfiles();

        // Assert
        expect(bloc.errorType, ProfileBrowseErrorType.server);
        expect(bloc.hasError, true);
      });

      test('should handle authentication exceptions', () async {
        // Arrange
        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenThrow(const ProfileAuthenticationException(
          message: 'Authentication failed',
        ));

        // Act
        await bloc.loadProfiles();

        // Assert
        expect(bloc.errorType, ProfileBrowseErrorType.authentication);
        expect(bloc.hasError, true);
      });
    });

    group('State Properties', () {
      test('should return correct search query', () {
        // Act
        bloc.searchProfiles('test query');

        // Assert
        expect(bloc.searchQuery, 'test query');
      });

      test('should return correct active filters', () async {
        // Arrange
        final filters = {'gender': 'MALE'};
        final mockResponse = ListNikkahProfilesResponse(
          profiles: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 1,
        );

        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: 'MALE',
          city: null,
          education: null,
          sect: null,
        )).thenAnswer((_) async => mockResponse);

        // Act
        await bloc.applyFilters(filters);

        // Assert
        expect(bloc.activeFilters, equals(filters));
      });

      test('should return correct loading states', () async {
        // Arrange
        final mockResponse = ListNikkahProfilesResponse(
          profiles: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 1,
        );

        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return mockResponse;
        });

        // Act
        final future = bloc.loadProfiles();

        // Assert - Should be loading initially
        expect(bloc.isLoading, true);
        expect(bloc.isLoadingMore, false);

        // Wait for completion
        await future;

        // Assert - Should not be loading after completion
        expect(bloc.isLoading, false);
        expect(bloc.isLoadingMore, false);
      });
    });
  });
} 