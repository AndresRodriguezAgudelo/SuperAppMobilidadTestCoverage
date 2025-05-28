import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:Equirent_Mobility/widgets/historialVehicular/historial_vehicular_lista_data.dart";
import "./test_helpers.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group("ListaDataHistorialVehicular Tests", () {
    
    setUp(() {
      // Configuramos el entorno de prueba antes de cada test
      configureTestEnvironment();
    });
    
    tearDown(() {
      // Limpieza después de cada test para evitar efectos secundarios
    });
    
    test("Debe manejar lista vacía correctamente", () {
      // Crear una instancia del widget con lista vacía
      final widget = ListaDataHistorialVehicular(data: []);
      
      // Verificar que el widget se crea correctamente
      expect(widget, isA<StatelessWidget>());
      expect(widget.data, isEmpty);
    });
    
    test("Debe manejar datos correctamente", () {
      final testData = [
        {"label": "Nombre", "value": "Juan Pérez"},
        {"label": "Edad", "value": "30"},
        {"label": "Activo", "value": true},
      ];
      
      // Crear una instancia del widget con datos
      final widget = ListaDataHistorialVehicular(data: List<Map<String, dynamic>>.from(testData));
      
      // Verificar que el widget se crea correctamente
      expect(widget, isA<StatelessWidget>());
      expect(widget.data.length, equals(3));
      
      // Verificar que los datos son correctos
      expect(widget.data[0]["label"], equals("Nombre"));
      expect(widget.data[0]["value"], equals("Juan Pérez"));
      expect(widget.data[1]["label"], equals("Edad"));
      expect(widget.data[1]["value"], equals("30"));
      expect(widget.data[2]["label"], equals("Activo"));
      expect(widget.data[2]["value"], equals(true));
    });
    
    test("Debe manejar valores booleanos correctamente", () {
      final testData = [
        {"label": "Aprobado", "value": true},
        {"label": "Rechazado", "value": false},
      ];
      
      // Crear una instancia del widget con datos booleanos
      final widget = ListaDataHistorialVehicular(data: List<Map<String, dynamic>>.from(testData));
      
      // Verificar que el widget se crea correctamente
      expect(widget, isA<StatelessWidget>());
      
      // Verificar que los valores booleanos son correctos
      expect(widget.data[0]["value"], isTrue);
      expect(widget.data[1]["value"], isFalse);
    });
    
    test("Debe manejar múltiples elementos correctamente", () {
      final testData = [
        {"label": "Item 1", "value": "Valor 1"},
        {"label": "Item 2", "value": "Valor 2"},
      ];
      
      // Crear una instancia del widget con múltiples elementos
      final widget = ListaDataHistorialVehicular(data: List<Map<String, dynamic>>.from(testData));
      
      // Verificar que el widget se crea correctamente
      expect(widget, isA<StatelessWidget>());
      expect(widget.data.length, equals(2));
    });
  });
}
