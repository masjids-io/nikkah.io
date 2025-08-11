import 'package:flutter/foundation.dart';
import 'nikkah_profile.dart';

/// Represents the different states of the profile browse screen
@immutable
abstract class ProfileBrowseState {
  const ProfileBrowseState();
}

/// Initial state when the screen is first loaded
class ProfileBrowseInitial extends ProfileBrowseState {
  const ProfileBrowseInitial();
}

/// Loading state when fetching profiles
class ProfileBrowseLoading extends ProfileBrowseState {
  const ProfileBrowseLoading();
}

/// Loading more profiles state (pagination)
class ProfileBrowseLoadingMore extends ProfileBrowseState {
  const ProfileBrowseLoadingMore();
}

/// Success state with loaded profiles
class ProfileBrowseSuccess extends ProfileBrowseState {
  final List<NikkahProfile> profiles;
  final int currentPage;
  final int totalPages;
  final bool hasMoreProfiles;
  final Map<String, dynamic>? activeFilters;
  final String? searchQuery;

  const ProfileBrowseSuccess({
    required this.profiles,
    required this.currentPage,
    required this.totalPages,
    required this.hasMoreProfiles,
    this.activeFilters,
    this.searchQuery,
  });

  ProfileBrowseSuccess copyWith({
    List<NikkahProfile>? profiles,
    int? currentPage,
    int? totalPages,
    bool? hasMoreProfiles,
    Map<String, dynamic>? activeFilters,
    String? searchQuery,
  }) {
    return ProfileBrowseSuccess(
      profiles: profiles ?? this.profiles,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMoreProfiles: hasMoreProfiles ?? this.hasMoreProfiles,
      activeFilters: activeFilters ?? this.activeFilters,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileBrowseSuccess &&
        listEquals(other.profiles, profiles) &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.hasMoreProfiles == hasMoreProfiles &&
        mapEquals(other.activeFilters, activeFilters) &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(profiles),
      currentPage,
      totalPages,
      hasMoreProfiles,
      activeFilters != null ? Object.hashAll(activeFilters!.entries) : null,
      searchQuery,
    );
  }
}

/// Error state with specific error information
class ProfileBrowseError extends ProfileBrowseState {
  final String message;
  final ProfileBrowseErrorType errorType;
  final ProfileBrowseState? previousState;

  const ProfileBrowseError({
    required this.message,
    required this.errorType,
    this.previousState,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileBrowseError &&
        other.message == message &&
        other.errorType == errorType;
  }

  @override
  int get hashCode => Object.hash(message, errorType);
}

/// Empty state when no profiles are found
class ProfileBrowseEmpty extends ProfileBrowseState {
  final String message;
  final Map<String, dynamic>? activeFilters;
  final String? searchQuery;

  const ProfileBrowseEmpty({
    this.message = 'No profiles found',
    this.activeFilters,
    this.searchQuery,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileBrowseEmpty &&
        other.message == message &&
        mapEquals(other.activeFilters, activeFilters) &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode => Object.hash(message, activeFilters != null ? Object.hashAll(activeFilters!.entries) : null, searchQuery);
}

/// Enum for different types of errors
enum ProfileBrowseErrorType {
  network,
  authentication,
  server,
  unknown,
}

/// Extension to provide user-friendly error messages
extension ProfileBrowseErrorTypeExtension on ProfileBrowseErrorType {
  String get userFriendlyMessage {
    switch (this) {
      case ProfileBrowseErrorType.network:
        return 'Network connection error. Please check your internet connection and try again.';
      case ProfileBrowseErrorType.authentication:
        return 'Authentication error. Please log in again.';
      case ProfileBrowseErrorType.server:
        return 'Server error. Please try again later.';
      case ProfileBrowseErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
} 