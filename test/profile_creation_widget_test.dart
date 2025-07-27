import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/screens/profile_creation_screen.dart';

void main() {
  group('ProfileCreationScreen Widget Tests', () {
    testWidgets('ProfileCreationScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileCreationScreen()));

      // Verify initial screen elements
      expect(find.text('Create Profile'), findsOneWidget);
      expect(find.text('Tell us about yourself'), findsOneWidget);
      expect(find.text('Let\'s start with your basic information'),
          findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Verify step indicator
      expect(find.text('Basic Info'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Birth Date'), findsOneWidget);
    });

    testWidgets('Form field accepts text input', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileCreationScreen()));

      // Find the text field and enter text
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'John Doe');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('John Doe'), findsOneWidget);
    });
  });
}
