import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final bool isPositive;
  final IconData icon;
  final String text;
  final DateTime date;
  final String title;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.isPositive,
    required this.icon,
    required this.text,
    required this.date,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // No usar directamente este widget
    // En su lugar, usar showNotification
    return _buildNotificationContent();
  }

  Widget _buildNotificationContent() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPositive ? const Color(0xFFECFAD7) : const Color(0xFFFADDD7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPositive
                    ? const Color(0xFF319E7C)
                    : const Color(0xFFE05C3A),
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
                  Text(
                    DateFormat('dd/MM/yyyy').format(date),
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
                      color: isPositive
                          ? const Color(0xFF319E7C)
                          : const Color(0xFFE05C3A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método estático para mostrar la notificación como overlay
  static void showNotification({
    required BuildContext context,
    required bool isPositive,
    required IconData icon,
    required String text,
    required DateTime date,
    required String title,
    Duration? duration,
  }) {
    // Crear un overlay entry
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _AnimatedNotification(
        isPositive: isPositive,
        icon: icon,
        text: text,
        date: date,
        title: title,
        duration: duration,
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
  final DateTime date;
  final String title;
  final VoidCallback onDismiss;
  final Duration? duration;

  const _AnimatedNotification({
    required this.isPositive,
    required this.icon,
    required this.text,
    required this.date,
    required this.title,
    required this.onDismiss,
    this.duration,
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

    // Auto-cerrar después del tiempo especificado o 3 segundos por defecto si es positiva
    Future.delayed(widget.duration ?? const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  void _noAction() {
    print('no action');
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
            date: widget.date,
            title: widget.title,
            //onTap: _dismiss,
            onTap: _noAction,
          ),
        ),
      ),
    );
  }
}
