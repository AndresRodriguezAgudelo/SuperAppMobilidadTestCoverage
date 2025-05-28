import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/utils/revision_frenos_utils.dart';

void main() {
  group('RevisionFrenosUtils', () {
    test('formatDate formatea correctamente las fechas ISO', () {
      // Probar diferentes formatos de fecha
      expect(RevisionFrenosUtils.formatDate('2023-05-15T00:00:00Z'), equals('15/05/2023'));
      expect(RevisionFrenosUtils.formatDate('2023-12-31T23:59:59Z'), equals('31/12/2023'));
      expect(RevisionFrenosUtils.formatDate('2023-01-01T12:30:45Z'), equals('01/01/2023'));
      
      // Probar con fechas inválidas
      expect(RevisionFrenosUtils.formatDate(''), equals(''));
      expect(RevisionFrenosUtils.formatDate('fecha-invalida'), equals('fecha-invalida'));
    });
    
    test('isFormValid retorna true solo cuando lastUpdateDate no es null', () {
      // Con fecha null, el formulario no es válido
      expect(RevisionFrenosUtils.isFormValid(null), isFalse);
      
      // Con fecha válida, el formulario es válido
      expect(RevisionFrenosUtils.isFormValid(DateTime.now()), isTrue);
    });
    
    test('formatDateToISO formatea correctamente a ISO 8601 con Z', () {
      // Crear una fecha fija para pruebas
      final testDate = DateTime(2023, 5, 15, 10, 30, 0);
      
      // Verificar que se agrega Z al final si no existe
      expect(
        RevisionFrenosUtils.formatDateToISO(testDate),
        equals('2023-05-15T10:30:00.000Z')
      );
      
      // Crear una fecha con Z ya incluida (simulando)
      final isoStringWithZ = '2023-05-15T10:30:00.000Z';
      final dateWithZ = DateTime.parse(isoStringWithZ);
      
      // Verificar que no se duplica la Z
      expect(
        RevisionFrenosUtils.formatDateToISO(dateWithZ),
        equals('2023-05-15T10:30:00.000Z')
      );
    });
  });
}
