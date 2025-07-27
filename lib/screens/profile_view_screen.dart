import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  // Form controllers for editing
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedGender = 'GENDER_UNSPECIFIED';
  int _selectedYear = DateTime.now().year - 25;
  String _selectedMonth = 'JANUARY';
  int _selectedDay = 1;

  final List<int> _years =
      List.generate(50, (index) => DateTime.now().year - 18 - index);
  final List<String> _months = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER'
  ];
  final List<int> _days = List.generate(31, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch profile data from API
      final response = await ProfileService.getSelfNikkahProfile();

      // Extract profile data from API response
      final profileData = response['profile'] ?? response;

      // Calculate age from birth date
      final birthDate = profileData['birth_date'] ?? profileData['birthDate'];
      final birthYear = birthDate['year'] as int;
      final age = DateTime.now().year - birthYear;

      // Format profile data for display
      final formattedProfileData = {
        'name': profileData['name'] as String,
        'gender': profileData['gender'] as String,
        'birthDate': {
          'year': birthDate['year'] as int,
          'month': birthDate['month'] as String,
          'day': birthDate['day'] as int,
        },
        'age': age,
        'profileId':
            profileData['profile_id'] ?? profileData['profileId'] ?? 'N/A',
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 30)), // This would come from API
      };

      setState(() {
        _profileData = formattedProfileData;
        _isLoading = false;

        // Initialize form controllers with current data
        _nameController.text = formattedProfileData['name'] as String;
        _selectedGender = formattedProfileData['gender'] as String;
        _selectedYear = formattedProfileData['birthDate']['year'] as int;
        _selectedMonth = formattedProfileData['birthDate']['month'] as String;
        _selectedDay = formattedProfileData['birthDate']['day'] as int;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Build the updated profile data
      final updatedData = ProfileService.buildNikkahProfileData(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        birthYear: _selectedYear,
        birthMonth: _selectedMonth,
        birthDay: _selectedDay,
      );

      // Call the API to update the profile
      await ProfileService.updateSelfNikkahProfile(updatedData);

      // Reload profile data to get the updated information
      await _loadProfile();

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // Reset form to original values
      _nameController.text = _profileData?['name'] ?? '';
      _selectedGender = _profileData?['gender'] ?? 'GENDER_UNSPECIFIED';
      _selectedYear =
          _profileData?['birthDate']?['year'] ?? DateTime.now().year - 25;
      _selectedMonth = _profileData?['birthDate']?['month'] ?? 'JANUARY';
      _selectedDay = _profileData?['birthDate']?['day'] ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          if (!_isEditing && _profileData != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _startEditing,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: _isLoading
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
                    'Loading profile...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
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
                        onPressed: _loadProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (_profileData == null) {
      return const Center(
        child: Text(
          'No profile data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Profile Information
            _buildProfileInformation(),
            const SizedBox(height: 24),

            // Action Buttons
            if (_isEditing) _buildEditActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              _profileData!['name'].substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profileData!['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_profileData!['age']} years old',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _profileData!['gender'] == 'MALE' ? 'Male' : 'Female',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 16),

        // Name Field
        _buildInfoCard(
          title: 'Full Name',
          content: _isEditing
              ? TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your full name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                )
              : Text(
                  _profileData!['name'],
                  style: const TextStyle(fontSize: 16),
                ),
        ),

        const SizedBox(height: 16),

        // Gender Field
        _buildInfoCard(
          title: 'Gender',
          content: _isEditing
              ? DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select your gender',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'MALE',
                      child: Text('Male'),
                    ),
                    DropdownMenuItem(
                      value: 'FEMALE',
                      child: Text('Female'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value == 'GENDER_UNSPECIFIED') {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                )
              : Text(
                  _profileData!['gender'] == 'MALE' ? 'Male' : 'Female',
                  style: const TextStyle(fontSize: 16),
                ),
        ),

        const SizedBox(height: 16),

        // Birth Date Field
        _buildInfoCard(
          title: 'Birth Date',
          content: _isEditing
              ? Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Year',
                        ),
                        items: _years.map((year) {
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMonth,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Month',
                        ),
                        items: _months.map((month) {
                          return DropdownMenuItem(
                            value: month,
                            child: Text(month.substring(0, 3)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMonth = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedDay,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Day',
                        ),
                        items: _days.map((day) {
                          return DropdownMenuItem(
                            value: day,
                            child: Text(day.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDay = value!;
                          });
                        },
                      ),
                    ),
                  ],
                )
              : Text(
                  '${_profileData!['birthDate']['day']} ${_profileData!['birthDate']['month']} ${_profileData!['birthDate']['year']}',
                  style: const TextStyle(fontSize: 16),
                ),
        ),

        const SizedBox(height: 16),

        // Profile ID
        _buildInfoCard(
          title: 'Profile ID',
          content: Text(
            _profileData!['profileId'],
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'monospace',
              color: Colors.grey,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Member Since
        _buildInfoCard(
          title: 'Member Since',
          content: Text(
            _formatDate(_profileData!['createdAt']),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildEditActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelEditing,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
