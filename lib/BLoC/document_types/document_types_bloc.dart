import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../services/API.dart';
import '../auth/auth_context.dart';

class DocumentTypesBloc extends ChangeNotifier {
  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();
  
  var _documentTypes = <Map<String, dynamic>>[];
  bool _isLoading = false;
  String? _error;
  
  List<Map<String, dynamic>> get documentTypes => List.unmodifiable(_documentTypes);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setState(void Function() fn) {
    fn();
    notifyListeners();
  }
  
  Future<void> getDocumentTypes({
    String? search,
    String order = 'ASC',
    int page = 1,
    int take = 10,
  }) async {
    if (_isLoading) return;
    
    print('\n📄 OBTENIENDO TIPOS DE DOCUMENTO');
    print('🔍 Parámetros:');
    print('- Búsqueda: ${search ?? 'ninguna'}');
    print('- Orden: $order');
    print('- Página: $page');
    print('- Cantidad: $take');
    print('🔑 Token: ${_authContext.token}');
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final response = await _apiService.get(
        '${_apiService.getDocumentTypesEndpoint}?search=${search ?? ''}&order=$order&page=$page&take=$take',
        token: _authContext.token,
      );
      
      print('✅ Respuesta: $response');
      
      setState(() {
        final types = List<Map<String, dynamic>>.from(response['data'] ?? []);
        _documentTypes.clear();
        _documentTypes.addAll(types);
        _isLoading = false;
      });
      
      print('💾 Tipos de documento almacenados en estado');
    } catch (e) {
      print('\n❌ ERROR OBTENIENDO TIPOS DE DOCUMENTO');
      print('📡 Error: $e');
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void prepareForVehicleCreation() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void finishVehicleCreation({String? error}) {
    _isLoading = false;
    _error = error;
    notifyListeners();
  }

  // Devuelve true si el vehículo se crea correctamente, o lanza una excepción con el error
  Future<bool> createVehicle({
    required String licensePlate,
    required String numberDocument,
    required int typeDocumentId,
  }) async {
    print('\n🚗 CREANDO NUEVO VEHÍCULO');
    print('📝 Datos:');
    print('- Placa: $licensePlate');
    print('- Número de documento: $numberDocument');
    print('- Tipo de documento ID: $typeDocumentId');
    print('🔑 Token: ${_authContext.token}');
    
    try {
      final response = await _apiService.post(
        _apiService.createVehicleEndpoint,
        body: {
          'licensePlate': licensePlate,
          'numberDocument': numberDocument,
          'typeDocumentId': typeDocumentId,
        },
        token: _authContext.token,
      );
      
      print('✅ Vehículo creado exitosamente');
      print('📄 Respuesta: $response');
      
      return true;
    } catch (e) {
      print('\n❌ ERROR CREANDO VEHÍCULO');
      print('📡 Error: $e');
      
      // Lanzar la excepción para que se maneje en el nivel superior
      rethrow;
    }
  }
}
