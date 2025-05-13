import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../BLoC/auth/auth_context.dart';
import '../screens/notification_screen.dart';
import '../services/API.dart';

/// Manejador global para notificaciones en segundo plano
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Asegurarse de que Firebase esté inicializado
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  
  // No podemos mostrar notificaciones locales aquí sin flutter_local_notifications
  // Pero Firebase mostrará automáticamente la notificación en la bandeja del sistema
  ///debugPrint('NOTIFICATION_SERVICE: Notificación recibida en segundo plano: ${message.notification?.title}');
}

class NotificationService {
  // Canal para comunicación con el código nativo de iOS
  static const MethodChannel _iosNotificationChannel = MethodChannel('com.tuapp/ios_notifications');

  /// Inicializa la escucha de eventos desde iOS (APNs)
  void listenToIosNotifications() {
    ///debugPrint('\n==================================================');
    ///debugPrint('DEBUG_FLUTTER: CONFIGURANDO ESCUCHA DE EVENTOS iOS APNs');
    ///debugPrint('==================================================\n');
    
    if (!Platform.isIOS) {
      ///debugPrint('DEBUG_FLUTTER: No estamos en iOS, saliendo de listenToIosNotifications');
      return;
    }
    
    try {
      ///debugPrint('DEBUG_FLUTTER: Configurando MethodChannel para iOS');
      _iosNotificationChannel.setMethodCallHandler((call) async {
        ///debugPrint('DEBUG_FLUTTER: Evento recibido desde iOS nativo: ${call.method}');
        
        if (call.method == 'onReceiveAPNSToken') {
          final token = call.arguments as String;
          ///debugPrint('\n==================================================');
          ///debugPrint('DEBUG_FLUTTER: APNs TOKEN RECIBIDO: $token');
          ///debugPrint('DEBUG_FLUTTER: LONGITUD DEL TOKEN: ${token.length} caracteres');
          ///debugPrint('==================================================\n');
          
          // Guardar el token APNs para usarlo después del login
          _deviceToken = token;
          // NO enviamos el token automáticamente, se enviará después del login
          return 'Token recibido exitosamente';
        } 
        else if (call.method == 'onReceiveNotification') {
          // Procesar notificación APNs recibida con la app en primer plano
          ///debugPrint('\n==================================================');
          ///debugPrint('DEBUG_FLUTTER: NOTIFICACIÓN APNs RECIBIDA (APP ABIERTA)');
          ///debugPrint('DEBUG_FLUTTER: Tipo de datos: ${call.arguments.runtimeType}');
          ///debugPrint('DEBUG_FLUTTER: Contenido: ${call.arguments}');
          ///debugPrint('==================================================\n');
          
          try {
            final notification = call.arguments as Map<dynamic, dynamic>;
            // Convertir la notificación APNs al formato común para mostrarla
            await _showIosNotification(notification);
            return 'Notificación procesada exitosamente';
          } catch (e) {
            ///debugPrint('DEBUG_FLUTTER: ERROR al procesar notificación APNs: $e');
            return FlutterError('Error al procesar notificación: $e');
          }
        }
        else if (call.method == 'onNotificationTap') {
          ///debugPrint('\n==================================================');
          ///debugPrint('DEBUG_FLUTTER: TAP EN NOTIFICACIÓN APNs');
          ///debugPrint('DEBUG_FLUTTER: Contenido: ${call.arguments}');
          ///debugPrint('==================================================\n');
          return 'Tap en notificación procesado';
        }
        
        ///debugPrint('DEBUG_FLUTTER: Método desconocido: ${call.method}');
        return FlutterError('Método no implementado: ${call.method}');
      });
      ///debugPrint('DEBUG_FLUTTER: MethodChannel configurado correctamente');
    } catch (e) {
      ///debugPrint('DEBUG_FLUTTER: ERROR al configurar MethodChannel: $e');
    }
  }

  final APIService _api = APIService();
  //final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // Temporalmente comentado para resolver problemas de compilación
  // final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Token del dispositivo
  String? _deviceToken;
  String? get deviceToken => _deviceToken;

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Inicializa el servicio de notificaciones y genera un token de dispositivo
  /// Optimizado para evitar duplicaciones y mejorar el manejo de errores
  Future<void> initialize() async {
    try {
      ///debugPrint('\n==================================================');
      ///debugPrint('NOTIFICATION_SERVICE: INICIANDO SERVICIO DE NOTIFICACIONES');
      ///debugPrint('==================================================\n');
      
      // Verificar si Firebase ya está inicializado
      if (Firebase.apps.isEmpty) {
        ///debugPrint('NOTIFICATION_SERVICE: Firebase no está inicializado. Esperando inicialización desde main.dart');
        await Future.delayed(const Duration(seconds: 1));
        
        // Verificar nuevamente si Firebase se ha inicializado
        if (Firebase.apps.isEmpty) {
          throw Exception('Firebase no se ha inicializado después de esperar');
        }
      } else {
        ///debugPrint('NOTIFICATION_SERVICE: Firebase ya estaba inicializado');
      }
      
      // Solicitar permisos para notificaciones
      await _requestNotificationPermissions();
      
      // Configurar para evitar notificaciones duplicadas en Android
      if (Platform.isAndroid) {
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: false,  // No mostrar alerta del sistema
          badge: false,  // No actualizar badge
          sound: false,  // No reproducir sonido
        );
      }
      
      // FLUJO PARA iOS: Obtener y guardar el token APNs (sin enviarlo al backend aún)
      if (Platform.isIOS) {
        try {
          // Configurar el canal para recibir notificaciones APNs cuando la app está en primer plano
          ///debugPrint('NOTIFICATION_SERVICE: Configurando canal para notificaciones iOS');
          listenToIosNotifications();
          
          final apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken != null && apnsToken.isNotEmpty) {
            // Mostrar solo una parte del token por seguridad
            final tokenPreview = apnsToken.length > 16 
                ? "${apnsToken.substring(0, 8)}...${apnsToken.substring(apnsToken.length - 8)}"
                : apnsToken;
                
            ///debugPrint('\n==================================================');
            ///debugPrint('NOTIFICATION_SERVICE: APNs TOKEN OBTENIDO: $tokenPreview');
            ///debugPrint('NOTIFICATION_SERVICE: LONGITUD DEL TOKEN: ${apnsToken.length} caracteres');
            ///debugPrint('NOTIFICATION_SERVICE: PLATAFORMA: ios');
            ///debugPrint('==================================================\n');
            _deviceToken = apnsToken;
            // NO generamos token alternativo ni enviamos al backend aquí
            // El token APNs se enviará después del login exitoso
          } else {
            ///debugPrint('NOTIFICATION_SERVICE: Token APNs no disponible, probablemente estamos en un simulador');
          }
        } catch (e) {
          ///debugPrint('NOTIFICATION_SERVICE: Error al obtener token APNs: $e');
        }
      } 
      // FLUJO PARA ANDROID: Obtener el token FCM normalmente
      else if (Platform.isAndroid) {
        try {
          final firebaseToken = await _firebaseMessaging.getToken();
          if (firebaseToken != null && firebaseToken.isNotEmpty) {
            _deviceToken = firebaseToken;
            
            // Mostrar solo una parte del token por seguridad
            final tokenPreview = firebaseToken.length > 16 
                ? "${firebaseToken.substring(0, 8)}...${firebaseToken.substring(firebaseToken.length - 8)}"
                : firebaseToken;
                
            ///debugPrint('\n==================================================');
            ///debugPrint('NOTIFICATION_SERVICE: LONGITUD DEL TOKEN: ${firebaseToken.length} caracteres');
            ///debugPrint('==================================================\n');
            // NO enviamos el token al backend aquí, se enviará después del login
          } else {
            ///debugPrint('NOTIFICATION_SERVICE: Token FCM no disponible en Android');
          }
        } catch (e) {
          ///debugPrint('NOTIFICATION_SERVICE: Error al obtener token de Firebase en Android: $e');
        }
      }
      
      // Configurar manejadores de mensajes (solo una vez)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        ///debugPrint('NOTIFICATION_SERVICE: Mensaje recibido mientras la app está en primer plano');
        ///debugPrint('NOTIFICATION_SERVICE: Título: ${message.notification?.title}');
        ///debugPrint('NOTIFICATION_SERVICE: Cuerpo: ${message.notification?.body}');
        _showLocalNotification(message);
      });
      
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        ///debugPrint('NOTIFICATION_SERVICE: Aplicación abierta desde notificación: ${message.notification?.title}');
        // Aquí se podría implementar navegación a una pantalla específica
      });
      
      // Registrar manejador para notificaciones en segundo plano
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      
      ///debugPrint('\n==================================================');
      ///debugPrint('NOTIFICATION_SERVICE: INICIALIZACIÓN COMPLETADA');
      if (_deviceToken != null) {
        final tokenPreview = _deviceToken!.length > 16 
            ? "${_deviceToken!.substring(0, 8)}...${_deviceToken!.substring(_deviceToken!.length - 8)}"
            : _deviceToken;
        ///debugPrint('NOTIFICATION_SERVICE: TOKEN FINAL: $tokenPreview');
      } else {
        ///debugPrint('NOTIFICATION_SERVICE: NO SE OBTUVO TOKEN');
      }
      ///debugPrint('==================================================\n');
      
    } catch (e) {
      // En caso de error, solo registramos el error
      ///debugPrint('NOTIFICATION_SERVICE: Error al inicializar el servicio de notificaciones: $e');
      
      // En iOS NO generamos token alternativo, respetamos el APNs token o nada
      if (!Platform.isIOS) {
        // Solo para Android podemos considerar un token alternativo
        _deviceToken = await _generateDeviceToken();
        
        // Mostrar solo una parte del token por seguridad
        if (_deviceToken != null) {
          final tokenPreview = _deviceToken!.length > 16 
              ? "${_deviceToken!.substring(0, 8)}...${_deviceToken!.substring(_deviceToken!.length - 8)}"
              : _deviceToken;
              
          ///debugPrint('\n==================================================');
          ///debugPrint('NOTIFICATION_SERVICE: TOKEN ALTERNATIVO GENERADO SOLO PARA ANDROID: $tokenPreview');
          ///debugPrint('NOTIFICATION_SERVICE: PLATAFORMA: ${getPlatform()}');
          ///debugPrint('==================================================\n');
        }
      } else {
        ///debugPrint('\n==================================================');
        ///debugPrint('NOTIFICATION_SERVICE: EN iOS NO SE GENERA TOKEN ALTERNATIVO');
        ///debugPrint('NOTIFICATION_SERVICE: SE USARÁ SOLO EL APNs TOKEN ORIGINAL');
        ///debugPrint('==================================================\n');
      }
    }
  }
  
  /// Genera un token único para el dispositivo basado en información del dispositivo
  /// El token generado debe estar en formato hexadecimal para ser compatible con Firebase
  Future<String> _generateDeviceToken() async {
    try {
      // Obtener información del dispositivo
      String deviceId = '';
      String deviceModel = '';
      String platform = getPlatform();
      
      // Intentar obtener información del dispositivo si se habilita device_info_plus
      // Por ahora, usamos un identificador aleatorio persistente
      if (Platform.isAndroid) {
        //final androidInfo = await _deviceInfo.androidInfo;
        //deviceId = androidInfo.id;
        //deviceModel = '${androidInfo.brand} ${androidInfo.model}';
        deviceId = _generatePersistentId('android');
        deviceModel = 'Android Device';
      } else if (Platform.isIOS) {
        //final iosInfo = await _deviceInfo.iosInfo;
        //deviceId = iosInfo.identifierForVendor ?? '';
        //deviceModel = '${iosInfo.name} ${iosInfo.model}';
        deviceId = _generatePersistentId('ios');
        deviceModel = 'iOS Device';
      }
      
      // Si no se pudo obtener un ID de dispositivo, generar uno aleatorio
      if (deviceId.isEmpty) {
        deviceId = _generateRandomId();
      }
      
      // Combinar información para crear una semilla para el token
      final tokenSeed = '$deviceId-$deviceModel-$platform-${DateTime.now().millisecondsSinceEpoch}';
      ///debugPrint('NOTIFICATION_SERVICE: Token seed: $tokenSeed');
      
      // Generar un token hexadecimal de 64 caracteres (formato similar a FCM)
      final random = Random();
      final hexChars = '0123456789abcdef';
      final hexToken = List.generate(64, (_) => hexChars[random.nextInt(hexChars.length)]).join('');
      
      // Validar que el token cumple con el formato requerido
      if (!_isValidHexToken(hexToken)) {
        ///debugPrint('NOTIFICATION_SERVICE: ⚠️ Token generado no válido, regenerando...');
        return _generateDeviceToken(); // Intentar de nuevo
      }
      
      ///debugPrint('\n==================================================');
      ///debugPrint('NOTIFICATION_SERVICE: TOKEN ALTERNATIVO HEXADECIMAL GENERADO: $hexToken');
      ///debugPrint('NOTIFICATION_SERVICE: LONGITUD DEL TOKEN: ${hexToken.length} caracteres');
      ///debugPrint('==================================================\n');
      
      return hexToken;
    } catch (e) {
      ///debugPrint('Error al generar token de dispositivo: $e');
      // Generar un token hexadecimal aleatorio como fallback
      final random = Random();
      final hexChars = '0123456789abcdef';
      final fallbackToken = List.generate(64, (_) => hexChars[random.nextInt(hexChars.length)]).join('');
      
      ///debugPrint('NOTIFICATION_SERVICE: ⚠️ Usando token de fallback: $fallbackToken');
      return fallbackToken;
    }
  }
  
  /// Verifica que el token sea un string hexadecimal válido de 64 caracteres
  bool _isValidHexToken(String token) {
    if (token.length != 64) return false;
    
    // Verificar que solo contiene caracteres hexadecimales
    final hexRegex = RegExp(r'^[0-9a-f]+$');
    return hexRegex.hasMatch(token);
  }
  
  /// Genera un ID persistente basado en la plataforma
  /// Este método simula un ID persistente hasta que se implemente device_info_plus
  String _generatePersistentId(String platformPrefix) {
    // En una implementación real, este ID se guardaría en almacenamiento local
    // y se reutilizaría en cada inicio de la aplicación
    final random = Random();
    final hexChars = '0123456789abcdef';
    return '$platformPrefix-${List.generate(16, (_) => hexChars[random.nextInt(hexChars.length)]).join('')}';
  }
  
  /// Genera un ID aleatorio
  String _generateRandomId() {
    final random = Random();
    return List.generate(16, (_) => random.nextInt(16).toRadixString(16)).join('');
  }
  
  /// Registra el token del dispositivo en el backend
  /// Incluye mecanismo de reintento en caso de fallo con backoff exponencial
  Future<bool> registerDeviceToken({int retryCount = 0, int maxRetries = 3}) async {
    try {
      // Verificar si hay token de dispositivo disponible
      if (_deviceToken == null) {
        ///debugPrint("NOTIFICATION_SERVICE: ⚠️ No hay token de dispositivo disponible");
        
        // Intentar generar un token si no hay uno disponible
        if (retryCount < maxRetries) {
          ///debugPrint("NOTIFICATION_SERVICE: 🔄 Intentando generar un nuevo token... (intento ${retryCount + 1})");
          await initialize();
          if (_deviceToken != null) {
            return registerDeviceToken(retryCount: retryCount + 1, maxRetries: maxRetries);
          }
        }
        return false;
      }

      // Verificar si hay token de autenticación disponible (requerido para ambas plataformas)
      final authToken = AuthContext().token;
      if (authToken == null) {
        ///debugPrint("NOTIFICATION_SERVICE: ⚠️ No hay token de autenticación disponible");
        return false;
      }

      // Preparar payload para enviar al backend
      final payload = {
        'deviceToken': _deviceToken,
        'platform': getPlatform(),
      };

      // Mostrar información del token que se enviará
      final platform = getPlatform();
      ///debugPrint("\n==================================================");
      if (platform == 'ios') {
        ///debugPrint("NOTIFICATION_SERVICE: REGISTRANDO TOKEN APNs EN BACKEND (iOS)");
      } else {
        ///debugPrint("NOTIFICATION_SERVICE: REGISTRANDO TOKEN EN BACKEND (Android)");
      }
      
      // Mostrar solo una parte del token por seguridad
      final tokenPreview = _deviceToken!.length > 16 
          ? "${_deviceToken!.substring(0, 8)}...${_deviceToken!.substring(_deviceToken!.length - 8)}"
          : _deviceToken;
      ///debugPrint("NOTIFICATION_SERVICE: TOKEN: $tokenPreview");
      ///debugPrint("==================================================\n");

      // Enviar token al backend
      final response = await _api.post(
        _api.registerNotificationsEndpoint,
        body: payload,
        token: authToken, // Siempre enviamos con token de autenticación
      );

      // Mostrar la respuesta del backend
      ///debugPrint("\n==================================================\nNOTIFICATION_SERVICE: RESPUESTA DEL BACKEND AL REGISTRAR TOKEN");
      ///debugPrint("NOTIFICATION_SERVICE: Respuesta completa: $response");
      ///debugPrint("==================================================\n");
      
      ///debugPrint("NOTIFICATION_SERVICE: ✅ Token registrado exitosamente en el backend");
      return true;
    } catch (e) {
      ///debugPrint("NOTIFICATION_SERVICE: ❌ Error al enviar token de dispositivo al backend: $e");
      
      // Implementar reintento en caso de fallo con backoff exponencial
      if (retryCount < maxRetries) {
        final waitTime = Duration(seconds: pow(2, retryCount).toInt()); // Backoff exponencial
        ///debugPrint("NOTIFICATION_SERVICE: 🔄 Reintentando en ${waitTime.inSeconds} segundos... (intento ${retryCount + 1}/$maxRetries)");
        await Future.delayed(waitTime);
        return registerDeviceToken(retryCount: retryCount + 1, maxRetries: maxRetries);
      }
      
      return false;
    }
  }

  /// Determina la plataforma actual (iOS o Android)
  String getPlatform() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'unknown';
    }
  }
  
  /// Solicita permisos para notificaciones
  Future<void> _requestNotificationPermissions() async {
    
    // Solicitar permisos para Firebase Messaging
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    ///debugPrint('Permisos de notificación: ${settings.authorizationStatus}');
    
    // Configurar manejadores de mensajes
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ///debugPrint('Mensaje recibido mientras la app está en primer plano: ${message.notification?.title}');
      _showLocalNotification(message);
    });
    
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      ///debugPrint('Aplicación abierta desde notificación: ${message.notification?.title}');
    });
  }
  
  // Procesa notificaciones FCM (Android) cuando la app está abierta
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (message.notification != null) {
      final notification = message.notification!;
      ///debugPrint('\n==================================================');
      ///debugPrint('NOTIFICACIÓN FCM RECIBIDA: ${notification.title} - ${notification.body}');
      ///debugPrint('==================================================\n');
      
      // Agregar la notificación a la pantalla de notificaciones
      try {
        // Convertir la notificación push a formato de notificación para la pantalla
        final notificationData = {
          'title': notification.title ?? 'Notificación',
          'body': notification.body ?? '',
          'data': message.data, // Datos adicionales que pueden venir en la notificación
        };
        
        // Usar el método estático de NotificationScreen para agregar la notificación
        NotificationScreen.addNotification(notificationData);
        ///debugPrint('Notificación FCM agregada a la pantalla de notificaciones');
      } catch (e) {
        ///debugPrint('Error al agregar notificación FCM a la pantalla: $e');
      }
    }
  }
  
  // Procesa notificaciones APNs (iOS) cuando la app está abierta
  Future<void> _showIosNotification(Map<dynamic, dynamic> notification) async {
    try {
      ///debugPrint('\n==================================================');
      ///debugPrint('DEBUG_FLUTTER: PROCESANDO NOTIFICACIÓN APNs');
      ///debugPrint('DEBUG_FLUTTER: Notificación completa: $notification');
      
      // Imprimir todas las claves en la notificación para depuración
      ///debugPrint('DEBUG_FLUTTER: Claves en la notificación: ${notification.keys.toList()}');
      
      // Intentar extraer datos de la estructura estándar de APNs
      Map<dynamic, dynamic>? aps;
      Map<dynamic, dynamic>? alert;
      String title = 'Notificación';
      String body = '';
      
      // Verificar si existe la estructura estándar de APNs
      if (notification.containsKey('aps')) {
        ///debugPrint('DEBUG_FLUTTER: Encontrada estructura APNs estándar');
        aps = notification['aps'] as Map<dynamic, dynamic>?;
        ///debugPrint('DEBUG_FLUTTER: Contenido de aps: $aps');
        
        // Verificar si existe la estructura de alerta
        if (aps != null && aps.containsKey('alert')) {
          // La alerta puede ser un string o un mapa
          var alertValue = aps['alert'];
          ///debugPrint('DEBUG_FLUTTER: Tipo de alerta: ${alertValue.runtimeType}');
          
          if (alertValue is String) {
            // Si es string, usarlo como cuerpo
            body = alertValue;
          } else if (alertValue is Map) {
            // Si es mapa, extraer título y cuerpo
            alert = alertValue; // Eliminado el cast innecesario
            title = alert['title'] as String? ?? 'Notificación';
            body = alert['body'] as String? ?? '';
          }
        } else if (aps != null && aps.containsKey('body')) {
          // Algunos servidores envían body directamente en aps
          body = aps['body'] as String? ?? '';
        }
      } else {
        // Si no tiene estructura estándar, buscar campos comunes
        ///debugPrint('DEBUG_FLUTTER: No se encontró estructura APNs estándar, buscando campos alternativos');
        title = notification['title'] as String? ?? 
                notification['Title'] as String? ?? 
                notification['notification_title'] as String? ?? 
                'Notificación';
        
        body = notification['body'] as String? ?? 
               notification['Body'] as String? ?? 
               notification['message'] as String? ?? 
               notification['Message'] as String? ?? 
               notification['notification_body'] as String? ?? 
               '';
      }
      
      // Extraer datos adicionales que pueden venir en la notificación
      final data = Map<String, dynamic>.from(notification);
      // Eliminar 'aps' para quedarnos solo con los datos personalizados
      data.remove('aps');
      
      ///debugPrint('DEBUG_FLUTTER: Título extraído: $title');
      ///debugPrint('DEBUG_FLUTTER: Cuerpo extraído: $body');
      ///debugPrint('DEBUG_FLUTTER: Datos adicionales: $data');
      ///debugPrint('==================================================\n');
      
      // Convertir al formato común para la pantalla de notificaciones
      final notificationData = {
        'title': title,
        'body': body,
        'data': data,
      };
      
      // Agregar a la pantalla de notificaciones
      ///debugPrint('DEBUG_FLUTTER: Intentando agregar notificación a NotificationScreen');
      NotificationScreen.addNotification(notificationData);
      ///debugPrint('DEBUG_FLUTTER: Notificación APNs agregada exitosamente a la pantalla de notificaciones');
      
      // Mostrar un mensaje en la consola para confirmar que todo el proceso fue exitoso
      ///debugPrint('\n==================================================');
      ///debugPrint('DEBUG_FLUTTER: ✅ NOTIFICACIÓN APNs PROCESADA EXITOSAMENTE');
      ///debugPrint('DEBUG_FLUTTER: Título: $title');
      ///debugPrint('DEBUG_FLUTTER: Cuerpo: $body');
      ///debugPrint('==================================================\n');
      ///
    // ignore: unused_catch_stack
    } catch (e, stackTrace) {
      
      ///debugPrint('\n==================================================');
      ///debugPrint('DEBUG_FLUTTER: ❌ ERROR al procesar notificación APNs: $e');
      ///debugPrint('DEBUG_FLUTTER: Stack trace: $stackTrace');
      ///debugPrint('==================================================\n');
    }
  }
}
