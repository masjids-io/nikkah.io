// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nikkah_io/main.dart';
import 'package:nikkah_io/intro_screen.dart';
import 'package:nikkah_io/screens/login_screen.dart';
import 'package:nikkah_io/screens/register_screen.dart';
import 'package:nikkah_io/screens/main_navigation_screen.dart';

void main() {
  group('Nikkah.io App Tests', () {
    testWidgets('Splash screen displays correctly',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const NikkahApp());

      // Verify that splash screen elements are present
      expect(find.text('Nikkah.io'), findsOneWidget);
      expect(find.text('Finding Your Soulmate'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Verify that the heart icon is present
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Verify that loading indicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the timer to complete to avoid pending timer issues
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });

    testWidgets('Splash screen navigates to intro after delay',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const NikkahApp());

      // Initially, we should see splash screen
      expect(find.text('Nikkah.io'), findsOneWidget);
      expect(find.text('Finding Your Soulmate'), findsOneWidget);

      // Wait for navigation to complete (3 seconds + buffer)
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // After navigation, we should see intro screen
      expect(find.text('Welcome to Nikkah.io'), findsOneWidget);
      expect(find.text('Your journey to finding your soulmate starts here'),
          findsOneWidget);

      // Splash screen elements should no longer be visible
      expect(find.text('Finding Your Soulmate'), findsNothing);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('Login screen displays correctly', (WidgetTester tester) async {
      // Build login screen directly
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Verify login screen elements are present
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue your journey'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      // Check for form fields by their labels
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('Register screen displays correctly',
        (WidgetTester tester) async {
      // Build register screen directly
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      // Verify register screen elements are present
      expect(
          find.text('Join Nikkah.io and start your journey'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);

      expect(find.text('Sign In'), findsOneWidget);

      // Check for form fields by their types
      expect(find.byType(TextFormField), findsNWidgets(7));
    });

    testWidgets('Intro screen displays correctly', (WidgetTester tester) async {
      // Build intro screen directly
      await tester.pumpWidget(const MaterialApp(home: IntroScreen()));

      // Verify intro screen elements are present
      expect(find.text('Welcome to Nikkah.io'), findsOneWidget);
      expect(find.text('Your journey to finding your soulmate starts here'),
          findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Verify page indicators are present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Main navigation screen displays correctly',
        (WidgetTester tester) async {
      // Build main navigation screen directly
      await tester.pumpWidget(const MaterialApp(home: MainNavigationScreen()));

      // Verify that bottom navigation bar is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Verify that home tab content is displayed
      expect(find.text('Nikkah.io'), findsOneWidget);
      expect(find.text('Welcome to Nikkah.io'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });
  });
}
