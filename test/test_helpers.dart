import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/BLoC/images/image_bloc.dart';
import 'package:Equirent_Mobility/BLoC/guides/guides_bloc.dart';

/// Widget de prueba para reemplazar imágenes de red
/// Evita errores de carga de imágenes durante las pruebas
class TestImageWidget extends StatelessWidget {
  final String url;
  
  const TestImageWidget({super.key, required this.url});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.blue,
      child: Center(child: Text(url)),
    );
  }
}

/// Widget de prueba para reemplazar reproductores de video
/// Evita errores de inicialización de video durante las pruebas
class TestVideoWidget extends StatelessWidget {
  final String videoUrl;
  
  const TestVideoWidget({super.key, required this.videoUrl});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      color: Colors.black,
      child: Center(child: Text('Video: $videoUrl', style: const TextStyle(color: Colors.white))),
    );
  }
}

/// Configura el entorno de pruebas para manejar recursos externos

/// Mock de AuthContext para pruebas
class MockAuthContext extends ChangeNotifier {
  String? _token;
  String? _name;
  String? _phone;
  String? _photo;
  int? _userId;
  bool wasLogoutCalled = false;
  
  // Getters requeridos por AuthContext
  String? get token => _token;
  String? get name => _name;
  String? get phone => _phone;
  String? get photo => _photo;
  int? get userId => _userId;
  
  // Método para configurar datos de usuario en pruebas
  void setUserData({
    String? token,
    String? name,
    String? phone,
    String? photo,
    int? userId,
    String? email, // Parámetro adicional para pruebas
  }) {
    _token = token;
    _name = name;
    _phone = phone;
    _photo = photo;
    _userId = userId;
    notifyListeners();
  }
  
  void clearUserData() {
    _token = null;
    _name = null;
    _phone = null;
    _photo = null;
    _userId = null;
    wasLogoutCalled = true;
    notifyListeners();
  }
  
  // Implementación de factory y singleton para compatibilidad
  static final MockAuthContext _instance = MockAuthContext._internal();
  factory MockAuthContext() => _instance;
  MockAuthContext._internal();
}
void configureTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Desactivar mensajes de error de imágenes durante las pruebas
  PaintingBinding.instance.imageCache.maximumSize = 0;
  
  // Registrar un handler para cargar imágenes de prueba
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/video_player'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'init') {
        return null;
      }
      if (methodCall.method == 'create') {
        return null;
      }
      if (methodCall.method == 'dispose') {
        return null;
      }
      return null;
    },
  );
}

/// Crea un widget de prueba que envuelve el widget a probar
Widget testableWidget({
  required Widget child,
  List<NavigatorObserver>? navigatorObservers,
  Map<String, WidgetBuilder>? routes,
}) {
  return MaterialApp(
    navigatorObservers: navigatorObservers ?? [],
    routes: routes ?? {},
    home: Scaffold(
      body: child,
    ),
  );
}

/// Clase base para simular respuestas de API
class MockAPIResponse {
  static Map<String, dynamic> guidesResponse() {
    return {
      'categories': [
        {
          'categoryName': 'Categoría 1',
          'items': [
            {
              'id': 1,
              'name': 'Guía 1',
              'categoryId': 1,
              'keyMain': 'guides/image1',
              'keySecondary': 'guides/image2',
              'keyTertiaryVideo': 'guides/video1',
              'description': 'Descripción de la guía 1'
            },
            {
              'id': 2,
              'name': 'Guía 2',
              'categoryId': 1,
              'keyMain': 'guides/image3',
              'keySecondary': 'guides/image4',
              'keyTertiaryVideo': 'guides/video2',
              'description': 'Descripción de la guía 2'
            }
          ]
        },
        {
          'categoryName': 'Categoría 2',
          'items': [
            {
              'id': 3,
              'name': 'Guía 3',
              'categoryId': 2,
              'keyMain': 'guides/image5',
              'keySecondary': 'guides/image6',
              'keyTertiaryVideo': 'guides/video3',
              'description': 'Descripción de la guía 3'
            }
          ]
        }
      ]
    };
  }
  
  static Map<String, dynamic> imageResponse(String folderName, String id) {
    return {
      'url': 'https://example.com/images/$folderName/$id.jpg'
    };
  }
  
  static Map<String, dynamic> errorResponse(String message) {
    return {
      'error': true,
      'message': message
    };
  }
}

/// Clase para simular BLoCs en pruebas
/// Mock de ImageBloc para pruebas
class MockImageBloc extends ChangeNotifier implements ImageBloc {
  final Map<String, String> _imageCache;
  final bool shouldFailAPI;
  final bool delayResponse;

  MockImageBloc({
    Map<String, String>? imageCache,
    this.shouldFailAPI = false,
    this.delayResponse = false,
  }) : _imageCache = imageCache ?? {};

  @override
  Future<String> getImageUrl(String key, {bool forceRefresh = false}) async {
    // Simular retraso en la respuesta si se solicita
    if (delayResponse) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    // Simular error de API si se solicita
    if (shouldFailAPI) {
      return 'assets/images/image_servicio1.png';
    }
    
    // Verificar formato de key
    if (!key.contains('/')) {
      return 'assets/images/image_servicio1.png';
    }
    
    // Si se solicita forzar actualización, ignorar caché
    if (forceRefresh) {
      // Simular obtención de nueva URL
      return 'assets/images/image_servicio1.png?t=${DateTime.now().millisecondsSinceEpoch}';
    }
    
    // Devolver URL en caché si existe
    if (_imageCache.containsKey(key)) {
      return _imageCache[key]!;
    }
    
    // Por defecto, devolver imagen por defecto
    return 'assets/images/image_servicio1.png';
  }

  @override
  void clearCache() {
    _imageCache.clear();
    notifyListeners();
  }
  
  @override
  void invalidateCache(String key) {
    if (_imageCache.containsKey(key)) {
      _imageCache.remove(key);
    }
    notifyListeners();
  }
}

/// Mock de GuidesBloc para pruebas
class MockGuidesBloc extends ChangeNotifier implements GuidesBloc {
  final List<GuideCategory> _categories;
  final bool _isLoading;
  final String? _error;

  MockGuidesBloc({
    List<GuideCategory>? categories,
    bool isLoading = false,
    String? error,
  }) : 
    _categories = categories ?? [],
    _isLoading = isLoading,
    _error = error;

  @override
  List<GuideCategory> get categories => _categories;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  Future<void> loadGuides() async {
    // No hace nada en el mock
    return;
  }

  @override
  void reset() {
    // No hace nada en el mock
  }
}

class MockBLoCs {
  /// Crea un mock simple de GuidesBloc para pruebas
  static dynamic mockGuidesBloc({
    List<Map<String, dynamic>>? categories,
    bool isLoading = false,
    String? error,
  }) {
    // Esta es una implementación simplificada para pruebas
    // No modifica el código real en lib/
    return {
      'getCategories': () => categories ?? [],
      'getIsLoading': () => isLoading,
      'getError': () => error,
    };
  }
  
  /// Crea un mock simple de ImageBloc para pruebas
  static dynamic mockImageBloc({
    Map<String, String> imageCache = const {},
  }) {
    // Esta es una implementación simplificada para pruebas
    // No modifica el código real en lib/
    return {
      'getImageUrl': (String key, {bool forceRefresh = false}) async {
        if (!forceRefresh && imageCache.containsKey(key)) {
          return imageCache[key]!;
        }
        return 'assets/images/image_servicio1.png';
      },
      'clearCache': () {},
      'invalidateCache': (String key) {}
    };
  }
}

/// Mock de ProfileBloc para pruebas
class MockProfileBloc extends ChangeNotifier {
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _error;
  bool _updatePhotoSuccess = true;
  
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
  
  // Configurar datos de perfil para pruebas
  void setProfileData(Map<String, dynamic> data) {
    _profileData = data;
    notifyListeners();
  }
  
  // Configurar estado de carga
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Configurar error
  void setError(String? errorMsg) {
    _error = errorMsg;
    notifyListeners();
  }
  
  // Configurar resultado de actualización de foto
  void setUpdatePhotoSuccess(bool success) {
    _updatePhotoSuccess = success;
  }
  
  // Mock del método para actualizar la foto de perfil
  Future<bool> updateProfilePhoto(int userId, String photoUrl) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (_updatePhotoSuccess) {
      if (_profileData != null) {
        _profileData!['photo'] = photoUrl;
      } else {
        _profileData = {'photo': photoUrl};
      }
    }
    
    _isLoading = false;
    notifyListeners();
    
    return _updatePhotoSuccess;
  }
}
