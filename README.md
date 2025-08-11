# Nikkah.io

A next-gen innovative open source Muslim matrimonial app built with Flutter.

## 🚀 Features

### Core Functionality
- **User Authentication** - Secure login and registration
- **Profile Management** - Create and manage detailed profiles
- **Profile Browsing** - Discover potential matches with advanced filtering
- **Chat System** - Real-time messaging between users
- **Conversation Management** - Track and manage conversations
- **Advanced Filters** - Find matches based on various criteria

### Technical Features
- **Cross-Platform** - Works on iOS, Android, Web, and Desktop
- **Modern Architecture** - Clean, scalable codebase with dependency injection
- **Responsive Design** - Beautiful UI that adapts to different screen sizes
- **State Management** - Efficient state management with Provider
- **Configuration Management** - Environment-based configuration
- **Enhanced Logging** - Comprehensive logging for debugging

## 🏗️ Architecture

The app uses a modern, scalable architecture with:

- **Dependency Injection** - Centralized service locator pattern
- **Configuration Management** - Environment-based settings
- **Service Layer** - Clean separation of business logic
- **Repository Pattern** - Data access abstraction
- **Provider State Management** - Efficient state handling

## 📱 Available Routes

| Route | Description |
|-------|-------------|
| `/` | Splash screen with animations |
| `/intro` | Introduction/onboarding |
| `/login` | User authentication |
| `/register` | User registration |
| `/profile-creation` | Profile setup wizard |
| `/profile-browse` | Browse potential matches |
| `/filters` | Advanced filtering system |
| `/conversations` | Chat conversations list |
| `/home` | Main navigation hub |
| `/chat` | Individual chat interface |
| `/profile-view` | Detailed profile view |

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (>=3.1.2)
- Dart SDK (>=3.1.2)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd nikkah.io
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For mobile
   flutter run
   
   # For web
   flutter run -d chrome
   
   # For specific platform
   flutter run -d ios
   flutter run -d android
   ```

### Web Development

For web development, you can access routes directly:

- `http://localhost:port/` - Splash screen
- `http://localhost:port/intro` - Introduction
- `http://localhost:port/login` - Login
- `http://localhost:port/register` - Registration
- `http://localhost:port/profile-browse` - Profile browsing
- `http://localhost:port/filters` - Filters
- `http://localhost:port/home` - Main navigation

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/                      # Configuration management
│   └── app_config.dart
├── di/                         # Dependency injection
│   └── service_locator.dart
├── services/                   # Business services
│   ├── auth_service.dart
│   ├── profile_service.dart
│   ├── chat_service.dart
│   └── logging_service.dart
├── models/                     # Data models
│   ├── nikkah_profile.dart
│   ├── conversation.dart
│   └── message.dart
├── screens/                    # UI screens
│   ├── login_screen.dart
│   ├── profile_browse_screen.dart
│   ├── chat_screen.dart
│   └── ...
├── providers/                  # State management
│   └── chat_provider.dart
├── repositories/               # Data repositories
│   └── profile_repository.dart
├── business/                   # Business logic
│   └── profile_browse_bloc.dart
├── widgets/                    # Reusable widgets
│   └── profile_browse_widgets.dart
└── exceptions/                 # Custom exceptions
    └── profile_exceptions.dart
```

## 🧪 Testing

Run tests with:
```bash
flutter test
```

The project includes comprehensive tests for:
- Widget tests
- Service tests
- Model tests
- Integration tests

## 🔧 Configuration

The app supports different environments:

```dart
// Development
appConfig.setEnvironment(Environment.development);

// Production
appConfig.setEnvironment(Environment.production);
```

## 📦 Dependencies

Key dependencies include:
- `provider` - State management
- `http` - HTTP client
- `grpc` - gRPC communication
- `web_socket_channel` - Real-time messaging
- `flutter_secure_storage` - Secure storage
- `uuid` - Unique identifiers

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

Built with ❤️ for the Muslim community, respecting Islamic values and traditions.

---

**Note**: This app is designed with Islamic values in mind, providing a halal approach to finding life partners while maintaining modern technology standards.
