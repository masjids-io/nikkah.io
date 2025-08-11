import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_localizations.dart';
import '../utils/validation_result.dart';
import '../utils/accessibility_helper.dart';

/// Improved register screen with better UX patterns
/// Demonstrates enhanced validation, accessibility, and user feedback
class RegisterScreenImproved extends StatefulWidget {
  const RegisterScreenImproved({super.key});

  @override
  State<RegisterScreenImproved> createState() => _RegisterScreenImprovedState();
}

class _RegisterScreenImprovedState extends State<RegisterScreenImproved> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // State management for better UX
  bool _isLoading = false;
  bool _isValidating = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedGender = 'GENDER_UNSPECIFIED';

  // Validation states for real-time feedback
  FieldValidationState _emailValidationState = FieldValidationState.clean();
  FieldValidationState _usernameValidationState = FieldValidationState.clean();
  FieldValidationState _passwordValidationState = FieldValidationState.clean();
  FieldValidationState _confirmPasswordValidationState =
      FieldValidationState.clean();

  // Focus nodes for accessibility
  final _emailFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupValidationListeners();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();

    _emailFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  /// Setup real-time validation listeners
  void _setupValidationListeners() {
    _emailController.addListener(() {
      _validateEmailRealTime();
    });

    _usernameController.addListener(() {
      _validateUsernameRealTime();
    });

    _passwordController.addListener(() {
      _validatePasswordRealTime();
      _validateConfirmPasswordRealTime();
    });

    _confirmPasswordController.addListener(() {
      _validateConfirmPasswordRealTime();
    });
  }

  /// Real-time email validation with debouncing
  Future<void> _validateEmailRealTime() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailValidationState = FieldValidationState.clean();
      });
      return;
    }

    setState(() {
      _emailValidationState = FieldValidationState.loading();
    });

    // Debounce validation
    await Future.delayed(const Duration(milliseconds: 500));

    if (_emailController.text.isEmpty) return;

    final result = _validateEmail(_emailController.text);
    setState(() {
      _emailValidationState = FieldValidationState.validated(result);
    });
  }

  /// Real-time username validation with async availability check
  Future<void> _validateUsernameRealTime() async {
    if (_usernameController.text.isEmpty) {
      setState(() {
        _usernameValidationState = FieldValidationState.clean();
      });
      return;
    }

    setState(() {
      _usernameValidationState = FieldValidationState.loading();
    });

    // Debounce validation
    await Future.delayed(const Duration(milliseconds: 500));

    if (_usernameController.text.isEmpty) return;

    // First validate format
    final formatResult = _validateUsername(_usernameController.text);
    if (!formatResult.isValid) {
      setState(() {
        _usernameValidationState = FieldValidationState.validated(formatResult);
      });
      return;
    }

    // Then check availability (simulated)
    setState(() {
      _isValidating = true;
    });

    try {
      await Future.delayed(
          const Duration(milliseconds: 1000)); // Simulate API call

      // Simulate some usernames being taken
      final takenUsernames = ['john', 'jane', 'admin', 'test'];
      if (takenUsernames.contains(_usernameController.text.toLowerCase())) {
        final availabilityResult = ValidationResult.error(
          'Username "${_usernameController.text}" is already taken',
          suggestion: 'Try adding numbers or different characters',
        );
        setState(() {
          _usernameValidationState =
              FieldValidationState.validated(availabilityResult);
        });
      } else {
        final successResult = ValidationResult.success(
          message: 'Username "${_usernameController.text}" is available!',
        );
        setState(() {
          _usernameValidationState =
              FieldValidationState.validated(successResult);
        });
      }
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  /// Real-time password validation with strength indicator
  void _validatePasswordRealTime() {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordValidationState = FieldValidationState.clean();
      });
      return;
    }

    final result = _validatePassword(_passwordController.text);
    setState(() {
      _passwordValidationState = FieldValidationState.validated(result);
    });
  }

  /// Real-time confirm password validation
  void _validateConfirmPasswordRealTime() {
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordValidationState = FieldValidationState.clean();
      });
      return;
    }

    final result = _validatePasswordConfirmation(
      _passwordController.text,
      _confirmPasswordController.text,
    );
    setState(() {
      _confirmPasswordValidationState = FieldValidationState.validated(result);
    });
  }

  /// Enhanced email validation
  ValidationResult _validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult.error(
        AppLocalizations.emailRequired,
        suggestion: 'Enter the email address you use regularly',
      );
    }

    email = email.trim().toLowerCase();

    if (email.length > 254) {
      return ValidationResult.error(
        AppLocalizations.emailTooLong,
        suggestion: 'Try using a shorter email address',
      );
    }

    final emailPattern =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      return ValidationResult.error(
        AppLocalizations.emailInvalid,
        suggestion:
            'Make sure to include @ and a valid domain (e.g., .com, .org)',
      );
    }

    // Check for common email injection patterns
    if (email.contains('<') || email.contains('>') || email.contains('"')) {
      return ValidationResult.error(
        AppLocalizations.emailInvalidCharacters,
        suggestion: 'Remove any special characters like <, >, or "',
      );
    }

    return ValidationResult.success(message: 'Email address looks good!');
  }

  /// Enhanced username validation
  ValidationResult _validateUsername(String username) {
    if (username.isEmpty) {
      return ValidationResult.error(
        AppLocalizations.usernameRequired,
        suggestion: 'Choose a unique username that represents you',
      );
    }

    username = username.trim();

    if (username.length < 3) {
      return ValidationResult.error(
        AppLocalizations.usernameTooShort,
        suggestion: 'Add more characters to make it at least 3 letters long',
      );
    }

    if (username.length > 30) {
      return ValidationResult.error(
        AppLocalizations.usernameTooLong,
        suggestion: 'Shorten your username to 30 characters or less',
      );
    }

    final usernamePattern = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernamePattern.hasMatch(username)) {
      return ValidationResult.error(
        AppLocalizations.usernameInvalidCharacters,
        suggestion: 'Use only letters, numbers, and underscores',
      );
    }

    // Check for reserved usernames
    const reservedUsernames = [
      'admin',
      'root',
      'system',
      'nikkah',
      'api',
      'www',
      'mail',
      'ftp',
      'localhost',
      'test',
      'guest',
      'anonymous',
      'null',
      'undefined'
    ];

    if (reservedUsernames.contains(username.toLowerCase())) {
      return ValidationResult.error(
        AppLocalizations.usernameReserved,
        suggestion:
            'Try adding numbers or different characters to make it unique',
      );
    }

    return ValidationResult.success(message: 'Username format is valid!');
  }

  /// Enhanced password validation
  ValidationResult _validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult.error(
        AppLocalizations.passwordRequired,
        suggestion: 'Create a strong password to protect your account',
      );
    }

    if (password.length < 8) {
      return ValidationResult.error(
        AppLocalizations.passwordTooShort,
        suggestion: 'Add more characters to make it at least 8 letters long',
      );
    }

    if (password.length > 128) {
      return ValidationResult.error(
        AppLocalizations.passwordTooLong,
        suggestion: 'Use a shorter password that you can remember easily',
      );
    }

    // Check for common weak passwords
    const weakPasswords = [
      'password',
      '123456',
      'qwerty',
      'admin',
      'letmein',
      'welcome',
      'monkey',
      'dragon',
      'master',
      'hello',
      'freedom',
      'whatever'
    ];

    if (weakPasswords.contains(password.toLowerCase())) {
      return ValidationResult.error(
        AppLocalizations.passwordWeak,
        suggestion:
            'Avoid common words. Try mixing letters, numbers, and symbols',
      );
    }

    // Check for password complexity
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));

    if (!hasUppercase || !hasLowercase || !hasDigits) {
      return ValidationResult.error(
        AppLocalizations.passwordComplexity,
        suggestion:
            'Include uppercase letters (A-Z), lowercase letters (a-z), and numbers (0-9)',
      );
    }

    return ValidationResult.success(
        message: 'Password meets security requirements!');
  }

  /// Enhanced password confirmation validation
  ValidationResult _validatePasswordConfirmation(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return ValidationResult.error(
        'Please confirm your password',
        suggestion: 'Re-enter your password to make sure it\'s correct',
      );
    }

    if (password != confirmPassword) {
      return ValidationResult.error(
        AppLocalizations.passwordMismatch,
        suggestion: 'Make sure both passwords are exactly the same',
      );
    }

    return ValidationResult.success(message: 'Passwords match!');
  }

  /// Get password strength indicator
  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length contribution
    strength += (password.length / 20.0).clamp(0.0, 0.3);

    // Character variety contribution
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    return strength.clamp(0.0, 1.0);
  }

  /// Get password strength description
  String _getPasswordStrengthDescription(String password) {
    final strength = _getPasswordStrength(password);

    if (strength < 0.3) return 'Weak';
    if (strength < 0.6) return 'Fair';
    if (strength < 0.8) return 'Good';
    return 'Strong';
  }

  /// Get password strength color
  Color _getPasswordStrengthColor(String password) {
    final strength = _getPasswordStrength(password);

    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.yellow;
    return Colors.green;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = AuthService.createUser(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
      );

      final result = await AuthService.register(userData);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/profile-creation');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Registration successful! Now let\'s create your profile'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Try Again',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _register();
              },
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Join Nikkah.io',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your account to start your journey',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Name Fields
              Row(
                children: [
                  Expanded(
                    child: AccessibilityHelper.createAccessibleFormField(
                      label: AppLocalizations.firstNameLabel,
                      controller: _firstNameController,
                      hint: AppLocalizations.firstNameHint,
                      isRequired: true,
                      prefixIcon:
                          const Icon(Icons.person, color: Color(0xFF4CAF50)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.nameRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AccessibilityHelper.createAccessibleFormField(
                      label: AppLocalizations.lastNameLabel,
                      controller: _lastNameController,
                      hint: AppLocalizations.lastNameHint,
                      isRequired: true,
                      prefixIcon:
                          const Icon(Icons.person, color: Color(0xFF4CAF50)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.nameRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Email Field with real-time validation
              AccessibilityHelper.createAccessibleFormField(
                label: AppLocalizations.emailLabel,
                controller: _emailController,
                hint: AppLocalizations.emailHint,
                helpText: AppLocalizations.emailHelp,
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                focusNode: _emailFocusNode,
                prefixIcon: const Icon(Icons.email, color: Color(0xFF4CAF50)),
                validator: (value) {
                  final result = _validateEmail(value ?? '');
                  return result.isValid ? null : result.message;
                },
              ),
              if (_emailValidationState.shouldShowFeedback) ...[
                const SizedBox(height: 8),
                _buildValidationFeedback(_emailValidationState),
              ],
              const SizedBox(height: 20),

              // Username Field with real-time validation
              AccessibilityHelper.createAccessibleFormField(
                label: AppLocalizations.usernameLabel,
                controller: _usernameController,
                hint: AppLocalizations.usernameHint,
                helpText: AppLocalizations.usernameHelp,
                isRequired: true,
                textInputAction: TextInputAction.next,
                focusNode: _usernameFocusNode,
                prefixIcon:
                    const Icon(Icons.account_circle, color: Color(0xFF4CAF50)),
                validator: (value) {
                  final result = _validateUsername(value ?? '');
                  return result.isValid ? null : result.message;
                },
              ),
              if (_usernameValidationState.shouldShowFeedback) ...[
                const SizedBox(height: 8),
                _buildValidationFeedback(_usernameValidationState),
              ],
              const SizedBox(height: 20),

              // Phone Field (optional)
              AccessibilityHelper.createAccessibleFormField(
                label: AppLocalizations.phoneLabel,
                controller: _phoneController,
                hint: AppLocalizations.phoneHint,
                helpText: AppLocalizations.phoneHelp,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF4CAF50)),
                validator: (value) => null, // Phone is optional
              ),
              const SizedBox(height: 20),

              // Password Field with strength indicator
              AccessibilityHelper.createAccessibleFormField(
                label: AppLocalizations.passwordLabel,
                controller: _passwordController,
                hint: AppLocalizations.passwordHint,
                helpText: AppLocalizations.passwordHelp,
                isRequired: true,
                isPassword: true,
                obscureText: _obscurePassword,
                onTogglePasswordVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                textInputAction: TextInputAction.next,
                focusNode: _passwordFocusNode,
                prefixIcon:
                    const Icon(Icons.lock_outline, color: Color(0xFF4CAF50)),
                validator: (value) {
                  final result = _validatePassword(value ?? '');
                  return result.isValid ? null : result.message;
                },
              ),
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildPasswordStrengthIndicator(),
              ],
              if (_passwordValidationState.shouldShowFeedback) ...[
                const SizedBox(height: 8),
                _buildValidationFeedback(_passwordValidationState),
              ],
              const SizedBox(height: 20),

              // Confirm Password Field
              AccessibilityHelper.createAccessibleFormField(
                label: AppLocalizations.confirmPasswordLabel,
                controller: _confirmPasswordController,
                hint: AppLocalizations.confirmPasswordHint,
                isRequired: true,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onTogglePasswordVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                textInputAction: TextInputAction.done,
                focusNode: _confirmPasswordFocusNode,
                prefixIcon:
                    const Icon(Icons.lock_outline, color: Color(0xFF4CAF50)),
                validator: (value) {
                  final result = _validatePasswordConfirmation(
                    _passwordController.text,
                    value,
                  );
                  return result.isValid ? null : result.message;
                },
              ),
              if (_confirmPasswordValidationState.shouldShowFeedback) ...[
                const SizedBox(height: 8),
                _buildValidationFeedback(_confirmPasswordValidationState),
              ],
              const SizedBox(height: 24),

              // Register Button
              AccessibilityHelper.createAccessibleButton(
                label:
                    _isLoading ? AppLocalizations.processing : 'Create Account',
                onPressed: _isLoading ? null : _register,
                isLoading: _isLoading,
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                height: 50,
                icon: _isLoading ? null : const Icon(Icons.person_add),
              ),
              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build validation feedback widget
  Widget _buildValidationFeedback(FieldValidationState state) {
    if (!state.shouldShowFeedback) return const SizedBox.shrink();

    final result = state.validationResult!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: result.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            result.icon,
            color: result.color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.message ?? '',
                  style: TextStyle(
                    color: result.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (result.suggestion != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    result.suggestion!,
                    style: TextStyle(
                      color: result.color.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build password strength indicator
  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    final strength = _getPasswordStrength(password);
    final description = _getPasswordStrengthDescription(password);
    final color = _getPasswordStrengthColor(password);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Password Strength: $description',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: strength,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}
