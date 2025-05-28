import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

class Environment {

  static const String localPujol = 'https://widespread-rated-oo-labour.trycloudflare.com/api/sign/v1';
  static const String azure = 'https://equirentappbackend-dev-f9e9d0geh6dgdkeu.eastus2-01.azurewebsites.net/api/sign/v1';
}

class APIService {
  static final APIService _instance = APIService._internal();
  factory APIService() => _instance;
  APIService._internal();

  static const String baseUrl = Environment.azure;

  Map<String, String> _getHeaders([String? token]) {

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      ///print('🔑 Agregando token al header: Bearer $token');
    }

    return headers;

  }


  static const String _authEndpoint = '';
  String get callOTPEndpoint => '/otp/create';
  String get validateOTPEndpoint => '/otp/validate';
  String get loginEndpoint => '/auth/login';
  String get callCitysEndpoint => '/city';
  String get createUserEndpoint => '/user';
  String get getCarsEndpoint => '/vehicle';
  String get createVehicleEndpoint => '/vehicle';
  String get getDocumentTypesEndpoint => '/document-type';
  String get getServicingListEndpoint => '/servicing';
  String get getTotalGuidesEndpoint => '/guides/app/total';
  String get getAllGuidesEndpoint => '/guides/app/all';
  String get getInsurersEndpoint => '/insurer';
  
  // Endpoints para recuperación de cuenta y cambio de teléfono
  String get accountRecoveryEndpoint => '/user/recovery/account';
  String get validateResetOTPEndpoint => '/otp/validate/reset';
  String get registerNotificationsEndpoint => '/notifications/register';

  String getVehicleDetailEndpoint(int id) => '/vehicle/$id';
  String deleteVehicleEndpoint(int id) => '/vehicle/$id';
  String getFileEndpoint(String folderName, String id) => '/files/file/$folderName/$id';
  String getVehicleExpirationEndpoint(int vehicleId) => '/expiration/$vehicleId';

  // Historial vehicular endpoints
  String getVehicleHistoryEndpoint(String plate) => '/vehicle/$plate/history';
  String getVehicleFinesEndpoint(String plate) => '/fines-simit/$plate';
  String getVehicleFinesSimitEndpoint(String search) => '/fines-simit/$search';
  String getVehicleAccidentsEndpoint(String plate) => '/vehicle/$plate/accidents';
  String getVehicleTransferHistoryEndpoint(String plate) => '/vehicle/$plate/transfer-history';
  String getVehiclePrecautionaryMeasuresEndpoint(String plate) => '/vehicle/$plate/precautionary-measures';
  
  // Alertas especiales endpoint
  String getSpecialAlertEndpoint(int id) => '/expiration/$id/one';
  
  // Endpoint para eliminar una alerta de vencimiento
  String getDeleteAlertEndpoint(int id) => '/expiration/$id/delete';
  
  // Endpoint para actualizar alertas no especiales
  String updateExpirationEndpoint(int id) {
    final endpoint = '/expiration/$id';
    ///print('\n📍 DEBUG: Construyendo endpoint para actualizar alerta');
    ///print('🆔 ID de alerta: $id');
    ///print('🔗 Endpoint generado: $endpoint');
    ///print('🔗 URL completa: ${baseUrl + endpoint}');
    return endpoint;
  }

  String getNotificationEndpoint() => '/notification/register';
  
  String getPeakPlateEndpoint(String city, String plate) {
    ///print('\n🚦 API_SERVICE: getPeakPlateEndpoint - Ciudad original: "$city", Placa: "$plate"');
    
    // Normalizar el nombre de la ciudad: convertir a minúsculas, quitar acentos y reemplazar espacios por guiones
    String normalizedCity = city.toLowerCase();
    
    // Mapa de caracteres acentuados a no acentuados
    final accentMap = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
      'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u',
      'ä': 'a', 'ë': 'e', 'ï': 'i', 'ö': 'o', 'ü': 'u',
      'â': 'a', 'ê': 'e', 'î': 'i', 'ô': 'o', 'û': 'u',
      'ñ': 'n'
    };
    
    // Reemplazar caracteres acentuados
    accentMap.forEach((accent, normal) {
      normalizedCity = normalizedCity.replaceAll(accent, normal);
    });
    
    // Reemplazar espacios por guiones
    normalizedCity = normalizedCity.replaceAll(' ', '-');
    
    // Eliminar cualquier caracter que no sea alfanumérico o guión
    normalizedCity = normalizedCity.replaceAll(RegExp(r'[^a-z0-9-]'), '');
    
    ///print('\n🚦 API_SERVICE: getPeakPlateEndpoint - Ciudad normalizada: "$normalizedCity"');
    
    final endpoint = '/peak-plate/$normalizedCity/$plate';
    ///print('\n🚦 API_SERVICE: getPeakPlateEndpoint - Endpoint generado: $endpoint');
    return endpoint;
  }
  //String getPeakPlateEndpoint(String city, String plate) => '/peak-plate/bogota/$plate';


  // Expiration reload endpoint
  String getReloadExpirationEndpoint(String name, {int? expirationId, int? vehicleId}) {

    if (expirationId != null) {
      if (vehicleId != null) {
        return '/expiration/reload-expiration/$name/$expirationId/$vehicleId';
      }
      return '/expiration/reload-expiration/$name/$expirationId';
    }
    return '/expiration/reload-expiration/$name';
  }

  Future<Map<String, dynamic>> reloadExpiration(String name, {String? token, int? expirationId, int? vehicleId}) async {
    final endpoint = getReloadExpirationEndpoint(name, expirationId: expirationId, vehicleId: vehicleId);
    return await get(endpoint, token: token);
  }

  // User Profile endpoints
  static const String profileEndpoint = '/profile';
  String get getProfileEndpoint => '$profileEndpoint/me';
  
  // Query History endpoint
  String get queryHistoryEndpoint => '/query-history';
  
  /// Realiza una petición POST al endpoint de historial de consultas
  /// Este endpoint solo requiere el token de autenticación y no devuelve un JSON válido
  /// Solo registra en el backend cuando un usuario entra a la web view de pagos
  Future<void> queryHistory({required String token}) async {
    print('\n📃 CONSULTANDO HISTORIAL DE PAGOS');
    print('🔑 Token: ${token.substring(0, math.min(20, token.length))}...');
    print('📍 Endpoint: $queryHistoryEndpoint');
    
    try {
      // Realizar petición POST directamente con http para manejar respuestas no JSON
      final response = await http.post(
        Uri.parse(_buildUrl(queryHistoryEndpoint)),
        headers: _getHeaders(token),
      );
      
      // No intentamos parsear la respuesta como JSON, solo verificamos el código de estado
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Registro de historial exitoso: ${response.statusCode}');
      } else {
        print('⚠️ Respuesta no exitosa: ${response.statusCode}');
        // No lanzamos excepción, simplemente registramos el error
      }
    } catch (e) {
      // Capturamos la excepción pero no la relanzamos
      print('❌ ERROR CONSULTANDO HISTORIAL: $e');
      // No hacemos rethrow para no interrumpir el flujo
    }
  }

  // User endpoints
  static const String _userProfileEndpoint = '/user';
  String getUserProfileEndpoint(int userId) => '$_userProfileEndpoint/$userId';
  String updateUserProfileEndpoint(int userId) => '$_userProfileEndpoint/$userId';
  String updateUserPhotoEndpoint() => '$_userProfileEndpoint/photo/update';
  String updateUserPasswordEndpoint() => '$_userProfileEndpoint/password/update';
  String deleteUserAccountEndpoint(int userId) => '$_userProfileEndpoint/$userId';


  String _buildUrl(String endpoint) {
    final url = baseUrl + endpoint;
    ///print('\n📍 _buildUrl: URL construida: $url');
    return url;
  }


  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams, String? token}) async {

    try {
      ///print('\nDEBUG: Iniciando petición GET');
      ///print('DEBUG: Endpoint: $endpoint');
      ///print('DEBUG: Base URL: $baseUrl');
      
      final uri = Uri.parse(_buildUrl(endpoint));
      final urlWithParams = queryParams != null 
          ? uri.replace(queryParameters: queryParams)
          : uri;
      
      final headers = _getHeaders(token);
      ///print('DEBUG: URL completa: ${urlWithParams.toString()}');
      ///print('DEBUG: Headers: $headers');
      
      final response = await http.get(
        urlWithParams,
        headers: headers,
      );
      
      ///print('DEBUG: Código de respuesta: ${response.statusCode}');
      ///print('DEBUG: Cuerpo de respuesta: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body, String? token}) async {

    try {
      final response = await http.post(
        Uri.parse(_buildUrl(endpoint)),
        headers: _getHeaders(token),
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }

  }

  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body, String? token}) async {

    try {
      final response = await http.put(
        Uri.parse(_buildUrl(endpoint)),
        headers: _getHeaders(token),
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
    
  }

  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse(_buildUrl(endpoint)),
        headers: _getHeaders(token),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String endpoint, {Map<String, dynamic>? body, String? token}) async {
    try {
      ///print('\nDEBUG: Iniciando petición PATCH');
      ///print('DEBUG: Endpoint: $endpoint');
      ///print('DEBUG: Base URL: $baseUrl');
      ///print('DEBUG: Body: $body');
      
      final uri = Uri.parse(_buildUrl(endpoint));
      final headers = _getHeaders(token);
      
      ///print('\n🔍 PATCH REQUEST DETAILS:');
      ///print('🔗 URL completa: ${uri.toString()}');
      ///print('📋 Headers completos:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          // Mostrar solo los primeros 20 caracteres del token por seguridad
          ///print('   $key: ${value.substring(0, math.min(20, value.length))}...');
        } else {
          ///print('   $key: $value');
        }
      });
      ///print('📦 Body: ${json.encode(body)}');
      
      final response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(body),
      );
      
      ///print('DEBUG: Código de respuesta: ${response.statusCode}');
      ///print('DEBUG: Cuerpo de respuesta: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      ///print('\nERROR en PATCH: $e');
      throw _handleError(e);
    }
  }
  
  // Método para enviar archivos usando FormData
  Future<Map<String, dynamic>> patchWithFile(String endpoint, {required File file, Map<String, String>? fields, String? token}) async {
    try {
      ///print('\nDEBUG: Iniciando petición PATCH con archivo');
      ///print('DEBUG: Endpoint: $endpoint');
      ///print('DEBUG: Base URL: $baseUrl');
      ///print('DEBUG: Archivo: ${file.path}');
      ///print('DEBUG: Campos adicionales: $fields');
      
      final uri = Uri.parse(_buildUrl(endpoint));
      
      // Crear una solicitud multipart
      final request = http.MultipartRequest('PATCH', uri);
      
      // Agregar el token de autorización si está disponible
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Agregar campos adicionales si están disponibles
      if (fields != null) {
        ///print('DEBUG: Agregando campos adicionales: $fields');
        request.fields.addAll(fields);
      } else {
        ///print('DEBUG: No se agregan campos adicionales');
        // Según la documentación, este endpoint no requiere campos adicionales
      }
      
      // Determinar el tipo MIME basado en la extensión del archivo
      final fileExtension = file.path.split('.').last.toLowerCase();
      String contentType;
      
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        default:
          contentType = 'application/octet-stream';
      }
      
      // Agregar el archivo a la solicitud
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      
      final multipartFile = http.MultipartFile(
        'file', // Nombre del campo para el archivo (según la documentación del API)
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
        contentType: MediaType.parse(contentType),
      );
      
      request.files.add(multipartFile);
      
      ///print('\n🔍 PATCH WITH FILE REQUEST DETAILS:');
      /////print('🔗 URL completa: ${uri.toString()}');
      /////print('📋 Headers: ${request.headers}');
      /////print('📦 Campos: ${request.fields}');
      /////print('📁 Archivo: ${file.path} (${fileLength} bytes, $contentType)');
      
      // Enviar la solicitud y obtener la respuesta
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      ///print('DEBUG: Código de respuesta: ${response.statusCode}');
      ///print('DEBUG: Cuerpo de respuesta: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      ///print('\nERROR en PATCH con archivo: $e');
      throw _handleError(e);
    }
  }



  Map<String, dynamic> _handleResponse(http.Response response) {
    ///print('\n💯 _handleResponse: Procesando respuesta HTTP');
    ///print('💯 Status code: ${response.statusCode}');
    ///print('💯 Headers: ${response.headers}');
    ///print('💯 Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Si la respuesta está vacía, devolver éxito
      if (response.body.isEmpty) {
        ///print('💯 Respuesta vacía, devolviendo success: true');
        return {'success': true};
      }
      
      try {
        // Intentar parsear como JSON
        final jsonData = json.decode(response.body);
        ///print('💯 Respuesta parseada como JSON: $jsonData');
        return jsonData;
      } catch (e) {
        // Si no es JSON, devolver como mensaje de texto
        ///print('💯 Error al parsear JSON: $e');
        ///print('💯 Devolviendo respuesta como mensaje de texto');
        return {
          'message': response.body.trim(),
          'success': true
        };
      }
    } else {
      print('\n🔝 ERROR: Status code ${response.statusCode}');
      print('\n🔝 Cuerpo de la respuesta: ${response.body}');
      
      String errorMessage;
      Map<String, dynamic>? errorData;
      
      try {
        // Intentar parsear el cuerpo de la respuesta como JSON
        errorData = json.decode(response.body);
        print('\n🔝 Datos de error parseados: $errorData');
        
        // Extraer el mensaje general de error
        errorMessage = errorData?['message'] ?? response.body;
        print('\n🔝 Mensaje de error del servidor: $errorMessage');
        
        // Verificar si hay mensajes específicos de error
        if (errorData != null && 
            errorData.containsKey('errors') && 
            errorData['errors'] is List && 
            (errorData['errors'] as List).isNotEmpty) {
          print('\n✅ Encontrados mensajes específicos de error: ${errorData['errors']}');
        }
      } catch (e) {
        errorMessage = response.body;
        print('\n🔝 Error al parsear respuesta de error: $e');
        print('\n🔝 Usando body completo como mensaje de error');
      }
      
      print('\n🔝 Lanzando APIException con datos completos');
      throw APIException(
        statusCode: response.statusCode,
        message: errorMessage,
        rawData: errorData,
      );
    }
  }


  Exception _handleError(dynamic error) {
    if (error is APIException) {
      return error;
    }
    return APIException(
      statusCode: 0,
      message: error.toString(),
    );
  }
}

class APIException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? rawData; // Datos completos del error

  APIException({
    required this.statusCode,
    required this.message,
    this.rawData,
  });

  @override
  String toString() => 'APIException: [$statusCode] $message';
  
  // Método para obtener el mensaje específico de error si está disponible
  String? getSpecificErrorMessage() {
    try {
      if (rawData != null && 
          rawData!.containsKey('errors') && 
          rawData!['errors'] is List && 
          (rawData!['errors'] as List).isNotEmpty) {
        final firstError = (rawData!['errors'] as List).first;
        if (firstError is Map && firstError.containsKey('message')) {
          return firstError['message'] as String?;
        }
      }
    } catch (e) {
      print('Error al extraer mensaje específico: $e');
    }
    return null;
  }
}