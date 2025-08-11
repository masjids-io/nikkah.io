import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  // Filter state variables
  String _selectedGender = 'ALL';
  String _selectedEducation = 'ALL';
  String _selectedSect = 'ALL';
  String _location = '';
  String _occupation = '';
  RangeValues _heightRange = const RangeValues(150, 200);
  List<String> _selectedHobbies = [];

  // Filter options
  final List<String> _genderOptions = ['ALL', 'MALE', 'FEMALE'];
  final List<String> _educationOptions = [
    'ALL',
    'HIGH_SCHOOL',
    'BACHELOR',
    'MASTER',
    'DOCTORATE',
  ];
  final List<String> _sectOptions = [
    'ALL',
    'SUNNI',
    'SUNNI_HANAFI',
    'SUNNI_MALEKI',
    'SUNNI_SHAFII',
    'SHIA',
    'OTHER',
  ];
  final List<String> _hobbyOptions = [
    'READING',
    'WATCHING_MOVIES',
    'WATCHING_TV',
    'PAINTING',
    'WRITING',
    'VOLUNTEERING',
    'VOLLEYBALL',
    'TRAVELING',
    'GAMING',
    'MARTIAL_ARTS',
    'SOCCER',
    'BASKETBALL',
    'FOOTBALL',
    'TENNIS',
    'BADMINTON',
    'CRICKET',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filters',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Filters Section
            _buildSectionHeader('Basic Filters'),
            const SizedBox(height: 16),

            // Gender Filter
            _buildFilterCard(
              title: 'Gender',
              subtitle: 'Show profiles of',
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _genderOptions.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender == 'ALL'
                        ? 'All Genders'
                        : _getGenderDisplay(gender)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Location Filter
            _buildFilterCard(
              title: 'Location',
              subtitle: 'Search by city',
              child: TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter city name',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Education Filter
            _buildFilterCard(
              title: 'Education',
              subtitle: 'Show profiles with education level',
              child: DropdownButtonFormField<String>(
                value: _selectedEducation,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _educationOptions.map((education) {
                  return DropdownMenuItem(
                    value: education,
                    child: Text(education == 'ALL'
                        ? 'All Education Levels'
                        : _getEducationDisplay(education)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEducation = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Occupation Filter
            _buildFilterCard(
              title: 'Occupation',
              subtitle: 'Search by occupation',
              child: TextFormField(
                initialValue: _occupation,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter occupation',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {
                    _occupation = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Religious Filters Section
            _buildSectionHeader('Religious Filters'),
            const SizedBox(height: 16),

            // Sect Filter
            _buildFilterCard(
              title: 'Sect',
              subtitle: 'Show profiles of specific sect',
              child: DropdownButtonFormField<String>(
                value: _selectedSect,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _sectOptions.map((sect) {
                  return DropdownMenuItem(
                    value: sect,
                    child: Text(
                        sect == 'ALL' ? 'All Sects' : _getSectDisplay(sect)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSect = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Physical Filters Section
            _buildSectionHeader('Physical Filters'),
            const SizedBox(height: 16),

            // Height Range Filter
            _buildFilterCard(
              title: 'Height Range',
              subtitle: 'Show profiles within height range (cm)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RangeSlider(
                    values: _heightRange,
                    min: 140,
                    max: 220,
                    divisions: 80,
                    activeColor: const Color(0xFF2E7D32),
                    inactiveColor: Colors.grey.shade300,
                    labels: RangeLabels(
                      '${_heightRange.start.round()} cm',
                      '${_heightRange.end.round()} cm',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _heightRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_heightRange.start.round()} cm',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        '${_heightRange.end.round()} cm',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hobbies Section
            _buildSectionHeader('Hobbies & Interests'),
            const SizedBox(height: 16),

            _buildFilterCard(
              title: 'Hobbies',
              subtitle: 'Show profiles with specific hobbies',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _hobbyOptions.map((hobby) {
                      final isSelected = _selectedHobbies.contains(hobby);
                      return FilterChip(
                        label: Text(_getHobbyDisplay(hobby)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedHobbies.add(hobby);
                            } else {
                              _selectedHobbies.remove(hobby);
                            }
                          });
                        },
                        selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF2E7D32),
                      );
                    }).toList(),
                  ),
                  if (_selectedHobbies.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Selected: ${_selectedHobbies.map((h) => _getHobbyDisplay(h)).join(', ')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Apply Filters Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Clear Filters Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _clearFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Clear All Filters',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildFilterCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  String _getGenderDisplay(String gender) {
    switch (gender) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      default:
        return gender;
    }
  }

  String _getEducationDisplay(String education) {
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
        return education;
    }
  }

  String _getSectDisplay(String sect) {
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
        return sect;
    }
  }

  String _getHobbyDisplay(String hobby) {
    switch (hobby) {
      case 'READING':
        return 'Reading';
      case 'WATCHING_MOVIES':
        return 'Movies';
      case 'WATCHING_TV':
        return 'TV';
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

  void _resetFilters() {
    setState(() {
      _selectedGender = 'ALL';
      _selectedEducation = 'ALL';
      _selectedSect = 'ALL';
      _location = '';
      _occupation = '';
      _heightRange = const RangeValues(150, 200);
      _selectedHobbies = [];
    });
  }

  void _clearFilters() {
    _resetFilters();
    _applyFilters();
  }

  void _applyFilters() {
    // Build filter data based on API specification
    final filterData = <String, dynamic>{};

    if (_selectedGender != 'ALL') {
      filterData['gender'] = _selectedGender;
    }
    if (_location.isNotEmpty) {
      filterData['location'] = _location;
    }
    if (_selectedEducation != 'ALL') {
      filterData['education'] = _selectedEducation;
    }
    if (_occupation.isNotEmpty) {
      filterData['occupation'] = _occupation;
    }
    if (_selectedSect != 'ALL') {
      filterData['sect'] = _selectedSect;
    }
    if (_selectedHobbies.isNotEmpty) {
      filterData['hobbies'] = _selectedHobbies;
    }
    if (_heightRange.start > 150 || _heightRange.end < 200) {
      filterData['heightRange'] = _heightRange;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied successfully!'),
        backgroundColor: Color(0xFF2E7D32),
        duration: Duration(seconds: 2),
      ),
    );

    // Return to previous screen with filter data
    Navigator.of(context).pop(filterData);
  }
}
