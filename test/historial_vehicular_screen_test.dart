import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/historial_vehicular_screen.dart';

void main() {
  group('HistorialVehicularScreen Tests', () {
    testWidgets('should render HistorialVehicularScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: HistorialVehicularScreen(placa: 'ABC123'),
      ));
      expect(find.byType(HistorialVehicularScreen), findsOneWidget);
    });
  });
}
