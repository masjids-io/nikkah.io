import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/screens/profile_view_screen.dart';

void main() {
  group('ProfileViewScreen Simple Tests', () {
    testWidgets('ProfileViewScreen displays loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileViewScreen()));

      // Initially should show loading
      expect(find.text('Loading profile...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ProfileViewScreen has correct app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileViewScreen()));

      // Should show app bar with title
      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('ProfileViewScreen has proper structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileViewScreen()));

      // Should have app bar
      expect(find.byType(AppBar), findsOneWidget);

      // Should have loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
