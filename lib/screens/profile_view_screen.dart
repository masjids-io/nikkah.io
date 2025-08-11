import 'package:flutter/material.dart';
import '../models/nikkah_profile.dart';
import '../services/profile_service.dart';

class ProfileViewScreen extends StatefulWidget {
  final NikkahProfile profile;

  const ProfileViewScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.profile.name ?? 'Profile',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildBasicInfo(),
                  const SizedBox(height: 24),
                  _buildLocationInfo(),
                  const SizedBox(height: 24),
                  _buildEducationAndOccupation(),
                  const SizedBox(height: 24),
                  _buildPhysicalInfo(),
                  const SizedBox(height: 24),
                  _buildReligiousInfo(),
                  const SizedBox(height: 24),
                  _buildHobbies(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF2E7D32),
            child: Text(
              (widget.profile.name?.isNotEmpty == true)
                  ? widget.profile.name![0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name and Age
          Text(
            widget.profile.name ?? 'Name not specified',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Age and Gender
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.profile.age != null) ...[
                Text(
                  '${widget.profile.age} years old',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
              ],
              Text(
                _getGenderDisplay(widget.profile.gender),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.person,
      children: [
        _buildInfoRow('Name', widget.profile.name ?? 'Not specified'),
        if (widget.profile.birthDate != null) ...[
          _buildInfoRow(
              'Birth Date', _formatBirthDate(widget.profile.birthDate!)),
        ],
      ],
    );
  }

  Widget _buildLocationInfo() {
    final location = widget.profile.location;
    if (location == null) return const SizedBox.shrink();

    return _buildSection(
      title: 'Location',
      icon: Icons.location_on,
      children: [
        if (location.city?.isNotEmpty == true)
          _buildInfoRow('City', location.city!),
        if (location.state?.isNotEmpty == true)
          _buildInfoRow('State', location.state!),
        if (location.country?.isNotEmpty == true)
          _buildInfoRow('Country', location.country!),
        if (location.zipCode?.isNotEmpty == true)
          _buildInfoRow('ZIP Code', location.zipCode!),
      ],
    );
  }

  Widget _buildEducationAndOccupation() {
    return _buildSection(
      title: 'Education & Occupation',
      icon: Icons.school,
      children: [
        _buildInfoRow(
            'Education', _getEducationDisplay(widget.profile.education)),
        _buildInfoRow(
            'Occupation', widget.profile.occupation ?? 'Not specified'),
      ],
    );
  }

  Widget _buildPhysicalInfo() {
    return _buildSection(
      title: 'Physical Information',
      icon: Icons.height,
      children: [
        _buildInfoRow(
            'Height', widget.profile.height?.displayHeight ?? 'Not specified'),
      ],
    );
  }

  Widget _buildReligiousInfo() {
    return _buildSection(
      title: 'Religious Information',
      icon: Icons.mosque,
      children: [
        _buildInfoRow('Sect', _getSectDisplay(widget.profile.sect)),
      ],
    );
  }

  Widget _buildHobbies() {
    final hobbies = widget.profile.hobbies;
    if (hobbies == null || hobbies.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: 'Hobbies & Interests',
      icon: Icons.favorite,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: hobbies
              .map((hobby) => Chip(
                    label: Text(_getHobbyDisplay(hobby)),
                    backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                    labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _likeProfile,
            icon: const Icon(Icons.favorite, color: Colors.white),
            label: const Text(
              'Like Profile',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _startChat,
            icon: const Icon(Icons.chat, color: Color(0xFF2E7D32)),
            label: const Text(
              'Start Chat',
              style: TextStyle(color: Color(0xFF2E7D32), fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2E7D32)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGenderDisplay(String? gender) {
    switch (gender) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      default:
        return 'Not specified';
    }
  }

  String _formatBirthDate(BirthDate birthDate) {
    final monthNames = [
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

    final month = birthDate.month ?? 'MONTH_UNSPECIFIED';
    final monthIndex = _getMonthIndex(month);
    final monthName = monthIndex >= 0 ? monthNames[monthIndex] : month;

    return '${monthName} ${birthDate.day}, ${birthDate.year}';
  }

  int _getMonthIndex(String month) {
    const months = [
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
    return months.indexOf(month);
  }

  String _getEducationDisplay(String? education) {
    switch (education) {
      case 'HIGH_SCHOOL':
        return 'High School';
      case 'BACHELOR':
        return 'Bachelor\'s Degree';
      case 'MASTER':
        return 'Master\'s Degree';
      case 'DOCTORATE':
        return 'Doctorate';
      default:
        return 'Not specified';
    }
  }

  String _getSectDisplay(String? sect) {
    switch (sect) {
      case 'SUNNI':
        return 'Sunni';
      case 'SUNNI_HANAFI':
        return 'Sunni (Hanafi)';
      case 'SUNNI_MALEKI':
        return 'Sunni (Maliki)';
      case 'SUNNI_SHAFII':
        return 'Sunni (Shafi\'i)';
      case 'SHIA':
        return 'Shia';
      case 'OTHER':
        return 'Other';
      default:
        return 'Not specified';
    }
  }

  String _getHobbyDisplay(String hobby) {
    switch (hobby) {
      case 'READING':
        return 'Reading';
      case 'WATCHING_MOVIES':
        return 'Watching Movies';
      case 'WATCHING_TV':
        return 'Watching TV';
      case 'PAINTING':
        return 'Painting';
      case 'WRITING':
        return 'Writing';
      case 'VOLUNTEERING':
        return 'Volunteering';
      case 'VOLLEYBALL':
        return 'Volleyball';
      case 'TRAVELING':
        return 'Traveling';
      case 'GAMING':
        return 'Gaming';
      case 'MARTIAL_ARTS':
        return 'Martial Arts';
      case 'SOCCER':
        return 'Soccer';
      case 'BASKETBALL':
        return 'Basketball';
      case 'FOOTBALL':
        return 'Football';
      case 'TENNIS':
        return 'Tennis';
      case 'BADMINTON':
        return 'Badminton';
      case 'CRICKET':
        return 'Cricket';
      default:
        return hobby;
    }
  }

  Future<void> _likeProfile() async {
    setState(() {
      _isLoading = true;
    });

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
        'likedProfileId': widget.profile.id,
      };

      final response = await ProfileService.initiateNikkahLike(likeData);

      if (response.code == '200' || response.status == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You liked ${widget.profile.name}\'s profile!'),
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startChat() {
    // Navigate back to the previous screen with chat data
    Navigator.of(context).pop({
      'action': 'start_chat',
      'profile': widget.profile,
    });
  }
}
