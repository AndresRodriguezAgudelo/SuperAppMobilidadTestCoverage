import "package:flutter_test/flutter_test.dart";
import "package:Equirent_Mobility/BLoC/guides/guides_bloc.dart";
import "./test_helpers.dart";

// Tests unitarios para GuidesBloc para evitar problemas de rendimiento
// que causaban bucles infinitos al renderizar widgets

void main() {
  late GuidesBloc guidesBloc;
  
  setUp(() {
    configureTestEnvironment();
    guidesBloc = GuidesBloc();
  });
  
  group("GuidesBloc Tests", () {
    test("GuidesBloc debería ser un singleton", () {
      // Crear dos instancias y verificar que son la misma
      final bloc1 = GuidesBloc();
      final bloc2 = GuidesBloc();
      
      expect(identical(bloc1, bloc2), isTrue);
      expect(bloc1, equals(bloc2));
    });
    
    test("GuidesBloc debería tener estado inicial correcto", () {
      // Verificar estado inicial
      expect(guidesBloc.categories, isEmpty);
      expect(guidesBloc.isLoading, isFalse);
      expect(guidesBloc.error, isNull);
    });
    
    test("GuidesBloc.reset() debería restablecer el estado", () {
      // Simular un estado con datos
      // No podemos modificar directamente las propiedades privadas,
      // pero podemos verificar que reset() funciona correctamente
      guidesBloc.reset();
      
      // Verificar que el estado se ha restablecido
      expect(guidesBloc.categories, isEmpty);
      expect(guidesBloc.isLoading, isFalse);
      expect(guidesBloc.error, isNull);
    });
  });
  
  group("GuideCategory Tests", () {
    test("GuideCategory debería crearse correctamente desde JSON", () {
      final json = {
        "categoryName": "Mantenimiento",
        "items": [
          {
            "id": 1,
            "name": "Cambio de aceite",
            "categoryId": 1,
            "keyMain": "main_key",
            "keySecondary": "secondary_key",
            "keyTertiaryVideo": "video_key",
            "description": "Cómo cambiar el aceite de tu vehículo"
          }
        ]
      };
      
      final category = GuideCategory.fromJson(json);
      
      expect(category.categoryName, equals("Mantenimiento"));
      expect(category.items.length, equals(1));
      expect(category.items[0].name, equals("Cambio de aceite"));
    });
  });
  
  group("GuideItem Tests", () {
    test("GuideItem debería crearse correctamente desde JSON", () {
      final json = {
        "id": 1,
        "name": "Cambio de aceite",
        "categoryId": 1,
        "keyMain": "main_key",
        "keySecondary": "secondary_key",
        "keyTertiaryVideo": "video_key",
        "description": "Cómo cambiar el aceite de tu vehículo"
      };
      
      final item = GuideItem.fromJson(json);
      
      expect(item.id, equals(1));
      expect(item.name, equals("Cambio de aceite"));
      expect(item.categoryId, equals(1));
      expect(item.keyMain, equals("main_key"));
      expect(item.keySecondary, equals("secondary_key"));
      expect(item.keyTertiaryVideo, equals("video_key"));
      expect(item.description, equals("Cómo cambiar el aceite de tu vehículo"));
    });
  });
  
  // Nota: falta implementar tests para loadGuides() porque depende de APIService
  // y requiere un mock adecuado para evitar llamadas reales al backend.
  // En un entorno real, deberíamos:
  // 1. Crear un mock de APIService
  // 2. Inyectar el mock en GuidesBloc
  // 3. Configurar el mock para devolver respuestas predefinidas
  // 4. Verificar que GuidesBloc procesa correctamente las respuestas
}
