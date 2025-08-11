import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../business/profile_browse_bloc.dart';
import '../models/nikkah_profile.dart';
import '../models/profile_browse_state.dart';
import '../repositories/profile_repository.dart';
import '../widgets/profile_browse_widgets.dart';
import '../exceptions/profile_exceptions.dart';

/// Refactored Profile Browse Screen with proper architecture
class ProfileBrowseScreenRefactored extends StatefulWidget {
  final Function(Map<String, dynamic>)? onStartChat;
  final bool hasActiveChat;

  const ProfileBrowseScreenRefactored({
    super.key,
    this.onStartChat,
    this.hasActiveChat = false,
  });

  @override
  State<ProfileBrowseScreenRefactored> createState() =>
      _ProfileBrowseScreenRefactoredState();
}

class _ProfileBrowseScreenRefactoredState
    extends State<ProfileBrowseScreenRefactored> {
  late final ProfileBrowseBloc _bloc;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize BLoC with repository
    final repository = ProfileRepositoryImpl();
    _bloc = ProfileBrowseBloc(repository: repository);

    // Load initial profiles
    _bloc.loadProfiles();

    // Listen to BLoC changes
    _bloc.addListener(_onBlocStateChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _bloc.removeListener(_onBlocStateChanged);
    _bloc.dispose();
    super.dispose();
  }

  void _onBlocStateChanged() {
    // Handle state changes if needed
    if (_bloc.hasError) {
      _showErrorSnackBar(_bloc.errorMessage ?? 'An error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_bloc.activeFilters != null) _buildActiveFilters(),
          Expanded(
            child: ListenableBuilder(
              listenable: _bloc,
              builder: (context, child) {
                return _buildContent();
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Browse Profiles',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _openFilters,
          tooltip: 'Filter Profiles',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search profiles...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _bloc.searchProfiles,
              onSubmitted: (_) => _bloc.performImmediateSearch(),
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _bloc.performImmediateSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    final activeFilters = <String>[];

    if (_bloc.activeFilters != null) {
      final filters = _bloc.activeFilters!;

      if (filters['gender'] != null && filters['gender'] != 'ALL') {
        activeFilters.add(filters['gender']);
      }
      if (filters['location'] != null &&
          filters['location'].toString().isNotEmpty) {
        activeFilters.add('Location: ${filters['location']}');
      }
      if (filters['education'] != null && filters['education'] != 'ALL') {
        activeFilters.add('Education: ${filters['education']}');
      }
      if (filters['sect'] != null && filters['sect'] != 'ALL') {
        activeFilters.add('Sect: ${filters['sect']}');
      }
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ...activeFilters.map((filter) => Chip(
                label: Text(filter),
                backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
                deleteIcon:
                    const Icon(Icons.close, size: 16, color: Color(0xFF2E7D32)),
                onDeleted: _bloc.clearFilters,
              )),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final strategy = ProfileDisplayStrategyFactory.createStrategy(
      _bloc.state,
      onRetry: _handleRetry,
      onClearFilters: _handleClearFilters,
      onLoadMore: _handleLoadMore,
      onRefresh: _handleRefresh,
      onProfileTap: _handleProfileTap,
    );

    return strategy.build(context);
  }

  Future<void> _openFilters() async {
    try {
      final result = await Navigator.of(context).pushNamed('/filters');
      if (result != null && result is Map<String, dynamic>) {
        await _bloc.applyFilters(result);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open filters: ${e.toString()}');
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _bloc.clearSearch();
    _searchFocusNode.unfocus();
  }

  Future<void> _handleRetry() async {
    try {
      await _bloc.loadProfiles();
    } catch (e) {
      _showErrorSnackBar('Failed to retry: ${e.toString()}');
    }
  }

  Future<void> _handleClearFilters() async {
    try {
      await _bloc.clearFilters();
    } catch (e) {
      _showErrorSnackBar('Failed to clear filters: ${e.toString()}');
    }
  }

  Future<void> _handleLoadMore() async {
    try {
      await _bloc.loadMoreProfiles();
    } catch (e) {
      _showErrorSnackBar('Failed to load more profiles: ${e.toString()}');
    }
  }

  Future<void> _handleRefresh() async {
    try {
      await _bloc.refresh();
    } catch (e) {
      _showErrorSnackBar('Failed to refresh: ${e.toString()}');
    }
  }

  void _handleProfileTap(NikkahProfile profile) {
    // Check if there's an active chat
    if (widget.hasActiveChat) {
      _showWarningSnackBar(
          'Please end your current chat before viewing other profiles');
      return;
    }

    _showProfileOptions(profile);
  }

  void _showProfileOptions(NikkahProfile profile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2E7D32)),
              title: const Text('View Profile'),
              subtitle:
                  Text('See ${profile.name ?? 'Unknown'}\'s full profile'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToProfileView(profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Color(0xFF2E7D32)),
              title: const Text('Like Profile'),
              subtitle: Text('Show interest in ${profile.name ?? 'Unknown'}'),
              onTap: () {
                Navigator.of(context).pop();
                _likeProfile(profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF2E7D32)),
              title: const Text('Start Chat'),
              subtitle:
                  Text('Begin chatting with ${profile.name ?? 'Unknown'}'),
              onTap: () {
                Navigator.of(context).pop();
                _startChat(profile);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProfileView(NikkahProfile profile) {
    try {
      Navigator.of(context).pushNamed(
        '/profile-view',
        arguments: profile,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to open profile: ${e.toString()}');
    }
  }

  Future<void> _likeProfile(NikkahProfile profile) async {
    try {
      await _bloc.likeProfile(profile);
      _showSuccessSnackBar(
          'You liked ${profile.name ?? 'Unknown'}\'s profile!');
    } on ProfileAuthenticationException {
      _showErrorSnackBar('Please log in again to like profiles');
    } on ProfileValidationException catch (e) {
      _showErrorSnackBar('Validation error: ${e.message}');
    } on ProfileNetworkException {
      _showErrorSnackBar('Network error. Please check your connection.');
    } on ProfileServerException catch (e) {
      _showErrorSnackBar('Server error: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('Failed to like profile: ${e.toString()}');
    }
  }

  void _startChat(NikkahProfile profile) {
    try {
      if (widget.onStartChat != null) {
        widget.onStartChat!({
          'id': profile.id ?? 'user-${DateTime.now().millisecondsSinceEpoch}',
          'name': profile.name ?? 'Unknown',
          'age': profile.age ?? 0,
          'location': profile.location?.displayLocation ?? 'Unknown',
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to start chat: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
