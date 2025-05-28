import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../services/API.dart';
import '../auth/auth_context.dart';

/// Un BLoC centralizado para gestionar el estado de vehículos y alertas con caché
/// para evitar recargas innecesarias y mejorar la experiencia del usuario.
class VehicleAlertsBloc extends ChangeNotifier {
  static final VehicleAlertsBloc _instance = VehicleAlertsBloc._internal();
  factory VehicleAlertsBloc() => _instance;
  VehicleAlertsBloc._internal();

  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();
  
  // Caché de datos
  Map<int, Map<String, dynamic>> _vehicleCache = {};
  Map<int, Map<String, dynamic>> _alertCache = {};
  
  // Banderas de actualización
  bool _needsVehicleRefresh = false;
  Map<int, bool> _alertRefreshStatus = {}; // Por ID de alerta
  
  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Último vehículo y alerta actualizados
  int? _lastUpdatedVehicleId;
  int? _lastUpdatedAlertId;
  
  // Getters para información de último actualizado
  int? get lastUpdatedVehicleId => _lastUpdatedVehicleId;
  int? get lastUpdatedAlertId => _lastUpdatedAlertId;
  
  // Controladores de Stream para notificaciones
  final _vehicleUpdateController = StreamController<int>.broadcast();
  final _alertUpdateController = StreamController<int>.broadcast();
  
  // Streams para suscripciones
  Stream<int> get vehicleUpdateStream => _vehicleUpdateController.stream;
  Stream<int> get alertUpdateStream => _alertUpdateController.stream;
  
  /// Marca un vehículo para ser actualizado
  void markVehicleForRefresh(int vehicleId) {
    _needsVehicleRefresh = true;
    _lastUpdatedVehicleId = vehicleId;
    notifyListeners();
  }
  
  /// Marca una alerta específica para ser actualizada
  void markAlertForRefresh(int alertId) {
    _alertRefreshStatus[alertId] = true;
    _lastUpdatedAlertId = alertId;
    notifyListeners();
  }
  
  /// Actualiza solo los datos que han sido marcados para actualización
  /// Si silent es true, no se emitirán notificaciones de cambio de estado
  Future<void> refreshIfNeeded({bool silent = false}) async {
    bool didRefresh = false;
    bool wasLoading = _isLoading;
    
    // Verificar si hay algo que actualizar
    bool needsUpdate = _needsVehicleRefresh || _alertRefreshStatus.values.contains(true);
    
    if (!needsUpdate) {
      debugPrint('\n✅ VEHICLE_ALERTS_BLOC: No hay actualizaciones pendientes');
      return; // Salir temprano si no hay nada que actualizar
    }
    
    // Actualizar el estado de carga si no es una actualización silenciosa
    if (!silent && needsUpdate) {
      _isLoading = true;
      // Solo notificar si el estado cambió
      if (!wasLoading) {
        notifyListeners();
        debugPrint('\n⏳ VEHICLE_ALERTS_BLOC: Iniciando actualización, isLoading = $_isLoading');
      }
    }
    
    // Actualizar vehículos si es necesario
    if (_needsVehicleRefresh && _lastUpdatedVehicleId != null) {
      await _refreshVehicle(_lastUpdatedVehicleId!);
      _needsVehicleRefresh = false;
      didRefresh = true;
    }
    
    // Actualizar alertas marcadas
    for (var entry in _alertRefreshStatus.entries) {
      if (entry.value) {
        await _refreshAlert(entry.key);
        _alertRefreshStatus[entry.key] = false;
        didRefresh = true;
      }
    }
    
    // Actualizar el estado de carga si se hizo alguna actualización
    if (didRefresh) {
      if (!silent) {
        _isLoading = false;
        debugPrint('\n⏳ VEHICLE_ALERTS_BLOC: Actualización completada, isLoading = $_isLoading');
      }
      
      // Solo notificar si no es silencioso o si hubo cambios reales
      if (!silent || didRefresh) {
        notifyListeners();
      }
    } else if (!silent && wasLoading) {
      // Si estaba cargando pero no hubo actualizaciones, resetear el estado
      _isLoading = false;
      notifyListeners();
      debugPrint('\n⏳ VEHICLE_ALERTS_BLOC: No hubo actualizaciones, reseteando estado de carga');
    }
  }
  
  /// Actualiza un vehículo específico
  Future<void> _refreshVehicle(int vehicleId) async {
    try {
      debugPrint('\n🔄 VEHICLE_ALERTS_BLOC: Actualizando vehículo ID: $vehicleId');
      
      final response = await _apiService.get(
        _apiService.getVehicleDetailEndpoint(vehicleId),
        token: _authContext.token,
      );
      
      _vehicleCache[vehicleId] = response;
      _vehicleUpdateController.add(vehicleId);
      
      debugPrint('✅ VEHICLE_ALERTS_BLOC: Vehículo actualizado exitosamente');
    } catch (e) {
      debugPrint('❌ VEHICLE_ALERTS_BLOC: Error actualizando vehículo: $e');
    }
  }
  
  /// Actualiza una alerta específica
  Future<void> _refreshAlert(int alertId) async {
    try {
      debugPrint('\n🔄 VEHICLE_ALERTS_BLOC: Actualizando alerta ID: $alertId');
      
      final endpoint = _apiService.getSpecialAlertEndpoint(alertId);
      final response = await _apiService.get(
        endpoint,
        token: _authContext.token,
      );
      
      _alertCache[alertId] = response;
      _alertUpdateController.add(alertId);
      
      debugPrint('✅ VEHICLE_ALERTS_BLOC: Alerta actualizada exitosamente');
    } catch (e) {
      debugPrint('❌ VEHICLE_ALERTS_BLOC: Error actualizando alerta: $e');
    }
  }
  
  /// Obtiene un vehículo (primero de caché, luego de API si es necesario)
  Future<Map<String, dynamic>?> getVehicle(int vehicleId) async {
    if (_vehicleCache.containsKey(vehicleId) && !_needsVehicleRefresh) {
      debugPrint('\n📋 VEHICLE_ALERTS_BLOC: Obteniendo vehículo $vehicleId de caché');
      return _vehicleCache[vehicleId];
    }
    
    try {
      debugPrint('\n🔍 VEHICLE_ALERTS_BLOC: Obteniendo vehículo $vehicleId de API');
      
      final response = await _apiService.get(
        _apiService.getVehicleDetailEndpoint(vehicleId),
        token: _authContext.token,
      );
      
      _vehicleCache[vehicleId] = response;
      return response;
    } catch (e) {
      debugPrint('❌ VEHICLE_ALERTS_BLOC: Error obteniendo vehículo: $e');
      return null;
    }
  }
  
  /// Obtiene una alerta (primero de caché, luego de API si es necesario)
  Future<Map<String, dynamic>?> getAlert(int alertId) async {
    if (_alertCache.containsKey(alertId) && !_alertRefreshStatus.containsKey(alertId)) {
      debugPrint('\n📋 VEHICLE_ALERTS_BLOC: Obteniendo alerta $alertId de caché');
      return _alertCache[alertId];
    }
    
    try {
      debugPrint('\n🔍 VEHICLE_ALERTS_BLOC: Obteniendo alerta $alertId de API');
      
      final endpoint = _apiService.getSpecialAlertEndpoint(alertId);
      final response = await _apiService.get(
        endpoint,
        token: _authContext.token,
      );
      
      _alertCache[alertId] = response;
      return response;
    } catch (e) {
      debugPrint('❌ VEHICLE_ALERTS_BLOC: Error obteniendo alerta: $e');
      return null;
    }
  }
  
  /// Procesa datos de navegación cuando se regresa al Home
  void processNavigationResult(Map<String, dynamic>? result) {
    if (result == null) return;
    
    debugPrint('\n🔄 VEHICLE_ALERTS_BLOC: Procesando resultado de navegación: $result');
    
    if (result['alertUpdated'] == true && result['alertId'] != null) {
      final alertId = result['alertId'];
      markAlertForRefresh(alertId);
      debugPrint('📝 VEHICLE_ALERTS_BLOC: Alerta $alertId marcada para actualización');
    }
    
    if (result['vehicleUpdated'] == true && result['vehicleId'] != null) {
      final vehicleId = result['vehicleId'];
      markVehicleForRefresh(vehicleId);
      debugPrint('🚗 VEHICLE_ALERTS_BLOC: Vehículo $vehicleId marcado para actualización');
    }
  }
  
  /// Limpia la caché
  void clearCache() {
    _vehicleCache.clear();
    _alertCache.clear();
    _alertRefreshStatus.clear();
    _needsVehicleRefresh = false;
    notifyListeners();
    debugPrint('\n🧹 VEHICLE_ALERTS_BLOC: Caché limpiada');
  }
  
  /// Notifica que una alerta ha sido actualizada
  void notifyAlertUpdated(int alertId) {
    debugPrint('\n🔔 VEHICLE_ALERTS_BLOC: Notificando actualización de alerta ID: $alertId');
    markAlertForRefresh(alertId);
    _alertUpdateController.add(alertId);
  }
  
  @override
  void dispose() {
    _vehicleUpdateController.close();
    _alertUpdateController.close();
    super.dispose();
  }
}
