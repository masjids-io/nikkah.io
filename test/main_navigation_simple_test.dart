import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/screens/main_navigation_screen.dart';

void main() {
  group('MainNavigationScreen Tests', () {
    testWidgets('MainNavigationScreen displays bottom navigation bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainNavigationScreen()));

      // Should show bottom navigation bar
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Should show all navigation items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('MainNavigationScreen shows home tab by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainNavigationScreen()));

      // Should show home tab content
      expect(find.text('Nikkah.io'), findsOneWidget);
      expect(find.text('Welcome to Nikkah.io'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('MainNavigationScreen has proper navigation structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainNavigationScreen()));

      // Should have IndexedStack for tab management
      expect(find.byType(IndexedStack), findsOneWidget);

      // Should have BottomNavigationBar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('MainNavigationScreen shows activity cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainNavigationScreen()));

      // Should show activity cards
      expect(find.text('Profile Views'), findsOneWidget);
      expect(find.text('New Likes'), findsOneWidget);
      expect(find.text('New Messages'), findsOneWidget);
    });
  });
}
