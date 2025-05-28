import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../services/API.dart';
import '../auth/auth_context.dart';
import '../images/image_bloc.dart';

class ProfileBloc extends ChangeNotifier {
  // Implementación del patrón Singleton
  static final ProfileBloc _instance = ProfileBloc._internal();
  factory ProfileBloc() => _instance;
  ProfileBloc._internal();

  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();
  final ImageBloc _imageBloc = ImageBloc();

  // Estado interno
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _error;
  
  // Mapa para controlar actualizaciones en progreso por campo
  final Map<String, bool> _updatingFields = {};

  // Getters
  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters específicos para datos del perfil
  String get name => _profileData?['name'] ?? '';
  String get phone => _profileData?['phone']?.toString() ?? '';
  String get email => _profileData?['email'] ?? '';
  String? get photo => _profileData?['photo'];
  String get cityName => _profileData?['city']?['cityName'] ?? '';
  bool get verify => _profileData?['verify'] ?? false;

  // Método para obtener los datos del perfil
  Future<void> loadProfile(int userId) async {
    if (_isLoading) return;

    try {
      print('\n👤 OBTENIENDO DATOS DEL PERFIL');
      print('🆔 UserId: $userId');
      print('🔑 Token: ${_authContext.token}');
      
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get(
        _apiService.getUserProfileEndpoint(userId),
        token: _authContext.token,
      );

      print('✅ Respuesta completa del perfil: $response');
      
      _profileData = response;
      
      // Imprimir información detallada sobre la foto para análisis
      print('\n🖼️ DATOS DE LA FOTO:');
      print('URL de la foto: ${_profileData?['photo']}');
      print('Tipo de dato de la foto: ${_profileData?['photo']?.runtimeType}');
      
      print('\n📋 Datos del perfil cargados:');
      print('Nombre: $name');
      print('Teléfono: $phone');
      print('Email: $email');
      print('Ciudad: $cityName');
        } catch (e) {
      print('\n❌ ERROR OBTENIENDO DATOS DEL PERFIL');
      print('📡 Error: $e');
      _error = e.toString();
      _profileData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para actualizar un campo específico del perfil
  /// Actualiza un campo del perfil del usuario
  /// Retorna un Map con 'success' (bool) y 'message' (String)
  Future<Map<String, dynamic>> updateProfileField(int userId, String field, String value) async {
    // Verificar si ya hay una actualización en progreso para este campo
    final String updateKey = '$userId-$field';
    if (_updatingFields[updateKey] == true) {
      print('\n⚠️ ACTUALIZACIÓN YA EN PROGRESO');
      print('🔑 UserId: $userId');
      print('🔤 Campo: $field');
      print('📝 Valor: $value');
      
      return {
        'success': false,
        'message': 'Ya hay una actualización en progreso para este campo'
      };
    }
    
    // Marcar este campo como en actualización
    _updatingFields[updateKey] = true;
    
    try {
      print('\n✏️ ACTUALIZANDO CAMPO DEL PERFIL');
      print('🔑 UserId: $userId');
      print('🔤 Campo: $field');
      print('📝 Valor: $value');
      
      _isLoading = true;
      notifyListeners();

      final Map<String, dynamic> updateData = {field: value};
      
      final response = await _apiService.patch(
        _apiService.updateUserProfileEndpoint(userId),
        body: updateData,
        token: _authContext.token,
      );

      print('✅ Respuesta de actualización: $response');
      print('Fin ciclo de peticiones');
      
      // Actualizar los datos locales con el nuevo valor
      if (_profileData != null) {
        _profileData![field] = value;
        
        // Si se está actualizando el correo electrónico, actualizar también el estado de verificación
        if (field == 'email') {
          print('\n💬 ACTUALIZANDO ESTADO DE VERIFICACIÓN: Nuevo correo no verificado');
          _profileData!['verify'] = false;
        }
        
        // Si se está actualizando el nombre, actualizar también el AuthContext
        if (field == 'name') {
          print('\n💬 ACTUALIZANDO NOMBRE EN AUTH CONTEXT: $value');
          _authContext.updateName(value);
        }
      }
      
      return {
        'success': true,
        'message': 'Perfil actualizado correctamente'
      };
    } catch (e) {
      print('\n❌ ERROR ACTUALIZANDO CAMPO DEL PERFIL');
      print('📡 Error: $e');
      
      // Extraer el mensaje de error de la excepción
      String errorMessage = e.toString();
      if (errorMessage.contains('APIException:')) {
        // Si es una APIException, extraer solo el mensaje relevante
        errorMessage = errorMessage.split('APIException:').last.trim();
        // Eliminar el código de error si está presente
        if (errorMessage.contains(']')) {
          errorMessage = errorMessage.split(']').last.trim();
        }
      }
      
      _error = errorMessage;
      return {
        'success': false,
        'message': errorMessage
      };
    } finally {
      // Limpiar el estado de actualización para este campo
      _updatingFields[updateKey] = false;
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Método para actualizar múltiples campos del perfil con PATCH
  Future<bool> updateUserProfile(int userId, Map<String, dynamic> updateData) async {
    try {
      print('\n✏️ ACTUALIZANDO PERFIL DE USUARIO');
      print('🔑 UserId: $userId');
      print('📝 Datos a actualizar: $updateData');
      
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.patch(
        _apiService.updateUserProfileEndpoint(userId),
        body: updateData,
        token: _authContext.token,
      );

      print('✅ Respuesta de actualización: $response');
      
      // Actualizar los datos locales con los nuevos valores
      if (_profileData != null) {
        updateData.forEach((key, value) {
          _profileData![key] = value;
        });
      }
      
      return true;
    } catch (e) {
      print('\n❌ ERROR ACTUALIZANDO PERFIL DE USUARIO');
      print('📡 Error: $e');
      _error = e.toString();
      
      // Lanzar una excepción para que se maneje en el bloque catch del llamador
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Método para actualizar la foto de perfil con URL
  Future<bool> updateProfilePhoto(int userId, String photoUrl) async {
    try {
      print('\n🖼️ ACTUALIZANDO FOTO DE PERFIL (URL)');
      print('🆔 UserId: $userId');
      print('🔗 URL de la foto: $photoUrl');
      
      _isLoading = true;
      notifyListeners();

      final Map<String, dynamic> updateData = {'photo': photoUrl};
      
      final response = await _apiService.patch(
        _apiService.updateUserProfileEndpoint(userId),
        body: updateData,
        token: _authContext.token,
      );

      print('✅ Respuesta de actualización de foto: $response');
      
      // Actualizar los datos locales con la nueva foto
      if (_profileData != null) {
        _profileData!['photo'] = photoUrl;
      }
      
      return true;
    } catch (e) {
      print('\n❌ ERROR ACTUALIZANDO FOTO DE PERFIL');
      print('📡 Error: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Método para actualizar la foto de perfil con un archivo
  Future<bool> updateProfilePhotoWithFile(int userId, File imageFile) async {
    try {
      print('\n🖼️ ACTUALIZANDO FOTO DE PERFIL (ARCHIVO)');
      print('🆔 UserId: $userId');
      print('📁 Archivo: ${imageFile.path}');
      
      _isLoading = true;
      notifyListeners();
      
      // Usar el endpoint específico para actualizar fotos
      final response = await _apiService.patchWithFile(
        _apiService.updateUserPhotoEndpoint(),
        file: imageFile,
        token: _authContext.token,
      );

      print('\n📡 RESPUESTA COMPLETA DEL ENDPOINT DE ACTUALIZACIÓN DE FOTO:');
      print('📡 Respuesta completa: $response');
      print('📡 Tipo de respuesta: ${response.runtimeType}');
      
      // Inspección detallada de la estructura de respuesta
      print('📡 Claves disponibles en la respuesta: ${response.keys.toList()}');
      
      // Verificar si existe la clave 'data'
      if (response.containsKey('data')) {
        print('📡 Contenido de data: ${response['data']}');
        if (response['data'] is Map<String, dynamic>) {
          final dataMap = response['data'] as Map<String, dynamic>;
          print('📡 Claves en data: ${dataMap.keys.toList()}');
          
          // Verificar si existe la clave 'photo' dentro de 'data'
          if (dataMap.containsKey('photo')) {
            print('📡 Valor de photo: ${dataMap['photo']}');
            print('📡 Tipo de photo: ${dataMap['photo'].runtimeType}');
          }
        }
      }
      
      // Verificar si existe la clave 'message'
      if (response.containsKey('message')) {
        print('📡 Mensaje: ${response['message']}');
      }
      
      // Verificar si existe la clave 'photo' directamente en la respuesta
      if (response.containsKey('photo')) {
        print('📡 Valor de photo (directo): ${response['photo']}');
        print('📡 Tipo de photo (directo): ${response['photo'].runtimeType}');
      }
      
      if (response is String) {
        print('📡 La respuesta es una cadena de texto: $response');
      } else if (response is int) {
        print('📡 La respuesta es un número entero: $response');
      }
      
      print('✅ Respuesta de actualización de foto: $response');
      
      // Consideramos que la actualización fue exitosa si recibimos cualquier respuesta 200
      // independientemente del formato, ya que el servidor parece estar respondiendo de manera inconsistente
      print('\n🔄 Actualización exitosa, recargando perfil para obtener la URL actualizada');
      
      print('\n🔄 Actualizando caché de imágenes');
      
      // Limpiar la caché de imágenes para forzar una recarga
      _imageBloc.clearCache();
      print('🗑 Caché de imágenes limpiado completamente');
      
      // Extraer la nueva URL de la foto directamente de la respuesta
      String? newPhotoUrl;
      
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is Map && data.containsKey('photo')) {
          newPhotoUrl = data['photo'] as String;
          print('\n🖼 NUEVA FOTO EXTRAÍDA DE LA RESPUESTA: $newPhotoUrl');
        }
      }
      
      // Si no pudimos extraer la URL de la respuesta, recargamos el perfil
      if (newPhotoUrl == null || newPhotoUrl.isEmpty) {
        print('\n⚠️ No se pudo extraer la URL de la foto de la respuesta, recargando perfil');
        // Esperar un momento para que el servidor procese la imagen
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Recargar el perfil para obtener la URL actualizada
        await loadProfile(userId);
        
        if (_profileData != null && _profileData!.containsKey('photo')) {
          newPhotoUrl = _profileData!['photo'];
        }
      }
      
      // Actualizar el contexto de autenticación con la nueva foto
      if (newPhotoUrl != null && newPhotoUrl.isNotEmpty) {
        print('\n🖼 ACTUALIZANDO FOTO DE PERFIL EN AUTH CONTEXT');
        print('🖼 URL de la foto: $newPhotoUrl');
        _authContext.updatePhoto(newPhotoUrl);
        print('✅ Foto actualizada en context');
        
        // Actualizar los datos locales con la nueva foto
        if (_profileData != null) {
          _profileData!['photo'] = newPhotoUrl;
        }
        
        // Invalidar la caché para esta foto específica
        print('🔄 Invalidando caché para la nueva foto');
        _imageBloc.invalidateCache(newPhotoUrl);
        
        // Forzar una recarga de la imagen en el caché
        await _imageBloc.getImageUrl(newPhotoUrl, forceRefresh: true);
      }
      
      return true;
    } catch (e) {
      print('\n❌ ERROR ACTUALIZANDO FOTO DE PERFIL CON ARCHIVO');
      print('📡 Error: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para eliminar la cuenta del usuario
  Future<bool> deleteAccount(int userId) async {
    try {
      print('\n🗑️ ELIMINANDO CUENTA DE USUARIO');
      print('🆔 UserId: $userId');
      
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.delete(
        _apiService.deleteUserAccountEndpoint(userId),
        token: _authContext.token,
      );

      print('✅ Respuesta de eliminación: $response');
      
      // Limpiar datos locales
      _profileData = null;
      _authContext.clearUserData();
      
      return true;
    } catch (e) {
      print('\n❌ ERROR ELIMINANDO CUENTA');
      print('📡 Error: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para limpiar el estado
  void reset() {
    _profileData = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
