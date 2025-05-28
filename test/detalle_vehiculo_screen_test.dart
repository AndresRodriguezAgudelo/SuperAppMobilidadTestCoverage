import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/detalle_vehiculo_screen.dart';

void main() {
  group('DetalleVehiculoScreen Tests', () {
    testWidgets('should render DetalleVehiculoScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: DetalleVehiculoScreen(placa: 'ABC123', vehicleId: 1),
      ));
      expect(find.byType(DetalleVehiculoScreen), findsOneWidget);
    });
  });
}
