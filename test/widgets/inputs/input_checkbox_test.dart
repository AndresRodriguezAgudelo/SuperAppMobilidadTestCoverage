import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/inputs/input_checkbox.dart';

void main() {
  group('InputCheckbox Widget Tests', () {
    testWidgets('renders correctly with default values', (WidgetTester tester) async {
      bool value = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputCheckbox(
              value: value,
              label: 'Test Checkbox',
              onChanged: (val) {
                value = val;
              },
            ),
          ),
        ),
      );
      
      // Verificar que el checkbox se renderiza correctamente
      expect(find.text('Test Checkbox'), findsOneWidget);
      expect(find.byType(InputCheckbox), findsOneWidget);
      
      // Verificar que el checkbox está en la posición predeterminada (izquierda)
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, equals(3)); // checkbox, spacer, label
    });
    
    testWidgets('changes value when tapped', (WidgetTester tester) async {
      bool value = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return InputCheckbox(
                  value: value,
                  label: 'Test Checkbox',
                  onChanged: (val) {
                    setState(() {
                      value = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      
      // Verificar estado inicial
      expect(value, isFalse);
      
      // Tap en el checkbox
      await tester.tap(find.byType(InputCheckbox));
      await tester.pump();
      
      // Verificar que el valor cambió
      expect(value, isTrue);
      
      // Tap de nuevo
      await tester.tap(find.byType(InputCheckbox));
      await tester.pump();
      
      // Verificar que el valor volvió a cambiar
      expect(value, isFalse);
    });
    
    testWidgets('renders with right position', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputCheckbox(
              value: true,
              label: 'Right Checkbox',
              onChanged: (_) {},
              position: CheckboxPosition.right,
            ),
          ),
        ),
      );
      
      // Verificar que el checkbox se renderiza correctamente
      expect(find.text('Right Checkbox'), findsOneWidget);
      
      // Verificar que el orden de los elementos es correcto (label, spacer, checkbox)
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, equals(3));
      expect(row.children[0], isA<Expanded>());
      expect(row.children[2], isNot(isA<Expanded>()));
    });
    
    testWidgets('applies custom colors correctly', (WidgetTester tester) async {
      const customActiveColor = Colors.red;
      const customBorderColor = Colors.green;
      const customTextColor = Colors.blue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputCheckbox(
              value: true,
              label: 'Custom Colors',
              onChanged: (_) {},
              activeColor: customActiveColor,
              borderColor: customBorderColor,
              textColor: customTextColor,
              fontSize: 18,
            ),
          ),
        ),
      );
      
      // Verificar que el texto tiene el color y tamaño correctos
      final textWidget = tester.widget<Text>(find.text('Custom Colors'));
      expect(textWidget.style!.color, equals(customTextColor));
      expect(textWidget.style!.fontSize, equals(18));
      
      // El container del checkbox debe tener el color activo
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customActiveColor));
    });
  });
}
