import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedGender = 'GENDER_UNSPECIFIED';
  int _selectedYear = DateTime.now().year - 25; // Default to 25 years old
  String _selectedMonth = 'JANUARY';
  int _selectedDay = 1;

  bool _isLoading = false;
  int _currentStep = 0;

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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate gender selection
    if (_selectedGender == 'GENDER_UNSPECIFIED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate age requirement (must be at least 18)
    final birthDate = DateTime(
        _selectedYear, _months.indexOf(_selectedMonth) + 1, _selectedDay);
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;

    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be at least 18 years old to use Nikkah.io'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Build profile data
      final profileData = ProfileService.buildNikkahProfileData(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        birthYear: _selectedYear,
        birthMonth: _selectedMonth,
        birthDay: _selectedDay,
      );

      // Call the CreateNikkahProfile API
      await ProfileService.createNikkahProfile(profileData);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile created successfully! Welcome to Nikkah.io'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildStepItem('Basic Info', 0),
          _buildStepConnector(),
          _buildStepItem('Gender', 1),
          _buildStepConnector(),
          _buildStepItem('Birth Date', 2),
        ],
      ),
    );
  }

  Widget _buildStepItem(String title, int step) {
    final isActive = _currentStep >= step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive ? const Color(0xFF2E7D32) : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      height: 2,
      width: 20,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tell us about yourself',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Let\'s start with your basic information',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(
                color: Color(0xFF4CAF50),
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenderStep() {
    return Column(
      children: [
        const Text(
          'What is your gender?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'This helps us match you with compatible profiles',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedGender == 'MALE'
                  ? const Color(0xFF4CAF50)
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _selectedGender == 'MALE'
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : Colors.transparent,
          ),
          child: RadioListTile<String>(
            title: const Text(
              'Male',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            value: 'MALE',
            groupValue: _selectedGender,
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
            activeColor: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedGender == 'FEMALE'
                  ? const Color(0xFF4CAF50)
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _selectedGender == 'FEMALE'
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : Colors.transparent,
          ),
          child: RadioListTile<String>(
            title: const Text(
              'Female',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            value: 'FEMALE',
            groupValue: _selectedGender,
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
            activeColor: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthDateStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'When were you born?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us ensure you meet our age requirements',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
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
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Month',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                  ),
                  items: _months.asMap().entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.value.substring(0, 3)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'Day',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
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
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You must be at least 18 years old to use Nikkah.io',
                    style: TextStyle(
                      color: const Color(0xFF4CAF50),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildGenderStep();
      case 2:
        return _buildBirthDateStep();
      default:
        return _buildBasicInfoStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF2E7D32),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _currentStep == 0
                          ? () => Navigator.of(context).pop()
                          : _previousStep,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Create Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Step Indicator
              _buildStepIndicator(),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildCurrentStep(),
                          ),
                          const SizedBox(height: 32),

                          // Navigation Buttons
                          Row(
                            children: [
                              if (_currentStep > 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _previousStep,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      side: const BorderSide(
                                          color: Color(0xFF4CAF50)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Previous',
                                      style: TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_currentStep > 0) const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : (_currentStep < 2
                                          ? _nextStep
                                          : _createProfile),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Text(
                                          _currentStep < 2
                                              ? 'Next'
                                              : 'Create Profile',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
