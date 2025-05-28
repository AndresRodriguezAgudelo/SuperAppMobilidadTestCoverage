/// Utilidades para el manejo de errores en la aplicación
class ErrorUtils {
  /// Limpia los mensajes de error de tipo APIException y aplica lógica según el código de error
  /// 
  /// Para errores 400-499: Muestra el mensaje de error específico
  /// Para errores 500+: Muestra un mensaje genérico de error del servidor
  static String cleanErrorMessage(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('APIException:')) {
      // Extraer el código de estado y el mensaje
      final codeRegex = RegExp(r'\[(\d+)\]');
      final codeMatch = codeRegex.firstMatch(errorStr);
      
      if (codeMatch != null && codeMatch.groupCount >= 1) {
        final statusCode = int.parse(codeMatch.group(1) ?? '0');
        
        // Para errores del servidor (500+), mostrar mensaje genérico
        if (statusCode >= 500) {
          return 'Error al procesar esta solicitud, prueba más adelante';
        }
        
        // Para errores del cliente (400-499), extraer el mensaje específico
        if (statusCode >= 400 && statusCode < 500) {
          final messageRegex = RegExp(r'\[\d+\]\s(.+)');
          final messageMatch = messageRegex.firstMatch(errorStr);
          
          if (messageMatch != null && messageMatch.groupCount >= 1) {
            final errorMessage = messageMatch.group(1);
            if (errorMessage != null && errorMessage.isNotEmpty) {
              return errorMessage;
            }
          }
          
          // Si no hay mensaje específico, mostrar un mensaje genérico según el código
          return 'Error en la solicitud. Por favor, intenta nuevamente.';
        }
      }
    }
    return errorStr;
  }
}
