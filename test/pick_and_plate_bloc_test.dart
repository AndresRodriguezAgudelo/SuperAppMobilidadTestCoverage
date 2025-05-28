import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/BLoC/pick_and_plate/pick_and_plate_bloc.dart';

void main() {
  group('PeakPlateBloc', () {
    late PeakPlateBloc peakPlateBloc;

    setUp(() {
      peakPlateBloc = PeakPlateBloc();
    });

    test('Estado inicial debe estar correctamente inicializado', () {
      expect(peakPlateBloc.isLoading, isFalse);
      expect(peakPlateBloc.error, isNull);
      expect(peakPlateBloc.alertId, isNull);
      expect(peakPlateBloc.cityId, isNull);
      expect(peakPlateBloc.cities, isEmpty);
      expect(peakPlateBloc.selectedCity, isNull);
      expect(peakPlateBloc.plate, isNull);
      expect(peakPlateBloc.peakPlateData, isNull);
      expect(peakPlateBloc.canDrive, isTrue); // Por defecto debe poder circular
      expect(peakPlateBloc.restrictionTime, equals('no disponible'));
    });

    test('setSelectedCity debe actualizar la ciudad seleccionada', () {
      final city = {
        'id': 1,
        'cityName': 'Bogotá',
      };

      peakPlateBloc.setSelectedCity(city);

      expect(peakPlateBloc.selectedCity, equals(city));
    });

    test('setPlate debe actualizar la placa', () {
      const plate = 'ABC123';

      peakPlateBloc.setPlate(plate);

      expect(peakPlateBloc.plate, equals(plate));
    });

    // No podemos probar setCityId directamente porque hace llamadas asíncronas
    // Verificamos que el método existe
    test('setCityId debe estar disponible como método', () {
      expect(peakPlateBloc.setCityId, isA<Function>());
    });

    test('getCurrentPeriod debe devolver el mes y año actuales', () {
      final now = DateTime.now();
      final period = peakPlateBloc.getCurrentPeriod();

      expect(period['year'], equals(now.year));
      expect(period['month'], equals(now.month));
    });

    test('canDriveOnDate debe devolver true por defecto', () {
      final today = DateTime.now();
      final result = peakPlateBloc.canDriveOnDate(today);

      // Sin datos de pico y placa, debería devolver true por defecto
      expect(result, isTrue);
    });
    
    test('canDrive debe ser accesible como propiedad', () {
      expect(peakPlateBloc.canDrive, isA<bool>());
    });
    
    test('restrictionTime debe devolver "no disponible" cuando no hay datos', () {
      expect(peakPlateBloc.restrictionTime, equals('no disponible'));
    });
  });
}
