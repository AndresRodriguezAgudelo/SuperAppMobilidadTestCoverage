import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/models/indicativos_model.dart';

void main() {
  group('IndicativosPaises', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final indicativo = IndicativosPaises(
        nameEs: 'Colombia',
        nameEn: 'Colombia',
        iso2: 'CO',
        iso3: 'COL',
        phoneCode: '57',
      );
      
      expect(indicativo.nameEs, equals('Colombia'));
      expect(indicativo.nameEn, equals('Colombia'));
      expect(indicativo.iso2, equals('CO'));
      expect(indicativo.iso3, equals('COL'));
      expect(indicativo.phoneCode, equals('57'));
    });
    
    test('debe crear una instancia desde JSON', () {
      final json = {
        "nameES": "Colombia",
        "nameEN": "Colombia",
        "iso2": "CO",
        "iso3": "COL",
        "phoneCode": "57"
      };
      
      final indicativo = IndicativosPaises.fromJson(json);
      
      expect(indicativo.nameEs, equals('Colombia'));
      expect(indicativo.nameEn, equals('Colombia'));
      expect(indicativo.iso2, equals('CO'));
      expect(indicativo.iso3, equals('COL'));
      expect(indicativo.phoneCode, equals('57'));
    });
    
    test('debe convertir a JSON correctamente', () {
      final indicativo = IndicativosPaises(
        nameEs: 'Colombia',
        nameEn: 'Colombia',
        iso2: 'CO',
        iso3: 'COL',
        phoneCode: '57',
      );
      
      final json = indicativo.toJson();
      
      expect(json, equals({
        "nameES": "Colombia",
        "nameEN": "Colombia",
        "iso2": "CO",
        "iso3": "COL",
        "phoneCode": "57"
      }));
    });
    
    test('debe manejar valores nulos', () {
      final indicativo = IndicativosPaises();
      
      expect(indicativo.nameEs, isNull);
      expect(indicativo.nameEn, isNull);
      expect(indicativo.iso2, isNull);
      expect(indicativo.iso3, isNull);
      expect(indicativo.phoneCode, isNull);
    });
  });
  
  group('Pais', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final pais = Pais(
        nombreES: 'Colombia',
        nombreEN: 'Colombia',
        iso2: 'CO',
        iso3: 'COL',
        phoneCode: '57',
      );
      
      expect(pais.nombreES, equals('Colombia'));
      expect(pais.nombreEN, equals('Colombia'));
      expect(pais.iso2, equals('CO'));
      expect(pais.iso3, equals('COL'));
      expect(pais.phoneCode, equals('57'));
    });
    
    test('debe crear una instancia desde JSON', () {
      final json = {
        "nameES": "Colombia",
        "nameEN": "Colombia",
        "iso2": "CO",
        "iso3": "COL",
        "phoneCode": "57"
      };
      
      final pais = Pais.fromJson(json);
      
      expect(pais.nombreES, equals('Colombia'));
      expect(pais.nombreEN, equals('Colombia'));
      expect(pais.iso2, equals('CO'));
      expect(pais.iso3, equals('COL'));
      expect(pais.phoneCode, equals('57'));
    });
    
    test('debe convertir a JSON correctamente', () {
      final pais = Pais(
        nombreES: 'Colombia',
        nombreEN: 'Colombia',
        iso2: 'CO',
        iso3: 'COL',
        phoneCode: '57',
      );
      
      final json = pais.toJson();
      
      expect(json, equals({
        "nameES": "Colombia",
        "nameEN": "Colombia",
        "iso2": "CO",
        "iso3": "COL",
        "phoneCode": "57"
      }));
    });
    
    test('debe generar bandera correctamente', () {
      final pais = Pais(
        nombreES: 'Colombia',
        nombreEN: 'Colombia',
        iso2: 'CO',
        iso3: 'COL',
        phoneCode: '57',
      );
      
      // La bandera de Colombia debe ser 🇨🇴
      expect(pais.bandera, equals('🇨🇴'));
      
      final usa = Pais(
        nombreES: 'Estados Unidos',
        nombreEN: 'United States',
        iso2: 'US',
        iso3: 'USA',
        phoneCode: '1',
      );
      
      // La bandera de USA debe ser 🇺🇸
      expect(usa.bandera, equals('🇺🇸'));
    });
    
    test('debe generar indicativo correctamente', () {
      final pais = Pais(
        nombreES: 'Colombia',
        nombreEN: 'Colombia',
        iso2: 'CO',
        iso3: 'COL',
        phoneCode: '57',
      );
      
      expect(pais.indicativo, equals('+57'));
    });
  });
  
  group('Indicativos', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final paises = [
        Pais(
          nombreES: 'Colombia',
          nombreEN: 'Colombia',
          iso2: 'CO',
          iso3: 'COL',
          phoneCode: '57',
        ),
        Pais(
          nombreES: 'Estados Unidos',
          nombreEN: 'United States',
          iso2: 'US',
          iso3: 'USA',
          phoneCode: '1',
        ),
      ];
      
      final indicativos = Indicativos(paises: paises);
      
      expect(indicativos.paises.length, equals(2));
      expect(indicativos.paises[0].nombreES, equals('Colombia'));
      expect(indicativos.paises[1].nombreES, equals('Estados Unidos'));
    });
    
    test('debe crear una instancia desde JSON', () {
      final jsonList = [
        {
          "nameES": "Colombia",
          "nameEN": "Colombia",
          "iso2": "CO",
          "iso3": "COL",
          "phoneCode": "57"
        },
        {
          "nameES": "Estados Unidos",
          "nameEN": "United States",
          "iso2": "US",
          "iso3": "USA",
          "phoneCode": "1"
        }
      ];
      
      final indicativos = Indicativos.fromJson(jsonList);
      
      expect(indicativos.paises.length, equals(2));
      expect(indicativos.paises[0].nombreES, equals('Colombia'));
      expect(indicativos.paises[1].nombreES, equals('Estados Unidos'));
    });
    
    test('debe convertir a JSON correctamente', () {
      final paises = [
        Pais(
          nombreES: 'Colombia',
          nombreEN: 'Colombia',
          iso2: 'CO',
          iso3: 'COL',
          phoneCode: '57',
        ),
        Pais(
          nombreES: 'Estados Unidos',
          nombreEN: 'United States',
          iso2: 'US',
          iso3: 'USA',
          phoneCode: '1',
        ),
      ];
      
      final indicativos = Indicativos(paises: paises);
      
      final json = indicativos.toJson();
      
      expect(json.length, equals(2));
      expect(json[0]['nameES'], equals('Colombia'));
      expect(json[1]['nameES'], equals('Estados Unidos'));
    });
  });
  
  group('Funciones de conversión', () {
    test('indicativosPaisesFromJson debe convertir JSON a lista de IndicativosPaises', () {
      final jsonString = '''
      [
        {
          "nameES": "Colombia",
          "nameEN": "Colombia",
          "iso2": "CO",
          "iso3": "COL",
          "phoneCode": "57"
        },
        {
          "nameES": "Estados Unidos",
          "nameEN": "United States",
          "iso2": "US",
          "iso3": "USA",
          "phoneCode": "1"
        }
      ]
      ''';
      
      final indicativos = indicativosPaisesFromJson(jsonString);
      
      expect(indicativos.length, equals(2));
      expect(indicativos[0].nameEs, equals('Colombia'));
      expect(indicativos[1].nameEs, equals('Estados Unidos'));
    });
    
    test('indicativosPaisesToJson debe convertir lista de IndicativosPaises a JSON', () {
      final indicativos = [
        IndicativosPaises(
          nameEs: 'Colombia',
          nameEn: 'Colombia',
          iso2: 'CO',
          iso3: 'COL',
          phoneCode: '57',
        ),
        IndicativosPaises(
          nameEs: 'Estados Unidos',
          nameEn: 'United States',
          iso2: 'US',
          iso3: 'USA',
          phoneCode: '1',
        ),
      ];
      
      final jsonString = indicativosPaisesToJson(indicativos);
      final jsonData = json.decode(jsonString);
      
      expect(jsonData.length, equals(2));
      expect(jsonData[0]['nameES'], equals('Colombia'));
      expect(jsonData[1]['nameES'], equals('Estados Unidos'));
    });
  });
}
