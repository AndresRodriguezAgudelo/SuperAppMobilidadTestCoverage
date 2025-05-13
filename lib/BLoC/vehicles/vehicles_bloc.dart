import 'package:flutter/foundation.dart';
import '../../services/API.dart';
import '../auth/auth_context.dart';

class VehiclesBloc extends ChangeNotifier {
  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();
  
  Map<String, dynamic>? _currentVehicle;
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic>? get currentVehicle => _currentVehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  get vehicles => null;

  void setState(void Function() fn) {
    fn();
    notifyListeners();
  }
  
  Future<void> getVehicleDetail(int id) async {
    if (_isLoading) return;
    
    print('\n🚗 OBTENIENDO DETALLE DEL VEHÍCULO');
    print('🔑 ID: $id');
    print('🔑 Token: ${_authContext.token}');
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentVehicle = null;
      });
      
      final response = await _apiService.get(
        _apiService.getVehicleDetailEndpoint(id),
        token: _authContext.token,
      );
      
      print('✅ Respuesta: $response');
      
      setState(() {
        _currentVehicle = response;
        _isLoading = false;
      });
      
      print('💾 Detalle del vehículo almacenado en estado');
    } catch (e) {
      print('\n❌ ERROR OBTENIENDO DETALLE DEL VEHÍCULO');
      print('📡 Error: $e');
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void clearCurrentVehicle() {
    print('\n🗑 LIMPIANDO DETALLE DEL VEHÍCULO');
    setState(() {
      _currentVehicle = null;
      _error = null;
    });
    print('✅ Estado limpiado');
  }

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
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
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
      
      setState(() {
        _isLoading = false;
      });
      
      return true;
    } catch (e) {
      print('\n❌ ERROR CREANDO VEHÍCULO');
      print('📡 Error: $e');
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      return false;
    }
  }

  /// Elimina un vehículo por su ID
  /// Retorna true si la eliminación fue exitosa, false en caso contrario
  Future<bool> deleteVehicle(int id) async {
    print('\n🗑 ELIMINANDO VEHÍCULO');
    print('🔑 ID: $id');
    print('🔑 Token: ${_authContext.token}');
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      await _apiService.delete(
        _apiService.deleteVehicleEndpoint(id),
        token: _authContext.token,
      );
      
      print('✅ Vehículo eliminado exitosamente');
      setState(() {
        _isLoading = false;
        // Si el vehículo actual es el que se eliminó, limpiarlo
        if (_currentVehicle != null && _currentVehicle!['id'] == id) {
          _currentVehicle = null;
        }
      });
      
      return true;
    } catch (e) {
      print('\n❌ ERROR ELIMINANDO VEHÍCULO');
      print('📡 Error: $e');
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      return false;
    }
  }
}
