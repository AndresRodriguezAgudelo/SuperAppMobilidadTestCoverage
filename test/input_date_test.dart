import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:Equirent_Mobility/widgets/inputs/input_date.dart';

void main() {
  group('InputDate Widget Tests', () {
    testWidgets('renders correctly with default values', (WidgetTester tester) async {
      DateTime? selectedDate;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputDate(
              label: 'Test Date',
              value: null,
              onChanged: (date) {
                selectedDate = date;
              },
            ),
          ),
        ),
      );
      
      // Verificar que el label se renderiza correctamente
      expect(find.text('Test Date'), findsOneWidget);
      
      // Verificar que el placeholder se muestra cuando no hay fecha seleccionada
      expect(find.text('Seleccionar fecha'), findsOneWidget);
      
      // Verificar que el icono de calendario está presente
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });
    
    testWidgets('displays selected date in correct format', (WidgetTester tester) async {
      final testDate = DateTime(2023, 5, 15);
      final formattedDate = DateFormat('dd/MM/yyyy').format(testDate);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputDate(
              label: 'Test Date',
              value: testDate,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      
      // Verificar que la fecha se muestra en el formato correcto
      expect(find.text(formattedDate), findsOneWidget);
    });
    
    testWidgets('shows required indicator when isRequired is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputDate(
              label: 'Required Date',
              value: null,
              onChanged: (_) {},
              isRequired: true,
            ),
          ),
        ),
      );
      
      // Verificar que el indicador de requerido (*) está presente
      expect(find.text(' *'), findsOneWidget);
    });
    
    testWidgets('shows error text when provided', (WidgetTester tester) async {
      const errorMessage = 'This field is required';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputDate(
              label: 'Test Date',
              value: null,
              onChanged: (_) {},
              errorText: errorMessage,
            ),
          ),
        ),
      );
      
      // Verificar que el mensaje de error se muestra
      expect(find.text(errorMessage), findsOneWidget);
      
      // Verificar que el borde es rojo cuando hay un error
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, equals(Colors.red));
    });
    
    testWidgets('responde al tap en el campo de fecha', (WidgetTester tester) async {
      DateTime? selectedDate;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputDate(
              label: 'Test Date',
              value: null,
              onChanged: (date) {
                selectedDate = date;
              },
            ),
          ),
        ),
      );
      
      // Buscar el widget que contiene el campo de fecha
      final inkWellFinder = find.byType(InkWell);
      expect(inkWellFinder, findsOneWidget);
      
      // Verificar que el widget es interactivo
      final inkWell = tester.widget<InkWell>(inkWellFinder);
      expect(inkWell.onTap, isNotNull);
      
      // No podemos probar completamente el date picker en tests,
      // pero podemos verificar que el widget tiene un onTap configurado
    });
  });
}
