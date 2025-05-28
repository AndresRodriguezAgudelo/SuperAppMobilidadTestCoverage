import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/BLoC/document_types/document_types_bloc.dart';

void main() {
  group('DocumentTypesBloc', () {
    late DocumentTypesBloc documentTypesBloc;

    setUp(() {
      documentTypesBloc = DocumentTypesBloc();
    });

    test('Estado inicial debe estar correctamente inicializado', () {
      expect(documentTypesBloc.documentTypes, isEmpty);
      expect(documentTypesBloc.isLoading, isFalse);
      expect(documentTypesBloc.error, isNull);
    });

    test('setState debe actualizar el estado y notificar a los oyentes', () {
      bool listenerCalled = false;
      
      documentTypesBloc.addListener(() {
        listenerCalled = true;
      });
      
      documentTypesBloc.setState(() {
        // Aquí no podemos modificar directamente las variables privadas
        // pero el método setState debería llamar a notifyListeners()
      });
      
      expect(listenerCalled, isTrue);
    });

    test('prepareForVehicleCreation debe actualizar el estado correctamente', () {
      bool listenerCalled = false;
      
      documentTypesBloc.addListener(() {
        listenerCalled = true;
      });
      
      documentTypesBloc.prepareForVehicleCreation();
      
      expect(documentTypesBloc.isLoading, isTrue);
      expect(documentTypesBloc.error, isNull);
      expect(listenerCalled, isTrue);
    });

    test('finishVehicleCreation debe actualizar el estado correctamente sin error', () {
      bool listenerCalled = false;
      
      // Primero preparamos para la creación
      documentTypesBloc.prepareForVehicleCreation();
      
      // Reiniciamos el flag
      documentTypesBloc.addListener(() {
        listenerCalled = true;
      });
      
      // Terminamos la creación sin error
      documentTypesBloc.finishVehicleCreation();
      
      expect(documentTypesBloc.isLoading, isFalse);
      expect(documentTypesBloc.error, isNull);
      expect(listenerCalled, isTrue);
    });

    test('finishVehicleCreation debe actualizar el estado correctamente con error', () {
      bool listenerCalled = false;
      
      // Primero preparamos para la creación
      documentTypesBloc.prepareForVehicleCreation();
      
      // Reiniciamos el flag
      documentTypesBloc.addListener(() {
        listenerCalled = true;
      });
      
      // Terminamos la creación con error
      final errorMessage = 'Error de prueba';
      documentTypesBloc.finishVehicleCreation(error: errorMessage);
      
      expect(documentTypesBloc.isLoading, isFalse);
      expect(documentTypesBloc.error, equals(errorMessage));
      expect(listenerCalled, isTrue);
    });

    test('getDocumentTypes debe ser una función', () {
      expect(documentTypesBloc.getDocumentTypes, isA<Function>());
    });

    test('createVehicle debe ser una función', () {
      expect(documentTypesBloc.createVehicle, isA<Function>());
    });
  });
}
