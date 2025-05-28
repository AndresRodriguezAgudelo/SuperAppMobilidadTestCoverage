import 'package:intl/intl.dart';

/// Utilidades para la pantalla de Revisión de Frenos
class RevisionFrenosUtils {
  /// Formatea una fecha ISO 8601 a formato dd/MM/yyyy
  static String formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      // Si no se puede parsear, devolver la cadena original
      return dateString;
    }
  }
  
  /// Verifica si el formulario es válido (tiene fecha de último mantenimiento)
  static bool isFormValid(DateTime? lastUpdateDate) {
    return lastUpdateDate != null;
  }
  
  /// Formatea una fecha DateTime a formato ISO 8601 con Z al final
  static String formatDateToISO(DateTime date) {
    String isoString = date.toIso8601String();
    // Verificar si ya termina en Z para no duplicarla
    return isoString.endsWith('Z') ? isoString : "${isoString}Z";
  }
}
