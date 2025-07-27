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
      expect(find.text('Additional Filters'), findsOneWidget);

      // Should show filter options
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Age Range'), findsOneWidget);
      expect(find.text('Sort By'), findsOneWidget);
      expect(find.text('Online Only'), findsOneWidget);
      expect(find.text('With Photos'), findsOneWidget);
      expect(find.text('Verified Only'), findsOneWidget);

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
      expect(find.byType(RangeSlider), findsOneWidget); // Age Range
      expect(find.byType(Switch), findsNWidgets(3)); // Toggle switches

      // Should have cards
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('FiltersScreen shows filter cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should show filter cards
      expect(find.byType(Card), findsWidgets);

      // Should show switch cards
      expect(find.text('Show profiles of'), findsOneWidget);
      expect(find.text('Show profiles between ages'), findsOneWidget);
      expect(find.text('Order profiles by'), findsOneWidget);
    });

    testWidgets('FiltersScreen has action buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiltersScreen()));

      // Should have apply and clear buttons
      expect(find.byType(ElevatedButton), findsOneWidget); // Apply Filters
      expect(find.byType(OutlinedButton), findsOneWidget); // Clear All Filters
    });
  });
}
