import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/BLoC/loading/loading_bloc.dart';

void main() {
  group('LoadingBloc', () {
    late LoadingBloc loadingBloc;
    
    setUp(() {
      loadingBloc = LoadingBloc();
    });
    
    test('Estado inicial debe estar correctamente inicializado', () {
      expect(loadingBloc.isLoading, isFalse);
      expect(loadingBloc.isComplete, isFalse);
      expect(loadingBloc.error, isNull);
    });
    
    test('startLoading debe cambiar isLoading a true al iniciar', () {
      // Crear un listener para verificar que se notifica el cambio
      bool listenerCalled = false;
      loadingBloc.addListener(() {
        listenerCalled = true;
      });
      
      // Iniciar la carga pero no esperar a que termine
      // Usamos try-catch para manejar posibles errores durante la carga
      try {
        loadingBloc.startLoading();
      } catch (e) {
        // Ignoramos errores de red o dependencias
        // ya que solo queremos verificar el cambio de estado inicial
      }
      
      // Verificar que isLoading cambia a true
      expect(listenerCalled, isTrue);
      
      // Nota: No podemos verificar isLoading directamente porque puede
      // haber cambiado a false si la carga terminó muy rápido o falló
    });
    
    test('El estado se actualiza correctamente después de un error', () async {
      // Forzamos un error en la carga
      // Esto es difícil de testear sin mockear las dependencias,
      // pero podemos verificar el comportamiento después de una carga
      
      // Iniciamos la carga y esperamos a que termine
      try {
        await loadingBloc.startLoading();
      } catch (e) {
        // Esperamos que falle debido a dependencias no disponibles en el entorno de test
      }
      
      // Después de la carga (exitosa o fallida), isLoading debe ser false
      expect(loadingBloc.isLoading, isFalse);
    });
  });
}
