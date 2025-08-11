import 'package:flutter/material.dart';
import '../models/nikkah_profile.dart';
import '../models/profile_browse_state.dart';

/// Strategy interface for different profile display states
abstract class ProfileDisplayStrategy {
  Widget build(BuildContext context);
}

/// Strategy for loading state
class LoadingDisplayStrategy implements ProfileDisplayStrategy {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading profiles...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Strategy for error state
class ErrorDisplayStrategy implements ProfileDisplayStrategy {
  final String message;
  final ProfileBrowseErrorType errorType;
  final VoidCallback onRetry;

  const ErrorDisplayStrategy({
    required this.message,
    required this.errorType,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getErrorIcon(),
            size: 64,
            color: _getErrorColor(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorType.userFriendlyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: _getErrorColor(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (errorType) {
      case ProfileBrowseErrorType.network:
        return Icons.wifi_off;
      case ProfileBrowseErrorType.authentication:
        return Icons.lock_outline;
      case ProfileBrowseErrorType.server:
        return Icons.error_outline;
      case ProfileBrowseErrorType.unknown:
        return Icons.help_outline;
    }
  }

  Color _getErrorColor() {
    switch (errorType) {
      case ProfileBrowseErrorType.network:
        return Colors.orange;
      case ProfileBrowseErrorType.authentication:
        return Colors.red;
      case ProfileBrowseErrorType.server:
        return Colors.red;
      case ProfileBrowseErrorType.unknown:
        return Colors.grey;
    }
  }
}

/// Strategy for empty state
class EmptyDisplayStrategy implements ProfileDisplayStrategy {
  final String message;
  final Map<String, dynamic>? activeFilters;
  final String? searchQuery;
  final VoidCallback onClearFilters;

  const EmptyDisplayStrategy({
    required this.message,
    this.activeFilters,
    this.searchQuery,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getSubtitle(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onClearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  String _getSubtitle() {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return 'Try adjusting your search terms';
    } else if (_hasActiveFilters()) {
      return 'Try adjusting your filters';
    } else {
      return 'Check back later for new profiles';
    }
  }

  bool _hasActiveFilters() {
    return activeFilters != null && activeFilters!.isNotEmpty;
  }
}

/// Strategy for success state with profiles list
class SuccessDisplayStrategy implements ProfileDisplayStrategy {
  final List<NikkahProfile> profiles;
  final bool hasMoreProfiles;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final VoidCallback onRefresh;
  final Function(NikkahProfile) onProfileTap;

  const SuccessDisplayStrategy({
    required this.profiles,
    required this.hasMoreProfiles,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onRefresh,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: profiles.length + (hasMoreProfiles ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == profiles.length) {
            return _buildLoadMoreButton();
          }
          return _buildProfileCard(profiles[index]);
        },
      ),
    );
  }

  Widget _buildProfileCard(NikkahProfile profile) {
    final name = profile.name ?? 'Unknown';
    final gender = profile.gender ?? 'GENDER_UNSPECIFIED';
    final age = profile.age;
    final ageText = age != null ? '$age years old' : 'Age not specified';
    final location =
        profile.location?.displayLocation ?? 'Location not specified';
    final education = profile.education ?? 'Education not specified';
    final occupation = profile.occupation ?? 'Occupation not specified';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onProfileTap(profile),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF2E7D32),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$ageText • ${_formatGender(gender)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$education • $occupation',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // View Button
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios,
                    color: Color(0xFF2E7D32)),
                onPressed: () => onProfileTap(profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (!hasMoreProfiles) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoadingMore
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              )
            : ElevatedButton(
                onPressed: onLoadMore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Load More'),
              ),
      ),
    );
  }

  String _formatGender(String gender) {
    switch (gender) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      default:
        return 'Not specified';
    }
  }
}

/// Factory for creating display strategies
class ProfileDisplayStrategyFactory {
  static ProfileDisplayStrategy createStrategy(
    ProfileBrowseState state, {
    required VoidCallback onRetry,
    required VoidCallback onClearFilters,
    required VoidCallback onLoadMore,
    required VoidCallback onRefresh,
    required Function(NikkahProfile) onProfileTap,
  }) {
    if (state is ProfileBrowseLoading) {
      return LoadingDisplayStrategy();
    } else if (state is ProfileBrowseError) {
      return ErrorDisplayStrategy(
        message: state.message,
        errorType: state.errorType,
        onRetry: onRetry,
      );
    } else if (state is ProfileBrowseEmpty) {
      return EmptyDisplayStrategy(
        message: state.message,
        activeFilters: state.activeFilters,
        searchQuery: state.searchQuery,
        onClearFilters: onClearFilters,
      );
    } else if (state is ProfileBrowseSuccess) {
      return SuccessDisplayStrategy(
        profiles: state.profiles,
        hasMoreProfiles: state.hasMoreProfiles,
        isLoadingMore: false, // This should be passed from BLoC
        onLoadMore: onLoadMore,
        onRefresh: onRefresh,
        onProfileTap: onProfileTap,
      );
    } else {
      return LoadingDisplayStrategy();
    }
  }
}
