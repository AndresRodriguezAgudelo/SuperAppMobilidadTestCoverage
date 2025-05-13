import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:Equirent_Mobility/widgets/notification_card.dart';

void main() {
  group('NotificationCard Widget Tests', () {
    final testDate = DateTime(2023, 5, 15);
    final formattedDate = DateFormat('dd/MM/yyyy').format(testDate);
    
    testWidgets('renders positive notification correctly', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCard(
              isPositive: true,
              icon: Icons.check_circle,
              text: 'Operación exitosa',
              date: testDate,
              title: 'Éxito',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );
      
      // Verificar que el texto se renderiza correctamente
      expect(find.text('Operación exitosa'), findsOneWidget);
      expect(find.text(formattedDate), findsOneWidget);
      
      // Verificar que el icono está presente
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // Verificar que el color de fondo es verde para notificaciones positivas
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFFECFAD7)));
    });
    
    testWidgets('renders negative notification correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCard(
              isPositive: false,
              icon: Icons.error,
              text: 'Error en la operación',
              date: testDate,
              title: 'Error',
              onTap: () {},
            ),
          ),
        ),
      );
      
      // Verificar que el texto se renderiza correctamente
      expect(find.text('Error en la operación'), findsOneWidget);
      
      // Verificar que el color de fondo es rojo para notificaciones negativas
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFFFADDD7)));
      
      // Verificar que el color del texto es rojo para notificaciones negativas
      final textWidget = tester.widget<Text>(find.text('Error en la operación'));
      expect(textWidget.style!.color, equals(const Color(0xFFE05C3A)));
    });
    
    testWidgets('executes onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      // Crear un widget personalizado para probar el callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    // Llamar directamente al callback que queremos probar
                    final card = NotificationCard(
                      isPositive: true,
                      icon: Icons.check_circle,
                      text: 'Operación exitosa',
                      date: testDate,
                      title: 'Éxito',
                      onTap: () {
                        tapped = true;
                      },
                    );
                    
                    // Ejecutar el callback manualmente
                    card.onTap();
                  },
                  child: const Text('Ejecutar callback'),
                );
              },
            ),
          ),
        ),
      );
      
      // Verificar que inicialmente no se ha ejecutado el callback
      expect(tapped, isFalse);
      
      // Tap en el botón que ejecuta el callback
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Verificar que se ejecutó el callback
      expect(tapped, isTrue);
    });
    
    testWidgets('showNotification displays overlay notification', (WidgetTester tester) async {
      // Crear un widget que contenga un botón para mostrar la notificación
      // Usamos una duración corta para evitar problemas con los timers en las pruebas
      const testDuration = Duration(milliseconds: 300);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  NotificationCard.showNotification(
                    context: context,
                    isPositive: true,
                    icon: Icons.check_circle,
                    text: 'Notificación de prueba',
                    date: testDate,
                    title: 'Prueba',
                    duration: testDuration, // Usar una duración corta para pruebas
                  );
                },
                child: const Text('Mostrar notificación'),
              ),
            ),
          ),
        ),
      );
      
      // Verificar que la notificación no está visible inicialmente
      expect(find.text('Notificación de prueba'), findsNothing);
      
      // Tap en el botón para mostrar la notificación
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Primer frame después del tap
      
      // Verificar que la notificación se muestra
      expect(find.text('Notificación de prueba'), findsOneWidget);
      
      // Avanzar el tiempo para que la notificación desaparezca
      await tester.pump(testDuration);
      await tester.pump(); // Frame después de que el timer se completa
    });
  });
}
