import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/models/insurer_model.dart';

void main() {
  group('Insurer', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final insurer = Insurer(id: 1, name: 'Seguros ABC');
      
      expect(insurer.id, equals(1));
      expect(insurer.name, equals('Seguros ABC'));
    });
    
    test('debe crear una instancia desde JSON con campo nameInsurer', () {
      final json = {
        'id': 2,
        'nameInsurer': 'Seguros XYZ'
      };
      
      final insurer = Insurer.fromJson(json);
      
      expect(insurer.id, equals(2));
      expect(insurer.name, equals('Seguros XYZ'));
    });
    
    test('debe crear una instancia desde JSON con campo name', () {
      final json = {
        'id': 3,
        'name': 'Seguros DEF'
      };
      
      final insurer = Insurer.fromJson(json);
      
      expect(insurer.id, equals(3));
      expect(insurer.name, equals('Seguros DEF'));
    });
    
    test('debe manejar valores nulos o ausentes en JSON', () {
      final json = <String, dynamic>{};
      
      final insurer = Insurer.fromJson(json);
      
      expect(insurer.id, equals(0));
      expect(insurer.name, equals('Sin nombre'));
    });
    
    test('debe convertir a JSON correctamente', () {
      final insurer = Insurer(id: 4, name: 'Seguros GHI');
      
      final json = insurer.toJson();
      
      expect(json, equals({
        'id': 4,
        'name': 'Seguros GHI'
      }));
    });
    
    test('debe generar una representación de texto correcta', () {
      final insurer = Insurer(id: 5, name: 'Seguros JKL');
      
      final string = insurer.toString();
      
      expect(string, equals('Insurer(id: 5, name: Seguros JKL)'));
    });
    
    test('debe manejar id como String', () {
      final insurer = Insurer(id: 'ABC123', name: 'Seguros MNO');
      
      expect(insurer.id, equals('ABC123'));
      expect(insurer.name, equals('Seguros MNO'));
      
      final json = insurer.toJson();
      expect(json['id'], equals('ABC123'));
    });
  });
}
