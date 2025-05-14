import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/models/licencia_model.dart';

void main() {
  group('LicenciaCategoria', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final categoria = LicenciaCategoria(
        categoria: 'B1',
        servicio: 'Particular',
      );
      
      expect(categoria.categoria, equals('B1'));
      expect(categoria.servicio, equals('Particular'));
    });
  });
  
  group('LicenciaModel', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final fechaVencimiento = DateTime(2023, 12, 31);
      final fechaRenovacion = DateTime(2023, 11, 30);
      
      final categorias = [
        LicenciaCategoria(
          categoria: 'B1',
          servicio: 'Particular',
        ),
        LicenciaCategoria(
          categoria: 'C1',
          servicio: 'Público',
        ),
      ];
      
      final licencia = LicenciaModel(
        categorias: categorias,
        fechaVencimiento: fechaVencimiento,
        status: 'Activa',
        puedeRenovar: true,
        fechaRenovacionDisponible: fechaRenovacion,
      );
      
      expect(licencia.categorias.length, equals(2));
      expect(licencia.categorias[0].categoria, equals('B1'));
      expect(licencia.categorias[1].categoria, equals('C1'));
      expect(licencia.fechaVencimiento, equals(fechaVencimiento));
      expect(licencia.status, equals('Activa'));
      expect(licencia.puedeRenovar, isTrue);
      expect(licencia.fechaRenovacionDisponible, equals(fechaRenovacion));
    });
    
    test('debe permitir fechaRenovacionDisponible nula', () {
      final fechaVencimiento = DateTime(2023, 12, 31);
      
      final categorias = [
        LicenciaCategoria(
          categoria: 'B1',
          servicio: 'Particular',
        ),
      ];
      
      final licencia = LicenciaModel(
        categorias: categorias,
        fechaVencimiento: fechaVencimiento,
        status: 'Activa',
        puedeRenovar: false,
        fechaRenovacionDisponible: null,
      );
      
      expect(licencia.categorias.length, equals(1));
      expect(licencia.fechaVencimiento, equals(fechaVencimiento));
      expect(licencia.status, equals('Activa'));
      expect(licencia.puedeRenovar, isFalse);
      expect(licencia.fechaRenovacionDisponible, isNull);
    });
  });
}
