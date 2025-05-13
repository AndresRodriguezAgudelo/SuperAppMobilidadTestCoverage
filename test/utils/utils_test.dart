import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/utils/utils.dart';

void main() {
  group('Utils Tests', () {
    test('should capitalize string', () {
      final result = capitalize('hola');
      expect(result, 'Hola');
    });
  });
}
