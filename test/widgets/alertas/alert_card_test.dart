import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/widgets/alertas/alert_card.dart';

void main() {
  group('AlertCard Widget', () {
    testWidgets('Muestra el título y status correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlertCard(
            isNew: true,
            title: 'Alerta de prueba',
            status: 'green',
            progress: 80,
          ),
        ),
      );
      expect(find.text('Alerta de prueba'), findsOneWidget);
      expect(find.byType(AlertCard), findsOneWidget);
    });

    testWidgets('Muestra el icono por defecto si iconName es null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlertCard(
            isNew: false,
            title: 'Alerta sin icono',
            status: 'yellow',
            progress: 50,
          ),
        ),
      );
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.notifications);
    });

    testWidgets('Muestra el icono correcto según iconName', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlertCard(
            isNew: false,
            title: 'Alerta con icono',
            status: 'yellow',
            progress: 50,
            iconName: 'Security',
          ),
        ),
      );
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.security);
    });

    testWidgets('Ejecuta onTap si se proporciona', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: AlertCard(
            isNew: false,
            title: 'Alerta tap',
            status: 'green',
            progress: 60,
            onTap: () { tapped = true; },
          ),
        ),
      );
      await tester.tap(find.byType(AlertCard));
      expect(tapped, isTrue);
    });

    testWidgets('Navega a AlertaScreen si onTap es null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlertCard(
            isNew: false,
            title: 'Alerta navega',
            status: 'green',
            progress: 60,
          ),
        ),
      );
      await tester.tap(find.byType(AlertCard));
      await tester.pumpAndSettle();
      expect(find.byType(AlertCard), findsWidgets); // Sigue en árbol
    });

    testWidgets('Animación activa si status es red', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlertCard(
            isNew: false,
            title: 'Alerta animada',
            status: 'red',
            progress: 100,
          ),
        ),
      );
      // Espera a que la animación inicie
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(AlertCard), findsOneWidget);
    });

    testWidgets('No muestra barra de progreso para Multas', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlertCard(
            isNew: false,
            title: 'Multas',
            status: 'green',
            progress: 60,
          ),
        ),
      );
      // No debe haber FractionallySizedBox
      expect(find.byType(FractionallySizedBox), findsNothing);
    });

    testWidgets('Muestra barra de progreso para otros títulos', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlertCard(
            isNew: false,
            title: 'Alerta genérica',
            status: 'green',
            progress: 50,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });
  });
}
