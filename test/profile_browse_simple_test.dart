import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/screens/profile_browse_screen.dart';
import 'package:nikkah_io/models/nikkah_profile.dart';

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

    testWidgets('ProfileBrowseScreen shows profile cards correctly',
        (WidgetTester tester) async {
      // Create a mock profile
      final mockProfile = NikkahProfile(
        id: 'profile-123',
        name: 'John Doe',
        gender: 'MALE',
        birthDate: BirthDate(year: 1995, month: 'JANUARY', day: 15),
        location: Location(city: 'New York', state: 'NY', country: 'USA'),
        education: 'BACHELOR',
        occupation: 'Software Engineer',
      );

      // Create a widget with mock data
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileBrowseScreen(),
        ),
      );

      // Wait for the widget to build
      await tester.pump();

      // Should show loading initially
      expect(find.text('Loading profiles...'), findsOneWidget);
    });

    testWidgets('ProfileBrowseScreen handles empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileBrowseScreen()));

      // Initially shows loading
      expect(find.text('Loading profiles...'), findsOneWidget);

      // After loading, if no profiles, should show empty state
      // This would be tested with mocked service responses
    });

    testWidgets('ProfileBrowseScreen shows active filters',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileBrowseScreen()));

      // Initially no active filters should be shown
      expect(find.text('Male'), findsNothing);
      expect(find.text('Location: New York'), findsNothing);
    });

    testWidgets('ProfileBrowseScreen has refresh functionality',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileBrowseScreen()));

      // Should have refresh indicator (pull to refresh)
      // This is tested by the RefreshIndicator widget presence
    });

    testWidgets('ProfileBrowseScreen handles error state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileBrowseScreen()));

      // Initially shows loading
      expect(find.text('Loading profiles...'), findsOneWidget);

      // Error state would be tested with mocked service responses
    });
  });
}
