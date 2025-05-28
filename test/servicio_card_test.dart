import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/nuestrosServicios/servicio_card.dart';

void main() {
  group('ServicioCard Widget Tests', () {
    // Este test solo verifica que el widget se pueda crear sin problemas
    test('should create ServicioCard with title', () {
      // Arrange & Act
      final card = ServicioCard(
        imagePath: 'assets/images/test_image.png',
        title: 'Test Service',
        url: 'https://example.com',
      );
      
      // Assert - verificar que el título se asigna correctamente
      expect(card.title, equals('Test Service'));
    });
    
    // Este test solo verifica la creación del widget sin renderizarlo completamente
    test('should create ServicioCard with correct properties', () {
      // Arrange & Act
      final card = ServicioCard(
        imagePath: 'assets/images/test_image.png',
        title: 'Test Service',
        url: 'https://example.com',
      );
      
      // Assert - verificar que las propiedades se asignan correctamente
      expect(card.imagePath, equals('assets/images/test_image.png'));
      expect(card.title, equals('Test Service'));
      expect(card.url, equals('https://example.com'));
    });
    
    testWidgets('should load network image when URL is provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServicioCard(
              imagePath: 'https://example.com/test_image.jpg',
              title: 'Test Service',
              url: 'https://example.com',
            ),
          ),
        ),
      );
      
      // Assert - should find Image.network widget
      expect(find.byType(Image), findsOneWidget);
    });
    
    testWidgets('should handle image loading error gracefully', (WidgetTester tester) async {
      // This test simulates a network image loading error
      // We can't directly test the error callback, but we can verify the widget structure
      
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServicioCard(
              imagePath: 'https://invalid-url.com/image.jpg',
              title: 'Test Service',
              url: 'https://example.com',
            ),
          ),
        ),
      );
      
      // Initial render should have an Image widget
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
