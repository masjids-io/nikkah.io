import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileBrowseScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onStartChat;
  final bool hasActiveChat;

  const ProfileBrowseScreen({
    super.key,
    this.onStartChat,
    this.hasActiveChat = false,
  });

  @override
  State<ProfileBrowseScreen> createState() => _ProfileBrowseScreenState();
}

class _ProfileBrowseScreenState extends State<ProfileBrowseScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _profiles = [];
  String? _nextPageToken;
  bool _hasMoreProfiles = true;

  // Search controller
  final _searchController = TextEditingController();

  // Filter state
  Map<String, dynamic>? _currentFilters;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles({bool refresh = false}) async {
    try {
      if (refresh) {
        setState(() {
          _isLoading = true;
          _profiles = [];
          _nextPageToken = null;
          _hasMoreProfiles = true;
        });
      } else {
        setState(() {
          _isLoadingMore = true;
        });
      }

      _errorMessage = null;

      // Call the API to get profiles
      final response = await ProfileService.listNikkahProfiles(
        pageSize: 10,
        pageToken: refresh ? null : _nextPageToken,
      );

      final profiles = response['profiles'] as List<dynamic>? ?? [];
      final nextPageToken = response['next_page_token'] as String?;

      setState(() {
        if (refresh) {
          _profiles = profiles.cast<Map<String, dynamic>>();
        } else {
          _profiles.addAll(profiles.cast<Map<String, dynamic>>());
        }
        _nextPageToken = nextPageToken;
        _hasMoreProfiles = nextPageToken != null;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profiles: ${e.toString()}';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _searchProfiles() async {
    // In a real app, this would call a search API
    // For now, we'll just reload profiles
    await _loadProfiles(refresh: true);
  }

  Future<void> _openFilters() async {
    final result = await Navigator.of(context).pushNamed('/filters');
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _currentFilters = result;
      });
      // Apply the filters by reloading profiles
      await _loadProfiles(refresh: true);
    }
  }

  void _viewProfile(Map<String, dynamic> profile) {
    // Check if there's an active chat
    if (widget.hasActiveChat) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please end your current chat before viewing other profiles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show profile view options
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
              subtitle: Text('See ${profile['name']}\'s full profile'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Viewing ${profile['name']}\'s profile'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF2E7D32)),
              title: const Text('Start Chat'),
              subtitle: Text('Begin chatting with ${profile['name']}'),
              onTap: () {
                Navigator.of(context).pop();
                if (widget.onStartChat != null) {
                  widget.onStartChat!({
                    'name': profile['name'] ?? 'Unknown',
                    'age': profile['age'] ?? 0,
                    'location': profile['location'] ?? 'Unknown',
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Active Filters Display
          if (_currentFilters != null) _buildActiveFilters(),

          // Profiles List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
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
                  )
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _profiles.isEmpty
                        ? _buildEmptyState()
                        : _buildProfilesList(),
          ),
        ],
      ),
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
              decoration: const InputDecoration(
                hintText: 'Search profiles...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF2E7D32)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _searchProfiles(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _searchProfiles,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Search',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    final activeFilters = <String>[];

    if (_currentFilters != null) {
      if (_currentFilters!['gender'] != 'ALL') {
        activeFilters.add(_currentFilters!['gender']);
      }
      if (_currentFilters!['onlineOnly'] == true) {
        activeFilters.add('Online Only');
      }
      if (_currentFilters!['withPhotos'] == true) {
        activeFilters.add('With Photos');
      }
      if (_currentFilters!['verifiedOnly'] == true) {
        activeFilters.add('Verified Only');
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
                onDeleted: () {
                  setState(() {
                    _currentFilters = null;
                  });
                  _loadProfiles(refresh: true);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadProfiles(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
          const Text(
            'No profiles found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentFilters = null;
              });
              _loadProfiles(refresh: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilesList() {
    return RefreshIndicator(
      onRefresh: () => _loadProfiles(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _profiles.length + (_hasMoreProfiles ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _profiles.length) {
            return _buildLoadMoreButton();
          }
          return _buildProfileCard(_profiles[index]);
        },
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final name = profile['name'] as String? ?? 'Unknown';
    final gender = profile['gender'] as String? ?? 'UNSPECIFIED';
    final birthDate = profile['birth_date'] ?? profile['birthDate'];
    final age = birthDate != null
        ? DateTime.now().year - (birthDate['year'] as int)
        : 'Unknown';
    final profileId = profile['profile_id'] ?? profile['profileId'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewProfile(profile),
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
                      '$age years old • ${gender == 'MALE' ? 'Male' : 'Female'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: $profileId',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              // View Button
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios,
                    color: Color(0xFF2E7D32)),
                onPressed: () => _viewProfile(profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (!_hasMoreProfiles) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              )
            : ElevatedButton(
                onPressed: _loadProfiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                child: const Text('Load More'),
              ),
      ),
    );
  }
}
