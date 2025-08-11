import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_creation_screen.dart';
import 'screens/profile_view_screen.dart';
import 'screens/profile_browse_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/filters_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/conversation_list_screen.dart';
import 'providers/chat_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Nikkah.io',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/intro': (context) => const IntroScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/profile-creation': (context) => const ProfileCreationScreen(),
          '/profile-browse': (context) => const ProfileBrowseScreen(),
          '/filters': (context) => const FiltersScreen(),
          '/conversations': (context) => const ConversationListScreen(),
          '/home': (context) => const MainNavigationScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/chat') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatPartner: args?['chatPartner'],
                conversationID:
                    args?['conversationID'] ?? 'default-conversation',
              ),
            );
          }
          if (settings.name == '/profile-view') {
            final args = settings.arguments as Map<String, dynamic>?;
            final profile = args?['profile'];
            if (profile != null) {
              return MaterialPageRoute(
                builder: (context) => ProfileViewScreen(profile: profile),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
