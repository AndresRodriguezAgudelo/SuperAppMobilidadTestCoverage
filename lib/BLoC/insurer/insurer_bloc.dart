import 'package:flutter/material.dart';
import '../../services/API.dart';
import '../auth/auth_context.dart';

class InsurerBloc extends ChangeNotifier {
  // Singleton pattern
  static final InsurerBloc _instance = InsurerBloc._internal();
  final APIService _apiService = APIService();
  
  factory InsurerBloc() {
    return _instance;
  }
  
  InsurerBloc._internal();

  // Method to get insurers from API
  Future<Map<String, dynamic>> getInsurers({
    String? search,
    String order = 'ASC',
    int page = 1,
    int take = 50,
  }) async {
    try {
      // Obtener el token de autenticación
      final authToken = AuthContext().token;
      if (authToken == null) {
        print('\n⚠️ INSURER_BLOC: No hay token de autenticación disponible');
        throw Exception('No hay token de autenticación disponible');
      }
      
      // Build query parameters
      final queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        'order': order,
        'page': page.toString(),
        'take': take.toString(),
      };

      // Usar el servicio API para hacer la petición
      print('\n🏢 INSURER_BLOC: Obteniendo aseguradoras con parámetros: $queryParams');
      print('\n🏢 INSURER_BLOC: Usando token: ${authToken.substring(0, 10)}...');
      
      final response = await _apiService.get(
        _apiService.getInsurersEndpoint,
        queryParams: queryParams,
        token: authToken, // Pasar el token de autenticación
      );
      
      print('\n🏢 INSURER_BLOC: Respuesta recibida: $response');
      return response;
    } catch (e) {
      print('\n❌ INSURER_BLOC: Error obteniendo aseguradoras: $e');
      rethrow;
    }
  }
}
