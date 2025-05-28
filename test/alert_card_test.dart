import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:Equirent_Mobility/widgets/alertas/alert_card.dart";

void main() {
  group("AlertCard - Tests de Propiedades", () {
    test("Crear AlertCard con valores básicos", () {
      // Crear una instancia del widget con valores básicos
      AlertCard widget = const AlertCard(
        isNew: false,
        title: "Alerta de prueba",
        status: "Vigente",
        progress: 80,
      );
      
      // Verificar que el widget se crea correctamente
      expect(widget, isA<StatefulWidget>());
      expect(widget.isNew, isFalse);
      expect(widget.title, equals("Alerta de prueba"));
      expect(widget.status, equals("Vigente"));
      expect(widget.progress, equals(80));
      expect(widget.onTap, isNull);
      expect(widget.iconName, isNull);
      expect(widget.id, isNull);
      expect(widget.isSpecial, isFalse);
    });
    
    test("Crear AlertCard con todos los parámetros", () {
      // Crear una fecha de prueba
      DateTime testDate = DateTime(2023, 5, 15);
      
      // Crear una función onTap de prueba
      void testOnTap() {}
      
      // Crear una instancia del widget con todos los parámetros
      AlertCard widget = AlertCard(
        isNew: true,
        title: "Alerta completa",
        status: "Vencido",
        progress: 50,
        onTap: testOnTap,
        iconName: "warning",
        id: 123,
        isSpecial: true,
        fecha: testDate,
      );
      
      // Verificar que el widget se crea correctamente con todos los parámetros
      expect(widget.isNew, isTrue);
      expect(widget.title, equals("Alerta completa"));
      expect(widget.status, equals("Vencido"));
      expect(widget.progress, equals(50));
      expect(widget.onTap, equals(testOnTap));
      expect(widget.iconName, equals("warning"));
      expect(widget.id, equals(123));
      expect(widget.isSpecial, isTrue);
    });
    
    test("Verificar diferentes estados de alerta", () {
      // Crear alertas con diferentes estados
      AlertCard greenAlert = const AlertCard(
        isNew: false,
        title: "Alerta verde",
        status: "Vigente",
        progress: 100,
      );
      
      AlertCard yellowAlert = const AlertCard(
        isNew: false,
        title: "Alerta amarilla",
        status: "Por vencer",
        progress: 50,
      );
      
      AlertCard redAlert = const AlertCard(
        isNew: false,
        title: "Alerta roja",
        status: "Vencido",
        progress: 20,
      );
      
      // Verificar los estados
      expect(greenAlert.status, equals("Vigente"));
      expect(yellowAlert.status, equals("Por vencer"));
      expect(redAlert.status, equals("Vencido"));
    });
    
    test("Verificar diferentes iconos", () {
      // Crear alertas con diferentes iconos
      AlertCard warningAlert = const AlertCard(
        isNew: false,
        title: "Alerta de advertencia",
        status: "Por vencer",
        progress: 50,
        iconName: "warning",
      );
      
      AlertCard carAlert = const AlertCard(
        isNew: false,
        title: "Alerta de vehículo",
        status: "Vigente",
        progress: 80,
        iconName: "car",
      );
      
      // Verificar los iconos
      expect(warningAlert.iconName, equals("warning"));
      expect(carAlert.iconName, equals("car"));
    });
    
    test("Verificar alertas especiales", () {
      // Crear una alerta especial
      AlertCard specialAlert = const AlertCard(
        isNew: true,
        title: "Alerta especial",
        status: "Vencido",
        progress: 30,
        isSpecial: true,
      );
      
      // Verificar que es una alerta especial
      expect(specialAlert.isSpecial, isTrue);
    });
    
    test("Verificar la estructura de createState()", () {
      // Crear una instancia del widget
      AlertCard widget = const AlertCard(
        isNew: false,
        title: "Alerta de prueba",
        status: "Vigente",
        progress: 80,
      );
      
      // Verificar que createState() devuelve una instancia de State
      State<AlertCard> state = widget.createState();
      expect(state, isA<State<AlertCard>>());
    });
  });
}
