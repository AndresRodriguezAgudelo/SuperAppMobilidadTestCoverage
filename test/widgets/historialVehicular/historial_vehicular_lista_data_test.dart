import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/historialVehicular/historial_vehicular_lista_data.dart';
import '../../test_helpers.dart';

void main() {
  group('ListaDataHistorialVehicular Tests', () {
    
    setUp(() {
      configureTestEnvironment();
    });
    
    testWidgets('Debe mostrar mensaje cuando la lista está vacía', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListaDataHistorialVehicular(
              data: [],
            ),
          ),
        ),
      );
      
      // Verificar que se muestra el mensaje de datos no disponibles
      expect(find.text('Estos datos no están disponibles por ahora'), findsOneWidget);
      
      // Verificar que se muestra el icono de información
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
    
    testWidgets('Debe mostrar los datos correctamente', (WidgetTester tester) async {
      final testData = [
        {'label': 'Nombre', 'value': 'Juan Pérez'},
        {'label': 'Edad', 'value': '30'},
        {'label': 'Activo', 'value': true},
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListaDataHistorialVehicular(
              data: testData,
            ),
          ),
        ),
      );
      
      // Verificar que se muestran las etiquetas
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Edad'), findsOneWidget);
      expect(find.text('Activo'), findsOneWidget);
      
      // Verificar que se muestran los valores
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      
      // Verificar que se muestra el icono de check para el valor booleano true
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
    
    testWidgets('Debe mostrar el icono correcto para valores booleanos', (WidgetTester tester) async {
      final testData = [
        {'label': 'Aprobado', 'value': true},
        {'label': 'Rechazado', 'value': false},
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListaDataHistorialVehicular(
              data: testData,
            ),
          ),
        ),
      );
      
      // Verificar que se muestra el icono de check para true
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // Verificar que se muestra el icono de cancel para false
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });
    
    testWidgets('Debe mostrar separadores entre los elementos', (WidgetTester tester) async {
      final testData = [
        {'label': 'Item 1', 'value': 'Valor 1'},
        {'label': 'Item 2', 'value': 'Valor 2'},
        {'label': 'Item 3', 'value': 'Valor 3'},
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListaDataHistorialVehicular(
              data: testData,
            ),
          ),
        ),
      );
      
      // Verificar que se muestran los separadores (dividers)
      // Debe haber 2 separadores para 3 elementos
      expect(find.byType(Divider), findsNWidgets(2));
    });
  });
}
