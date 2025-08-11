import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Comprehensive input validation utility for security
class InputValidator {
  // Maximum lengths for different input types
  static const int maxNameLength = 50;
  static const int maxEmailLength = 254;
  static const int maxUsernameLength = 30;
  static const int maxPasswordLength = 128;
  static const int maxMessageLength = 1000;
  static const int maxBioLength = 500;
  static const int maxPhoneLength = 20;

  // Allowed characters for different input types
  static final RegExp namePattern = RegExp(r'^[a-zA-Z\s\-\.\']+$');
  static final RegExp usernamePattern = RegExp(r'^[a-zA-Z0-9_]+$');
  static final RegExp emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp phonePattern = RegExp(r'^[\+]?[0-9\s\-\(\)]+$');
  static final RegExp safeTextPattern = RegExp(r'^[a-zA-Z0-9\s\-\.\,\!\?\:\;\(\)\'\"]+$');

  /// Validate and sanitize email address
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    email = email.trim().toLowerCase();

    if (email.length > maxEmailLength) {
      return 'Email is too long (max $maxEmailLength characters)';
    }

    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Check for common email injection patterns
    if (email.contains('<') || email.contains('>') || email.contains('"')) {
      return 'Email contains invalid characters';
    }

    return null;
  }

  /// Validate and sanitize username
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }

    username = username.trim();

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (username.length > maxUsernameLength) {
      return 'Username is too long (max $maxUsernameLength characters)';
    }

    if (!usernamePattern.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    // Check for reserved usernames
    final reservedUsernames = [
      'admin', 'root', 'system', 'nikkah', 'api', 'www', 'mail', 'ftp',
      'localhost', 'test', 'guest', 'anonymous', 'null', 'undefined'
    ];

    if (reservedUsernames.contains(username.toLowerCase())) {
      return 'This username is not available';
    }

    return null;
  }

  /// Validate and sanitize password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (password.length > maxPasswordLength) {
      return 'Password is too long (max $maxPasswordLength characters)';
    }

    // Check for common weak passwords
    final weakPasswords = [
      'password', '123456', 'qwerty', 'admin', 'letmein', 'welcome',
      'monkey', 'dragon', 'master', 'hello', 'freedom', 'whatever'
    ];

    if (weakPasswords.contains(password.toLowerCase())) {
      return 'Please choose a stronger password';
    }

    // Check for password complexity
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));

    if (!hasUppercase || !hasLowercase || !hasDigits) {
      return 'Password must contain uppercase, lowercase, and numbers';
    }

    return null;
  }

  /// Validate and sanitize name
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }

    name = name.trim();

    if (name.length > maxNameLength) {
      return 'Name is too long (max $maxNameLength characters)';
    }

    if (!namePattern.hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens, dots, and apostrophes';
    }

    // Check for suspicious patterns
    if (name.toLowerCase().contains('script') || 
        name.toLowerCase().contains('javascript') ||
        name.toLowerCase().contains('alert') ||
        name.toLowerCase().contains('eval')) {
      return 'Name contains invalid content';
    }

    return null;
  }

  /// Validate and sanitize phone number
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Phone is optional
    }

    phone = phone.trim();

    if (phone.length > maxPhoneLength) {
      return 'Phone number is too long (max $maxPhoneLength characters)';
    }

    if (!phonePattern.hasMatch(phone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate and sanitize message content
  static String? validateMessage(String? message) {
    if (message == null || message.isEmpty) {
      return 'Message cannot be empty';
    }

    message = message.trim();

    if (message.length > maxMessageLength) {
      return 'Message is too long (max $maxMessageLength characters)';
    }

    // Check for potential XSS patterns
    final xssPatterns = [
      '<script', '</script>', 'javascript:', 'onload=', 'onerror=',
      'onclick=', 'onmouseover=', 'eval(', 'document.cookie',
      'window.location', 'alert(', 'confirm(', 'prompt('
    ];

    final lowerMessage = message.toLowerCase();
    for (final pattern in xssPatterns) {
      if (lowerMessage.contains(pattern)) {
        return 'Message contains invalid content';
      }
    }

    return null;
  }

  /// Validate and sanitize bio text
  static String? validateBio(String? bio) {
    if (bio == null || bio.isEmpty) {
      return null; // Bio is optional
    }

    bio = bio.trim();

    if (bio.length > maxBioLength) {
      return 'Bio is too long (max $maxBioLength characters)';
    }

    // Check for potential XSS patterns
    final xssPatterns = [
      '<script', '</script>', 'javascript:', 'onload=', 'onerror=',
      'onclick=', 'onmouseover=', 'eval(', 'document.cookie'
    ];

    final lowerBio = bio.toLowerCase();
    for (final pattern in xssPatterns) {
      if (lowerBio.contains(pattern)) {
        return 'Bio contains invalid content';
      }
    }

    return null;
  }

  /// Sanitize text input by removing dangerous characters
  static String sanitizeText(String text) {
    // Remove HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Remove script tags and content
    text = text.replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');
    
    // Remove dangerous attributes
    text = text.replaceAll(RegExp(r'on\\w+'), '');
    
    // Remove javascript: protocol
    text = text.replaceAll(RegExp(r'javascript:', caseSensitive: false), '');
    
    // Remove eval() calls
    text = text.replaceAll(RegExp(r'eval\\s*\\([^)]*\\)'), '');
    
    return text.trim();
  }

  /// Hash sensitive data for secure transmission
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate age (must be 18+)
  static String? validateAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    if (age < 18) {
      return 'You must be at least 18 years old';
    }
    
    if (age > 120) {
      return 'Please enter a valid birth date';
    }
    
    return null;
  }

  /// Validate gender selection
  static String? validateGender(String? gender) {
    if (gender == null || gender.isEmpty) {
      return 'Please select your gender';
    }

    final validGenders = ['MALE', 'FEMALE'];
    if (!validGenders.contains(gender)) {
      return 'Please select a valid gender';
    }

    return null;
  }

  /// Validate education level
  static String? validateEducation(String? education) {
    if (education == null || education.isEmpty) {
      return null; // Education is optional
    }

    final validEducation = [
      'HIGH_SCHOOL', 'BACHELOR', 'MASTER', 'DOCTORATE', 'OTHER'
    ];

    if (!validEducation.contains(education)) {
      return 'Please select a valid education level';
    }

    return null;
  }

  /// Validate sect selection
  static String? validateSect(String? sect) {
    if (sect == null || sect.isEmpty) {
      return null; // Sect is optional
    }

    final validSects = [
      'SUNNI', 'SUNNI_HANAFI', 'SUNNI_MALEKI', 'SUNNI_SHAFII', 
      'SHIA', 'OTHER'
    ];

    if (!validSects.contains(sect)) {
      return 'Please select a valid sect';
    }

    return null;
  }
} 