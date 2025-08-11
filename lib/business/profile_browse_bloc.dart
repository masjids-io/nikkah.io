import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/profile_browse_state.dart';
import '../models/nikkah_profile.dart';
import '../repositories/profile_repository.dart';
import '../exceptions/profile_exceptions.dart';

/// Business Logic Component for Profile Browse functionality
class ProfileBrowseBloc extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileBrowseState _state = const ProfileBrowseInitial();
  ProfileBrowseState get state => _state;

  // Search and filter state
  String _searchQuery = '';
  Map<String, dynamic>? _activeFilters;
  Timer? _searchDebounceTimer;

  // Pagination state
  static const int _pageSize = 10;
  int _currentPage = 1;
  bool _hasMoreProfiles = true;

  ProfileBrowseBloc({required ProfileRepository repository})
      : _repository = repository;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  /// Load initial profiles
  Future<void> loadProfiles() async {
    if (_state is ProfileBrowseLoading) return;

    _setState(const ProfileBrowseLoading());
    _currentPage = 1;
    _hasMoreProfiles = true;

    await _fetchProfiles(refresh: true);
  }

  /// Load more profiles (pagination)
  Future<void> loadMoreProfiles() async {
    if (_state is ProfileBrowseLoadingMore || !_hasMoreProfiles) return;

    _setState(const ProfileBrowseLoadingMore());
    await _fetchProfiles(refresh: false);
  }

  /// Search profiles with debouncing
  void searchProfiles(String query) {
    _searchQuery = query.trim();

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Debounce search to avoid too many API calls
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  /// Perform immediate search without debouncing
  Future<void> performImmediateSearch() async {
    _searchDebounceTimer?.cancel();
    await _performSearch();
  }

  /// Apply filters and reload profiles
  Future<void> applyFilters(Map<String, dynamic> filters) async {
    _activeFilters = Map.from(filters);
    _currentPage = 1;
    _hasMoreProfiles = true;

    await _fetchProfiles(refresh: true);
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _activeFilters = null;
    _currentPage = 1;
    _hasMoreProfiles = true;

    await _fetchProfiles(refresh: true);
  }

  /// Clear search query
  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    _hasMoreProfiles = true;

    await _fetchProfiles(refresh: true);
  }

  /// Like a profile
  Future<void> likeProfile(NikkahProfile profile) async {
    try {
      // Get current user's profile first
      final selfProfile = await _repository.getSelfProfile();

      if (selfProfile.id == null) {
        throw const ProfileValidationException(
          message: 'Invalid user profile',
          validationErrors: {'profile': 'User profile ID is missing'},
        );
      }

      if (profile.id == null) {
        throw const ProfileValidationException(
          message: 'Invalid target profile',
          validationErrors: {'profile': 'Target profile ID is missing'},
        );
      }

      await _repository.likeProfile(selfProfile.id!, profile.id!);

      // Show success feedback (could be handled by UI layer)
      debugPrint('Successfully liked ${profile.name}\'s profile');
    } on ProfileException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      final error = _handleGenericError(e, 'Failed to like profile');
      _handleError(error);
      rethrow;
    }
  }

  /// Refresh profiles
  Future<void> refresh() async {
    _currentPage = 1;
    _hasMoreProfiles = true;
    await _fetchProfiles(refresh: true);
  }

  /// Get current search query
  String get searchQuery => _searchQuery;

  /// Get current active filters
  Map<String, dynamic>? get activeFilters => _activeFilters;

  /// Check if there are more profiles to load
  bool get hasMoreProfiles => _hasMoreProfiles;

  /// Check if currently loading
  bool get isLoading => _state is ProfileBrowseLoading;

  /// Check if loading more profiles
  bool get isLoadingMore => _state is ProfileBrowseLoadingMore;

  /// Check if there's an error
  bool get hasError => _state is ProfileBrowseError;

  /// Get error message if any
  String? get errorMessage {
    if (_state is ProfileBrowseError) {
      return (_state as ProfileBrowseError).message;
    }
    return null;
  }

  /// Get error type if any
  ProfileBrowseErrorType? get errorType {
    if (_state is ProfileBrowseError) {
      return (_state as ProfileBrowseError).errorType;
    }
    return null;
  }

  /// Get current profiles
  List<NikkahProfile> get profiles {
    if (_state is ProfileBrowseSuccess) {
      return (_state as ProfileBrowseSuccess).profiles;
    }
    return [];
  }

  /// Get current page
  int get currentPage {
    if (_state is ProfileBrowseSuccess) {
      return (_state as ProfileBrowseSuccess).currentPage;
    }
    return _currentPage;
  }

  /// Get total pages
  int get totalPages {
    if (_state is ProfileBrowseSuccess) {
      return (_state as ProfileBrowseSuccess).totalPages;
    }
    return 1;
  }

  /// Private method to perform search
  Future<void> _performSearch() async {
    _currentPage = 1;
    _hasMoreProfiles = true;
    await _fetchProfiles(refresh: true);
  }

  /// Private method to fetch profiles from repository
  Future<void> _fetchProfiles({required bool refresh}) async {
    try {
      final response = await _repository.listProfiles(
        page: refresh ? 1 : _currentPage + 1,
        limit: _pageSize,
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
        gender: _getFilterValue('gender'),
        city: _getFilterValue('location'),
        education: _getFilterValue('education'),
        sect: _getFilterValue('sect'),
      );

      final profiles = response.profiles ?? [];
      final totalPages = response.totalPages ?? 1;
      final currentPage = response.currentPage ?? 1;

      if (refresh) {
        _currentPage = currentPage;
        _hasMoreProfiles = currentPage < totalPages;

        if (profiles.isEmpty) {
          _setState(ProfileBrowseEmpty(
            message: _getEmptyStateMessage(),
            activeFilters: _activeFilters,
            searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          ));
        } else {
          _setState(ProfileBrowseSuccess(
            profiles: profiles,
            currentPage: currentPage,
            totalPages: totalPages,
            hasMoreProfiles: currentPage < totalPages,
            activeFilters: _activeFilters,
            searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          ));
        }
      } else {
        // Append to existing profiles
        if (_state is ProfileBrowseSuccess) {
          final currentState = _state as ProfileBrowseSuccess;
          final updatedProfiles = [...currentState.profiles, ...profiles];

          _currentPage = currentPage;
          _hasMoreProfiles = currentPage < totalPages;

          _setState(currentState.copyWith(
            profiles: updatedProfiles,
            currentPage: currentPage,
            totalPages: totalPages,
            hasMoreProfiles: currentPage < totalPages,
          ));
        }
      }
    } on ProfileException catch (e) {
      _handleError(e);
    } catch (e) {
      final error = _handleGenericError(e, 'Failed to load profiles');
      _handleError(error);
    }
  }

  /// Private method to get filter value
  String? _getFilterValue(String key) {
    if (_activeFilters == null) return null;

    final value = _activeFilters![key];
    if (value == null || value == 'ALL' || value.toString().isEmpty) {
      return null;
    }

    return value.toString();
  }

  /// Private method to get empty state message
  String _getEmptyStateMessage() {
    if (_searchQuery.isNotEmpty && _activeFilters != null) {
      return 'No profiles found matching your search and filters';
    } else if (_searchQuery.isNotEmpty) {
      return 'No profiles found matching "$_searchQuery"';
    } else if (_activeFilters != null) {
      return 'No profiles found with the selected filters';
    } else {
      return 'No profiles found';
    }
  }

  /// Private method to set state
  void _setState(ProfileBrowseState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Private method to handle errors
  void _handleError(ProfileException error) {
    ProfileBrowseErrorType errorType;

    if (error is ProfileNetworkException) {
      errorType = ProfileBrowseErrorType.network;
    } else if (error is ProfileAuthenticationException) {
      errorType = ProfileBrowseErrorType.authentication;
    } else if (error is ProfileServerException) {
      errorType = ProfileBrowseErrorType.server;
    } else {
      errorType = ProfileBrowseErrorType.unknown;
    }

    _setState(ProfileBrowseError(
      message: error.message,
      errorType: errorType,
      previousState: _state,
    ));
  }

  /// Private method to handle generic errors
  ProfileException _handleGenericError(dynamic error, String context) {
    if (error is ProfileException) {
      return error;
    } else {
      return ProfileServerException(
        message: '$context: ${error.toString()}',
        statusCode: 0,
        originalError: error,
      );
    }
  }
}
