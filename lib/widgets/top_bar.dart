import 'package:flutter/material.dart';
import '../screens/notification_screen.dart';

enum ScreenType {
  baseScreen,
  progressScreen,
  homeScreen,
}

class TopBar extends StatefulWidget {
  final ScreenType? screenType;
  final String? title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actionItems;

  const TopBar({
    super.key,
    this.screenType,
    this.title,
    this.onBackPressed,
    this.onMenuPressed,
    this.actionItems,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> with SingleTickerProviderStateMixin {
  int _notificationCount = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Configurar la animación
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticIn)),
        weight: 60,
      ),
    ]).animate(_animationController);
    
    // Registrar el listener para el contador de notificaciones
    NotificationScreen.addListener(_updateNotificationCount);
  }
  
  @override
  void dispose() {
    // Eliminar el listener y liberar recursos
    NotificationScreen.removeListener(_updateNotificationCount);
    _animationController.dispose();
    super.dispose();
  }
  
  void _updateNotificationCount(int count) {
    // Solo animar si el contador aumenta
    if (count > _notificationCount) {
      _animationController.reset();
      _animationController.forward();
    }
    
    setState(() {
      _notificationCount = count;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: widget.screenType == ScreenType.progressScreen
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
            )
          : widget.screenType == ScreenType.baseScreen
              ? IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: widget.onMenuPressed ??
                      () {
                        Scaffold.of(context).openDrawer();
                      },
                )
              : null,
      title: widget.screenType == ScreenType.baseScreen
          ? Image.asset(
              'assets/images/LogoMobilityAZUL.png',
              height: 42,
              fit: BoxFit.contain,
            )
          : widget.title != null
              ? Text(widget.title!)
              : null,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: widget.screenType == ScreenType.progressScreen,
      titleSpacing: widget.screenType == ScreenType.baseScreen ? 0 : NavigationToolbar.kMiddleSpacing,
      actions: widget.actionItems ?? [
        if (widget.screenType == ScreenType.homeScreen || widget.screenType == ScreenType.baseScreen)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                  // Marcar todas las notificaciones como leídas al visitar la pantalla
                  NotificationScreen.markAllAsRead();
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF1E3340),
                ),
              ),
              if (_notificationCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          _notificationCount > 99 ? '99+' : '$_notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
