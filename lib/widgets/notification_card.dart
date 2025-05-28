import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../utils/error_utils.dart';

class NotificationCard extends StatelessWidget {
  final bool isPositive;
  final IconData icon;
  final String text;
  final DateTime? date;
  final String title;
  final VoidCallback onTap;
  final Color? backgroundColor; // Color personalizado para el fondo
  final Color? iconBackgroundColor; // Color personalizado para el fondo del icono
  final Color? textColor; // Color personalizado para el texto

  const NotificationCard({
    super.key,
    required this.isPositive,
    required this.icon,
    required this.text,
    this.date, // Ahora es opcional
    required this.title,
    required this.onTap,
    this.backgroundColor, // Color opcional para el fondo
    this.iconBackgroundColor, // Color opcional para el fondo del icono
    this.textColor, // Color opcional para el texto
  });

  @override
  Widget build(BuildContext context) {
    // No usar directamente este widget
    // En su lugar, usar showNotification
    return _buildNotificationContent();
  }

  Widget _buildNotificationContent() {
    // Definir colores por defecto o usar los personalizados
    final bgColor = backgroundColor ?? 
                   (isPositive ? const Color(0xFFECFAD7) : const Color(0xFFFADDD7));
    final iconBgColor = iconBackgroundColor ?? 
                      (isPositive ? const Color(0xFF319E7C) : const Color(0xFFE05C3A));
    final txtColor = textColor ?? 
                    (isPositive ? const Color(0xFF319E7C) : const Color(0xFFE05C3A));
    
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap, // Añadir interactividad al tocar la tarjeta
        borderRadius: BorderRadius.circular(8),
        splashColor: bgColor.withOpacity(0.5), // Color de splash personalizado
        highlightColor: bgColor.withOpacity(0.3), // Color de highlight personalizado
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (date != null) Text(
                      DateFormat('dd/MM/yyyy').format(date!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 14,
                        color: txtColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ));
  }

  // Método estático para mostrar la notificación como overlay
  static void showNotification({
    required BuildContext context,
    required bool isPositive,
    required IconData icon,
    required String text,
    DateTime? date, // Ahora es opcional
    required String title,
    Duration? duration,
    Color? backgroundColor, // Color personalizado para el fondo
    Color? iconBackgroundColor, // Color personalizado para el fondo del icono
    Color? textColor, // Color personalizado para el texto
  }) {
    debugPrint('🔔 NotificationCard: Mostrando notificación con duración: ${duration?.inSeconds ?? 4} segundos');
    // Limpiar el mensaje de error si contiene APIException
    final cleanedText = ErrorUtils.cleanErrorMessage(text);
    
    // Crear un overlay entry
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _AnimatedNotification(
        isPositive: isPositive,
        icon: icon,
        text: cleanedText,
        date: date, // Ahora puede ser null
        title: title,
        duration: duration,
        backgroundColor: backgroundColor,
        iconBackgroundColor: iconBackgroundColor,
        textColor: textColor,
        onDismiss: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _AnimatedNotification extends StatefulWidget {
  final bool isPositive;
  final IconData icon;
  final String text;
  final DateTime? date; // Ahora es opcional
  final String title;
  final VoidCallback onDismiss;
  final Duration? duration;
  final Color? backgroundColor; // Color personalizado para el fondo
  final Color? iconBackgroundColor; // Color personalizado para el fondo del icono
  final Color? textColor; // Color personalizado para el texto

  const _AnimatedNotification({
    required this.isPositive,
    required this.icon,
    required this.text,
    this.date,
    required this.title,
    required this.onDismiss,
    this.duration,
    this.backgroundColor,
    this.iconBackgroundColor,
    this.textColor,
  });

  @override
  _AnimatedNotificationState createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Iniciar animación de entrada
    _controller.forward();

    // Auto-cerrar después del tiempo especificado (4 segundos por defecto)
    // Sumamos 500ms adicionales para compensar la duración de la animación de salida
    // y asegurar que la notificación se muestre completamente durante el tiempo deseado
    debugPrint('⏰ NotificationCard: Iniciando temporizador para notificación con duración: ${widget.duration?.inMilliseconds ?? 4000} ms');
    
    Future.delayed(
      Duration(
        milliseconds: (widget.duration?.inMilliseconds ?? 4000) + 500,
      ), 
      () {
        debugPrint('⏰ NotificationCard: Tiempo cumplido, intentando descartar notificación');
        if (mounted) {
          debugPrint('✅ NotificationCard: Widget montado, ejecutando dismiss');
          _dismiss();
        } else {
          debugPrint('❌ NotificationCard: Widget ya no está montado, no se puede descartar');
        }
      }
    );
  }

  void _dismiss() {
    debugPrint('🔄 NotificationCard: Iniciando animación de salida');
    _controller.reverse().then((_) {
      debugPrint('✅ NotificationCard: Animación de salida completada, ejecutando onDismiss');
      widget.onDismiss();
    });
  }

  void _noAction() {
    debugPrint('ℹ️ NotificationCard: Tap en notificación - no action');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: NotificationCard(
            isPositive: widget.isPositive,
            icon: widget.icon,
            text: widget.text,
            date: widget.date, // Ahora puede ser null
            title: widget.title,
            backgroundColor: widget.backgroundColor,
            iconBackgroundColor: widget.iconBackgroundColor,
            textColor: widget.textColor,
            //onTap: _dismiss,
            onTap: _noAction,
          ),
        ),
      ),
    );
  }
}
