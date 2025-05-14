import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/ciudad_model.dart';

void main() {
  group('Ciudad Model', () {
    test('Debería crear una instancia de Ciudad con valores correctos', () {
      final ciudad = Ciudad(id: 1, cityName: 'Bogotá');
      
      expect(ciudad.id, 1);
      expect(ciudad.cityName, 'Bogotá');
    });
    
    test('fromJson debería crear una instancia correcta desde un mapa', () {
      final json = {
        'id': 2,
        'cityName': 'Medellín'
      };
      
      final ciudad = Ciudad.fromJson(json);
      
      expect(ciudad.id, 2);
      expect(ciudad.cityName, 'Medellín');
    });
    
    test('toJson debería retornar un mapa con los valores correctos', () {
      final ciudad = Ciudad(id: 3, cityName: 'Cali');
      
      final json = ciudad.toJson();
      
      expect(json, {
        'id': 3,
        'cityName': 'Cali'
      });
    });
    
    test('fromJson y toJson deberían ser inversos', () {
      final originalJson = {
        'id': 4,
        'cityName': 'Barranquilla'
      };
      
      final ciudad = Ciudad.fromJson(originalJson);
      final resultJson = ciudad.toJson();
      
      expect(resultJson, originalJson);
    });
    
    test('fromJson debería manejar diferentes tipos de ciudades', () {
      final jsonList = [
        {'id': 5, 'cityName': 'Cartagena'},
        {'id': 6, 'cityName': 'Santa Marta'},
        {'id': 7, 'cityName': 'Bucaramanga'}
      ];
      
      final ciudades = jsonList.map((json) => Ciudad.fromJson(json)).toList();
      
      expect(ciudades.length, 3);
      expect(ciudades[0].id, 5);
      expect(ciudades[0].cityName, 'Cartagena');
      expect(ciudades[1].id, 6);
      expect(ciudades[1].cityName, 'Santa Marta');
      expect(ciudades[2].id, 7);
      expect(ciudades[2].cityName, 'Bucaramanga');
    });
  });
}
