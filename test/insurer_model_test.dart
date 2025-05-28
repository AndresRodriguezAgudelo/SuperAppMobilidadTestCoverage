import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/models/insurer_model.dart';

void main() {
  group('Insurer Model Tests', () {
    test('should create Insurer from JSON with id as int', () {
      // Arrange
      final Map<String, dynamic> jsonData = {
        'id': 123,
        'nameInsurer': 'Seguros Bolívar'
      };
      
      // Act
      final insurer = Insurer.fromJson(jsonData);
      
      // Assert
      expect(insurer.id, equals(123));
      expect(insurer.id.runtimeType, equals(int));
      expect(insurer.name, equals('Seguros Bolívar'));
    });
    
    test('should create Insurer from JSON with id as String', () {
      // Arrange
      final Map<String, dynamic> jsonData = {
        'id': '456',
        'nameInsurer': 'Sura'
      };
      
      // Act
      final insurer = Insurer.fromJson(jsonData);
      
      // Assert
      expect(insurer.id, equals('456'));
      expect(insurer.id.runtimeType, equals(String));
      expect(insurer.name, equals('Sura'));
    });
    
    test('should handle null id in JSON', () {
      // Arrange
      final Map<String, dynamic> jsonData = {
        'id': null,
        'nameInsurer': 'Liberty Seguros'
      };
      
      // Act
      final insurer = Insurer.fromJson(jsonData);
      
      // Assert
      expect(insurer.id, equals(0));
      expect(insurer.name, equals('Liberty Seguros'));
    });
    
    test('should handle missing id in JSON', () {
      // Arrange
      final Map<String, dynamic> jsonData = {
        'nameInsurer': 'Allianz'
      };
      
      // Act
      final insurer = Insurer.fromJson(jsonData);
      
      // Assert
      expect(insurer.id, equals(0));
      expect(insurer.name, equals('Allianz'));
    });
    
    test('should use name field if nameInsurer is missing', () {
      // Arrange
      final Map<String, dynamic> jsonData = {
        'id': 789,
        'name': 'Mapfre'
      };
      
      // Act
      final insurer = Insurer.fromJson(jsonData);
      
      // Assert
      expect(insurer.id, equals(789));
      expect(insurer.name, equals('Mapfre'));
    });
    
    test('should handle both name fields missing', () {
      // Arrange
      final Map<String, dynamic> jsonData = {
        'id': 999
      };
      
      // Act
      final insurer = Insurer.fromJson(jsonData);
      
      // Assert
      expect(insurer.id, equals(999));
      expect(insurer.name, equals('Sin nombre'));
    });
    
    test('should convert Insurer to JSON', () {
      // Arrange
      final insurer = Insurer(id: 123, name: 'Seguros Bolívar');
      
      // Act
      final jsonData = insurer.toJson();
      
      // Assert
      expect(jsonData, equals({
        'id': 123,
        'name': 'Seguros Bolívar'
      }));
    });
    
    test('should have correct toString representation', () {
      // Arrange
      final insurer = Insurer(id: 123, name: 'Seguros Bolívar');
      
      // Act
      final stringRepresentation = insurer.toString();
      
      // Assert
      expect(stringRepresentation, equals('Insurer(id: 123, name: Seguros Bolívar)'));
    });
  });
}
