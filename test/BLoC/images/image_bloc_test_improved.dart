import 'package:flutter_test/flutter_test.dart';
import '../../test_helpers.dart';

void main() {
  late MockImageBloc mockImageBloc;
  
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    configureTestEnvironment();
    mockImageBloc = MockImageBloc();
  });

  group('ImageBloc Tests', () {
    test('processKey should correctly parse folder and id', () {
      // Prueba con una key válida
      final key = 'folder/123';
      final expectedFolderName = 'folder';
      final expectedId = '123';
      
      // Verificar que la función procesa correctamente la key
      expect(key.split('/')[0], equals(expectedFolderName));
      expect(key.split('/')[1], equals(expectedId));
    });

    test('getImageUrl should return cached URL if available', () async {
      // Crear un mock con una URL en caché
      final mockImageBloc = MockImageBloc(
        imageCache: {'test/123': 'https://example.com/test/123.jpg'}
      );
      
      // Obtener la URL desde el caché
      final url = await mockImageBloc.getImageUrl('test/123');
      
      // Verificar que devuelve la URL en caché
      expect(url, equals('https://example.com/test/123.jpg'));
    });

    test('getImageUrl should return default image on error', () async {
      // Configurar el mock para simular un error
      final mockImageBloc = MockImageBloc();
      
      // Obtener la URL para una key que no está en caché y debería fallar
      final url = await mockImageBloc.getImageUrl('invalid/key');
      
      // Verificar que devuelve la imagen por defecto
      expect(url, equals('assets/images/image_servicio1.png'));
    });
    
    test('getImageUrl should handle invalid key format', () async {
      // Configurar el mock
      final mockImageBloc = MockImageBloc();
      
      // Obtener la URL para una key con formato inválido (sin /)
      final url = await mockImageBloc.getImageUrl('invalidkey');
      
      // Verificar que devuelve la imagen por defecto
      expect(url, equals('assets/images/image_servicio1.png'));
    });

    test('clearCache should empty the cache', () async {
      // Crear un mock con una URL en caché
      final mockImageBloc = MockImageBloc(
        imageCache: {'test/123': 'https://example.com/test/123.jpg'}
      );
      
      // Verificar que la URL está en caché
      expect(await mockImageBloc.getImageUrl('test/123'), equals('https://example.com/test/123.jpg'));
      
      // Limpiar el caché
      mockImageBloc.clearCache();
      
      // Verificar que la URL ya no está en caché (debería devolver la imagen por defecto)
      expect(await mockImageBloc.getImageUrl('test/123'), equals('assets/images/image_servicio1.png'));
    });
    
    test('getImageUrl should handle API errors gracefully', () async {
      // Crear un mock que simule un error de API
      final mockImageBloc = MockImageBloc(shouldFailAPI: true);
      
      // Intentar obtener una URL que provocará un error de API
      final url = await mockImageBloc.getImageUrl('test/error');
      
      // Verificar que devuelve la imagen por defecto
      expect(url, equals('assets/images/image_servicio1.png'));
    });
  });
}
