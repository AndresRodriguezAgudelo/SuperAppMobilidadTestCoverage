import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Equirent_Mobility/screens/generic_alert_screen.dart';
import '../widgets/top_bar.dart';
import '../widgets/notification_card.dart';

// Importaciones para las pantallas de vencimientos
import '../screens/RTM_screen.dart';
import '../screens/multas_screen.dart';
import '../screens/SOAT_screen.dart';
import '../screens/revision_frenos_screen.dart';
import '../screens/extintor_screen.dart';
import '../screens/kit_carretera_screen.dart';
import '../screens/poliza_todo_riesgo_screen.dart';
import '../screens/cambio_llantas_screen.dart';
import '../screens/cambio_aceite_screen.dart';

// Importaciones para los BLoCs
import '../BLoC/home/home_bloc.dart';

// Tipo para los listeners de notificaciones
typedef NotificationCountCallback = void Function(int count);

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  // Lista estática para almacenar notificaciones
  static final List<Map<String, dynamic>> _notifications = [];
  
  // Lista de callbacks para notificar cambios en el contador
  static final List<NotificationCountCallback> _listeners = [];
  
  // Método para registrar un listener
  static void addListener(NotificationCountCallback callback) {
    _listeners.add(callback);
    // Notificar inmediatamente el estado actual
    callback(getUnreadCount());
  }
  
  // Método para eliminar un listener
  static void removeListener(NotificationCountCallback callback) {
    _listeners.remove(callback);
  }
  
  // Método para notificar a todos los listeners
  static void _notifyListeners() {
    final count = getUnreadCount();
    for (final listener in _listeners) {
      listener(count);
    }
  }
  
  // Método para obtener el número de notificaciones no leídas
  static int getUnreadCount() {
    return _notifications.where((n) => n['status'] == 'nuevo').length;
  }
  
  // Método para marcar todas las notificaciones como leídas
  static void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = {..._notifications[i], 'status': 'leido'};
    }
    _saveNotifications(); // Guardar el estado actualizado
    _notifyListeners(); // Notificar a los listeners
  }
  
  // Método para marcar una notificación específica como leída
  static void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index] = {..._notifications[index], 'status': 'leido'};
      _saveNotifications(); // Guardar el estado actualizado
      _notifyListeners(); // Notificar a los listeners
    }
  }
  
  // Método para limpiar todas las notificaciones (usado en logout)
  static Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications(); // Guardar el estado actualizado
    _notifyListeners(); // Notificar a los listeners
  }
  
  // Método estático para agregar notificaciones desde cualquier parte de la app
  static void addNotification(Map<String, dynamic> notification) {
    // Extraer expirationId, expirationType y colores si están presentes
    final int? expirationId = notification['expirationId'];
    final String? expirationType = notification['expirationType'];
    final Color? backgroundColor = notification['backgroundColor'];
    final Color? iconBackgroundColor = notification['iconBackgroundColor'];
    final Color? textColor = notification['textColor'];
    final bool isPositive = notification['isPositive'] ?? true; // Usar el valor que viene de la notificación
    
    debugPrint('NOTIFICATION_SCREEN: Recibiendo notificación con expirationId: $expirationId, expirationType: $expirationType');
    
    // Convertir la notificación al formato esperado
    final formattedNotification = {
      'isPositive': isPositive, // Usar el valor que viene de la notificación
      'icon': Icons.notifications,
      'text': notification['body'] ?? '',
      'date': DateTime.now(),
      'title': notification['title'] ?? 'Notificación',
      'status': 'nuevo', // Siempre nueva al crearla
      'id': DateTime.now().millisecondsSinceEpoch.toString(), // ID único
      // Agregar campos para navegación a pantallas de vencimientos
      'expirationId': expirationId,
      'expirationType': expirationType,
      // Colores personalizados
      'backgroundColor': backgroundColor,
      'iconBackgroundColor': iconBackgroundColor,
      'textColor': textColor,
      // Guardar datos adicionales que puedan ser útiles
      'data': notification['data'],
    };
    
    // Agregar al inicio de la lista
    _notifications.insert(0, formattedNotification);
    
    // Limitar la cantidad de notificaciones almacenadas
    if (_notifications.length > 20) {
      _notifications.removeLast();
    }
    
    // Guardar notificaciones y notificar a los listeners
    _saveNotifications();
    _notifyListeners();
  }
  
  // Método para guardar las notificaciones en SharedPreferences
  static Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications.map((n) => {
        'isPositive': n['isPositive'],
        'text': n['text'],
        'title': n['title'],
        'status': n['status'],
        'date': n['date'].millisecondsSinceEpoch,
        'id': n['id'],
        // Guardar los nuevos campos para navegación
        'expirationId': n['expirationId'],
        'expirationType': n['expirationType'],
        // Guardar los colores como valores enteros
        'backgroundColor': n['backgroundColor'] is Color ? (n['backgroundColor'] as Color).value : null,
        'iconBackgroundColor': n['iconBackgroundColor'] is Color ? (n['iconBackgroundColor'] as Color).value : null,
        'textColor': n['textColor'] is Color ? (n['textColor'] as Color).value : null,
        // Guardar datos adicionales como string JSON si existen
        'data': n['data'] != null ? jsonEncode(n['data']) : null,
      }).toList();
      
      await prefs.setString('notifications', jsonEncode(notificationsJson));
      debugPrint('Notificaciones guardadas: ${_notifications.length}');
    } catch (e) {
      debugPrint('Error guardando notificaciones: $e');
    }
  }
  
  // Método para cargar las notificaciones desde SharedPreferences
  static Future<void> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = prefs.getString('notifications');
      
      if (notificationsString != null && notificationsString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(notificationsString);
        _notifications.clear();
        
        for (var item in decodedList) {
          // Intentar decodificar los datos adicionales si existen
          Map<String, dynamic>? additionalData;
          if (item['data'] != null && item['data'] is String) {
            try {
              additionalData = jsonDecode(item['data']);
            } catch (e) {
              debugPrint('Error decodificando datos adicionales: $e');
            }
          }
          
          final notification = {
            'isPositive': item['isPositive'] ?? true,
            'icon': Icons.notifications,
            'text': item['text'] ?? '',
            'title': item['title'] ?? 'Notificación',
            'status': item['status'] ?? 'leido',
            'date': DateTime.fromMillisecondsSinceEpoch(item['date'] ?? 0),
            'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            // Cargar los campos para navegación
            'expirationId': item['expirationId'],
            'expirationType': item['expirationType'],
            // Convertir los valores enteros de color de vuelta a objetos Color
            'backgroundColor': item['backgroundColor'] != null ? Color(item['backgroundColor']) : null,
            'iconBackgroundColor': item['iconBackgroundColor'] != null ? Color(item['iconBackgroundColor']) : null,
            'textColor': item['textColor'] != null ? Color(item['textColor']) : null,
            // Cargar datos adicionales
            'data': additionalData,
          };
          _notifications.add(notification);
        }
        
        debugPrint('Notificaciones cargadas: ${_notifications.length}');
      }
      
      _notifyListeners();
    } catch (e) {
      debugPrint('Error cargando notificaciones: $e');
    }
  }
  
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
  
  // Inicializar las notificaciones al inicio de la aplicación
  static void initialize() {
    loadNotifications();
  }
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Marcar todas las notificaciones como leídas al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationScreen.markAllAsRead();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: const TopBar(
          title: 'Notificaciones',
          screenType: ScreenType.progressScreen,
        ),
      ),
      body: SafeArea(
        child: NotificationScreen._notifications.isEmpty
            ? _buildEmptyState()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Notifications
                  ...List.generate(NotificationScreen._notifications.length, (index) {
                    final notification = NotificationScreen._notifications[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NotificationCard(
                        isPositive: notification['isPositive'],
                        icon: notification['icon'],
                        text: notification['text'],
                        date: notification['date'],
                        title: notification['title'],
                        backgroundColor: notification['backgroundColor'],
                        iconBackgroundColor: notification['iconBackgroundColor'],
                        textColor: notification['textColor'],
                        onTap: () {
                          // Obtener expirationId y expirationType de la notificación
                          final int? expirationId = notification['expirationId'];
                          final String? expirationType = notification['expirationType'];
                          
                          debugPrint('NOTIFICATION_SCREEN: Navegando con expirationId: $expirationId, expirationType: $expirationType');
                          
                          // Si no hay expirationType, usar la pantalla genérica
                          if (expirationType == null || expirationId == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GenericAlertScreen(
                                  alertId: notification['id'],
                                ),
                              ),
                            );
                            return;
                          }
                          
                          // Usar el expirationType para determinar a qué pantalla navegar
                          late Widget screenWidget;
                          
                          // Intentar obtener el vehicleId de la notificación
                          int? vehicleId;
                          if (notification.containsKey('vehicleId')) {
                            try {
                              vehicleId = int.parse(notification['vehicleId'].toString());
                              debugPrint('NOTIFICATION_SCREEN: Obtenido vehicleId: $vehicleId');
                            } catch (e) {
                              debugPrint('NOTIFICATION_SCREEN: Error al parsear vehicleId: $e');
                            }
                          }
                          
                          switch (expirationType) {
                            case 'SOAT':
                              debugPrint('NOTIFICATION_SCREEN: Navegando a SOATScreen con alertId: $expirationId y vehicleId: $vehicleId');
                              screenWidget = SOATScreen(alertId: expirationId, vehicleId: vehicleId);
                              break;
                              
                            case 'RTM':
                              debugPrint('NOTIFICATION_SCREEN: Navegando a RTMScreen con alertId: $expirationId y vehicleId: $vehicleId');
                              screenWidget = RTMScreen(alertId: expirationId, vehicleId: vehicleId);
                              break;
                              
                            case 'Multas':
                              // Aquí necesitaríamos la placa, pero no la tenemos en la notificación
                              // Usaríamos la placa seleccionada en HomeBloc
                              final homeBloc = Provider.of<HomeBloc>(context, listen: false);
                              final plate = homeBloc.selectedPlate;
                              debugPrint('NOTIFICATION_SCREEN: Navegando a MultasScreen con placa: $plate');
                              screenWidget = MultasScreen(plate: plate);
                              break;
                              
                            case 'Licencia de conducción':
                              debugPrint('NOTIFICATION_SCREEN: Caso Licencia de conducción - No se redirecciona');
                              // No redireccionar a ninguna pantalla
                              return;
                              
                            case 'Revisión de frenos':
                              debugPrint('NOTIFICATION_SCREEN: Navegando a RevisionFrenosScreen con alertId: $expirationId');
                              screenWidget = RevisionFrenosScreen(alertId: expirationId);
                              break;
                              
                            case 'Extintor':
                              debugPrint('NOTIFICATION_SCREEN: Navegando a ExtintorScreen con alertId: $expirationId');
                              screenWidget = ExtintorScreen(alertId: expirationId);
                              break;
                              
                            case 'Kit de carretera':
                              debugPrint('NOTIFICATION_SCREEN: Navegando a KitCarreteraScreen con alertId: $expirationId');
                              screenWidget = KitCarreteraScreen(alertId: expirationId);
                              break;
                              
                            case 'Póliza todo riesgo':
                              debugPrint('NOTIFICATION_SCREEN: Navegando a PolizaTodoRiesgoScreen con alertId: $expirationId');
                              screenWidget = PolizaTodoRiesgoScreen(alertId: expirationId);
                              break;
                              
                            case 'Cambio de llantas':
                              debugPrint('NOTIFICATION_SCREEN: Navegando a CambioLlantasScreen con alertId: $expirationId');
                              screenWidget = CambioLlantasScreen(alertId: expirationId);
                              break;
                              
                            case 'Cambio de aceite':
                              debugPrint('NOTIFICATION_SCREEN: Navegando a CambioAceiteScreen con alertId: $expirationId');
                              screenWidget = CambioAceiteScreen(alertId: expirationId);
                              break;
                              
                            default:
                              // Para cualquier otro tipo, usar la pantalla genérica
                              debugPrint('NOTIFICATION_SCREEN: Tipo no reconocido: $expirationType, usando GenericAlertScreen');
                              screenWidget = GenericAlertScreen(alertId: expirationId);
                              break;
                          }
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => screenWidget,
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
  
  // Widget para mostrar cuando no hay notificaciones
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono con animación de opacidad
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.6, end: 1.0),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 80,
                  color: Colors.grey[400],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Mensaje principal
          Text(
            'Todo está limpio y vacío por acá',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          // Mensaje secundario
          Text(
            'Las notificaciones aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
