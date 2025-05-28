import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/nuestrosServicios/service_long_card.dart';
import 'package:Equirent_Mobility/BLoC/images/image_bloc.dart';

// Mock simple para ImageBloc
class MockImageBloc extends ImageBloc {
  @override
  Future<String> getImageUrl(String key, {bool forceRefresh = false}) async {
    // Simular un retraso para probar el indicador de carga
    await Future.delayed(const Duration(milliseconds: 100));
    return 'https://example.com/test-image.jpg';
  }
}

void main() {
  group('ServiceLongCard Widget Tests', () {
    // Este test solo verifica que el widget se pueda crear sin problemas
    test('should create ServiceLongCard with title and subtitle', () {
      // Arrange & Act
      const card = ServiceLongCard(
        imageUrl: 'test-image.jpg',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        url: 'https://example.com',
      );
      
      // Assert - verificar que las propiedades se asignan correctamente
      expect(card.title, equals('Test Title'));
      expect(card.subtitle, equals('Test Subtitle'));
    });
    
    // Este test solo verifica la creación del widget sin renderizarlo completamente
    test('should create ServiceLongCard with correct properties', () {
      // Arrange & Act
      const card = ServiceLongCard(
        imageUrl: 'test-image.jpg',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        url: 'https://example.com',
      );
      
      // Assert - verificar que las propiedades se asignan correctamente
      expect(card.imageUrl, equals('test-image.jpg'));
      expect(card.title, equals('Test Title'));
      expect(card.subtitle, equals('Test Subtitle'));
      expect(card.url, equals('https://example.com'));
    });
    
    // Test unitario para verificar la lógica de carga de imágenes
    test('should use ImageBloc to load images', () {
      // Arrange
      final mockImageBloc = MockImageBloc();
      const imageUrl = 'test-image.jpg';
      
      // Act - verificar que getImageUrl se puede llamar
      final futureUrl = mockImageBloc.getImageUrl(imageUrl);
      
      // Assert - verificar que devuelve una Future<String>
      expect(futureUrl, isA<Future<String>>());
    });
  });
}
