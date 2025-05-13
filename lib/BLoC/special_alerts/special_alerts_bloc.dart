import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/API.dart';
import '../auth/auth_context.dart';

class SpecialAlertsBloc extends ChangeNotifier {
  // --- Métodos utilitarios para Póliza Todo Riesgo ---
  String getPolizaStatus({Map<String, dynamic>? alertData, DateTime? fechaVencimiento}) {
    String? status;
    if (alertData != null) {
      if (alertData.containsKey('estado')) {
        status = alertData['estado'];
      }
      if (status == null && alertData.containsKey('expirationDate') && alertData['expirationDate'] != null) {
        try {
          final expirationDate = DateTime.parse(alertData['expirationDate']);
          final now = DateTime.now();
          final difference = expirationDate.difference(now).inDays;
          if (difference < 0) {
            status = 'Vencido';
          } else if (difference < 30) {
            status = 'Por vencer';
          } else {
            status = 'Vigente';
          }
        } catch (_) {}
      }
    }
    if (status == null && fechaVencimiento != null) {
      final now = DateTime.now();
      final difference = fechaVencimiento.difference(now).inDays;
      if (difference < 0) {
        status = 'Vencido';
      } else if (difference < 30) {
        status = 'Por vencer';
      } else {
        status = 'Vigente';
      }
    }
    return status ?? 'Configurar';
  }

  Color getPolizaStatusColor(String status) {
    switch (status) {
      case 'Vencido':
        return const Color(0xFFE72F3E);
      case 'Por vencer':
        return const Color(0xFFECA263);
      case 'Vigente':
        return const Color(0xFF43AF8B);
      default:
        return Colors.grey;
    }
  }

  String getPolizaActionText(String status) {
    switch (status) {
      case 'Vencido':
        return 'Vencido';
      case 'Por vencer':
        return 'Por vencer';
      case 'Vigente':
        return 'Vigente';
      default:
        return 'Configurar';
    }
  }

  // Implementación del patrón Singleton con reinicio automático
  static SpecialAlertsBloc? _instance;
  
  factory SpecialAlertsBloc() {
    if (_instance == null || _instance!._isDisposed) {
      _instance = SpecialAlertsBloc._internal();
    }
    return _instance!;
  }
  
  SpecialAlertsBloc._internal();

  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();

  Map<String, dynamic>? _alertData;
  bool _isLoading = false;
  String? _error;
  int? _alertId;

  // Getters
  Map<String, dynamic>? get alertData => _alertData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get alertId => _alertId;

  // Método para cargar los datos de una alerta especial
  Future<void> loadSpecialAlert(int alertId) async {
    if (_isLoading) return;
    
    print('\n🔴🔴🔴 INICIANDO CARGA DE ALERTA ESPECIAL ID: $alertId 🔴🔴🔴');
    
    // Limpiar estado anterior
    _alertId = alertId;
    _isLoading = true;
    _error = null;
    _alertData = null; // Limpiar datos anteriores
    
    // Notificar a los listeners que estamos cargando
    notifyListeners();

    try {
      print('\n💻 LLAMANDO ENDPOINT: ${_apiService.getSpecialAlertEndpoint(alertId)}');
      
      final response = await _apiService.get(
        _apiService.getSpecialAlertEndpoint(alertId),
        token: _authContext.token,
      );
      
      print('\n📦📦📦 RESPUESTA DE LA API PARA ALERTA ESPECIAL:');
      print('TIPO DE RESPUESTA: ${response.runtimeType}');
      print('CONTENIDO: $response');
      
      try {
        // La respuesta puede ser un mapa o una lista
        dynamic data = response;
        
        print('\n💾 PROCESANDO DATOS DE RESPUESTA:');
        print('TIPO DE DATOS: ${data.runtimeType}');
        
        // Si es una lista, tomamos el primer elemento
        if (data is List) {
          print('RESPUESTA ES UNA LISTA DE ${data.length} ELEMENTOS');
          if (data.isNotEmpty) {
            print('TOMANDO PRIMER ELEMENTO: ${data[0]}');
            _alertData = data[0];
            print('TIPO DEL PRIMER ELEMENTO: ${_alertData?.runtimeType}');
            print('CLAVES DISPONIBLES: ${_alertData?.keys.toList()}');
            
            // Procesar el campo ExtraData si existe
            if (_alertData != null && _alertData!.containsKey('ExtraData')) {
              print('\n💼 ENCONTRADO CAMPO ExtraData: ${_alertData!['ExtraData']}');
              
              // Si ExtraData es un mapa y contiene insurerId, extraerlo y agregarlo directamente al alertData
              if (_alertData!['ExtraData'] is Map && _alertData!['ExtraData'].containsKey('insurerId')) {
                final insurerId = _alertData!['ExtraData']['insurerId'];
                print('\n💼 ENCONTRADO insurerId EN ExtraData: $insurerId');
                _alertData!['insurerId'] = insurerId;
              }
            }
          } else {
            print('\n⚠️ LISTA VACÍA - NO HAY DATOS');
            _error = 'No se encontraron datos para esta alerta';
          }
        } else {
          // Si no es una lista, asumimos que es un mapa
          print('RESPUESTA ES UN OBJETO INDIVIDUAL');
          _alertData = data;
          print('TIPO DEL OBJETO: ${_alertData?.runtimeType}');
          print('CLAVES DISPONIBLES: ${_alertData?.keys.toList()}');
          
          // Procesar el campo ExtraData si existe
          if (_alertData != null && _alertData!.containsKey('ExtraData')) {
            print('\n💼 ENCONTRADO CAMPO ExtraData: ${_alertData!['ExtraData']}');
            
            // Si ExtraData es un mapa y contiene insurerId, extraerlo y agregarlo directamente al alertData
            if (_alertData!['ExtraData'] is Map && _alertData!['ExtraData'].containsKey('insurerId')) {
              final insurerId = _alertData!['ExtraData']['insurerId'];
              print('\n💼 ENCONTRADO insurerId EN ExtraData: $insurerId');
              _alertData!['insurerId'] = insurerId;
            }
          }
        }
      } catch (e) {
        print('\n❌❌❌ ERROR PROCESANDO LA RESPUESTA: $e');
        print('STACK TRACE: ${StackTrace.current}');
        _error = 'Error procesando la respuesta: $e';
      }
      
      _isLoading = false;
      print('\n🟢 CARGA COMPLETADA - alertData: ${_alertData != null ? 'Presente' : 'No presente'}');
      if (_alertData != null) {
        print('DATOS FINALES:');
        _alertData!.forEach((key, value) {
          print('$key: $value');
        });
      }
      
      // Asegurarnos de notificar a los listeners con los nuevos datos
      print('\n📢 NOTIFICANDO A LOS LISTENERS CON NUEVOS DATOS');
      notifyListeners();
    } catch (e) {
      print('\n❌ ERROR CARGANDO ALERTA ESPECIAL');
      print('📡 Error: $e');
      _error = e.toString();
      _isLoading = false;
      print('\n🟢 CARGA COMPLETADA - alertData: ${_alertData != null ? 'Presente' : 'No presente'}');
      if (_alertData != null) {
        print('DATOS FINALES:');
        _alertData!.forEach((key, value) {
          print('$key: $value');
        });
      }
      
      // Asegurarnos de notificar a los listeners con los nuevos datos
      print('\n📢 NOTIFICANDO A LOS LISTENERS CON NUEVOS DATOS');
      notifyListeners();
    }
  }

  // Método para formatear la fecha de expiración
  String formatExpirationDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'No disponible';
    }

    try {
      final date = DateTime.parse(dateString).toLocal();
      final dia = date.day.toString().padLeft(2, '0');
      final mes = date.month.toString().padLeft(2, '0');
      final anio = date.year;
      int hour = date.hour;
      final minutos = date.minute.toString().padLeft(2, '0');
      final isPM = hour >= 12;
      final ampm = isPM ? 'pm' : 'am';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      final hora12 = hour.toString().padLeft(2, '0');
      return '$dia/$mes/$anio $hora12:$minutos $ampm';
    } catch (e) {
      print('Error al formatear la fecha: $e');
      return dateString;
    }
  }

  // Método para determinar el estado del SOAT basado en la fecha de expiración
  String getSOATStatus() {

    if (_alertData == null || _alertData!['estado'] == null) {
      return 'No disponible';
    }

    try {
      final expirationDate = _alertData!['estado'];
      return expirationDate;

    } catch (e) {
      print('Error al determinar el estado del SOAT: $e');
      return 'No disponible';
    }
  }

  // Método para obtener el color del estado del SOAT
  Color getSOATStatusColor() {
    final status = getSOATStatus();
    
    switch (status) {
      case 'Vencido':
        return const Color(0xFFE05D38); // Rojo
      case 'Próximo a vencer':
        return const Color(0xFFF5A462); // Naranja
      case 'Vigente':
        return const Color(0xFF0B9E7C); // Verde
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

    Color getSOATStatusSubColor() {
    final status = getSOATStatus();
    
    switch (status) {
      case 'Vencido':
        return const Color(0xFFFADDD7); // Rojo
      case 'Próximo a vencer':
        return const Color(0xFFFCECDE); // Naranja
      case 'Vigente':
        return const Color(0xFFECFAD7); // Verde
      default:
        return const Color.fromARGB(255, 217, 217, 217); // Gris
    }
  }
  
  // Método para determinar el estado de la RTM basado en la fecha de expiración o el estado proporcionado
  String getRTMStatus() {
    if (_alertData == null) {
      return 'No disponible';
    }
    
    // Si hay un estado explícito en los datos, usarlo
    if (_alertData!.containsKey('status')) {
      return _alertData!['status'];
    }
    
    // Si no hay estado explícito, calcularlo basado en la fecha de expiración
    if (_alertData!['expirationDate'] == null) {
      return 'No disponible';
    }

    try {
      final expirationDate = DateTime.parse(_alertData!['expirationDate']);
      final today = DateTime.now();
      final difference = expirationDate.difference(today).inDays;

      if (difference < 0) {
        return 'Vencido';
      } else if (difference <= 30) {
        return 'Próximo a vencer';
      } else {
        return 'Vigente';
      }
    } catch (e) {
      print('Error al determinar el estado de la RTM: $e');
      return 'No disponible';
    }
  }

  // Método para obtener el color del estado de la RTM
  Color getRTMStatusColor() {
    final status = getRTMStatus();
    
    switch (status) {
      case 'Vencido':
        return const Color(0xFFE05D38); // Rojo
      case 'Próximo a vencer':
        return const Color(0xFFF5A462); // Naranja
      case 'Vigente':
        return const Color(0xFF0B9E7C); // Verde
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

      Color getRTMStatusSubColor() {
    final status = getRTMStatus();
    
    switch (status) {
      case 'Vencido':
        return const Color(0xFFFADDD7); // Rojo
      case 'Próximo a vencer':
        return const Color(0xFFFCECDE); // Naranja
      case 'Vigente':
        return const Color(0xFFECFAD7); // Verde
      default:
        return const Color.fromARGB(255, 217, 217, 217); // Gris
    }
  }

  // Método para crear un nuevo vencimiento
  Future<int?> createExpiration(String expirationType, DateTime? expirationDate, int vehicleId, {List<Map<String, dynamic>>? reminders}) async {
    if (_isLoading) return null;
    
    print('\n🆕 CREANDO NUEVO VENCIMIENTO');
    print('🚗 ID del vehículo: $vehicleId');
    print('📝 Tipo de vencimiento: $expirationType');
    print('📅 Fecha de vencimiento: $expirationDate');
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Preparar el cuerpo de la solicitud
      final Map<String, dynamic> body = {
        'expirationType': expirationType,
        'vehicleId': vehicleId,
      };
      
      // Solo agregar la fecha si no es nula
      if (expirationDate != null) {
        // Convertir la fecha a formato ISO 8601 String para que sea serializable a JSON
        final String fechaISO = '${expirationDate.toIso8601String()}Z';
        body['expirationDate'] = fechaISO;
        print('📅 Fecha formateada para API: $fechaISO');
      }
      
      // Agregar recordatorios si no son nulos
      if (reminders != null && reminders.isNotEmpty) {
        body['reminders'] = List<dynamic>.from(reminders);
      }
      
      print('📦 Body de la petición: $body');
      
      // Usar el endpoint para crear vencimientos
      final endpoint = '/expiration';
      print('🔗 Endpoint para crear vencimiento: $endpoint');
      print('TOKEN al que tengo acceso desde special alerts: ${_authContext.token}');

      final response = await _apiService.post(
        endpoint,
        body: body,
        token: _authContext.token,
      );
      
      print('✅ Respuesta de creación: $response');
      
      // Extraer el ID del nuevo vencimiento de la respuesta
      int? newExpirationId;
      if (response.containsKey('id')) {
        newExpirationId = int.tryParse(response['id'].toString());
      } else if (response.containsKey('expirationId')) {
        newExpirationId = int.tryParse(response['expirationId'].toString());
      } else {
        print('\n⚠️ No se pudo extraer el ID del nuevo vencimiento de la respuesta');
      }
      
      _isLoading = false;
      notifyListeners();
      
      return newExpirationId;
    } catch (e) {
      print('\n❌ ERROR CREANDO VENCIMIENTO');
      print('📱 Error: $e');
      print('📱 Tipo de error: ${e.runtimeType}');
      
      // Extraer el mensaje específico de error si está disponible
      String errorMsg;
      
      if (e is APIException) {
        print('\n📱 Detectado error de tipo APIException');
        
        // Intentar obtener el mensaje específico usando el nuevo método
        String? specificMessage = e.getSpecificErrorMessage();
        if (specificMessage != null) {
          print('\n✅ Mensaje específico encontrado: $specificMessage');
          errorMsg = specificMessage;
        } else {
          // Si no hay mensaje específico, usar el mensaje general
          print('\n❌ No se encontró mensaje específico, usando mensaje general');
          errorMsg = e.message;
        }
        
        // Imprimir los datos completos del error para depuración
        if (e.rawData != null) {
          print('\n📝 Datos completos del error: ${e.rawData}');
        }
      } else {
        // Si no es un APIException, usar el mensaje de error estándar
        errorMsg = e.toString();
        print('\n❌ No es un APIException, usando mensaje estándar');
      }
      
      // Guardar el mensaje de error (ya sea el original o el específico)
      _error = errorMsg;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Método para eliminar una alerta especial
  Future<bool> deleteSpecialAlert(int alertId) async {
    if (_isLoading) return false;
    
    print('\n🔴 ELIMINANDO ALERTA ESPECIAL');
    print('🆔 ID de alerta: $alertId');
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Usar el endpoint para eliminar alertas especiales
      final endpoint = _apiService.getDeleteAlertEndpoint(alertId);
      print('🔗 Endpoint para eliminar alerta especial: $endpoint');
      
      final response = await _apiService.delete(
        endpoint,
        token: _authContext.token,
      );
      
      print('✅ Respuesta de eliminación: $response');
      
      // Limpiar los datos locales si la alerta eliminada es la que estamos mostrando
      if (_alertId == alertId) {
        _alertData = null;
        _alertId = null;
      }
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('📱 Error al eliminar alerta: $e');
      _error = 'Error al eliminar la alerta: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  // Método para actualizar una alerta especial
  Future<bool> updateSOATandRTM (int alertId, {List<Map<String, dynamic>>? reminders}) async {
    if (_isLoading) return false;
    _isLoading = true;
    notifyListeners();
    
    try {
      // Preparar el cuerpo de la solicitud
      final Map<String, dynamic> body = {};
      
      // Agregar recordatorios si no son nulos
      if (reminders != null && reminders.isNotEmpty) {
        body['reminders'] = List<dynamic>.from(reminders);
      }
      
      print('entre a updateSOATandRTM');
      print('📦 Body de la petición: $body');
      
      // Usar el endpoint para alertas especiales
      final endpoint = '/expiration/$alertId';
      print('🔗 Endpoint para actualizar alerta especial: $endpoint');
      print('TOKEN al que tengo acceso desde special alerts: ${_authContext.token}');


      final response = await _apiService.patch(
        endpoint,
        body: body,
        token: _authContext.token,
      );
      
      print('✅ Respuesta de actualización: $response');
      
      // Actualizar los datos locales
      if (_alertData != null && _alertId == alertId) {
        
        if (reminders != null) {
          _alertData!['reminders'] = reminders;
        }
      } else {
        // Si no tenemos datos locales, volver a cargar la alerta completa
        print('\n🔄 NO HAY DATOS LOCALES, RECARGANDO ALERTA COMPLETA');
        // Guardar el estado de carga actual
        final bool wasLoading = _isLoading;
        _isLoading = false;
        
        // Cargar la alerta después de terminar esta operación
        Future.microtask(() => loadSpecialAlert(alertId));
      }
      
      _isLoading = false;
      print('\n📢 NOTIFICANDO A LOS LISTENERS CON DATOS ACTUALIZADOS');
      notifyListeners();
      return true;
    } catch (e) {
      print('\n❌ ERROR ACTUALIZANDO ALERTA ESPECIAL');
      print('📱 Error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  


  // Método para actualizar una alerta especial
  Future<bool> updateInsurerAlert(int alertId, DateTime? expirationDate, {List<Map<String, dynamic>>? reminders, int? insurerId}) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();
    
    
    try {
      print('\n📃 SPECIAL_ALERTS_BLOC: updateInsurerAlert iniciado');
      print('\n💼 SPECIAL_ALERTS_BLOC: ID Aseguradora recibido: $insurerId (tipo: ${insurerId.runtimeType})');
      
      // Construir el cuerpo de la petición con el formato correcto para el backend
      final Map<String, dynamic> body = {
        "extraData": {
          "insurerId": insurerId,
        },
      };
      
      print('\n💾 SPECIAL_ALERTS_BLOC: Estructura del body con extraData: $body');

      // Preparar el cuerpo de la solicitud
      
      
      // Solo agregar la fecha si no es nula
      if (expirationDate != null) {
        // Usar directamente la fecha sin convertir a UTC nuevamente
        final String fechaISO =  "${expirationDate.toIso8601String()}Z";
        body['expirationDate'] = fechaISO;

      }
      
      // Agregar recordatorios si no son nulos
      if (reminders != null && reminders.isNotEmpty) {
        body['reminders'] = List<dynamic>.from(reminders);
      }
      
      print('📦 Body de la petición: $body');
      
      // Usar el endpoint para alertas especiales
      final endpoint = '/expiration/$alertId';
      print('🔗 Endpoint para actualizar alerta especial: $endpoint');
      print('TOKEN al que tengo acceso desde special alerts: ${_authContext.token}');


      final response = await _apiService.patch(
        endpoint,
        body: body,
        token: _authContext.token,
      );
      
      print('✅ Respuesta de actualización: $response');
      
      // Actualizar los datos locales
      if (_alertData != null && _alertId == alertId) {
        if (expirationDate != null) {
          _alertData!['expirationDate'] = expirationDate.toIso8601String();
          
          // Actualizar también el estado basado en la fecha
          final now = DateTime.now();
          final difference = expirationDate.difference(now).inDays;
          
          if (difference < 0) {
            _alertData!['status'] = 'Vencido';
          } else if (difference < 30) {
            _alertData!['status'] = 'Por vencer';
          } else {
            _alertData!['status'] = 'Vigente';
          }
          
          print('\n🔄 ESTADO ACTUALIZADO BASADO EN FECHA: ${_alertData!['status']}');
        }
        
        if (reminders != null) {
          _alertData!['reminders'] = reminders;
        }
      } else {
        // Si no tenemos datos locales, volver a cargar la alerta completa
        print('\n🔄 NO HAY DATOS LOCALES, RECARGANDO ALERTA COMPLETA');
        // Guardar el estado de carga actual
        final bool wasLoading = _isLoading;
        _isLoading = false;
        
        // Cargar la alerta después de terminar esta operación
        Future.microtask(() => loadSpecialAlert(alertId));
      }
      
      _isLoading = false;
      print('\n📢 NOTIFICANDO A LOS LISTENERS CON DATOS ACTUALIZADOS');
      notifyListeners();
      return true;
    } catch (e) {
      print('\n❌ ERROR ACTUALIZANDO ALERTA ESPECIAL');
      print('📱 Error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  


  // Método para actualizar una alerta especial
  Future<bool> updateSpecialAlert(int alertId, String expirationType, DateTime? expirationDate, {List<Map<String, dynamic>>? reminders, String? insurerId}) async {
    if (_isLoading) return false;
    
    print('\n🔄 ACTUALIZANDO ALERTA ESPECIAL');
    print('🆔 ID de alerta: $alertId');
    print('📝 Tipo de vencimiento: $expirationType');
    print('📅 Fecha de vencimiento: $expirationDate');

    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Preparar el cuerpo de la solicitud
      final Map<String, dynamic> body = {
        'expirationType': expirationType,
      };
      
      // Incluir insurerId si está disponible (para pólizas todo riesgo)
      if (insurerId != null && insurerId.isNotEmpty) {
        print('\n💼 SPECIAL_ALERTS_BLOC: Incluyendo insurerId: $insurerId');
        body['insurerId'] = insurerId;
      }
      
      // Solo agregar la fecha si no es nula
      if (expirationDate != null) {
        // Usar directamente la fecha sin convertir a UTC nuevamente
        final String fechaISO =  "${expirationDate.toIso8601String()}Z";
        body['expirationDate'] = fechaISO;

      }
      
      // Agregar recordatorios si no son nulos
      if (reminders != null && reminders.isNotEmpty) {
        body['reminders'] = List<dynamic>.from(reminders);
      }
      
      print('📦 Body de la petición: $body');
      
      // Usar el endpoint para alertas especiales
      final endpoint = '/expiration/$alertId';
      print('🔗 Endpoint para actualizar alerta especial: $endpoint');
      print('TOKEN al que tengo acceso desde special alerts: ${_authContext.token}');


      final response = await _apiService.patch(
        endpoint,
        body: body,
        token: _authContext.token,
      );
      
      print('✅ Respuesta de actualización: $response');
      
      // Actualizar los datos locales
      if (_alertData != null && _alertId == alertId) {
        _alertData!['expirationType'] = expirationType;
        if (expirationDate != null) {
          _alertData!['expirationDate'] = expirationDate.toIso8601String();
          
          // Actualizar también el estado basado en la fecha
          final now = DateTime.now();
          final difference = expirationDate.difference(now).inDays;
          
          if (difference < 0) {
            _alertData!['status'] = 'Vencido';
          } else if (difference < 30) {
            _alertData!['status'] = 'Por vencer';
          } else {
            _alertData!['status'] = 'Vigente';
          }
          
          print('\n🔄 ESTADO ACTUALIZADO BASADO EN FECHA: ${_alertData!['status']}');
        }
        
        if (reminders != null) {
          _alertData!['reminders'] = reminders;
        }
      } else {
        // Si no tenemos datos locales, volver a cargar la alerta completa
        print('\n🔄 NO HAY DATOS LOCALES, RECARGANDO ALERTA COMPLETA');
        // Guardar el estado de carga actual
        final bool wasLoading = _isLoading;
        _isLoading = false;
        
        // Cargar la alerta después de terminar esta operación
        Future.microtask(() => loadSpecialAlert(alertId));
      }
      
      _isLoading = false;
      print('\n📢 NOTIFICANDO A LOS LISTENERS CON DATOS ACTUALIZADOS');
      notifyListeners();
      return true;
    } catch (e) {
      print('\n❌ ERROR ACTUALIZANDO ALERTA ESPECIAL');
      print('📱 Error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  



  // Método para actualizar una alerta especial
  Future<bool> updateSpecialAlertRevertCount(int alertId, String expirationType, DateTime? expirationDate, {List<Map<String, dynamic>>? reminders}) async {
    if (_isLoading) return false;
    
    print('\n🔄 ACTUALIZANDO ALERTA ESPECIAL para reversa');
    print('🆔 ID de alerta: $alertId');
    print('📝 Tipo de vencimiento: $expirationType');
    print('📅 Fecha de vencimiento: $expirationDate');
    
    _isLoading = true;
    notifyListeners();

    // Formatear la fecha correctamente para la API, asegurando que solo tenga una Z al final
    String? fechaISO;
    if (expirationDate != null) {
      String isoString = expirationDate.toIso8601String();
      // Verificar si ya termina en Z para no duplicarla
      fechaISO = isoString.endsWith('Z') ? isoString : "${isoString}Z";
      print('\n📅 Fecha original: $expirationDate');
      print('\n📅 Fecha ISO formateada correctamente: $fechaISO');
    }
    
    try {
      // Preparar el cuerpo de la solicitud
      final Map<String, dynamic> body = {
        "extraData": {
          "lastMaintenanceDate": fechaISO,
        },
        'reminders':
            reminders,
      };
      
      // Solo agregar la fecha si no es nula
      if (expirationDate != null) {
        // Usar directamente la fecha sin convertir a UTC nuevamente
        // ya que la fecha ya viene en formato ISO con Z (UTC)
        //final formattedDate = expirationDate.toIso8601String();
        //body['expirationDate'] = formattedDate;
        print('📅 Fecha formateada para API: $fechaISO');
      }
      
      // Agregar recordatorios si no son nulos
      if (reminders != null && reminders.isNotEmpty) {
        body['reminders'] = List<dynamic>.from(reminders);
      }
      
      print('📦 Body de la petición: $body');
      
      // Usar el endpoint para alertas especiales
      final endpoint = '/expiration/$alertId';
      print('🔗 Endpoint para actualizar alerta especial: $endpoint');
      print('TOKEN al que tengo acceso desde special alerts: ${_authContext.token}');


      final response = await _apiService.patch(
        endpoint,
        body: body,
        token: _authContext.token,
      );
      
      print('✅ Respuesta de actualización: $response');
      
      // Actualizar los datos locales
      if (_alertData != null && _alertId == alertId) {
        _alertData!['expirationType'] = expirationType;
        if (expirationDate != null) {
          _alertData!['expirationDate'] = expirationDate.toIso8601String();
          
          // Actualizar también el estado basado en la fecha
          final now = DateTime.now();
          final difference = expirationDate.difference(now).inDays;
          
          if (difference < 0) {
            _alertData!['status'] = 'Vencido';
          } else if (difference < 30) {
            _alertData!['status'] = 'Por vencer';
          } else {
            _alertData!['status'] = 'Vigente';
          }
          
          print('\n🔄 ESTADO ACTUALIZADO BASADO EN FECHA: ${_alertData!['status']}');
        }
        
        if (reminders != null) {
          _alertData!['reminders'] = reminders;
        }
      } else {
        // Si no tenemos datos locales, volver a cargar la alerta completa
        print('\n🔄 NO HAY DATOS LOCALES, RECARGANDO ALERTA COMPLETA');
        // Guardar el estado de carga actual
        final bool wasLoading = _isLoading;
        _isLoading = false;
        
        // Cargar la alerta después de terminar esta operación
        Future.microtask(() => loadSpecialAlert(alertId));
      }
      
      _isLoading = false;
      print('\n📢 NOTIFICANDO A LOS LISTENERS CON DATOS ACTUALIZADOS');
      notifyListeners();
      return true;
    } catch (e) {
      print('\n❌ ERROR ACTUALIZANDO ALERTA ESPECIAL');
      print('📱 Error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  








  // Método para eliminar un vencimiento
  Future<bool> deleteExpiration(int alertId) async {
    if (_isLoading) return false;
    
    print('\n🗑️ ELIMINANDO VENCIMIENTO');
    print('🆔 ID de alerta: $alertId');
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Usar el endpoint para eliminar vencimientos
      final endpoint = '/expiration/$alertId/delete';
      print('🔗 Endpoint para eliminar vencimiento: $endpoint');
      
      final response = await _apiService.delete(
        endpoint,
        token: _authContext.token,
      );
      
      print('✅ Respuesta de eliminación: $response');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('\n❌ ERROR ELIMINANDO VENCIMIENTO');
      print('📱 Error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    print('\n🔄 REINICIANDO ESTADO DE SPECIALALERTSBLOC');
    _alertData = null;
    _isLoading = false;
    _error = null;
    _alertId = null;
    // No notificamos aquí para evitar actualizaciones innecesarias durante la carga
  }

  // Método para limpiar los datos sin hacer dispose
  void clear() {
    reset();
  }
  
  // Controlamos si el bloc ya ha sido disposed para evitar errores
  bool _isDisposed = false;
  
  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      reset();
      super.dispose();
    }
  }
}
