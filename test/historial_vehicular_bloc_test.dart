import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/BLoC/historial_vehicular/historial_vehicular_bloc.dart';
import 'package:Equirent_Mobility/services/API.dart';
import 'package:Equirent_Mobility/BLoC/auth/auth_context.dart';
import 'package:mockito/annotations.dart';

// Generar mocks
@GenerateMocks([APIService, AuthContext])

void main() {
  late HistorialVehicularBloc historialBloc;

  setUp(() {
    // Crear instancia del bloc para cada test
    historialBloc = HistorialVehicularBloc();
  });

  group('HistorialVehicularBloc - Estado inicial', () {
    test('debe tener valores iniciales correctos', () {
      // Verificar estado inicial
      expect(historialBloc.isLoading, isFalse);
      expect(historialBloc.isLoadingTramites, isFalse);
      expect(historialBloc.isLoadingMultas, isFalse);
      expect(historialBloc.isLoadingAccidentes, isFalse);
      expect(historialBloc.isLoadingNovedades, isFalse);
      expect(historialBloc.isLoadingMedidas, isFalse);
      
      expect(historialBloc.error, isNull);
      expect(historialBloc.errorTramites, isNull);
      expect(historialBloc.errorMultas, isNull);
      expect(historialBloc.errorAccidentes, isNull);
      expect(historialBloc.errorNovedades, isNull);
      expect(historialBloc.errorMedidas, isNull);
      
      expect(historialBloc.placa, isNull);
      expect(historialBloc.historialTramites, isNull);
      expect(historialBloc.multas, isNull);
      expect(historialBloc.accidentes, isNull);
      expect(historialBloc.novedadesTraspaso, isNull);
      expect(historialBloc.medidasCautelares, isNull);
    });
  });

  group('HistorialVehicularBloc - Métodos y funcionalidades', () {
    test('loadHistorialVehicular debe establecer la placa correctamente', () {
      const placa = 'ABC123';
      historialBloc.loadHistorialVehicular(placa);
      expect(historialBloc.placa, equals(placa));
    });
    
    test('getAccidentesFormateados debe devolver lista vacía si no hay datos', () {
      final resultado = historialBloc.getAccidentesFormateados();
      expect(resultado, isEmpty);
    });
    
    test('getNovedadesFormateadas debe devolver lista vacía si no hay datos', () {
      final resultado = historialBloc.getNovedadesFormateadas();
      expect(resultado, isEmpty);
    });
    
    test('getMedidasFormateadas debe devolver lista vacía si no hay datos', () {
      final resultado = historialBloc.getMedidasFormateadas();
      expect(resultado, isEmpty);
    });
    
    test('reset debe estar disponible como método', () {
      expect(historialBloc.reset, isA<Function>());
    });
    
    test('dispose debe estar disponible como método', () {
      expect(historialBloc.dispose, isA<Function>());
    });
  });
}
