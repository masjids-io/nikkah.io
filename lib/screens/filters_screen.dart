import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  // Filter state variables
  String _selectedGender = 'ALL';
  String _selectedAgeRange = 'ALL';
  String _selectedSortBy = 'RECENT';
  RangeValues _ageRange = const RangeValues(18, 50);
  bool _showOnlineOnly = false;
  bool _showWithPhotos = false;
  bool _showVerifiedOnly = false;

  // Filter options
  final List<String> _genderOptions = ['ALL', 'MALE', 'FEMALE'];
  final List<String> _ageRangeOptions = [
    'ALL',
    '18-25',
    '26-35',
    '36-45',
    '46+',
  ];
  final List<String> _sortOptions = [
    'RECENT',
    'NAME',
    'AGE',
    'DISTANCE',
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
                    child: Text(gender == 'ALL' ? 'All Genders' : gender),
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

            // Age Range Filter
            _buildFilterCard(
              title: 'Age Range',
              subtitle: 'Show profiles between ages',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RangeSlider(
                    values: _ageRange,
                    min: 18,
                    max: 70,
                    divisions: 52,
                    activeColor: const Color(0xFF2E7D32),
                    inactiveColor: Colors.grey.shade300,
                    labels: RangeLabels(
                      _ageRange.start.round().toString(),
                      _ageRange.end.round().toString(),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _ageRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_ageRange.start.round()} years',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        '${_ageRange.end.round()} years',
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
            const SizedBox(height: 16),

            // Sort By Filter
            _buildFilterCard(
              title: 'Sort By',
              subtitle: 'Order profiles by',
              child: DropdownButtonFormField<String>(
                value: _selectedSortBy,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _sortOptions.map((sort) {
                  return DropdownMenuItem(
                    value: sort,
                    child: Text(_getSortDisplayName(sort)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSortBy = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Additional Filters Section
            _buildSectionHeader('Additional Filters'),
            const SizedBox(height: 16),

            // Online Only Filter
            _buildSwitchCard(
              title: 'Online Only',
              subtitle: 'Show only profiles that are currently online',
              value: _showOnlineOnly,
              onChanged: (value) {
                setState(() {
                  _showOnlineOnly = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // With Photos Filter
            _buildSwitchCard(
              title: 'With Photos',
              subtitle: 'Show only profiles with photos',
              value: _showWithPhotos,
              onChanged: (value) {
                setState(() {
                  _showWithPhotos = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // Verified Only Filter
            _buildSwitchCard(
              title: 'Verified Only',
              subtitle: 'Show only verified profiles',
              value: _showVerifiedOnly,
              onChanged: (value) {
                setState(() {
                  _showVerifiedOnly = value;
                });
              },
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

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
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
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF2E7D32),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortDisplayName(String sort) {
    switch (sort) {
      case 'RECENT':
        return 'Most Recent';
      case 'NAME':
        return 'Name (A-Z)';
      case 'AGE':
        return 'Age (Youngest First)';
      case 'DISTANCE':
        return 'Distance (Nearest First)';
      default:
        return sort;
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedGender = 'ALL';
      _selectedAgeRange = 'ALL';
      _selectedSortBy = 'RECENT';
      _ageRange = const RangeValues(18, 50);
      _showOnlineOnly = false;
      _showWithPhotos = false;
      _showVerifiedOnly = false;
    });
  }

  void _clearFilters() {
    _resetFilters();
    _applyFilters();
  }

  void _applyFilters() {
    // In a real app, this would pass the filter data back to the browse screen
    // For now, we'll just show a success message and go back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied successfully!'),
        backgroundColor: Color(0xFF2E7D32),
        duration: Duration(seconds: 2),
      ),
    );

    // Return to previous screen with filter data
    Navigator.of(context).pop({
      'gender': _selectedGender,
      'ageRange': _ageRange,
      'sortBy': _selectedSortBy,
      'onlineOnly': _showOnlineOnly,
      'withPhotos': _showWithPhotos,
      'verifiedOnly': _showVerifiedOnly,
    });
  }
}
