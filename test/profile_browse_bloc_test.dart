import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:nikkah_io/business/profile_browse_bloc.dart';
import 'package:nikkah_io/models/nikkah_profile.dart';
import 'package:nikkah_io/models/profile_browse_state.dart';
import 'package:nikkah_io/repositories/profile_repository.dart';
import 'package:nikkah_io/exceptions/profile_exceptions.dart';

// Generate mocks
@GenerateMocks([ProfileRepository])
import 'profile_browse_bloc_test.mocks.dart';

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

        await bloc.applyFilters(filters);
        expect(bloc.activeFilters, equals(filters));
      });

      test('should clear filters when requested', () async {
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

        when(mockRepository.listProfiles(
          page: 1,
          limit: 10,
          name: null,
          gender: null,
          city: null,
          education: null,
          sect: null,
        )).thenAnswer((_) async => mockResponse);

        await bloc.applyFilters(filters);
        await bloc.clearFilters();
        expect(bloc.activeFilters, isNull);
      });
    });

    group('Profile Loading', () {
      test('should load profiles successfully', () async {
        final mockProfiles = [
          NikkahProfile(id: '1', name: 'John Doe'),
          NikkahProfile(id: '2', name: 'Jane Smith'),
        ];

        final mockResponse = ListNikkahProfilesResponse(
          profiles: mockProfiles,
          totalCount: 2,
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

        await bloc.loadProfiles();

        expect(bloc.state, isA<ProfileBrowseSuccess>());
        expect(bloc.profiles, hasLength(2));
        expect(bloc.profiles.first.name, 'John Doe');
        expect(bloc.profiles.last.name, 'Jane Smith');
      });

      test('should handle pagination state correctly', () async {
        final profiles = [NikkahProfile(id: '1', name: 'John Doe')];
        final response = ListNikkahProfilesResponse(
          profiles: profiles,
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
        )).thenAnswer((_) async => response);

        await bloc.loadProfiles();

        expect(bloc.profiles, hasLength(1));
        expect(bloc.currentPage, 1);
        expect(bloc.totalPages, 1);
        expect(bloc.hasMoreProfiles, false);
      });

      test('should not load more profiles when no more available', () async {
        final profiles = [NikkahProfile(id: '1', name: 'John Doe')];
        final response = ListNikkahProfilesResponse(
          profiles: profiles,
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
        )).thenAnswer((_) async => response);

        await bloc.loadProfiles();
        await bloc.loadMoreProfiles();

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

    group('Profile Liking', () {
      test('should like profile successfully', () async {
        final targetProfile = NikkahProfile(id: 'target', name: 'Target User');
        final selfProfile = NikkahProfile(id: 'self', name: 'Current User');

        when(mockRepository.getSelfProfile()).thenAnswer((_) async => selfProfile);
        when(mockRepository.likeProfile('self', 'target')).thenAnswer((_) async {});

        await bloc.likeProfile(targetProfile);

        verify(mockRepository.getSelfProfile()).called(1);
        verify(mockRepository.likeProfile('self', 'target')).called(1);
      });

      test('should handle like profile error', () async {
        final targetProfile = NikkahProfile(id: 'target', name: 'Target User');

        when(mockRepository.getSelfProfile()).thenThrow(
          const ProfileNetworkException(message: 'Failed to get self profile'),
        );

        expect(
          () => bloc.likeProfile(targetProfile),
          throwsA(isA<ProfileException>()),
        );
      });
    });

    group('Error Handling', () {
      test('should handle network exceptions', () async {
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

        await bloc.loadProfiles();

        expect(bloc.errorType, ProfileBrowseErrorType.network);
        expect(bloc.hasError, true);
      });

      test('should handle server exceptions', () async {
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

        await bloc.loadProfiles();

        expect(bloc.errorType, ProfileBrowseErrorType.server);
        expect(bloc.hasError, true);
      });

      test('should handle authentication exceptions', () async {
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

        await bloc.loadProfiles();

        expect(bloc.errorType, ProfileBrowseErrorType.authentication);
        expect(bloc.hasError, true);
      });
    });

    group('State Properties', () {
      test('should return correct search query', () {
        bloc.searchProfiles('test query');
        expect(bloc.searchQuery, 'test query');
      });

      test('should return correct active filters', () async {
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

        await bloc.applyFilters(filters);
        expect(bloc.activeFilters, equals(filters));
      });

      test('should return correct loading states', () async {
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

        final future = bloc.loadProfiles();

        expect(bloc.isLoading, true);
        expect(bloc.isLoadingMore, false);

        await future;

        expect(bloc.isLoading, false);
        expect(bloc.isLoadingMore, false);
      });
    });
  });
} 