import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/cambio_llantas_screen.dart';

void main() {
  group('CambioLlantasScreen Tests', () {
    testWidgets('should render CambioLlantasScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CambioLlantasScreen(alertId: 1),
      ));
      expect(find.byType(CambioLlantasScreen), findsOneWidget);
    });
  });
}
