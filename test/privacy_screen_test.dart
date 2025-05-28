import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/privacy_screen.dart';

void main() {
  group('PrivacyScreen Tests', () {
    testWidgets('should render PrivacyScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PrivacyScreen(),
      ));
      expect(find.byType(PrivacyScreen), findsOneWidget);
    });
  });
}
