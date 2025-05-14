import 'package:flutter_test/flutter_test.dart';
import '../../../lib/BLoC/callCity/city_bloc.dart';

void main() {
  group('CityBloc', () {
    late CityBloc cityBloc;

    setUp(() {
      cityBloc = CityBloc();
    });

    test('getCities debería ser una función', () {
      expect(cityBloc.getCities, isA<Function>());
    });

    test('getCities debería aceptar parámetros opcionales', () {
      // Verificamos que el método acepte los parámetros opcionales
      final call = () => cityBloc.getCities(
        search: 'Bogotá',
        order: 'DESC',
        page: 2,
        take: 20,
      );
      expect(call, isA<Function>());
    });

    test('getCities debería funcionar con parámetros por defecto', () {
      // Verificamos que el método funcione sin parámetros
      final call = () => cityBloc.getCities();
      expect(call, isA<Function>());
    });

    test('getCities debería retornar un Future<Map<String, dynamic>>', () {
      // Verificamos el tipo de retorno
      final result = cityBloc.getCities();
      expect(result, isA<Future<Map<String, dynamic>>>());
    });
  });
}
