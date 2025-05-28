import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/cambio_aceite_screen.dart';

void main() {
  group('CambioAceiteScreen Tests', () {
    testWidgets('should render CambioAceiteScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CambioAceiteScreen(alertId: 1),
      ));
      expect(find.byType(CambioAceiteScreen), findsOneWidget);
    });
  });
}
