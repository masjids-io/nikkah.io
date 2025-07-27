// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nikkah_io/main.dart';

void main() {
  group('Nikkah.io App Tests', () {
    testWidgets('Splash screen displays correctly',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

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

    testWidgets('Splash screen navigates to home after delay',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Initially, we should see splash screen
      expect(find.text('Nikkah.io'), findsOneWidget);
      expect(find.text('Finding Your Soulmate'), findsOneWidget);

      // Wait for navigation to complete (3 seconds + buffer)
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // After navigation, we should see home screen
      expect(find.text('Welcome to Nikkah.io'), findsOneWidget);
      expect(find.text('Your journey to finding your soulmate starts here'),
          findsOneWidget);

      // Splash screen elements should no longer be visible
      expect(find.text('Finding Your Soulmate'), findsNothing);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
