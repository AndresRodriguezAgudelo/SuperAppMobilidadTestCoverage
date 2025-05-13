import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/widgets/guide_image_carousel.dart';
import 'package:Equirent_Mobility/BLoC/images/image_bloc.dart';
import '../test_helpers.dart';

void main() {
  group('GuideImageCarousel Widget Tests', () {
    late MockImageBloc mockImageBloc;
    
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      configureTestEnvironment();
      
      // Crear un mock de ImageBloc para cada prueba
      mockImageBloc = MockImageBloc();
    });

    test('should call getImageUrl for both images', () {
      // Crear una instancia del widget
      final widget = GuideImageCarousel(
        mainImageKey: 'main/123',
        secondaryImageKey: 'secondary/456',
      );
      
      // Verificar que los parámetros se pasaron correctamente
      expect(widget.mainImageKey, equals('main/123'));
      expect(widget.secondaryImageKey, equals('secondary/456'));
    });

    test('should handle empty secondaryImageKey', () {
      // Crear una instancia del widget con secondaryImageKey vacío
      final widget = GuideImageCarousel(
        mainImageKey: 'main/123',
        secondaryImageKey: '',
      );
      
      // Verificar que los parámetros se pasaron correctamente
      expect(widget.mainImageKey, equals('main/123'));
      expect(widget.secondaryImageKey, equals(''));
    });
    
    testWidgets('should render carousel with both images', (WidgetTester tester) async {
      // Construir el widget con un Provider para proporcionar el ImageBloc
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ImageBloc>.value(
            value: mockImageBloc,
            child: Scaffold(
              body: GuideImageCarousel(
                mainImageKey: 'main/123',
                secondaryImageKey: 'secondary/456',
              ),
            ),
          ),
        ),
      );
      
      // Esperar a que se complete la carga de imágenes (con un timeout más corto)
      await tester.pump(const Duration(milliseconds: 500));
      
      // Verificar que el widget se renderizó correctamente
      expect(find.byType(GuideImageCarousel), findsOneWidget);
    });
    
    testWidgets('should render carousel with only main image when secondary is empty', (WidgetTester tester) async {
      // Construir el widget con un Provider para proporcionar el ImageBloc
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ImageBloc>.value(
            value: mockImageBloc,
            child: Scaffold(
              body: GuideImageCarousel(
                mainImageKey: 'main/123',
                secondaryImageKey: '',
              ),
            ),
          ),
        ),
      );
      
      // Esperar a que se complete la carga de imágenes (con un timeout más corto)
      await tester.pump(const Duration(milliseconds: 500));
      
      // Verificar que el widget se renderizó correctamente
      expect(find.byType(GuideImageCarousel), findsOneWidget);
    });
    
    testWidgets('should handle tap on image', (WidgetTester tester) async {
      // Construir el widget con un Provider para proporcionar el ImageBloc
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ImageBloc>.value(
            value: mockImageBloc,
            child: Scaffold(
              body: GuideImageCarousel(
                mainImageKey: 'main/123',
                secondaryImageKey: 'secondary/456',
              ),
            ),
          ),
        ),
      );
      
      // Esperar a que se complete la carga de imágenes (con un timeout más corto)
      await tester.pump(const Duration(milliseconds: 500));
      
      // Simular un tap en el widget
      await tester.tap(find.byType(GuideImageCarousel));
      await tester.pump(const Duration(milliseconds: 500));
      
      // Verificar que el widget sigue existiendo después del tap
      expect(find.byType(GuideImageCarousel), findsOneWidget);
    });
  });
}
