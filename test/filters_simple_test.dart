import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/screens/filters_screen.dart';

void main() {
  group('FiltersScreen Tests', () {
    testWidgets('FiltersScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should show app bar with title
      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Should show section headers
      expect(find.text('Basic Filters'), findsOneWidget);
      expect(find.text('Religious Filters'), findsOneWidget);
      expect(find.text('Physical Filters'), findsOneWidget);
      expect(find.text('Hobbies & Interests'), findsOneWidget);

      // Should show filter options
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Education'), findsOneWidget);
      expect(find.text('Occupation'), findsOneWidget);
      expect(find.text('Sect'), findsOneWidget);
      expect(find.text('Height Range'), findsOneWidget);
      expect(find.text('Hobbies'), findsOneWidget);

      // Should show action buttons
      expect(find.text('Apply Filters'), findsOneWidget);
      expect(find.text('Clear All Filters'), findsOneWidget);
    });

    testWidgets('FiltersScreen has proper structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should have app bar
      expect(find.byType(AppBar), findsOneWidget);

      // Should have form elements
      expect(find.byType(RangeSlider), findsOneWidget); // Height Range
      expect(find.byType(FilterChip), findsWidgets); // Hobbies

      // Should have cards
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('FiltersScreen shows filter cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should show filter cards
      expect(find.byType(Card), findsWidgets);

      // Should show filter descriptions
      expect(find.text('Show profiles of'), findsOneWidget);
      expect(find.text('Search by city'), findsOneWidget);
      expect(find.text('Show profiles with education level'), findsOneWidget);
      expect(find.text('Search by occupation'), findsOneWidget);
      expect(find.text('Show profiles of specific sect'), findsOneWidget);
      expect(find.text('Show profiles within height range (cm)'), findsOneWidget);
      expect(find.text('Show profiles with specific hobbies'), findsOneWidget);
    });

    testWidgets('FiltersScreen has action buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should have apply and clear buttons
      expect(find.byType(ElevatedButton), findsOneWidget); // Apply Filters
      expect(find.byType(OutlinedButton), findsOneWidget); // Clear All Filters
    });

    testWidgets('FiltersScreen shows gender options',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should show gender dropdown
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('All Genders'), findsOneWidget);
    });

    testWidgets('FiltersScreen shows education options',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should show education dropdown
      expect(find.text('Education'), findsOneWidget);
      expect(find.text('All Education Levels'), findsOneWidget);
    });

    testWidgets('FiltersScreen shows sect options',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should show sect dropdown
      expect(find.text('Sect'), findsOneWidget);
      expect(find.text('All Sects'), findsOneWidget);
    });

    testWidgets('FiltersScreen shows height range slider',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should show height range slider
      expect(find.text('Height Range'), findsOneWidget);
      expect(find.byType(RangeSlider), findsOneWidget);
    });

    testWidgets('FiltersScreen shows hobbies chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should show hobbies section
      expect(find.text('Hobbies & Interests'), findsOneWidget);
      expect(find.text('Hobbies'), findsOneWidget);
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('FiltersScreen shows location input',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should show location input field
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Enter city name'), findsOneWidget);
    });

    testWidgets('FiltersScreen shows occupation input',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should show occupation input field
      expect(find.text('Occupation'), findsOneWidget);
      expect(find.text('Enter occupation'), findsOneWidget);
    });

    testWidgets('FiltersScreen has reset functionality',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should have reset button
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('FiltersScreen has clear all functionality',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should have clear all button
      expect(find.text('Clear All Filters'), findsOneWidget);
    });
  });
}
