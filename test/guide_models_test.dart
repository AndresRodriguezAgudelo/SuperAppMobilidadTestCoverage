import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/BLoC/guides/guides_bloc.dart';

void main() {
  group('GuideItem', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final guideItem = GuideItem(
        id: 1,
        name: 'Guía de prueba',
        categoryId: 2,
        keyMain: 'main/key',
        keySecondary: 'secondary/key',
        keyTertiaryVideo: 'video/key',
        description: 'Descripción de prueba',
        date: '2025-01-08T12:00:00Z',
      );
      
      expect(guideItem.id, equals(1));
      expect(guideItem.name, equals('Guía de prueba'));
      expect(guideItem.categoryId, equals(2));
      expect(guideItem.keyMain, equals('main/key'));
      expect(guideItem.keySecondary, equals('secondary/key'));
      expect(guideItem.keyTertiaryVideo, equals('video/key'));
      expect(guideItem.description, equals('Descripción de prueba'));
    });
    
    test('debe crear una instancia desde JSON', () {
      final json = {
        'id': 1,
        'name': 'Guía de prueba',
        'categoryId': 2,
        'keyMain': 'main/key',
        'keySecondary': 'secondary/key',
        'keyTertiaryVideo': 'video/key',
        'description': 'Descripción de prueba',
      };
      
      final guideItem = GuideItem.fromJson(json);
      
      expect(guideItem.id, equals(1));
      expect(guideItem.name, equals('Guía de prueba'));
      expect(guideItem.categoryId, equals(2));
      expect(guideItem.keyMain, equals('main/key'));
      expect(guideItem.keySecondary, equals('secondary/key'));
      expect(guideItem.keyTertiaryVideo, equals('video/key'));
      expect(guideItem.description, equals('Descripción de prueba'));
    });
  });
  
  group('GuideCategory', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final items = [
        GuideItem(
          id: 1,
          name: 'Guía 1',
          categoryId: 1,
          keyMain: 'main/key1',
          keySecondary: 'secondary/key1',
          keyTertiaryVideo: 'video/key1',
          description: 'Descripción 1',
          date: '2025-01-08T12:00:00Z',
        ),
        GuideItem(
          id: 2,
          name: 'Guía 2',
          categoryId: 1,
          keyMain: 'main/key2',
          keySecondary: 'secondary/key2',
          keyTertiaryVideo: 'video/key2',
          description: 'Descripción 2',
          date: '2025-01-08T12:00:00Z',
        ),
      ];
      
      final category = GuideCategory(
        categoryName: 'Categoría de prueba',
        items: items,
      );
      
      expect(category.categoryName, equals('Categoría de prueba'));
      expect(category.items, equals(items));
      expect(category.items.length, equals(2));
    });
    
    test('debe crear una instancia desde JSON', () {
      final json = {
        'categoryName': 'Categoría de prueba',
        'items': [
          {
            'id': 1,
            'name': 'Guía 1',
            'categoryId': 1,
            'keyMain': 'main/key1',
            'keySecondary': 'secondary/key1',
            'keyTertiaryVideo': 'video/key1',
            'description': 'Descripción 1',
          },
          {
            'id': 2,
            'name': 'Guía 2',
            'categoryId': 1,
            'keyMain': 'main/key2',
            'keySecondary': 'secondary/key2',
            'keyTertiaryVideo': 'video/key2',
            'description': 'Descripción 2',
          },
        ],
      };
      
      final category = GuideCategory.fromJson(json);
      
      expect(category.categoryName, equals('Categoría de prueba'));
      expect(category.items.length, equals(2));
      expect(category.items[0].id, equals(1));
      expect(category.items[0].name, equals('Guía 1'));
      expect(category.items[1].id, equals(2));
      expect(category.items[1].name, equals('Guía 2'));
    });
  });
}
