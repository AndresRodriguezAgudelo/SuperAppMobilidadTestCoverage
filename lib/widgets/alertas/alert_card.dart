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
    // Imprimir información de depuración
    //print('\n📌 ALERT_CARD: iconName="$iconName", title="${widget.title}", status="${widget.status}"');
    
    // Si no se proporciona un nombre de icono o es vacío, usar el icono predeterminado
    if (iconName == null || iconName.isEmpty) {
      //print('\n📌 ALERT_CARD: iconName es nulo o vacío, usando icono predeterminado');
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
        return Icons.account_box_outlined;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'assignment':
        return Icons.assignment_outlined;
      case 'assessment':
        return Icons.assessment_outlined;
      case 'fire_extinguisher':
        return Icons.fire_extinguisher;
      case 'business_center':
        return Icons.business_center_outlined;
      case 'Tire repair':
        return Icons.tire_repair_outlined;
      case 'opacity':
        return Icons.opacity;
      case 'construction':
        return Icons.construction;
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
        return Icons.assignment_outlined;
      case 'pico_placa':
                return Icons.security;
      case 'licencia':
        return Icons.account_box_outlined;
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
        // Si no se reconoce el nombre del icono, intentar determinar por el título
        if (widget.title == 'Pico y placa') {
          return Icons.access_time_outlined;
        } else if (widget.title == 'Multas') {
          return Icons.assignment_outlined;
        } else if (widget.title == 'Licencia de conducción') {
          return Icons.account_box_outlined;
        }
        // Usar icono predeterminado si no se reconoce el nombre ni el título
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
    
    // Imprimir información de depuración sobre el estado y colores
    //print('\n🎨 ALERT_CARD COLOR: title="${widget.title}", status="${widget.status}", id=${widget.id}');
    
    // Caso especial: Licencia de conducción siempre en gris
    if (widget.title == 'Licencia de conducción') {
      cardColor = const Color(0xFFF7F7F7); // Gris
      progressColor = const Color(0xFF7A7A7A);
      //rint('\n⬜ ALERT_CARD COLOR: Caso especial - Asignando color GRIS para Licencia de conducción');
    } else {
      // Mapear colores según el valor del estado para el resto de casos
      switch (widget.status) {
      case 'Vencido':
      case 'No salir':
      case 'Con multas':
      case 'No disponible':
        cardColor = const Color(0xFFFADFD9); // Rojo
        progressColor = const Color(0xFFE05C3A);
        //print('\n🔴 ALERT_CARD COLOR: Asignando color ROJO para status="${widget.status}"');
        break;
      case 'Por vencer':
        cardColor = const Color(0xFFFCEBDE); // Amarillo
        progressColor = const Color(0xFFF5A462);
       // print('\n🟡 ALERT_CARD COLOR: Asignando color AMARILLO para status="${widget.status}"');
        break;
      case 'Vigente':
      case 'Permitido salir':
      case 'No hay multas':
      case 'Vehículo nuevo':
      case 'Sin multas':
        cardColor = const Color(0xFFEDFAD7); // Verde
        progressColor = const Color(0xFF319E7C);
        //print('\n🟢 ALERT_CARD COLOR: Asignando color VERDE para status="${widget.status}"');
        break;
      case 'Configurar':
      case 'sinAsignar':
      default:
        cardColor = const Color(0xFFF7F7F7); // Gris
        progressColor = const Color(0xFF7A7A7A);
        //print('\n⬜ ALERT_CARD COLOR: Asignando color GRIS para status="${widget.status}"');
      }
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: progressColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(widget.iconName),
                            color: Colors.white,
                            size: 30,
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  //overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                displayStatus,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
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
