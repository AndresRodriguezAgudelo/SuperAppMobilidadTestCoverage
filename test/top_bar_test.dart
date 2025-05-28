import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/top_bar.dart';
import 'test_helpers.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    configureTestEnvironment();
  });

  group('TopBar Widget Tests', () {
    testWidgets('renders correctly with baseScreen type', (WidgetTester tester) async {
      bool menuPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopBar(
              screenType: ScreenType.baseScreen,
              onMenuPressed: () {
                menuPressed = true;
              },
            ),
          ),
        ),
      );
      
      // Verificar que el logo se muestra
      expect(find.byType(Image), findsOneWidget);
      
      // Verificar que el icono de menú está presente
      expect(find.byIcon(Icons.menu), findsOneWidget);
      
      // Verificar que el icono de notificaciones está presente
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      
      // Tap en el icono de menú
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();
      
      // Verificar que se ejecutó el callback
      expect(menuPressed, isTrue);
    });
    
    testWidgets('renders correctly with progressScreen type', (WidgetTester tester) async {
      bool backPressed = false;
      const testTitle = 'Test Title';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopBar(
              screenType: ScreenType.progressScreen,
              title: testTitle,
              onBackPressed: () {
                backPressed = true;
              },
            ),
          ),
        ),
      );
      
      // Verificar que el título se muestra
      expect(find.text(testTitle), findsOneWidget);
      
      // Verificar que el icono de retroceso está presente
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Verificar que el icono de notificaciones no está presente
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);
      
      // Tap en el icono de retroceso
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      
      // Verificar que se ejecutó el callback
      expect(backPressed, isTrue);
    });
    
    testWidgets('renders correctly with homeScreen type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopBar(
              screenType: ScreenType.homeScreen,
            ),
          ),
        ),
      );
      
      // Verificar que el icono de notificaciones está presente
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
    
    testWidgets('navigates to notification screen when notification icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/notifications': (context) => const Scaffold(
              body: Text('Notification Screen'),
            ),
          },
          home: Scaffold(
            body: TopBar(
              screenType: ScreenType.baseScreen,
            ),
          ),
        ),
      );
      
      // Tap en el icono de notificaciones
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();
      
      // Verificar que se navegó a la pantalla de notificaciones
      expect(find.text('Notification Screen'), findsOneWidget);
    });
    
    testWidgets('renders custom action items when provided', (WidgetTester tester) async {
      const testActionText = 'Custom Action';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopBar(
              screenType: ScreenType.baseScreen,
              actionItems: [
                TextButton(
                  onPressed: () {},
                  child: const Text(testActionText),
                ),
              ],
            ),
          ),
        ),
      );
      
      // Verificar que el elemento de acción personalizado se muestra
      expect(find.text(testActionText), findsOneWidget);
      
      // Verificar que el icono de notificaciones no está presente (reemplazado por el elemento personalizado)
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);
    });
  });
}
