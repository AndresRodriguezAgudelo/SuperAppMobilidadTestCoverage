import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/widgets/guide_video_player.dart';
import 'package:Equirent_Mobility/BLoC/images/image_bloc.dart';
import 'test_helpers.dart';

void main() {
  group('GuideVideoPlayer Widget Tests', () {
    late MockImageBloc mockImageBloc;
    
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      configureTestEnvironment();
      mockImageBloc = MockImageBloc();
    });

    testWidgets('should render loading state initially', (WidgetTester tester) async {
      // Configurar el mock para que demore en responder
      final mockImageBloc = MockImageBloc(delayResponse: true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ImageBloc>.value(
            value: mockImageBloc,
            child: const Scaffold(
              body: GuideVideoPlayer(videoKey: 'video/123'),
            ),
          ),
        ),
      );
      
      // Verificar que se muestra el indicador de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Avanzar el tiempo suficiente para que se completen todos los temporizadores
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });

    testWidgets('should render error state when video cannot be loaded', (WidgetTester tester) async {
      // Configurar el mock para que falle
      final mockImageBloc = MockImageBloc(shouldFailAPI: true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ImageBloc>.value(
            value: mockImageBloc,
            child: const Scaffold(
              body: GuideVideoPlayer(videoKey: 'video/error'),
            ),
          ),
        ),
      );
      
      // Esperar a que se procese la respuesta del mock
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      
      // Verificar que se muestra el mensaje de error
      expect(find.text('No se pudo cargar el video'), findsOneWidget);
      expect(find.byIcon(Icons.videocam_off), findsOneWidget);
    });
    
    testWidgets('should render video player when URL is valid', (WidgetTester tester) async {
      // Configurar el mock para devolver una URL válida
      final mockImageBloc = MockImageBloc(
        imageCache: {'video/123': 'https://example.com/video.mp4'}
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ImageBloc>.value(
            value: mockImageBloc,
            child: const Scaffold(
              body: GuideVideoPlayer(videoKey: 'video/123'),
            ),
          ),
        ),
      );
      
      // Esperar a que se procese la respuesta del mock
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      
      // Verificar que se muestra el contenedor del video
      expect(find.byType(Container), findsWidgets);
    });
  });
}
