import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/screens/profile_browse_screen.dart';

void main() {
  group('ProfileBrowseScreen Simple Tests', () {
    testWidgets('ProfileBrowseScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileBrowseScreen()));

      // Should show app bar with title
      expect(find.text('Browse Profiles'), findsOneWidget);

      // Should show search bar
      expect(find.text('Search profiles...'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);

      // Should show filter button
      expect(find.byIcon(Icons.filter_list), findsOneWidget);

      // Initially should show loading
      expect(find.text('Loading profiles...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ProfileBrowseScreen has search functionality',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileBrowseScreen()));

      // Should have search text field
      expect(find.byType(TextField), findsOneWidget);

      // Should have search button
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('ProfileBrowseScreen has filter button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileBrowseScreen()));

      // Should have filter button in app bar
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('ProfileBrowseScreen has proper structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileBrowseScreen()));

      // Should have app bar
      expect(find.byType(AppBar), findsOneWidget);

      // Should have search bar container
      expect(find.byType(Container), findsWidgets);

      // Should have loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
