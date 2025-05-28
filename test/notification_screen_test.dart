import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:Equirent_Mobility/screens/notification_screen.dart";
import "package:Equirent_Mobility/widgets/notification_card.dart";
import "./test_helpers.dart";

void main() {
  // Configurar el mock de SharedPreferences
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    configureTestEnvironment();
    
    // Limpiar notificaciones estáticas antes de cada test
    NotificationScreen.clearAllNotifications();
  });
  
  group("NotificationScreen Tests", () {
    testWidgets("should render NotificationScreen with empty state", (WidgetTester tester) async {
      // Configurar SharedPreferences mock para devolver una lista vacía
      SharedPreferences.setMockInitialValues({"notifications": "[]"});
      
      await tester.pumpWidget(const MaterialApp(
        home: NotificationScreen(),
      ));
      await tester.pumpAndSettle();
      
      // Verificar que se muestra el widget NotificationScreen
      expect(find.byType(NotificationScreen), findsOneWidget);
      
      // Verificar que se muestra el estado vacío con los textos correctos
      expect(find.text("Todo está limpio y vacío por acá"), findsOneWidget);
      expect(find.text("Las notificaciones aparecerán aquí"), findsOneWidget);
    });
    
    testWidgets("should display notifications when available", (WidgetTester tester) async {
      // Añadir una notificación de prueba
      NotificationScreen.addNotification({
        "title": "Test Notification",
        "body": "This is a test notification"
      });
      
      await tester.pumpWidget(const MaterialApp(
        home: NotificationScreen(),
      ));
      await tester.pumpAndSettle();
      
      // Verificar que se muestra la tarjeta de notificación
      expect(find.byType(NotificationCard), findsOneWidget);
      
      // Verificar que se muestra el texto de la notificación
      // El componente NotificationCard muestra el body como text
      expect(find.text("This is a test notification"), findsOneWidget);
    });
    
    test("should track unread notification count", () {
      // Añadir notificaciones de prueba
      NotificationScreen.addNotification({
        "title": "Notification 1",
        "body": "Message 1"
      });
      
      NotificationScreen.addNotification({
        "title": "Notification 2",
        "body": "Message 2"
      });
      
      // Verificar el contador de notificaciones no leídas
      expect(NotificationScreen.getUnreadCount(), equals(2));
      
      // Marcar todas como leídas
      NotificationScreen.markAllAsRead();
      
      // Verificar que el contador se actualiza
      expect(NotificationScreen.getUnreadCount(), equals(0));
    });
    
    test("should notify listeners when notification count changes", () {
      int notificationCount = -1;
      
      // Registrar un listener
      NotificationScreen.addListener((count) {
        notificationCount = count;
      });
      
      // Inicialmente debería ser 0
      expect(notificationCount, equals(0));
      
      // Añadir una notificación
      NotificationScreen.addNotification({
        "title": "New Notification",
        "body": "New Message"
      });
      
      // El listener debería haber sido notificado
      expect(notificationCount, equals(1));
      
      // Limpiar
      NotificationScreen.removeListener((count) {
        notificationCount = count;
      });
    });
  });
}
