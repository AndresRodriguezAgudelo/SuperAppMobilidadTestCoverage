import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:Equirent_Mobility/services/API.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  group('APIService', () {
    late APIService apiService;
    late MockClient client;

    setUp(() {
      client = MockClient();
      apiService = APIService();
    });

    test('getVehicleDetailEndpoint returns correct URL', () {
      final url = apiService.getVehicleDetailEndpoint(123);
      expect(url, contains('/vehicle/123'));
    });

    // No se puede testear _handleResponse directamente porque es privado.
    // En su lugar, se testean los endpoints públicos y la construcción de URLs.

  });
}
