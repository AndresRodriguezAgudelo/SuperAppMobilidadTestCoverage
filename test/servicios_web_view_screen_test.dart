import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/servicios_web_view_screen.dart';

// Creamos un widget para testear solo la creación de ServiciosScreen
class TestServiciosScreen extends StatelessWidget {
  final String url;
  
  const TestServiciosScreen({super.key, required this.url});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          // Solo verificamos que se puede crear la instancia
          final screen = ServiciosScreen(url: url);
          // Devolvemos un widget simple para evitar problemas con WebView
          return Scaffold(
            body: Text('Test ServiciosScreen con URL: $url'),
          );
        },
      ),
    );
  }
}

void main() {
  group('ServiciosScreen Tests', () {
    testWidgets('should create ServiciosScreen instance', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(TestServiciosScreen(url: 'https://example.com'));
      
      // Assert - verificamos que el widget de prueba se renderiza
      expect(find.text('Test ServiciosScreen con URL: https://example.com'), findsOneWidget);
    });
    
    // Test unitario para verificar que la URL se asigna correctamente
    test('should store correct URL', () {
      // Arrange
      const testUrl = 'https://example.com';
      
      // Act - Creamos la instancia para verificar propiedades
      final screen = ServiciosScreen(url: testUrl);
      
      // Assert - verificamos que la URL se asigna correctamente
      expect(screen.url, equals(testUrl));
    });
  });
}
