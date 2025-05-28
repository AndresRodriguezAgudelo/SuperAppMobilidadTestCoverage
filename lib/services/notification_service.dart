import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import '../BLoC/auth/auth_context.dart';
import '../BLoC/home/home_bloc.dart';
// AlertsBloc ya no es necesario aquí
import '../BLoC/pick_and_plate/pick_and_plate_bloc.dart';
import '../screens/notification_screen.dart';
import '../screens/home_screen.dart';
import '../services/API.dart';

// Importaciones para las pantallas de vencimientos
import '../screens/RTM_screen.dart';
import '../screens/multas_screen.dart';
import '../screens/pico_placa_screen.dart';
import '../screens/SOAT_screen.dart';
import '../screens/revision_frenos_screen.dart';
import '../screens/extintor_screen.dart';
import '../screens/kit_carretera_screen.dart';
import '../screens/poliza_todo_riesgo_screen.dart';
import '../screens/cambio_llantas_screen.dart';
import '../screens/cambio_aceite_screen.dart';
import '../screens/generic_alert_screen.dart';

/// Manejador global para notificaciones en segundo plano
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Asegurarse de que Firebase esté inicializado
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  
  // Extraer datos para la navegación
  try {
    final data = message.data;
    
    // Intentar extraer expirationId y expirationType
    int? expirationId;
    String? expirationType;
    
    // Buscar expirationId en los datos
    if (data.containsKey('expirationId')) {
      final rawExpirationId = data['expirationId'];
      if (rawExpirationId is int) {
        expirationId = rawExpirationId;
      } else if (rawExpirationId is String) {
        expirationId = int.tryParse(rawExpirationId);
      }
    }
    
    // Buscar expirationType en los datos
    if (data.containsKey('onTap')) {
      expirationType = data['onTap'] as String?;
    } else if (data.containsKey('expirationType')) {
      expirationType = data['expirationType'] as String?;
    }
    
    // Si tenemos los datos necesarios, guardarlos para la navegación
    if (expirationId != null && expirationType != null) {
      // Guardar los datos para procesarlos cuando la app se abra
      NotificationService._pendingNavigationData = {
        'expirationId': expirationId,
        'expirationType': expirationType,
        'data': Map<String, dynamic>.from(data),
      };
    }
  } catch (e) {
    // No podemos hacer mucho en segundo plano, solo registrar el error
    // para depuración futura
  }
}

class NotificationService {
  // Canal para comunicación con el código nativo de iOS
  static const MethodChannel _iosNotificationChannel = MethodChannel('com.tuapp/ios_notifications');
  
  // Variable para almacenar datos de navegación pendientes
  static Map<String, dynamic>? _pendingNavigationData;

  // Método para verificar si hay navegación pendiente
  static bool hasPendingNavigation() {
    final hasPending = _pendingNavigationData != null;
    debugPrint('NOTIFICATION_SERVICE: Verificando navegación pendiente: ${hasPending ? "SÍ hay datos pendientes" : "NO hay datos pendientes"}');
    if (hasPending) {
      debugPrint('NOTIFICATION_SERVICE: Datos pendientes: $_pendingNavigationData');
    }
    return hasPending;
  }

  // Método  /// Procesa los datos de navegación pendientes (si existen)
  static Future<void> processPendingNavigation(BuildContext context) async {
    debugPrint('\n==================================================');
    debugPrint('NOTIFICATION_SERVICE: PROCESANDO DATOS DE NAVEGACIÓN PENDIENTES');
    
    if (_pendingNavigationData != null) {
      debugPrint('NOTIFICATION_SERVICE: ¡DATOS ENCONTRADOS!');
      
      final localExpirationId = _pendingNavigationData!['expirationId'];
      final localExpirationType = _pendingNavigationData!['expirationType'];
      final localData = _pendingNavigationData!['data'];
      
      debugPrint('NOTIFICATION_SERVICE: expirationId=$localExpirationId (${localExpirationId.runtimeType})');
      debugPrint('NOTIFICATION_SERVICE: expirationType=$localExpirationType (${localExpirationType.runtimeType})');
      debugPrint('NOTIFICATION_SERVICE: Datos adicionales disponibles: ${localData != null}');
      
      // Hacer una copia de los datos y limpiar los pendientes para evitar navegaciones duplicadas
      final dataCopy = Map<String, dynamic>.from(_pendingNavigationData!);
      _pendingNavigationData = null;
      
      // Verificar que tenemos un contexto válido
      if (!context.mounted) {
        debugPrint('NOTIFICATION_SERVICE: ERROR - Contexto no válido para navegación');
        // Restaurar los datos para un posible reintento
        _pendingNavigationData = dataCopy;
        return;
      }
      
      debugPrint('NOTIFICATION_SERVICE: NAVEGANDO DIRECTAMENTE');
      
      // NAVEGACIÓN SIMPLIFICADA Y DIRECTA
      try {
        Widget targetScreen;
        
        // Determinar la pantalla según el tipo de alerta
        switch (localExpirationType) {
          case 'SOAT':
            debugPrint('NOTIFICATION_SERVICE: Navegando a SOATScreen');
            targetScreen = SOATScreen(alertId: localExpirationId);
            break;
          case 'RTM':
            debugPrint('NOTIFICATION_SERVICE: Navegando a RTMScreen');
            targetScreen = RTMScreen(alertId: localExpirationId);
            break;
          case 'Revisión de frenos':
            debugPrint('NOTIFICATION_SERVICE: Navegando a RevisionFrenosScreen');
            targetScreen = RevisionFrenosScreen(alertId: localExpirationId);
            break;
          case 'Extintor':
            debugPrint('NOTIFICATION_SERVICE: Navegando a ExtintorScreen');
            targetScreen = ExtintorScreen(alertId: localExpirationId);
            break;
          case 'Kit de carretera':
            debugPrint('NOTIFICATION_SERVICE: Navegando a KitCarreteraScreen');
            targetScreen = KitCarreteraScreen(alertId: localExpirationId);
            break;
          case 'Póliza todo riesgo':
            debugPrint('NOTIFICATION_SERVICE: Navegando a PolizaTodoRiesgoScreen');
            targetScreen = PolizaTodoRiesgoScreen(alertId: localExpirationId);
            break;
          case 'Cambio de llantas':
            debugPrint('NOTIFICATION_SERVICE: Navegando a CambioLlantasScreen');
            targetScreen = CambioLlantasScreen(alertId: localExpirationId);
            break;
          case 'Cambio de aceite':
            debugPrint('NOTIFICATION_SERVICE: Navegando a CambioAceiteScreen');
            targetScreen = CambioAceiteScreen(alertId: localExpirationId);
            break;
          default:
            debugPrint('NOTIFICATION_SERVICE: Tipo no reconocido: "$localExpirationType"');
            debugPrint('NOTIFICATION_SERVICE: Usando GenericAlertScreen como fallback');
            targetScreen = GenericAlertScreen(alertId: localExpirationId);
        }
        
        // Navegar directamente a la pantalla de destino
        debugPrint('NOTIFICATION_SERVICE: Navegando directamente a ${targetScreen.runtimeType}');
        
        // Usar pushReplacement para mantener la posibilidad de volver atrás
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => targetScreen,
            // Establecer maintainState en true para mantener el estado de la pantalla anterior
            maintainState: true,
          ),
        );
        
        debugPrint('NOTIFICATION_SERVICE: Navegación completada exitosamente');
      } catch (e, stackTrace) {
        debugPrint('NOTIFICATION_SERVICE: ERROR durante la navegación: $e');
        debugPrint('NOTIFICATION_SERVICE: Stack trace: $stackTrace');
        
        // Intentar un enfoque alternativo si la navegación falló
        try {
          if (context.mounted) {
            debugPrint('NOTIFICATION_SERVICE: Intentando navegación alternativa a GenericAlertScreen');
            
            // Navegar directamente a la pantalla de destino
            debugPrint('NOTIFICATION_SERVICE: Navegando directamente a GenericAlertScreen como fallback');
            
            // Usar pushReplacement para mantener la posibilidad de volver atrás
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => GenericAlertScreen(alertId: localExpirationId),
                // Establecer maintainState en true para mantener el estado de la pantalla anterior
                maintainState: true,
              ),
            );
          }
        } catch (e2) {
          debugPrint('NOTIFICATION_SERVICE: Navegación alternativa también falló: $e2');
          // Restaurar los datos para un posible reintento
          _pendingNavigationData = dataCopy;
        }
      }
    } else {
      debugPrint('NOTIFICATION_SERVICE: No hay datos de navegación pendientes');
    }
    
    debugPrint('==================================================\n');
  }
  
  /// Función centralizada para navegar a la pantalla específica según el tipo de vencimiento
  static Future<void> navigateToExpirationScreen(
    BuildContext context, 
    int? expirationId, 
    String? expirationType,
    {Map<String, dynamic>? additionalData}
  ) async {
    debugPrint('\n==================================================');
    debugPrint('NOTIFICATION_SERVICE: Iniciando navegación a pantalla específica');
    debugPrint('NOTIFICATION_SERVICE: expirationId=$expirationId, expirationType=$expirationType');
    debugPrint('NOTIFICATION_SERVICE: additionalData=$additionalData');
    
    // Si no hay expirationType o expirationId, no podemos navegar
    if (expirationType == null || expirationId == null) {
      debugPrint('NOTIFICATION_SERVICE: ERROR - No se puede navegar, falta expirationType o expirationId');
      return;
    }
    
    try {
      // Caso especial para "cualquier cosa" - navegar directamente a GenericAlertScreen
      if (expirationType == "cualquier cosa") {
        debugPrint('\n==================================================');
        debugPrint('NOTIFICATION_SERVICE: DETECTADO TIPO ESPECIAL "cualquier cosa"');
        debugPrint('NOTIFICATION_SERVICE: Navegando directamente a GenericAlertScreen');
        debugPrint('NOTIFICATION_SERVICE: AlertId: $expirationId');
        
        // Verificar que el contexto sigue siendo válido
        if (!context.mounted) {
          debugPrint('NOTIFICATION_SERVICE: ERROR - Contexto no válido');
          return;
        }
        
        // Verificar si hay rutas en el historial antes de navegar
        if (Navigator.canPop(context)) {
          debugPrint('NOTIFICATION_SERVICE: Hay rutas en el historial, usando push normal');
          // Si hay rutas en el historial, usar push normal
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GenericAlertScreen(alertId: expirationId),
            ),
          );
        } else {
          debugPrint('NOTIFICATION_SERVICE: No hay rutas en el historial, usando enfoque de dos pasos');
          // Si no hay rutas en el historial, primero navegar al HomeScreen y luego a la pantalla deseada
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
              settings: const RouteSettings(name: '/home'),
            ),
            (route) => false, // Eliminar todas las rutas anteriores
          );
          
          // Esperar un breve momento para asegurar que la navegación anterior se complete
          await Future.delayed(const Duration(milliseconds: 100));
          
          if (context.mounted) {
            debugPrint('NOTIFICATION_SERVICE: Navegando al segundo paso');
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GenericAlertScreen(alertId: expirationId),
              ),
            );
          }
        }
        
        debugPrint('NOTIFICATION_SERVICE: Navegación directa completada');
        debugPrint('==================================================\n');
        return; // Salir de la función después de la navegación directa
      }
      
      // Normalizar el tipo para hacer la comparación más robusta
      String normalizedType = expirationType.trim().toLowerCase();
      debugPrint('NOTIFICATION_SERVICE: Tipo normalizado: "$normalizedType"');
      
      // Intentar obtener el vehicleId de los datos adicionales de la notificación
      int? vehicleId;
      if (additionalData != null && additionalData.containsKey('vehicleId')) {
        try {
          vehicleId = int.parse(additionalData['vehicleId'].toString());
          debugPrint('NOTIFICATION_SERVICE: Obtenido vehicleId: $vehicleId');
        } catch (e) {
          debugPrint('NOTIFICATION_SERVICE: Error al parsear vehicleId: $e');
        }
      }
      
      // Definir un mapa de tipos a pantallas para que coincida EXACTAMENTE con los tipos de la API
      // Estos son los tipos exactos que pueden llegar desde el backend
      final Map<String, Function(int)> screenMap = {
        'SOAT': (id) => SOATScreen(alertId: id, vehicleId: vehicleId),
        'RTM': (id) => RTMScreen(alertId: id, vehicleId: vehicleId),
        'Revisión de frenos': (id) => RevisionFrenosScreen(alertId: id),
        'Extintor': (id) => ExtintorScreen(alertId: id),
        'Kit de carretera': (id) => KitCarreteraScreen(alertId: id),
        'Póliza todo riesgo': (id) => PolizaTodoRiesgoScreen(alertId: id),
        'Cambio de llantas': (id) => CambioLlantasScreen(alertId: id),
        'Cambio de aceite': (id) => CambioAceiteScreen(alertId: id),
      };
      
      // Widget por defecto (pantalla genérica)
      Widget? screenWidget;
      
      // Casos especiales que requieren lógica adicional
      if (normalizedType.contains('licencia')) {
        debugPrint('NOTIFICATION_SERVICE: Caso especial - Licencia de conducción (no navegar)');
        return; // No navegar en caso de licencia
      }
      else if (normalizedType.contains('multa')) {
        debugPrint('NOTIFICATION_SERVICE: Caso especial - Multas (requiere placa)');
        final homeBloc = Provider.of<HomeBloc>(context, listen: false);
        final plate = homeBloc.selectedPlate;
        screenWidget = MultasScreen(plate: plate);
      }
      else if (normalizedType.contains('pico') || normalizedType.contains('placa')) {
        debugPrint('NOTIFICATION_SERVICE: Caso especial - Pico y placa (requiere cityId)');
        
        final authContext = AuthContext();
        final userId = authContext.userId;
        int? userCityId;
        
        if (userId != null) {
          try {
            final apiService = APIService();
            final endpoint = apiService.getUserProfileEndpoint(userId);
            final token = authContext.token;
            final response = await apiService.get(endpoint, token: token);
            
            if (response.containsKey('cityId')) {
              userCityId = response['cityId'];
            } else if (response.containsKey('data') && response['data'] is Map) {
              final data = response['data'] as Map<String, dynamic>;
              if (data.containsKey('cityId')) {
                userCityId = data['cityId'];
              }
            }
          } catch (e) {
            debugPrint('NOTIFICATION_SERVICE: Error al obtener cityId: $e');
          }
        }
        
        final homeBloc = Provider.of<HomeBloc>(context, listen: false);
        final plate = homeBloc.selectedPlate;
        
        final bloc = PeakPlateBloc();
        // Asegurarnos de que userCityId no sea nulo
        if (userCityId != null) {
          bloc.setCityId(userCityId);
        } else {
          // Usar un valor predeterminado si es nulo
          debugPrint('NOTIFICATION_SERVICE: userCityId es nulo, usando valor predeterminado');
          bloc.setCityId(1); // Valor predeterminado (ajustar según sea necesario)
        }
        if (plate.isNotEmpty) bloc.setPlate(plate);
        await bloc.loadAlertData(expirationId);
        await bloc.loadPeakPlateData();
        
        screenWidget = ChangeNotifierProvider.value(
          value: bloc,
          child: PicoPlacaScreen(
            alertId: expirationId,
            plate: plate,
            cityId: userCityId,
          ),
        );
      }
      else {
        // Primero intentar una coincidencia exacta con el tipo original (sin normalizar)
        if (screenMap.containsKey(expirationType)) {
          debugPrint('NOTIFICATION_SERVICE: Coincidencia exacta encontrada para "$expirationType"');
          screenWidget = screenMap[expirationType]!(expirationId);
        }
        // Si no hay coincidencia exacta, intentar con el tipo normalizado
        else {
          // Normalizar las claves del mapa para comparación
          final normalizedMap = Map.fromEntries(
            screenMap.entries.map((entry) => 
              MapEntry(entry.key.toLowerCase(), entry.value)
            )
          );
          
          // Buscar coincidencia exacta con el tipo normalizado
          if (normalizedMap.containsKey(normalizedType)) {
            debugPrint('NOTIFICATION_SERVICE: Coincidencia normalizada encontrada para "$normalizedType"');
            screenWidget = normalizedMap[normalizedType]!(expirationId);
          }
        }
        
        // Si no se ha asignado un screenWidget, usar la pantalla genérica
        if (screenWidget == null) {
          debugPrint('\n==================================================');
          debugPrint('NOTIFICATION_SERVICE: TIPO NO RECONOCIDO: "$expirationType"');
          debugPrint('NOTIFICATION_SERVICE: Usando GenericAlertScreen como fallback');
          debugPrint('NOTIFICATION_SERVICE: AlertId: $expirationId');
          debugPrint('==================================================\n');
          
          screenWidget = GenericAlertScreen(alertId: expirationId);
        }
      }
      
      // El análisis estático confirma que screenWidget nunca es nulo en este punto
      debugPrint('NOTIFICATION_SERVICE: Pantalla determinada: ${screenWidget.runtimeType}');
      
      // Verificar que el contexto sigue siendo válido
      if (!context.mounted) {
        debugPrint('NOTIFICATION_SERVICE: ERROR - Contexto no válido');
        return;
      }
      
      // Navegar a la pantalla correspondiente
      debugPrint('NOTIFICATION_SERVICE: Navegando a ${screenWidget.runtimeType}');
      
      // Verificar si hay rutas en el historial antes de navegar
      if (Navigator.canPop(context)) {
        debugPrint('NOTIFICATION_SERVICE: Hay rutas en el historial, usando push normal');
        // Si hay rutas en el historial, usar push normal
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => screenWidget!,
          ),
        );
      } else {
        debugPrint('NOTIFICATION_SERVICE: No hay rutas en el historial, usando enfoque de dos pasos');
        // Si no hay rutas en el historial, primero navegar al HomeScreen y luego a la pantalla deseada
        // Esto garantiza que siempre haya una ruta en el historial para el botón de atrás
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
            settings: const RouteSettings(name: '/home'),
          ),
          (route) => false, // Eliminar todas las rutas anteriores
        ).then((_) {
          // Esperar un breve momento para asegurar que la navegación anterior se complete
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              debugPrint('NOTIFICATION_SERVICE: Navegando al segundo paso');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => screenWidget!,
                ),
              );
            }
          });
        });
      }
      
      debugPrint('NOTIFICATION_SERVICE: Navegación iniciada exitosamente');
      debugPrint('==================================================\n');
    } catch (e, stackTrace) {
      debugPrint('\n==================================================');
      debugPrint('NOTIFICATION_SERVICE: ERROR GRAVE durante la navegación:');
      debugPrint('$e');
      debugPrint('Stack trace: $stackTrace');
      
      // Intentar navegar a la pantalla genérica como último recurso
      try {
        if (context.mounted) {
          debugPrint('NOTIFICATION_SERVICE: Intentando navegar a GenericAlertScreen como fallback');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GenericAlertScreen(alertId: expirationId),
            ),
          );
        }
      } catch (e2) {
        debugPrint('NOTIFICATION_SERVICE: Fallback también falló: $e2');
      }
      
      debugPrint('==================================================\n');
    }
  }

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
          debugPrint('\n==================================================');
          debugPrint('NOTIFICATION_SERVICE: TAP EN NOTIFICACIÓN APNs DETECTADO');
          debugPrint('NOTIFICATION_SERVICE: Contenido completo: ${call.arguments}');
          debugPrint('==================================================\n');
          
          // Extraer expirationId y expirationType
          int? expirationId;
          String? expirationType;
          
          if (call.arguments is Map) {
            final notification = call.arguments as Map<dynamic, dynamic>;
            
            debugPrint('NOTIFICATION_SERVICE: Analizando datos de notificación para navegación...');
            
            // Buscar expirationId en diferentes ubicaciones posibles
            if (notification.containsKey('expirationId')) {
              var rawExpirationId = notification['expirationId'];
              debugPrint('NOTIFICATION_SERVICE: Valor crudo de expirationId: $rawExpirationId (${rawExpirationId.runtimeType})');
              
              if (rawExpirationId is int) {
                expirationId = rawExpirationId;
              } else if (rawExpirationId is String) {
                expirationId = int.tryParse(rawExpirationId);
              } else if (rawExpirationId != null) {
                expirationId = int.tryParse(rawExpirationId.toString());
              }
              
              debugPrint('NOTIFICATION_SERVICE: Encontrado expirationId: $expirationId (${expirationId?.runtimeType})');
            } else if (notification.containsKey('aps') && notification['aps'] is Map) {
              final aps = notification['aps'] as Map<dynamic, dynamic>;
              if (aps.containsKey('expirationId')) {
                var rawExpirationId = aps['expirationId'];
                debugPrint('NOTIFICATION_SERVICE: Valor crudo de expirationId en aps: $rawExpirationId (${rawExpirationId.runtimeType})');
                
                if (rawExpirationId is int) {
                  expirationId = rawExpirationId;
                } else if (rawExpirationId is String) {
                  expirationId = int.tryParse(rawExpirationId);
                } else if (rawExpirationId != null) {
                  expirationId = int.tryParse(rawExpirationId.toString());
                }
                
                debugPrint('NOTIFICATION_SERVICE: Encontrado expirationId en aps: $expirationId (${expirationId?.runtimeType})');
              }
            }
            
            // Buscar expirationType (onTap) en diferentes ubicaciones posibles
            if (notification.containsKey('onTap')) {
              expirationType = notification['onTap']?.toString();
              debugPrint('NOTIFICATION_SERVICE: Encontrado expirationType (onTap): "$expirationType" (${expirationType.runtimeType})');
            } else if (notification.containsKey('aps') && notification['aps'] is Map) {
              final aps = notification['aps'] as Map<dynamic, dynamic>;
              if (aps.containsKey('onTap')) {
                expirationType = aps['onTap']?.toString();
                debugPrint('NOTIFICATION_SERVICE: Encontrado expirationType (onTap) en aps: "$expirationType"');
              }
            }
            
            // Almacenar los datos para usarlos cuando la app esté completamente inicializada
            _pendingNavigationData = {
              'expirationId': expirationId,
              'expirationType': expirationType,
              'data': Map<String, dynamic>.from(notification),
            };
            
            debugPrint('NOTIFICATION_SERVICE: Datos de navegación pendientes guardados:');
            debugPrint('NOTIFICATION_SERVICE: expirationId=$expirationId, expirationType=$expirationType');
            debugPrint('NOTIFICATION_SERVICE: _pendingNavigationData=$_pendingNavigationData');
            
            debugPrint('NOTIFICATION_SERVICE: Datos de navegación pendientes guardados: expirationId=$expirationId, expirationType=$expirationType');
          }
          
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
        debugPrint('NOTIFICATION_SERVICE: Mensaje recibido mientras la app está en primer plano');
        debugPrint('NOTIFICATION_SERVICE: Título: ${message.notification?.title}');
        debugPrint('NOTIFICATION_SERVICE: Cuerpo: ${message.notification?.body}');
        _showLocalNotification(message);
      });
      
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('\n==================================================');
        debugPrint('NOTIFICATION_SERVICE: Aplicación abierta desde notificación: ${message.notification?.title}');
        debugPrint('NOTIFICATION_SERVICE: Datos: ${message.data}');
        debugPrint('==================================================\n');
        
        // Extraer expirationId y expirationType
        int? expirationId;
        String? expirationType;
        
        debugPrint('NOTIFICATION_SERVICE: Datos de la notificación: ${message.data}');
        
        if (message.data.containsKey('expirationId')) {
          var rawExpirationId = message.data['expirationId'];
          debugPrint('NOTIFICATION_SERVICE: Valor crudo de expirationId: $rawExpirationId (${rawExpirationId.runtimeType})');
          
          if (rawExpirationId is int) {
            expirationId = rawExpirationId;
          } else if (rawExpirationId is String) {
            expirationId = int.tryParse(rawExpirationId);
          } else if (rawExpirationId != null) {
            expirationId = int.tryParse(rawExpirationId.toString());
          }
          
          debugPrint('NOTIFICATION_SERVICE: Encontrado expirationId: $expirationId (${expirationId?.runtimeType})');
        }
        
        if (message.data.containsKey('onTap')) {
          expirationType = message.data['onTap']?.toString();
          debugPrint('NOTIFICATION_SERVICE: Encontrado expirationType (onTap): "$expirationType" (${expirationType?.runtimeType})');
        }
        
        // Almacenar los datos para usarlos cuando la app esté completamente inicializada
        _pendingNavigationData = {
          'expirationId': expirationId,
          'expirationType': expirationType,
          'data': message.data,
        };
        
        debugPrint('NOTIFICATION_SERVICE: Datos de navegación pendientes guardados: expirationId=$expirationId, expirationType=$expirationType');
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

          
      debugPrint("NOTIFICATION_SERVICE: TOKEN: $tokenPreview");
      debugPrint("==================================================\n");

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
    // Imprimir la estructura completa de la notificación push recibida
    debugPrint('\n==================================================');
    debugPrint('NOTIFICATION_SERVICE: PUSH FCM RECIBIDA (ANDROID)');
    debugPrint('NOTIFICATION_SERVICE: Estructura completa del mensaje:');
    debugPrint('NOTIFICATION_SERVICE: Notification: ${message.notification?.toMap()}');
    debugPrint('NOTIFICATION_SERVICE: Data: ${message.data}');
    debugPrint('NOTIFICATION_SERVICE: MessageId: ${message.messageId}');
    debugPrint('NOTIFICATION_SERVICE: SenderId: ${message.senderId}');
    debugPrint('NOTIFICATION_SERVICE: Category: ${message.category}');
    debugPrint('NOTIFICATION_SERVICE: CollapseKey: ${message.collapseKey}');
    debugPrint('NOTIFICATION_SERVICE: ContentAvailable: ${message.contentAvailable}');
    debugPrint('==================================================\n');
    
    if (message.notification != null) {
      final notification = message.notification!;
      try {
        // Extraer expirationId y expirationType (onTap) de los datos
        int? expirationId;
        String? expirationType;
        
        // Verificar si expirationId está en los datos
        if (message.data.containsKey('expirationId')) {
          expirationId = message.data['expirationId'] is int 
              ? message.data['expirationId'] 
              : int.tryParse(message.data['expirationId'].toString());
          debugPrint('NOTIFICATION_SERVICE: Encontrado expirationId: $expirationId');
        }
        
        // Verificar si onTap (expirationType) está en los datos
        if (message.data.containsKey('onTap')) {
          expirationType = message.data['onTap']?.toString();
          debugPrint('NOTIFICATION_SERVICE: Encontrado expirationType (onTap): $expirationType');
        }
        
        // Convertir la notificación push a formato de notificación para la pantalla
        // Determinar colores según el campo 'color' o el tipo de expiración
        Color? backgroundColor;
        Color? iconBackgroundColor;
        Color? textColor;
        bool isPositive = true;
        
        // Primero intentar usar el campo 'color' de la notificación
        String? colorValue;
        if (message.data.containsKey('color')) {
          colorValue = message.data['color']?.toString();
          debugPrint('NOTIFICATION_SERVICE: Encontrado campo color: $colorValue');
        }
        
        // Aplicar colores según el valor del campo 'color'
        if (colorValue != null) {
          switch (colorValue.toLowerCase()) {
            case 'red':
              // Colores para alertas críticas (rojo)
              backgroundColor = const Color(0xFFFADDD7);
              iconBackgroundColor = const Color(0xFFE05C3A);
              textColor = const Color(0xFFE05C3A);
              isPositive = false;
              break;
            case 'yellow':
              // Colores para advertencias (amarillo/naranja)
              backgroundColor = const Color(0xFFFFF3E0);
              iconBackgroundColor = const Color(0xFFFF9800);
              textColor = const Color(0xFFFF9800);
              isPositive = true;
              break;
            case 'green':
              // Colores para notificaciones positivas (verde)
              backgroundColor = const Color(0xFFECFAD7);
              iconBackgroundColor = const Color(0xFF319E7C);
              textColor = const Color(0xFF319E7C);
              isPositive = true;
              break;
            default:
              // Si el valor de color no es reconocido, usar la lógica basada en expirationType
              colorValue = null; // Resetear para que entre en la lógica de fallback
          }
        }
        
        // Si no hay un color válido, usar la lógica basada en expirationType como fallback
        if (colorValue == null && expirationType != null) {
          switch (expirationType) {
            case 'SOAT':
            case 'RTM':
            case 'Póliza todo riesgo':
              // Colores para alertas importantes (rojo)
              backgroundColor = const Color(0xFFFADDD7);
              iconBackgroundColor = const Color(0xFFE05C3A);
              textColor = const Color(0xFFE05C3A);
              isPositive = false;
              break;
            case 'Extintor':
            case 'Kit de carretera':
              // Colores para alertas de seguridad (naranja)
              backgroundColor = const Color(0xFFFFF3E0);
              iconBackgroundColor = const Color(0xFFFF9800);
              textColor = const Color(0xFFFF9800);
              isPositive = true;
              break;
            case 'Cambio de aceite':
            case 'Cambio de llantas':
            case 'Revisión de frenos':
              // Colores para mantenimiento (amarillo/naranja)
              backgroundColor = const Color(0xFFFFF3E0);
              iconBackgroundColor = const Color(0xFFFF9800);
              textColor = const Color(0xFFFF9800);
              isPositive = true;
              break;
            default:
              // Colores por defecto (verde)
              backgroundColor = const Color(0xFFECFAD7);
              iconBackgroundColor = const Color(0xFF319E7C);
              textColor = const Color(0xFF319E7C);
              isPositive = true;
              break;
          }
        }
        
        final notificationData = {
          'title': notification.title ?? 'Notificación',
          'body': notification.body ?? '',
          'data': message.data, // Datos adicionales que pueden venir en la notificación
          'expirationId': expirationId,       // Añadir expirationId
          'expirationType': expirationType,   // Añadir expirationType
          'isPositive': isPositive,           // Indicar si es positiva o negativa
          'backgroundColor': backgroundColor,  // Color de fondo personalizado
          'iconBackgroundColor': iconBackgroundColor, // Color de fondo del icono
          'textColor': textColor,            // Color del texto
        };
        
        // Usar el método estático de NotificationScreen para agregar la notificación
        debugPrint('NOTIFICATION_SERVICE: Agregando notificación FCM a NotificationScreen con expirationId: $expirationId, expirationType: $expirationType');
        NotificationScreen.addNotification(notificationData);
        debugPrint('Notificación FCM agregada a la pantalla de notificaciones');
      } catch (e) {
        debugPrint('Error al agregar notificación FCM a la pantalla: $e');
      }
    }
  }
  
  // Procesa notificaciones APNs (iOS) cuando la app está abierta
  Future<void> _showIosNotification(Map<dynamic, dynamic> notification) async {
    // Imprimir la estructura completa de la notificación push recibida
    debugPrint('\n==================================================');
    debugPrint('NOTIFICATION_SERVICE: PUSH APNs RECIBIDA (iOS)');
    debugPrint('NOTIFICATION_SERVICE: Estructura completa de la notificación:');
    debugPrint('NOTIFICATION_SERVICE:Notification: $notification');
    debugPrint('==================================================\n');
    
    try {
      Map<dynamic, dynamic>? aps;
      Map<dynamic, dynamic>? alert;
      String title = 'Notificación';
      String body = '';
      
      // Extraer expirationId y expirationType (onTap)
      int? expirationId;
      String? expirationType;
      
      // Obtener expirationId si existe
      if (notification.containsKey('expirationId')) {
        var rawExpirationId = notification['expirationId'];
        debugPrint('NOTIFICATION_SERVICE: Valor crudo de expirationId: $rawExpirationId (${rawExpirationId.runtimeType})');
        
        if (rawExpirationId is int) {
          expirationId = rawExpirationId;
        } else if (rawExpirationId is String) {
          expirationId = int.tryParse(rawExpirationId);
        } else if (rawExpirationId != null) {
          expirationId = int.tryParse(rawExpirationId.toString());
        }
        
        debugPrint('NOTIFICATION_SERVICE: Encontrado expirationId: $expirationId (${expirationId?.runtimeType})');
      }
      
      // Obtener expirationType del campo onTap
      if (notification.containsKey('onTap')) {
        expirationType = notification['onTap']?.toString();
        debugPrint('NOTIFICATION_SERVICE: Encontrado expirationType (onTap): "$expirationType" (${expirationType?.runtimeType})');
      }
      if (notification.containsKey('aps')) {
        aps = notification['aps'] as Map<dynamic, dynamic>?;
        if (aps != null && aps.containsKey('alert')) {
          // La alerta puede ser un string o un mapa
          var alertValue = aps['alert'];
          if (alertValue is String) {
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
      
      // Incluir expirationId y expirationType en los datos
      if (expirationId != null) {
        data['expirationId'] = expirationId;
      }
      if (expirationType != null) {
        data['expirationType'] = expirationType;
      }
      
      // Determinar colores según el campo 'color' o el tipo de expiración
      Color? backgroundColor;
      Color? iconBackgroundColor;
      Color? textColor;
      bool isPositive = true;
      
      // Primero intentar usar el campo 'color' de la notificación
      String? colorValue;
      if (notification.containsKey('color')) {
        colorValue = notification['color']?.toString();
        debugPrint('NOTIFICATION_SERVICE: Encontrado campo color: $colorValue');
      }
      
      // Aplicar colores según el valor del campo 'color'
      if (colorValue != null) {
        switch (colorValue.toLowerCase()) {
          case 'red':
            // Colores para alertas críticas (rojo)
            backgroundColor = const Color(0xFFFADDD7);
            iconBackgroundColor = const Color(0xFFE05C3A);
            textColor = const Color(0xFFE05C3A);
            isPositive = false;
            break;
          case 'yellow':
            // Colores para advertencias (amarillo/naranja)
            backgroundColor = const Color(0xFFFFF3E0);
            iconBackgroundColor = const Color(0xFFFF9800);
            textColor = const Color(0xFFFF9800);
            isPositive = true;
            break;
          case 'green':
            // Colores para notificaciones positivas (verde)
            backgroundColor = const Color(0xFFECFAD7);
            iconBackgroundColor = const Color(0xFF319E7C);
            textColor = const Color(0xFF319E7C);
            isPositive = true;
            break;
          default:
            // Si el valor de color no es reconocido, usar la lógica basada en expirationType
            colorValue = null; // Resetear para que entre en la lógica de fallback
        }
      }
      
      // Si no hay un color válido, usar la lógica basada en expirationType como fallback
      if (colorValue == null && expirationType != null) {
        switch (expirationType) {
          case 'SOAT':
          case 'RTM':
          case 'Póliza todo riesgo':
            // Colores para alertas importantes (rojo)
            backgroundColor = const Color(0xFFFADDD7);
            iconBackgroundColor = const Color(0xFFE05C3A);
            textColor = const Color(0xFFE05C3A);
            isPositive = false;
            break;
          case 'Extintor':
          case 'Kit de carretera':
            // Colores para alertas de seguridad (naranja)
            backgroundColor = const Color(0xFFFFF3E0);
            iconBackgroundColor = const Color(0xFFFF9800);
            textColor = const Color(0xFFFF9800);
            isPositive = true;
            break;
          case 'Cambio de aceite':
          case 'Cambio de llantas':
          case 'Revisión de frenos':
            // Colores para mantenimiento (amarillo/naranja)
            backgroundColor = const Color(0xFFFFF3E0);
            iconBackgroundColor = const Color(0xFFFF9800);
            textColor = const Color(0xFFFF9800);
            isPositive = true;
            break;
          default:
            // Colores por defecto (verde)
            backgroundColor = const Color(0xFFECFAD7);
            iconBackgroundColor = const Color(0xFF319E7C);
            textColor = const Color(0xFF319E7C);
            isPositive = true;
            break;
        }
      }
      
      final notificationData = {
        'title': title,
        'body': body,
        'data': data,
        'expirationId': expirationId,       // Añadir expirationId
        'expirationType': expirationType,   // Añadir expirationType
        'isPositive': isPositive,           // Indicar si es positiva o negativa
        'backgroundColor': backgroundColor,  // Color de fondo personalizado
        'iconBackgroundColor': iconBackgroundColor, // Color de fondo del icono
        'textColor': textColor,            // Color del texto
      };
      
      // Agregar a la pantalla de notificaciones
      debugPrint('NOTIFICATION_SERVICE: Agregando notificación a NotificationScreen con expirationId: $expirationId, expirationType: $expirationType');
      NotificationScreen.addNotification(notificationData);
    } catch (e) {
      // Error silencioso - los logs están comentados para evitar ruido en la consola
      // pero se pueden descomentar para depuración si es necesario
      ///debugPrint('\n==================================================');
      ///debugPrint('DEBUG_FLUTTER: ❌ ERROR al procesar notificación APNs: $e');
      ///debugPrint('==================================================\n');
    }
  }
}
