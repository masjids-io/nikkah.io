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
    testWidgets('App starts with splash screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const NikkahAppRefactored());

      // Verify that splash screen elements are present
      expect(find.text('Nikkah.io'), findsOneWidget);
      expect(find.text('Finding Your Soulmate'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Verify that the heart icon is present
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Verify that loading indicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for timer to complete to avoid pending timer issues
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });

    testWidgets('App has proper theme configuration',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const NikkahAppRefactored());

      // Verify app title
      expect(find.text('Nikkah.io'), findsOneWidget);

      // Wait for timer to complete to avoid pending timer issues
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });
  });
}
