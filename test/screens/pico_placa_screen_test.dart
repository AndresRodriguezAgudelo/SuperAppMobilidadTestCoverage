import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/pico_placa_screen.dart';

void main() {
  group('PicoPlacaScreen Tests', () {
    testWidgets('should render PicoPlacaScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PicoPlacaScreen(alertId: 1),
      ));
      expect(find.byType(PicoPlacaScreen), findsOneWidget);
    });
  });
}
