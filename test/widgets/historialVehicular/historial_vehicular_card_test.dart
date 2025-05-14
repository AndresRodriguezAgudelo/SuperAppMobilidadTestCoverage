import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/historialVehicular/historial_vehicular_card.dart';
import '../../test_helpers.dart';

void main() {
  group('HistorialVehicularCard Tests', () {
    
    setUp(() {
      configureTestEnvironment();
    });
    
    testWidgets('Debe mostrar correctamente una multa contraída', (WidgetTester tester) async {
      final multaData = {
        'numeroMulta': '123456',
        'descripcionInfraccion': 'Exceso de velocidad',
        'fechaInfraccion': '2023-01-15',
        'valorInfraccion': 500000,
        'estado': 'Pendiente',
        'comparendo': {
          'codigoInfraccion': 'C29',
          'direccion': 'Calle 123',
          'localidad': 'Centro',
          'ciudad': 'Bogotá',
        }
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistorialVehicularCard(
              data: multaData,
              isMulta: true,
            ),
          ),
        ),
      );
      
      // Verificar que se muestra el número de multa
      expect(find.text('Infracción #123456'), findsOneWidget);
    });
    
    testWidgets('Debe manejar datos nulos en multas correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistorialVehicularCard(
              data: {},
              isMulta: true,
            ),
          ),
        ),
      );
      
      // Verificar que no falla con datos nulos
      expect(find.text('Infracción #N/A'), findsOneWidget);
    });
  });
}
