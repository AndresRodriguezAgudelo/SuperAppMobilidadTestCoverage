import 'package:flutter/foundation.dart';
import '../../services/API.dart';
import '../auth/auth_context.dart';
import '../home/home_bloc.dart';

class AlertsBloc extends ChangeNotifier {
  static final AlertsBloc _instance = AlertsBloc._internal();
  factory AlertsBloc() => _instance;
  AlertsBloc._internal();

  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();
  final HomeBloc _homeBloc = HomeBloc();

  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAlerts(int vehicleId) async {
    if (_isLoading) return;
    
    // Verificar el switch de peticiones en HomeBloc


    try {
      print('\n🚨 OBTENIENDO ALERTAS');
      print('🚗 VehiculoId: $vehicleId');
      print('🔑 Token: ${_authContext.token}');
      
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get(
        _apiService.getVehicleExpirationEndpoint(vehicleId),
        token: _authContext.token,
        queryParams: {
          'page': '1',
          'take': '20',
          'order': 'ASC',
        },
      );

      print('✅ Respuesta completa: $response-----------------------------AQUI--------------------------------------');
      print('📦 Datos de respuesta: ${response['data']}');

      if (response['data'] != null) {
        _alerts = List<Map<String, dynamic>>.from(response['data']);
        print('📋 Alertas antes del mapeo: $_alerts');
        
        // Mapear los campos del backend a los campos que espera el widget
        _alerts = _alerts.map((alert) {
          print('\n💾 ALERTA ORIGINAL DEL BACKEND: $alert');
          print('ID: ${alert['id']}, Tipo: ${alert['expirationType']}');
          
          return {
            'id': alert['id'], // Añadir el ID de la alerta
            'title': alert['expirationType'],
            'expirationType': alert['expirationType'], // Añadir el tipo de expiración para que coincida con lo que espera _handleAlertTap
            'status': alert['status'],
            'isSpecial': alert['isSpecial'],
            'whatScreenNavegation': _getScreenNavigation(alert['expirationType']),
            'fecha': alert['expirationDate'] != null 
              ? DateTime.parse(alert['expirationDate'])
              : null,
            'color': alert['color'] ?? 'gray',
            'percentage': alert['percentage'] ?? 0,
            'icon': alert['icon'] ?? _getDefaultIcon(alert['expirationType']), // Mapear el icono o usar uno predeterminado
          };
        }).toList();

        print('🚨 Alertas cargadas: ${_alerts.length}');
        print('📋 Alertas después del mapeo: $_alerts');
      } else {
        print('⚠️ No se encontraron alertas en la respuesta');
        _alerts = [];
      }

    } catch (e) {
      print('\n❌ ERROR OBTENIENDO ALERTAS');
      print('📡 Error: $e');
      _error = e.toString();
      _alerts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getScreenNavigation(String expirationType) {
    switch (expirationType) {
      case 'Licencia de conducción':
        return 'licencia';
      case 'Multas':
        return 'multas';
      case 'Pico y placa':
        return 'pico_placa';
      case 'RTM':
        return 'RTM';
      case 'SOAT':
        return 'SOAT';
      default:
        return '';
    }
  }
  
  // Método para obtener un icono predeterminado basado en el tipo de alerta
  String _getDefaultIcon(String expirationType) {
    switch (expirationType) {
      case 'Licencia de conducción':
        return 'license';
      case 'Multas':
        return 'money';
      case 'Pico y placa':
        return 'pico_placa';
      case 'SOAT':
        return 'soat';
      case 'RTM':
        return 'rtm';
      case 'Mantenimiento':
        return 'maintenance';
      case 'Seguro':
        return 'shield';
      case 'Impuesto':
        return 'document';
      default:
        return 'alert';
    }
  }

  void reset() {
    _alerts = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
  
  Future<bool> updateExpiration(
    int alertId,
    String expirationType,
    DateTime? expirationDate, {
    List<Map<String, dynamic>>? reminders,
  }) async {
    try {
      print('\n🔄 ACTUALIZANDO ALERTA NO ESPECIAL');
      print('🆔 ID de alerta: $alertId');
      print('📝 Tipo de vencimiento: $expirationType');
      print('📅 Fecha de vencimiento: $expirationDate');
      print('📅 Fecha ISO8601: ${expirationDate?.toIso8601String()}');
      print('🔔 Recordatorios: $reminders');
      
      if (alertId <= 0) {
        print('❌ ERROR: ID de alerta inválido ($alertId)');
        return false;
      }
      
      _isLoading = true;
      notifyListeners();
      
      final Map<String, dynamic> body = {
        'expirationType': expirationType,
      };
      
      // Solo agregar la fecha si no es nula
      if (expirationDate != null) {
        // Formatear la fecha como YYYY-MM-DD para evitar problemas de validación
        final formattedDate = '${expirationDate.year}-${expirationDate.month.toString().padLeft(2, '0')}-${expirationDate.day.toString().padLeft(2, '0')}';
        body['expirationDate'] = formattedDate;
        print('📅 Fecha formateada para API: $formattedDate');
      }
      
      // Agregar recordatorios si no son nulos
      if (reminders != null && reminders.isNotEmpty) {
        // Convertir la lista de mapas a una lista dinámica para evitar problemas de tipo
        body['reminders'] = List<dynamic>.from(reminders);
      }
      
      print('📦 Body de la petición: $body');
      print('📦 Token: ${_authContext.token?.substring(0, 20)}...');
      
      final endpoint = _apiService.updateExpirationEndpoint(alertId);
      print('🔗 Endpoint completo: $endpoint');
      
      final response = await _apiService.patch(
        endpoint,
        body: body,
        token: _authContext.token,
      );
      
      print('✅ Respuesta de actualización: $response');
      
      // Actualizar la alerta en la lista local
      final index = _alerts.indexWhere((alert) => alert['id'] == alertId);
      if (index != -1) {
        _alerts[index]['title'] = expirationType;
        _alerts[index]['fecha'] = expirationDate;
        
        // Actualizar el estado basado en la fecha
        if (expirationDate != null) {
          final now = DateTime.now();
          final daysUntilExpiration = expirationDate.difference(now).inDays;
          
          // Actualizar porcentaje y color basado en los días restantes
          if (daysUntilExpiration <= 0) {
            _alerts[index]['status'] = 'Vencido';
            _alerts[index]['color'] = 'red';
            _alerts[index]['percentage'] = 100;
          } else if (daysUntilExpiration <= 30) {
            _alerts[index]['status'] = 'Próximo a vencer';
            _alerts[index]['color'] = 'yellow';
            _alerts[index]['percentage'] = 75;
          } else {
            _alerts[index]['status'] = 'Vigente';
            _alerts[index]['color'] = 'green';
            _alerts[index]['percentage'] = 25;
          }
        } else {
          _alerts[index]['status'] = 'Configurar';
          _alerts[index]['color'] = 'gray';
          _alerts[index]['percentage'] = 0;
        }
        
        print('🔄 Alerta actualizada localmente con nuevos valores:');
        print('Título: ${_alerts[index]['title']}');
        print('Fecha: ${_alerts[index]['fecha']}');
        print('Estado: ${_alerts[index]['status']}');
        print('Color: ${_alerts[index]['color']}');
        print('Porcentaje: ${_alerts[index]['percentage']}');
      }
      
      return true;
    } catch (e) {
      print('\n❌ ERROR ACTUALIZANDO ALERTA');
      print('📡 Error: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
