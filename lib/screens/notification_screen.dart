import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Equirent_Mobility/screens/generic_alert_screen.dart';
import '../widgets/top_bar.dart';
import '../widgets/notification_card.dart';

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
    // Convertir la notificación al formato esperado
    final formattedNotification = {
      'isPositive': true, // Por defecto, considerar positiva
      'icon': Icons.notifications,
      'text': notification['body'] ?? '',
      'date': DateTime.now(),
      'title': notification['title'] ?? 'Notificación',
      'status': 'nuevo', // Siempre nueva al crearla
      'id': DateTime.now().millisecondsSinceEpoch.toString(), // ID único
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
          final notification = {
            'isPositive': item['isPositive'] ?? true,
            'icon': Icons.notifications,
            'text': item['text'] ?? '',
            'title': item['title'] ?? 'Notificación',
            'status': item['status'] ?? 'leido',
            'date': DateTime.fromMillisecondsSinceEpoch(item['date'] ?? 0),
            'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenericAlertScreen(
                                alertId: notification['id'],
                              ),
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
