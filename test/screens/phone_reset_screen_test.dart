import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/phone_reset_screen.dart';

void main() {
  group('PhoneResetScreen Tests', () {
    testWidgets('should render PhoneResetScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PhoneResetScreen(),
      ));
      expect(find.byType(PhoneResetScreen), findsOneWidget);
    });
  });
}
