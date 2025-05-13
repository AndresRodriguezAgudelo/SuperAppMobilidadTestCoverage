import 'package:flutter/foundation.dart';
import '../../services/API.dart';
import '../auth/auth_context.dart';

class ImageBloc extends ChangeNotifier {
  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();
  
  // Cache para almacenar las URLs de las imágenes ya procesadas
  // Agregamos un timestamp para evitar problemas de caché
  final Map<String, Map<String, dynamic>> _imageCache = {};
  
  // Método para procesar la key y obtener folderName e id
  Map<String, String> _processKey(String key) {
    ///print('\n🔍 PROCESANDO KEY: $key');
    
    final parts = key.split('/');
    if (parts.length != 2) {
      throw Exception('Key inválida: debe contener exactamente un "/"');
    }
    
    final folderName = parts[0];
    final id = parts[1];
    
    ///print('📁 FolderName: $folderName');
    ///print('🆔 ID: $id');
    
    return {
      'folderName': folderName,
      'id': id,
    };
  }
  
  // Método para obtener la URL de la imagen
  Future<String> getImageUrl(String key, {bool forceRefresh = false}) async {
    try {
      ///print('\n🖼 OBTENIENDO IMAGEN');
      ///print('🔑 Key: $key');
      ///print('🔄 Force refresh: $forceRefresh');
      
      // Verificar si ya tenemos la imagen en caché y no estamos forzando una actualización
      final now = DateTime.now().millisecondsSinceEpoch;
      if (!forceRefresh && _imageCache.containsKey(key)) {
        final cacheData = _imageCache[key]!;
        final cacheTime = cacheData['timestamp'] as int;
        final url = cacheData['url'] as String;
        
        // Verificar si la caché es reciente (menos de 5 segundos)
        if (now - cacheTime < 5000) {
          ///print('💾 Imagen encontrada en caché (reciente)');
          return url;
        } else {
          ///print('⏰ Caché expirada, obteniendo nueva URL');
        }
      }
      
      // Procesar la key para obtener folderName e id
      final params = _processKey(key);
      
      ///print('🔑 Token: ${_authContext.token}');
      
      // Construir la URL completa de la imagen
      final imageUrl = '${APIService.baseUrl}${_apiService.getFileEndpoint(
        params['folderName']!,
        params['id']!,
      )}';
      
      ///print('🌐 URL de la imagen: $imageUrl');
      
      // Intentar acceder a la imagen
      try {
        final response = await _apiService.get(
          _apiService.getFileEndpoint(
            params['folderName']!,
            params['id']!,
          ),
          token: _authContext.token,
        );
        
        ///print('✅ Imagen encontrada');
        
        // Guardar en caché con timestamp
        _imageCache[key] = {
          'url': imageUrl,
          'timestamp': DateTime.now().millisecondsSinceEpoch
        };
        ///print('💾 URL guardada en caché con timestamp');
        ///print('⏰ Timestamp: ${_imageCache[key]!["timestamp"]}');
        
        return imageUrl;
      } catch (e) {
        ///print('⚠️ Error accediendo a la imagen: $e');
        ///print('⚠️ Usando imagen por defecto');
        return 'assets/images/image_servicio1.png';
      }
    } catch (e) {
      ///print('\n❌ ERROR OBTENIENDO IMAGEN');
      ///print('📡 Error: $e');
      
      // En caso de error, retornar la imagen por defecto
      return 'assets/images/image_servicio1.png';
    }
  }
  
  // Método para limpiar el caché
  void clearCache() {
    ///print('\n🗑 LIMPIANDO CACHÉ DE IMÁGENES');
    _imageCache.clear();
    ///print('✅ Caché limpiado');
  }
  
  // Método para invalidar una entrada específica del caché
  void invalidateCache(String key) {
    ///print('\n🔄 INVALIDANDO CACHÉ PARA: $key');
    if (_imageCache.containsKey(key)) {
      _imageCache.remove(key);
      ///print('✅ Entrada eliminada del caché');
    } else {
      ///print('⚠️ La clave no existe en el caché');
    }
    notifyListeners();
  }
}
