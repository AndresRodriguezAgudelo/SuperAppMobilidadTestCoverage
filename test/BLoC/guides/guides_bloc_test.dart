import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:Equirent_Mobility/BLoC/guides/guides_bloc.dart';
import '../../mocks.mocks.dart' as mocks;
import '../../test_helpers.dart';

void main() {
  group('GuidesBloc Tests', () {
    late GuidesBloc guidesBloc;
    late mocks.MockAPIService mockApiService;
    late mocks.MockAuthContext mockAuthContext;
    late MockGuidesBloc mockGuidesBloc;

    setUp(() {
      // Configurar el entorno de pruebas
      configureTestEnvironment();
      
      // Obtener la instancia singleton de GuidesBloc
      guidesBloc = GuidesBloc();
      
      // Crear mocks
      mockApiService = mocks.MockAPIService();
      mockAuthContext = mocks.MockAuthContext();
      mockGuidesBloc = MockGuidesBloc();
      
      // Configurar comportamiento básico de los mocks
      when(mockAuthContext.token).thenReturn('test_token');
      when(mockApiService.getAllGuidesEndpoint).thenReturn('/guides/app/all');
      
      // Nota: Como GuidesBloc usa un patrón Singleton y no permite inyección de dependencias,
      // no podemos reemplazar sus dependencias internas para pruebas.
      // En un escenario ideal, modificaríamos GuidesBloc para permitir inyección de dependencias.
    });

    test('categories should be empty initially', () {
      // Verificar estado inicial
      expect(guidesBloc.categories, isEmpty);
      expect(guidesBloc.isLoading, false);
      expect(guidesBloc.error, isNull);
    });

    test('reset should clear all data', () {
      // Preparar un estado no vacío (simulado)
      // Nota: Como no podemos modificar el estado interno directamente,
      // esta prueba es limitada
      
      // Ejecutar reset
      guidesBloc.reset();
      
      // Verificar que todo esté limpio
      expect(guidesBloc.categories, isEmpty);
      expect(guidesBloc.isLoading, false);
      expect(guidesBloc.error, isNull);
    });
    
    test('GuidesBloc should be a singleton', () {
      // Obtener dos instancias de GuidesBloc
      final instance1 = GuidesBloc();
      final instance2 = GuidesBloc();
      
      // Verificar que ambas instancias son la misma
      expect(identical(instance1, instance2), isTrue);
      expect(instance1, equals(instance2));
    });
    
    test('GuideCategory model should parse JSON correctly', () {
      // Datos de prueba
      final json = {
        'categoryName': 'Test Category',
        'items': [
          {
            'id': 1,
            'name': 'Test Guide',
            'categoryId': 1,
            'keyMain': 'main/key',
            'keySecondary': 'secondary/key',
            'keyTertiaryVideo': 'video/key',
            'description': 'Test description'
          }
        ]
      };
      
      // Crear modelo a partir de JSON
      final category = GuideCategory.fromJson(json);
      
      // Verificar que los datos se parsean correctamente
      expect(category.categoryName, equals('Test Category'));
      expect(category.items.length, equals(1));
      expect(category.items[0].id, equals(1));
      expect(category.items[0].name, equals('Test Guide'));
      expect(category.items[0].keyMain, equals('main/key'));
      expect(category.items[0].description, equals('Test description'));
    });
    
    test('GuideItem model should parse JSON correctly', () {
      // Datos de prueba
      final json = {
        'id': 2,
        'name': 'Another Guide',
        'categoryId': 3,
        'keyMain': 'main/key2',
        'keySecondary': 'secondary/key2',
        'keyTertiaryVideo': 'video/key2',
        'description': 'Another description'
      };
      
      // Crear modelo a partir de JSON
      final item = GuideItem.fromJson(json);
      
      // Verificar que los datos se parsean correctamente
      expect(item.id, equals(2));
      expect(item.name, equals('Another Guide'));
      expect(item.categoryId, equals(3));
      expect(item.keyMain, equals('main/key2'));
      expect(item.keySecondary, equals('secondary/key2'));
      expect(item.keyTertiaryVideo, equals('video/key2'));
      expect(item.description, equals('Another description'));
    });

    // Nota: No podemos probar loadGuides() completamente sin modificar la clase
    // para permitir inyección de dependencias. Sin embargo, podemos documentar
    // cómo sería la prueba ideal:
    
    /* 
    test('loadGuides should update categories when API returns data', () async {
      // Arrange - Preparar datos de prueba
      final mockResponse = {
        'categories': [
          {
            'categoryName': 'Test Category',
            'items': [
              {
                'id': 1,
                'name': 'Test Guide',
                'categoryId': 1,
                'keyMain': 'main/123',
                'keySecondary': 'secondary/456',
                'keyTertiaryVideo': 'video/789',
                'description': 'Test description'
              }
            ]
          }
        ]
      };
      
      when(mockApiService.get(
        any,
        token: anyNamed('token'),
        queryParams: anyNamed('queryParams')
      )).thenAnswer((_) async => mockResponse);
      
      // Act - Ejecutar el método a probar
      await guidesBloc.loadGuides();
      
      // Assert - Verificar resultados
      expect(guidesBloc.isLoading, false);
      expect(guidesBloc.categories.length, 1);
      expect(guidesBloc.categories[0].categoryName, 'Test Category');
      expect(guidesBloc.categories[0].items.length, 1);
      expect(guidesBloc.categories[0].items[0].name, 'Test Guide');
      expect(guidesBloc.error, isNull);
    });
    */
  });
}
