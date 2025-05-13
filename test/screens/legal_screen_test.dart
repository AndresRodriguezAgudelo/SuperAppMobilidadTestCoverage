import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/legal_screen.dart';

void main() {
  group('LegalScreen Tests', () {
    testWidgets('should render LegalScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LegalScreen(),
      ));
      expect(find.byType(LegalScreen), findsOneWidget);
    });
  });
}
