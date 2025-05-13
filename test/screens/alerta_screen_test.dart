import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/alerta_screen.dart';

void main() {
  group('AlertaScreen Tests', () {
    testWidgets('should render AlertaScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AlertaScreen(),
      ));
      expect(find.byType(AlertaScreen), findsOneWidget);
    });
  });
}
