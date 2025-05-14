import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/BLoC/multas/multas_bloc.dart';

void main() {
  group('MultaDetalle', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final multa = MultaDetalle(
        numeroMulta: '12345',
        fecha: '2023-01-01',
        codigoInfraccion: 'C01',
        descripcionInfraccion: 'Exceso de velocidad',
        estado: 'Pendiente',
        valorPagar: 500000.0,
        detalleValor: {'base': 450000.0, 'intereses': 50000.0},
      );
      
      expect(multa.numeroMulta, equals('12345'));
      expect(multa.fecha, equals('2023-01-01'));
      expect(multa.codigoInfraccion, equals('C01'));
      expect(multa.descripcionInfraccion, equals('Exceso de velocidad'));
      expect(multa.estado, equals('Pendiente'));
      expect(multa.valorPagar, equals(500000.0));
      expect(multa.detalleValor, equals({'base': 450000.0, 'intereses': 50000.0}));
    });
    
    test('debe crear una instancia desde JSON', () {
      final json = {
        'numeroMulta': '12345',
        'fecha': '2023-01-01',
        'codigoInfraccion': 'C01',
        'descripcionInfraccion': 'Exceso de velocidad',
        'estado': 'Pendiente',
        'valorPagar': 500000.0,
        'detalleValor': {'base': 450000.0, 'intereses': 50000.0},
      };
      
      final multa = MultaDetalle.fromJson(json);
      
      expect(multa.numeroMulta, equals('12345'));
      expect(multa.fecha, equals('2023-01-01'));
      expect(multa.codigoInfraccion, equals('C01'));
      expect(multa.descripcionInfraccion, equals('Exceso de velocidad'));
      expect(multa.estado, equals('Pendiente'));
      expect(multa.valorPagar, equals(500000.0));
      expect(multa.detalleValor, equals({'base': 450000.0, 'intereses': 50000.0}));
    });
    
    test('debe manejar valores nulos o ausentes en JSON', () {
      final json = <String, dynamic>{};
      
      final multa = MultaDetalle.fromJson(json);
      
      expect(multa.numeroMulta, equals('N/A'));
      expect(multa.fecha, equals('Sin fecha'));
      expect(multa.codigoInfraccion, equals('N/A'));
      expect(multa.descripcionInfraccion, equals('Sin descripción'));
      expect(multa.estado, equals('Sin estado'));
      expect(multa.valorPagar, equals(0.0));
      expect(multa.detalleValor, equals({}));
    });
    
    test('debe convertir a JSON correctamente', () {
      final multa = MultaDetalle(
        numeroMulta: '12345',
        fecha: '2023-01-01',
        codigoInfraccion: 'C01',
        descripcionInfraccion: 'Exceso de velocidad',
        estado: 'Pendiente',
        valorPagar: 500000.0,
        detalleValor: {'base': 450000.0, 'intereses': 50000.0},
      );
      
      final json = multa.toJson();
      
      expect(json['numeroMulta'], equals('12345'));
      expect(json['fecha'], equals('2023-01-01'));
      expect(json['codigoInfraccion'], equals('C01'));
      expect(json['descripcionInfraccion'], equals('Exceso de velocidad'));
      expect(json['estado'], equals('Pendiente'));
      expect(json['valorPagar'], equals(500000.0));
      expect(json['detalleValor'], equals({'base': 450000.0, 'intereses': 50000.0}));
    });
    
    test('debe convertir a formato de tarjeta correctamente', () {
      final multa = MultaDetalle(
        numeroMulta: '12345',
        fecha: '2023-01-01',
        codigoInfraccion: 'C01',
        descripcionInfraccion: 'Exceso de velocidad',
        estado: 'Pendiente',
        valorPagar: 500000.0,
        detalleValor: {'base': 450000.0, 'intereses': 50000.0},
      );
      
      final cardData = multa.toCardData(placa: 'ABC123');
      
      expect(cardData['numeroMulta'], equals('12345'));
      expect(cardData['fecha'], equals('2023-01-01'));
      expect(cardData['descripcionInfraccion'], equals('Exceso de velocidad'));
      expect(cardData['estado'], equals('Pendiente'));
      expect(cardData['valorPagar'], equals(500000.0));
      expect(cardData['placa'], equals('ABC123'));
    });
  });
  
  group('MultasData', () {
    test('debe crear una instancia correctamente con constructor directo', () {
      final detalles = [
        MultaDetalle(
          numeroMulta: '12345',
          fecha: '2023-01-01',
          codigoInfraccion: 'C01',
          descripcionInfraccion: 'Exceso de velocidad',
          estado: 'Pendiente',
          valorPagar: 500000.0,
          detalleValor: {'base': 450000.0, 'intereses': 50000.0},
        ),
      ];
      
      final fecha = DateTime.now();
      final multasData = MultasData(
        comparendosMultas: 1,
        totalPagar: 500000.0,
        mensaje: 'Tiene multas pendientes',
        detallesComparendos: detalles,
        ultimaActualizacion: fecha,
        placa: 'ABC123',
      );
      
      expect(multasData.comparendosMultas, equals(1));
      expect(multasData.totalPagar, equals(500000.0));
      expect(multasData.mensaje, equals('Tiene multas pendientes'));
      expect(multasData.detallesComparendos, equals(detalles));
      expect(multasData.ultimaActualizacion, equals(fecha));
      expect(multasData.placa, equals('ABC123'));
      expect(multasData.tieneMultas, isTrue);
    });
    
    test('debe crear una instancia desde JSON', () {
      final json = {
        'comparendos_multas': 1,
        'totalPagar': 500000.0,
        'mensaje': 'Tiene multas pendientes',
        'detallesComparendos': [
          {
            'numeroMulta': '12345',
            'fecha': '2023-01-01',
            'codigoInfraccion': 'C01',
            'descripcionInfraccion': 'Exceso de velocidad',
            'estado': 'Pendiente',
            'valorPagar': 500000.0,
            'detalleValor': {'base': 450000.0, 'intereses': 50000.0},
          }
        ],
        'placa': 'ABC123',
      };
      
      final multasData = MultasData.fromJson(json);
      
      expect(multasData.comparendosMultas, equals(1));
      expect(multasData.totalPagar, equals(500000.0));
      expect(multasData.mensaje, equals('Tiene multas pendientes'));
      expect(multasData.detallesComparendos.length, equals(1));
      expect(multasData.placa, equals('ABC123'));
      expect(multasData.tieneMultas, isTrue);
    });
    
    test('debe manejar valores nulos o ausentes en JSON', () {
      final json = <String, dynamic>{};
      
      final multasData = MultasData.fromJson(json);
      
      expect(multasData.comparendosMultas, equals(0));
      expect(multasData.totalPagar, equals(0.0));
      expect(multasData.mensaje, equals('No hay información disponible'));
      expect(multasData.detallesComparendos, isEmpty);
      expect(multasData.placa, equals(''));
      expect(multasData.tieneMultas, isFalse);
    });
    
    test('tieneMultas debe devolver false cuando no hay multas', () {
      final multasData = MultasData(
        comparendosMultas: 0,
        totalPagar: 0.0,
        mensaje: 'No tiene multas',
        detallesComparendos: [],
        ultimaActualizacion: DateTime.now(),
        placa: 'ABC123',
      );
      
      expect(multasData.tieneMultas, isFalse);
    });
  });
  
  group('MultasBloc', () {
    late MultasBloc multasBloc;
    
    setUp(() {
      multasBloc = MultasBloc();
      multasBloc.reset();
    });
    
    test('Estado inicial debe estar correctamente inicializado', () {
      expect(multasBloc.isLoading, isFalse);
      expect(multasBloc.error, isNull);
      expect(multasBloc.plate, isNull);
      expect(multasBloc.multasData, isNull);
      expect(multasBloc.tieneMultas, isFalse);
      expect(multasBloc.ultimaActualizacion, isNull);
    });
    
    test('setPlate debe actualizar la placa', () {
      const plate = 'ABC123';
      
      // Llamamos a setPlate pero no esperamos a que termine loadMultasData
      multasBloc.setPlate(plate);
      
      expect(multasBloc.plate, equals(plate));
    });
    
    test('reset debe reiniciar el estado', () {
      // Primero configuramos algunos valores
      const plate = 'ABC123';
      multasBloc.setPlate(plate);
      
      // Verificamos que los valores se hayan establecido
      expect(multasBloc.plate, equals(plate));
      
      // Ahora reiniciamos
      multasBloc.reset();
      
      // Verificamos que los valores se hayan reiniciado
      expect(multasBloc.isLoading, isFalse);
      expect(multasBloc.error, isNull);
      expect(multasBloc.plate, isNull);
      expect(multasBloc.multasData, isNull);
      expect(multasBloc.tieneMultas, isFalse);
      expect(multasBloc.ultimaActualizacion, isNull);
    });
    
    // Verificar que MultasBloc implementa el patrón Singleton
    test('MultasBloc debe implementar el patrón Singleton', () {
      final multasBloc1 = MultasBloc();
      final multasBloc2 = MultasBloc();
      
      // Ambas instancias deben ser la misma
      expect(identical(multasBloc1, multasBloc2), isTrue);
    });
    
    test('loadMultasData debe ser una función', () {
      expect(multasBloc.loadMultasData, isA<Function>());
    });
    
    test('refresh debe ser una función', () {
      expect(multasBloc.refresh, isA<Function>());
    });
  });
}
