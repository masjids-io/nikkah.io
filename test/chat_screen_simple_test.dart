import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nikkah_io/screens/chat_screen.dart';

void main() {
  group('ChatScreen', () {
    testWidgets('displays app bar with partner info',
        (WidgetTester tester) async {
      final chatPartner = {
        'name': 'Sarah Ahmed',
        'age': 25,
        'location': 'London, UK',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(chatPartner: chatPartner),
        ),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 2));

      // Verify app bar with partner info
      expect(find.text('Sarah Ahmed'), findsOneWidget);
      expect(find.text('25 years old • London, UK'), findsOneWidget);
    });

    testWidgets('displays chat interface elements',
        (WidgetTester tester) async {
      final chatPartner = {
        'name': 'Sarah Ahmed',
        'age': 25,
        'location': 'London, UK',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(chatPartner: chatPartner),
        ),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 2));

      // Verify chat interface elements
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('displays chat interface when no partner provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatScreen(),
        ),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 2));

      // Verify default chat interface is shown
      expect(find.text('Sarah Ahmed'), findsOneWidget);
      expect(find.text('25 years old • London, UK'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
