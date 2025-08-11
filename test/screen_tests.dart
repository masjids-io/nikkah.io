import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nikkah_io/intro_screen.dart';
import 'package:nikkah_io/screens/login_screen.dart';
import 'package:nikkah_io/screens/register_screen.dart';
import 'package:nikkah_io/screens/main_navigation_screen.dart';
import 'package:nikkah_io/screens/profile_creation_screen.dart';
import 'package:nikkah_io/screens/chat_screen.dart';
import 'package:nikkah_io/screens/filters_screen.dart';
import 'package:nikkah_io/screens/profile_view_screen.dart';
import 'package:nikkah_io/providers/chat_provider.dart';
import 'package:nikkah_io/models/nikkah_profile.dart';

void main() {
  group('Screen Tests', () {
    group('Intro Screen', () {
      testWidgets('displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: IntroScreen()));

        expect(find.text('Welcome to Nikkah.io'), findsOneWidget);
        expect(find.text('Your journey to finding your soulmate starts here'),
            findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('Login Screen', () {
      testWidgets('displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

        expect(find.text('Welcome Back'), findsOneWidget);
        expect(find.text('Sign in to continue your journey'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Sign Up'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));
      });
    });

    group('Register Screen', () {
      testWidgets('displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

        expect(
            find.text('Join Nikkah.io and start your journey'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Confirm Password'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(7));
      });
    });

    group('Main Navigation Screen', () {
      testWidgets('displays bottom navigation bar',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(const MaterialApp(home: MainNavigationScreen()));

        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Browse'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('shows home tab by default', (WidgetTester tester) async {
        await tester
            .pumpWidget(const MaterialApp(home: MainNavigationScreen()));

        expect(find.text('Nikkah.io'), findsOneWidget);
        expect(find.text('Welcome to Nikkah.io'), findsOneWidget);
        expect(find.text('Quick Actions'), findsOneWidget);
        expect(find.text('Recent Activity'), findsOneWidget);
      });

      testWidgets('has proper navigation structure',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(const MaterialApp(home: MainNavigationScreen()));

        expect(find.byType(IndexedStack), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });

      testWidgets('shows activity cards', (WidgetTester tester) async {
        await tester
            .pumpWidget(const MaterialApp(home: MainNavigationScreen()));

        expect(find.text('Profile Views'), findsOneWidget);
        expect(find.text('New Likes'), findsOneWidget);
        expect(find.text('New Messages'), findsOneWidget);
      });
    });

    group('Profile Creation Screen', () {
      testWidgets('displays correctly', (WidgetTester tester) async {
        await tester
            .pumpWidget(const MaterialApp(home: ProfileCreationScreen()));

        expect(find.text('Create Profile'), findsOneWidget);
        expect(find.text('Tell us about yourself'), findsOneWidget);
        expect(find.text('Let\'s start with your basic information'),
            findsOneWidget);
        expect(find.text('Full Name'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);

        expect(find.text('Basic Info'), findsOneWidget);
        expect(find.text('Gender'), findsOneWidget);
        expect(find.text('Birth Date'), findsOneWidget);
      });

      testWidgets('form field accepts text input', (WidgetTester tester) async {
        await tester
            .pumpWidget(const MaterialApp(home: ProfileCreationScreen()));

        final textField = find.byType(TextFormField);
        expect(textField, findsOneWidget);

        await tester.enterText(textField, 'John Doe');
        await tester.pumpAndSettle();

        expect(find.text('John Doe'), findsOneWidget);
      });
    });

    group('Chat Screen', () {
      testWidgets('displays app bar with partner info',
          (WidgetTester tester) async {
        final chatPartner = {
          'name': 'Sarah Ahmed',
          'age': 25,
          'location': 'London, UK',
        };

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider(
              create: (_) => ChatProvider(),
              child: ChatScreen(
                chatPartner: chatPartner,
                conversationID: 'test-conversation-1',
              ),
            ),
          ),
        );

        await tester.pump(const Duration(seconds: 2));

        expect(find.text('Sarah Ahmed'), findsOneWidget);
        expect(find.text('25 years old • London, UK'), findsOneWidget);
      });

      testWidgets('displays chat interface elements',
          (WidgetTester tester) async {
        final chatPartner = {
          'name': 'Sarah Ahmed',
          'age': 25,
          'location': 'London, UK',
        };

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider(
              create: (_) => ChatProvider(),
              child: ChatScreen(
                chatPartner: chatPartner,
                conversationID: 'test-conversation-2',
              ),
            ),
          ),
        );

        await tester.pump(const Duration(seconds: 2));

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);
        expect(find.byIcon(Icons.more_vert), findsOneWidget);
      });
    });

    group('Filters Screen', () {
      testWidgets('displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

        expect(find.text('Filters'), findsOneWidget);
        expect(find.text('Reset'), findsOneWidget);
        expect(find.text('Basic Filters'), findsOneWidget);
        expect(find.text('Religious Filters'), findsOneWidget);
        expect(find.text('Physical Filters'), findsOneWidget);
        expect(find.text('Hobbies & Interests'), findsOneWidget);
        expect(find.text('Apply Filters'), findsOneWidget);
        expect(find.text('Clear All Filters'), findsOneWidget);
      });

      testWidgets('has proper structure', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(RangeSlider), findsOneWidget);
        expect(find.byType(FilterChip), findsWidgets);
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('shows filter options', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

        expect(find.text('Gender'), findsOneWidget);
        expect(find.text('Location'), findsOneWidget);
        expect(find.text('Education'), findsOneWidget);
        expect(find.text('Occupation'), findsOneWidget);
        expect(find.text('Sect'), findsOneWidget);
        expect(find.text('Height Range'), findsOneWidget);
        expect(find.text('Hobbies'), findsOneWidget);
      });
    });

    group('Profile View Screen', () {
      testWidgets('displays correctly with profile data', (WidgetTester tester) async {
        final mockProfile = NikkahProfile(
          id: 'profile-123',
          name: 'John Doe',
          gender: 'MALE',
          birthDate: BirthDate(year: 1995, month: 'JANUARY', day: 15),
          location: Location(city: 'New York', state: 'NY', country: 'USA'),
          education: 'BACHELOR',
          occupation: 'Software Engineer',
          height: Height(cm: 180),
          sect: 'SUNNI',
          hobbies: ['READING', 'TRAVELING'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ProfileViewScreen(profile: mockProfile),
          ),
        );

        expect(find.text('John Doe'), findsWidgets);
        expect(find.text('Basic Information'), findsOneWidget);
        expect(find.text('Location'), findsOneWidget);
        expect(find.text('Education & Occupation'), findsOneWidget);
        expect(find.text('Physical Information'), findsOneWidget);
        expect(find.text('Religious Information'), findsOneWidget);
        expect(find.text('Hobbies & Interests'), findsOneWidget);
        expect(find.text('Like Profile'), findsOneWidget);
        expect(find.text('Start Chat'), findsOneWidget);
      });

      testWidgets('has proper structure', (WidgetTester tester) async {
        final mockProfile = NikkahProfile(name: 'John Doe');

        await tester.pumpWidget(
          MaterialApp(
            home: ProfileViewScreen(profile: mockProfile),
          ),
        );

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Column), findsWidgets);
      });
    });
  });
}
