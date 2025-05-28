import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/poliza_todo_riesgo_screen.dart';

void main() {
  group('PolizaTodoRiesgoScreen Tests', () {
    testWidgets('should render PolizaTodoRiesgoScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PolizaTodoRiesgoScreen(alertId: 1),
      ));
      expect(find.byType(PolizaTodoRiesgoScreen), findsOneWidget);
    });
  });
}
