import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/screens/profile_view_screen.dart';
import 'package:nikkah_io/models/nikkah_profile.dart';

void main() {
  group('ProfileViewScreen Simple Tests', () {
    testWidgets('ProfileViewScreen displays correctly with profile data',
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
        height: Height(cm: 180),
        sect: 'SUNNI',
        hobbies: ['READING', 'TRAVELING'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileViewScreen(profile: mockProfile),
        ),
      );

      // Should show app bar with profile name
      expect(find.text('John Doe'), findsWidgets);

      // Should show profile information
      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Education & Occupation'), findsOneWidget);
      expect(find.text('Physical Information'), findsOneWidget);
      expect(find.text('Religious Information'), findsOneWidget);
      expect(find.text('Hobbies & Interests'), findsOneWidget);

      // Should show action buttons
      expect(find.text('Like Profile'), findsOneWidget);
      expect(find.text('Start Chat'), findsOneWidget);
    });

    testWidgets('ProfileViewScreen displays loading state',
        (WidgetTester tester) async {
      final mockProfile = NikkahProfile(name: 'John Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileViewScreen(profile: mockProfile),
        ),
      );

      // Should not show loading initially since we have profile data
      expect(find.text('Loading profile...'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('ProfileViewScreen has correct app bar',
        (WidgetTester tester) async {
      final mockProfile = NikkahProfile(name: 'John Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileViewScreen(profile: mockProfile),
        ),
      );

      // Should show app bar with profile name
      expect(find.text('John Doe'), findsWidgets);
    });

    testWidgets('ProfileViewScreen has proper structure',
        (WidgetTester tester) async {
      final mockProfile = NikkahProfile(name: 'John Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileViewScreen(profile: mockProfile),
        ),
      );

      // Should have app bar
      expect(find.byType(AppBar), findsOneWidget);

      // Should have profile sections
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('ProfileViewScreen displays profile details correctly',
        (WidgetTester tester) async {
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

      // Should display profile information
      expect(find.text('John Doe'), findsWidgets);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Bachelor\'s Degree'), findsOneWidget);
      expect(find.text('Software Engineer'), findsOneWidget);
      expect(find.text('Sunni'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Traveling'), findsOneWidget);
    });

    testWidgets('ProfileViewScreen handles missing profile data',
        (WidgetTester tester) async {
      final mockProfile = NikkahProfile(); // Empty profile

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileViewScreen(profile: mockProfile),
        ),
      );

      // Should handle missing data gracefully
      expect(find.text('Name not specified'), findsOneWidget);
      expect(find.text('Not specified'), findsWidgets);
    });

    testWidgets('ProfileViewScreen has action buttons',
        (WidgetTester tester) async {
      final mockProfile = NikkahProfile(name: 'John Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileViewScreen(profile: mockProfile),
        ),
      );

      // Should have like and chat buttons
      expect(find.text('Like Profile'), findsOneWidget);
      expect(find.text('Start Chat'), findsOneWidget);
    });
  });
}
