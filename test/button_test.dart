import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/button.dart';
import 'test_helpers.dart';

void main() {
  group('Button Widget Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      configureTestEnvironment();
    });

    testWidgets('should render button with text', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      // Construir el widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button(
              text: 'Test Button',
              action: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );
      
      // Verificar que el texto se muestra correctamente
      expect(find.text('Test Button'), findsOneWidget);
      
      // Verificar que el botón es clicable
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Verificar que la acción se ejecutó
      expect(buttonPressed, isTrue);
    });
    
    testWidgets('should render button with custom background color', (WidgetTester tester) async {
      // Construir el widget con color personalizado
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button(
              text: 'Colored Button',
              action: () {},
              backgroundColor: Colors.red,
            ),
          ),
        ),
      );
      
      // Verificar que el texto se muestra correctamente
      expect(find.text('Colored Button'), findsOneWidget);
      
      // Verificar el color del botón
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style as ButtonStyle;
      final backgroundColor = buttonStyle.backgroundColor?.resolve({});
      expect(backgroundColor, equals(Colors.red));
    });
    
    testWidgets('should render button with icon', (WidgetTester tester) async {
      // Construir el widget con icono
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button(
              text: 'Icon Button',
              action: () {},
              icon: Icons.add,
            ),
          ),
        ),
      );
      
      // Verificar que el texto se muestra correctamente
      expect(find.text('Icon Button'), findsOneWidget);
      
      // Verificar que el icono se muestra
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
    
    testWidgets('should render loading state', (WidgetTester tester) async {
      // Construir el widget en estado de carga
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button(
              text: 'Loading Button',
              action: () {},
              isLoading: true,
            ),
          ),
        ),
      );
      
      // Verificar que el indicador de carga se muestra
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Verificar que el texto no se muestra en estado de carga
      expect(find.text('Loading Button'), findsNothing);
      
      // Verificar que el botón está deshabilitado
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
    
    testWidgets('should render with custom height', (WidgetTester tester) async {
      // Construir el widget con altura personalizada
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button(
              text: 'Tall Button',
              action: () {},
              height: 60.0,
            ),
          ),
        ),
      );
      
      // Verificar que el texto se muestra correctamente
      expect(find.text('Tall Button'), findsOneWidget);
      
      // Verificar la altura del botón
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, equals(60.0));
    });
  });
}
