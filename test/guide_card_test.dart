import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/BLoC/images/image_bloc.dart';
import 'package:Equirent_Mobility/widgets/guide_card.dart';
import 'test_helpers.dart';

void main() {
  group('GuideCard Widget Tests', () {
    late MockImageBloc mockImageBloc;
    
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      configureTestEnvironment();
      
      // Crear un mock de ImageBloc para cada prueba
      mockImageBloc = MockImageBloc(
        imageCache: {
          'test/image': 'https://example.com/image.jpg',
        },
      );
    });

    testWidgets('should render card with title and image', (WidgetTester tester) async {
      // Construir el widget con un Provider para proporcionar el ImageBloc
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ImageBloc>.value(
            value: mockImageBloc,
            child: const Scaffold(
              body: GuideCard(
                title: 'Test Guide',
                imageKey: 'test/image',
                date: '01 Mar 2025',
                tag: 'Test',
                content: 'Test content',
              ),
            ),
          ),
        ),
      );
      
      // Esperar a que se complete la carga de imágenes
      await tester.pump(const Duration(milliseconds: 500));
      
      // Verificar que el título se muestra correctamente
      expect(find.text('Test Guide'), findsOneWidget);
      
      // Verificar que la fecha se muestra correctamente
      expect(find.text('01 Mar 2025'), findsOneWidget);
    });
    
    testWidgets('should render card with tap detector', (WidgetTester tester) async {
      // Construir el widget con un Provider para proporcionar el ImageBloc
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ImageBloc>.value(
            value: mockImageBloc,
            child: const Scaffold(
              body: GuideCard(
                title: 'Test Guide',
                imageKey: 'test/image',
                date: '01 Mar 2025',
                tag: 'Test',
                content: 'Test content',
              ),
            ),
          ),
        ),
      );
      
      // Esperar a que se complete la carga de imágenes
      await tester.pump(const Duration(milliseconds: 500));
      
      // Verificar que el GestureDetector está presente para manejar taps
      expect(find.byType(GestureDetector), findsOneWidget);
    });
    
    testWidgets('should handle image loading error', (WidgetTester tester) async {
      // Construir el widget con un Provider para proporcionar el ImageBloc
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ImageBloc>.value(
            value: mockImageBloc,
            child: const Scaffold(
              body: GuideCard(
                title: 'Test Guide',
                imageKey: 'non_existent_image',
                date: '01 Mar 2025',
                tag: 'Test',
                content: 'Test content',
              ),
            ),
          ),
        ),
      );
      
      // Esperar a que se complete la carga de imágenes
      await tester.pump(const Duration(milliseconds: 500));
      
      // Verificar que el widget se renderizó correctamente a pesar del error
      expect(find.text('Test Guide'), findsOneWidget);
      expect(find.text('01 Mar 2025'), findsOneWidget);
    });
  });
}
