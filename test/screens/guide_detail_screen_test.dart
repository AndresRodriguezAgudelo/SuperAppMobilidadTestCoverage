import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/guide_detail_screen.dart';

void main() {
  group('GuideDetailScreen Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('should accept required parameters', () {
      // Arrange
      const title = 'Test Guide Title';
      const content = 'Test guide content description';
      const tag = 'Test Tag';
      const image = 'main/123';
      const date = '2025-03-30';
      
      // Act - Crear una instancia de la pantalla
      final screen = GuideDetailScreen(
        title: title,
        content: content,
        tag: tag,
        image: image,
        date: date,
      );
      
      // Assert - Verificar que los parámetros se pasaron correctamente
      expect(screen.title, equals(title));
      expect(screen.content, equals(content));
      expect(screen.tag, equals(tag));
      expect(screen.image, equals(image));
      expect(screen.date, equals(date));
    });

    test('should accept optional secondaryImage parameter', () {
      // Arrange
      const title = 'Test Guide Title';
      const content = 'Test guide content description';
      const tag = 'Test Tag';
      const image = 'main/123';
      const secondaryImage = 'secondary/456';
      const date = '2025-03-30';
      
      // Act - Crear una instancia de la pantalla con imagen secundaria
      final screen = GuideDetailScreen(
        title: title,
        content: content,
        tag: tag,
        image: image,
        date: date,
        secondaryImage: secondaryImage,
      );
      
      // Assert - Verificar que el parámetro opcional se pasó correctamente
      expect(screen.secondaryImage, equals(secondaryImage));
    });

    test('should accept optional videoKey parameter', () {
      // Arrange
      const title = 'Test Guide Title';
      const content = 'Test guide content description';
      const tag = 'Test Tag';
      const image = 'main/123';
      const videoKey = 'video/789';
      const date = '2025-03-30';
      
      // Act - Crear una instancia de la pantalla con video
      final screen = GuideDetailScreen(
        title: title,
        content: content,
        tag: tag,
        image: image,
        date: date,
        videoKey: videoKey,
      );
      
      // Assert - Verificar que el parámetro opcional se pasó correctamente
      expect(screen.videoKey, equals(videoKey));
    });

    test('should have null secondaryImage by default', () {
      // Arrange
      const title = 'Test Guide Title';
      const content = 'Test guide content description';
      const tag = 'Test Tag';
      const image = 'main/123';
      const date = '2025-03-30';
      
      // Act - Crear una instancia de la pantalla sin imagen secundaria
      final screen = GuideDetailScreen(
        title: title,
        content: content,
        tag: tag,
        image: image,
        date: date,
      );
      
      // Assert - Verificar que secondaryImage sea null por defecto
      expect(screen.secondaryImage, isNull);
    });
  });
}
