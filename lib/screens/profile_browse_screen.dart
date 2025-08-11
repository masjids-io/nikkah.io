import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../models/nikkah_profile.dart';

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
  List<NikkahProfile> _profiles = [];
  int _currentPage = 1;
  int _totalPages = 1;
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
          _currentPage = 1;
          _hasMoreProfiles = true;
        });
      } else {
        setState(() {
          _isLoadingMore = true;
        });
      }

      _errorMessage = null;

      // Build query parameters based on filters
      final queryParams = <String, dynamic>{
        'page': refresh ? 1 : _currentPage + 1,
        'limit': 10,
      };

      // Add search term if provided
      if (_searchController.text.isNotEmpty) {
        queryParams['name'] = _searchController.text;
      }

      // Add filters if provided
      if (_currentFilters != null) {
        if (_currentFilters!['gender'] != null &&
            _currentFilters!['gender'] != 'ALL') {
          queryParams['gender'] = _currentFilters!['gender'];
        }
        if (_currentFilters!['location'] != null &&
            _currentFilters!['location'].isNotEmpty) {
          queryParams['location.city'] = _currentFilters!['location'];
        }
        if (_currentFilters!['education'] != null &&
            _currentFilters!['education'] != 'ALL') {
          queryParams['education'] = _currentFilters!['education'];
        }
        if (_currentFilters!['sect'] != null &&
            _currentFilters!['sect'] != 'ALL') {
          queryParams['sect'] = _currentFilters!['sect'];
        }
      }

      // Call the API to get profiles
      final response = await ProfileService.listNikkahProfiles(
        start: queryParams['start'],
        limit: queryParams['limit'],
        page: queryParams['page'],
        name: queryParams['name'],
        gender: queryParams['gender'],
        city: queryParams['location.city'],
        education: queryParams['education'],
        sect: queryParams['sect'],
      );

      final profiles = response.listProfilesResponse?.profiles ?? [];
      final totalPages = response.listProfilesResponse?.totalPages ?? 1;
      final currentPage = response.listProfilesResponse?.currentPage ?? 1;

      setState(() {
        if (refresh) {
          _profiles = profiles;
        } else {
          _profiles.addAll(profiles);
        }
        _currentPage = currentPage;
        _totalPages = totalPages;
        _hasMoreProfiles = currentPage < totalPages;
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

  void _viewProfile(NikkahProfile profile) {
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
              subtitle: Text('See ${profile.name}\'s full profile'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  '/profile-view',
                  arguments: profile,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Color(0xFF2E7D32)),
              title: const Text('Like Profile'),
              subtitle: Text('Show interest in ${profile.name}'),
              onTap: () {
                Navigator.of(context).pop();
                _likeProfile(profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF2E7D32)),
              title: const Text('Start Chat'),
              subtitle: Text('Begin chatting with ${profile.name}'),
              onTap: () {
                Navigator.of(context).pop();
                if (widget.onStartChat != null) {
                  widget.onStartChat!({
                    'id': profile.id ??
                        'user-${DateTime.now().millisecondsSinceEpoch}',
                    'name': profile.name ?? 'Unknown',
                    'age': profile.age ?? 0,
                    'location': profile.location?.displayLocation ?? 'Unknown',
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _likeProfile(NikkahProfile profile) async {
    try {
      // Get current user's profile first
      final selfProfileResponse = await ProfileService.getSelfNikkahProfile();
      final selfProfile = selfProfileResponse.nikkahProfile;

      if (selfProfile == null) {
        throw Exception('Unable to get your profile');
      }

      // Create like data
      final likeData = {
        'likerProfileId': selfProfile.id,
        'likedProfileId': profile.id,
      };

      final response = await ProfileService.initiateNikkahLike(likeData);

      if (response.code == '200' || response.status == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You liked ${profile.name}\'s profile!'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      } else {
        throw Exception(response.message ?? 'Failed to like profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      if (_currentFilters!['gender'] != null &&
          _currentFilters!['gender'] != 'ALL') {
        activeFilters.add(_currentFilters!['gender']);
      }
      if (_currentFilters!['location'] != null &&
          _currentFilters!['location'].isNotEmpty) {
        activeFilters.add('Location: ${_currentFilters!['location']}');
      }
      if (_currentFilters!['education'] != null &&
          _currentFilters!['education'] != 'ALL') {
        activeFilters.add('Education: ${_currentFilters!['education']}');
      }
      if (_currentFilters!['sect'] != null &&
          _currentFilters!['sect'] != 'ALL') {
        activeFilters.add('Sect: ${_currentFilters!['sect']}');
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
                      '$ageText • ${gender == 'MALE' ? 'Male' : 'Female'}',
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
