import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'di/service_locator.dart';
import 'config/app_config.dart';
import 'services/logging_service.dart';
import 'splash_screen.dart';
import 'intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_creation_screen.dart';
import 'screens/profile_view_screen.dart';
import 'screens/profile_browse_screen.dart';
import 'screens/profile_browse_screen_refactored.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/filters_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/conversation_list_screen.dart';
import 'providers/chat_provider.dart';

/// Refactored main application entry point
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize configuration
  _initializeConfiguration();

  // Initialize dependencies
  await initializeDependencies();

  // Initialize logging
  _initializeLogging();

  // Run the app
  runApp(const NikkahAppRefactored());
}

/// Initialize application configuration
void _initializeConfiguration() {
  // Set environment based on build configuration
  // In a real app, this would be determined by build flavors or environment variables
  if (const bool.fromEnvironment('dart.vm.product')) {
    appConfig.setEnvironment(Environment.production);
  } else {
    appConfig.setEnvironment(Environment.development);
  }

  logger.info('App initialized with environment: ${appConfig.environment}');
}

/// Initialize logging service
void _initializeLogging() {
  if (appConfig.enableDebugLogging) {
    logger.setLogLevel(LogLevel.debug);
  } else {
    logger.setLogLevel(LogLevel.info);
  }

  logger.info('Logging service initialized', context: {
    'enableAnalytics': appConfig.enableAnalytics,
    'enableCrashReporting': appConfig.enableCrashReporting,
  });
}

/// Refactored Nikkah App
class NikkahAppRefactored extends StatelessWidget {
  const NikkahAppRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Nikkah.io',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: '/',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  /// Build the app theme
  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: const Color(0xFF2E7D32),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF2E7D32),
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
        labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
        deleteIconColor: const Color(0xFF2E7D32),
      ),
    );
  }

  /// Generate routes for navigation
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      case '/intro':
        return MaterialPageRoute(
          builder: (context) => const IntroScreen(),
        );
      case '/login':
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      case '/register':
        return MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        );
      case '/profile-creation':
        return MaterialPageRoute(
          builder: (context) => const ProfileCreationScreen(),
        );
      case '/profile-browse':
        return MaterialPageRoute(
          builder: (context) => const ProfileBrowseScreen(),
        );
      case '/profile-browse-refactored':
        return MaterialPageRoute(
          builder: (context) => const ProfileBrowseScreenRefactored(),
        );
      case '/filters':
        return MaterialPageRoute(
          builder: (context) => const FiltersScreen(),
        );
      case '/conversations':
        return MaterialPageRoute(
          builder: (context) => const ConversationListScreen(),
        );
      case '/home':
        return MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        );
      case '/chat':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatPartner: args?['chatPartner'],
            conversationID: args?['conversationID'] ?? 'default-conversation',
          ),
        );
      case '/profile-view':
        final args = settings.arguments as Map<String, dynamic>?;
        final profile = args?['profile'];
        if (profile != null) {
          return MaterialPageRoute(
            builder: (context) => ProfileViewScreen(profile: profile),
          );
        }
        // Fallback if no profile provided
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Profile View')),
            body: const Center(child: Text('Profile not found')),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(child: Text('The requested page was not found')),
          ),
        );
    }
  }
}
