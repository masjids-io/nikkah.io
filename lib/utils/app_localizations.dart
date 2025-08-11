/// Localization system for user-facing strings
/// This enables easy internationalization and consistent messaging
class AppLocalizations {
  // Validation Messages
  static const String emailRequired = 'Please enter your email address';
  static const String emailTooLong = 'Email address is too long. Please use a shorter email.';
  static const String emailInvalid = 'Please enter a valid email address (e.g., user@example.com)';
  static const String emailInvalidCharacters = 'Email contains characters that are not allowed. Please check and try again.';
  
  static const String usernameRequired = 'Please choose a username';
  static const String usernameTooShort = 'Username must be at least 3 characters long';
  static const String usernameTooLong = 'Username is too long. Please choose a shorter username.';
  static const String usernameInvalidCharacters = 'Username can only contain letters, numbers, and underscores';
  static const String usernameReserved = 'This username is not available. Please choose a different one.';
  
  static const String passwordRequired = 'Please enter a password';
  static const String passwordTooShort = 'Password must be at least 8 characters long for security';
  static const String passwordTooLong = 'Password is too long. Please use a shorter password.';
  static const String passwordWeak = 'This password is too common. Please choose a stronger, more unique password.';
  static const String passwordComplexity = 'Password must include uppercase letters, lowercase letters, and numbers for better security';
  static const String passwordMismatch = 'Passwords do not match. Please make sure both passwords are identical.';
  
  static const String nameRequired = 'Please enter your name';
  static const String nameTooLong = 'Name is too long. Please use a shorter name.';
  static const String nameInvalidCharacters = 'Name can only contain letters, spaces, hyphens, dots, and apostrophes';
  static const String nameInvalidContent = 'Name contains content that is not allowed. Please use only letters and common punctuation.';
  
  static const String phoneTooLong = 'Phone number is too long. Please check and try again.';
  static const String phoneInvalid = 'Please enter a valid phone number (e.g., +1-555-123-4567)';
  
  static const String messageEmpty = 'Please enter a message to send';
  static const String messageTooLong = 'Message is too long. Please shorten your message.';
  static const String messageInvalidContent = 'Message contains content that is not allowed. Please revise and try again.';
  
  static const String bioTooLong = 'Bio is too long. Please keep it under 500 characters.';
  static const String bioInvalidContent = 'Bio contains content that is not allowed. Please revise and try again.';
  
  static const String ageTooYoung = 'You must be at least 18 years old to use this service';
  static const String ageInvalid = 'Please enter a valid birth date';
  
  static const String genderRequired = 'Please select your gender';
  static const String genderInvalid = 'Please select a valid gender option';
  
  static const String educationInvalid = 'Please select a valid education level';
  
  static const String sectInvalid = 'Please select a valid sect option';
  
  // Success Messages
  static const String validationSuccess = 'All information looks good!';
  static const String formComplete = 'Form completed successfully';
  
  // Loading States
  static const String validating = 'Validating...';
  static const String processing = 'Processing...';
  static const String saving = 'Saving...';
  static const String loading = 'Loading...';
  
  // Error States
  static const String networkError = 'Connection failed. Please check your internet connection and try again.';
  static const String serverError = 'We\'re experiencing technical difficulties. Please try again in a few moments.';
  static const String unknownError = 'Something went wrong. Please try again or contact support if the problem persists.';
  
  // Accessibility
  static const String passwordVisibilityToggle = 'Toggle password visibility';
  static const String formSubmit = 'Submit form';
  static const String formReset = 'Reset form';
  static const String requiredField = 'Required field';
  static const String optionalField = 'Optional field';
  
  // Field Labels
  static const String emailLabel = 'Email Address';
  static const String usernameLabel = 'Username';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String firstNameLabel = 'First Name';
  static const String lastNameLabel = 'Last Name';
  static const String fullNameLabel = 'Full Name';
  static const String phoneLabel = 'Phone Number';
  static const String messageLabel = 'Message';
  static const String bioLabel = 'About Me';
  static const String genderLabel = 'Gender';
  static const String educationLabel = 'Education Level';
  static const String sectLabel = 'Sect';
  
  // Hints
  static const String emailHint = 'Enter your email address';
  static const String usernameHint = 'Choose a unique username';
  static const String passwordHint = 'Create a strong password';
  static const String confirmPasswordHint = 'Re-enter your password';
  static const String firstNameHint = 'Enter your first name';
  static const String lastNameHint = 'Enter your last name';
  static const String fullNameHint = 'Enter your full name';
  static const String phoneHint = 'Enter your phone number';
  static const String messageHint = 'Type your message here...';
  static const String bioHint = 'Tell us about yourself...';
  
  // Help Text
  static const String passwordHelp = 'Use at least 8 characters with uppercase, lowercase, and numbers';
  static const String usernameHelp = '3-30 characters, letters, numbers, and underscores only';
  static const String emailHelp = 'We\'ll use this to send you important updates';
  static const String phoneHelp = 'Optional - for account recovery and notifications';
  static const String bioHelp = 'Optional - tell others about yourself (max 500 characters)';
} 