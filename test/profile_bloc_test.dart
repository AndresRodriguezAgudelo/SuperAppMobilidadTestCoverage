import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/BLoC/profile/profile_bloc.dart';

void main() {
  group('ProfileBloc', () {
    late ProfileBloc profileBloc;

    setUp(() {
      profileBloc = ProfileBloc();
      // Reiniciar el estado antes de cada test
      profileBloc.reset();
    });

    test('Estado inicial debe estar correctamente inicializado', () {
      expect(profileBloc.isLoading, isFalse);
      expect(profileBloc.error, isNull);
      expect(profileBloc.profileData, isNull);
    });

    test('Getters específicos deben manejar valores nulos', () {
      // Cuando profileData es null, los getters deben devolver valores por defecto
      expect(profileBloc.name, equals(''));
      expect(profileBloc.phone, equals(''));
      expect(profileBloc.email, equals(''));
      expect(profileBloc.photo, isNull);
      expect(profileBloc.cityName, equals(''));
      expect(profileBloc.verify, isFalse);
    });

    test('reset debe reiniciar el estado', () {
      // Llamamos a reset
      profileBloc.reset();

      // Verificamos que el estado se reinicia correctamente
      expect(profileBloc.isLoading, isFalse);
      expect(profileBloc.error, isNull);
      expect(profileBloc.profileData, isNull);
    });

    // Para los métodos que interactúan con servicios externos,
    // necesitaríamos mockear esos servicios para probarlos adecuadamente.
    // A continuación, se muestran tests que verifican la estructura básica
    // de los métodos, pero no su funcionalidad completa.

    test('loadProfile debe ser una función que acepta un userId', () {
      expect(profileBloc.loadProfile, isA<Function>());
      // No llamamos a la función para evitar errores por falta de mocks
    });

    test('updateProfileField debe ser una función que acepta userId, field y value', () {
      expect(profileBloc.updateProfileField, isA<Function>());
      // No llamamos a la función para evitar errores por falta de mocks
    });

    test('updateUserProfile debe ser una función que acepta userId y updateData', () {
      expect(profileBloc.updateUserProfile, isA<Function>());
      // No llamamos a la función para evitar errores por falta de mocks
    });

    test('updateProfilePhoto debe ser una función que acepta userId y photoUrl', () {
      expect(profileBloc.updateProfilePhoto, isA<Function>());
      // No llamamos a la función para evitar errores por falta de mocks
    });

    test('deleteAccount debe ser una función que acepta un userId', () {
      expect(profileBloc.deleteAccount, isA<Function>());
      // No llamamos a la función para evitar errores por falta de mocks
    });

    // Verificar que ProfileBloc implementa el patrón Singleton
    test('ProfileBloc debe implementar el patrón Singleton', () {
      final profileBloc1 = ProfileBloc();
      final profileBloc2 = ProfileBloc();
      
      // Ambas instancias deben ser la misma
      expect(identical(profileBloc1, profileBloc2), isTrue);
    });
  });
}
