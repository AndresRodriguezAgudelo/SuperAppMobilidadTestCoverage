import 'package:flutter/material.dart';
import '../../screens/alerta_screen.dart';

class AlertCard extends StatefulWidget {
  final bool isNew;
  final String title;
  final String status;
  final double progress;
  final VoidCallback? onTap;
  final String? iconName; // Parámetro para el nombre del icono
  final dynamic id; // ID de la alerta para actualizaciones (puede ser int o String)
  final bool isSpecial; // Indica si es una alerta especial
  final DateTime? fecha; // Fecha de vencimiento actual

  const AlertCard({
    super.key,
    required this.isNew,
    required this.title,
    required this.status,
    required this.progress,
    this.onTap,
    this.iconName,
    this.id,
    this.isSpecial = false,
    this.fecha,
  });

  @override
  State<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<AlertCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.status == 'red') {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Método para convertir el nombre del icono en un objeto IconData
  IconData _getIconData(String? iconName) {
    // Si no se proporciona un nombre de icono o es vacío, usar el icono predeterminado
    if (iconName == null || iconName.isEmpty) {
      return Icons.notifications;
    }
    
    // Mapeo de nombres de iconos a objetos IconData
    switch (iconName) {
      // Iconos que vienen directamente del backend
      case 'MiscellaneousServices':
        return Icons.miscellaneous_services;
      case 'Security':
        return Icons.security;
      case 'account_box':
        return Icons.account_box;
      case 'directions_car':
        return Icons.directions_car;
      case 'assignment':
        return Icons.assignment;
      case 'assessment':
        return Icons.assessment;
      case 'fire_extinguisher':
        return Icons.fire_extinguisher;
      case 'business_center':
        return Icons.business_center;
      case 'Tire repair':
        return Icons.tire_repair;
      case 'opacity':
        return Icons.opacity;
      case 'construction':
        return Icons.construction;
      // Iconos adicionales para compatibilidad
      case 'car':
        return Icons.directions_car;
      case 'license':
        return Icons.badge;
      case 'calendar':
        return Icons.calendar_today;
      case 'document':
        return Icons.description;
      case 'warning':
        return Icons.warning;
      case 'traffic':
        return Icons.traffic;
      case 'money':
        return Icons.attach_money;
      case 'shield':
        return Icons.shield;
      case 'health':
        return Icons.health_and_safety;
      case 'speed':
        return Icons.speed;
      case 'gas':
        return Icons.local_gas_station;
      case 'maintenance':
        return Icons.build;
      case 'check':
        return Icons.check_circle;
      case 'alert':
        return Icons.notification_important;
      // Iconos para tipos específicos de alertas
      case 'soat':
        return Icons.security;
      case 'rtm':
        return Icons.car_repair;
      case 'multas':
        return Icons.receipt_long;
      case 'pico_placa':
        return Icons.access_time;
      case 'licencia':
        return Icons.card_membership;
      // Casos adicionales que podrían venir del backend con nombres diferentes
      case 'ssignment': // Corregir posible error tipográfico en 'assignment'
        return Icons.assignment;
      case 'notification':
      case 'notifications':
        return Icons.notifications;
      case 'error':
        return Icons.error;
      case 'info':
        return Icons.info;
      case 'help':
        return Icons.help;
      case 'default_icon':
        return Icons.notifications;
      default:
        // Usar icono predeterminado si no se reconoce el nombre
        return Icons.notifications;
    }
  }

  @override
  void didUpdateWidget(AlertCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == 'red' && !_animationController.isAnimating) {
      _animationController.repeat(reverse: true);
    } else if (widget.status != 'red' && _animationController.isAnimating) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNew) {
      return InkWell(
        onTap: widget.onTap,
        child: Container(
          width: 158,
          height: 85,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                color: Color(0xFF38A8E0),
                size: 32,
              ),
              const SizedBox(height: 8),
              const Text(
                'Agregar Alerta',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Usar el estado original que viene del backend
    String displayStatus = widget.status;
    
    // Determinar colores basados en el estado
    Color cardColor;
    Color progressColor;
    
    // Mapear colores según el valor del estado
    switch (widget.status) {
      case 'Vencido':
      case 'No salir':
      case 'Tiene multas':
      case 'No disponible':
        cardColor = const Color(0xFFFADFD9); // Rojo
        progressColor = const Color(0xFFE05C3A);
        break;
      case 'Por vencer':
        cardColor = const Color(0xFFFCEBDE); // Amarillo
        progressColor = const Color(0xFFF5A462);
        break;
      case 'Vigente':
      case 'Puede salir':
      case 'No hay multas':
      case 'Sin multas':
        cardColor = const Color(0xFFEDFAD7); // Verde
        progressColor = const Color(0xFF319E7C);
        break;
      case 'Configurar':
      case 'sinAsignar':
      default:
        cardColor = const Color(0xFFF7F7F7); // Gris
        progressColor = const Color(0xFF7A7A7A);
    }

    return InkWell(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AlertaScreen(),
            ),
          );
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.status == 'red' ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 158,
              height: 84,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: progressColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(widget.iconName),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayStatus,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Barra de progreso - No mostrar para Multas y Pico y placa
                  if (widget.status != 'sinAsignar' && 
                      widget.title != 'Multas' && 
                      widget.title != 'Pico y placa' &&
                      widget.title != 'Licencia de conducción'
                      )
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: Container(
                          height: 8,
                          width: double.infinity,
                          color: progressColor.withOpacity(0.2),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: widget.progress / 100,
                            child: Container(
                              color: progressColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
