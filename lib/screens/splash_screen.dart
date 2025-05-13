import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/notification_service.dart';
import '../services/session_manager.dart';
import '../BLoC/auth/auth_context.dart';
import 'package:Equirent_Mobility/main.dart' show navigatorKey;
// import '../BLoC/home/home_bloc.dart'; // ya no se necesita

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _deviceToken;
  String? _platform;
  bool _tokenObtained = false;

  @override
  void initState() {
    super.initState();
    ///debugPrint('SPLASH_SCREEN: initState');
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    // Inicializar el servicio de notificaciones y obtener el token del dispositivo
    _initializeNotifications();

    // Verificar sesión y navegar después de 3 segundos
    _checkSessionAndNavigate();
  }
  
  Future<void> _initializeNotifications() async {
    try {
      // Inicializar el servicio de notificaciones
      await NotificationService().initialize();
      
      // Obtener y mostrar el token del dispositivo y la plataforma
      final notificationService = NotificationService();
      final deviceToken = notificationService.deviceToken;
      final platform = notificationService.getPlatform();
      
      // Verificar si el widget todavía está montado antes de actualizar el estado
      if (mounted) {
        // Actualizar el estado para mostrar el token en la UI
        setState(() {
          _deviceToken = deviceToken;
          _platform = platform;
          _tokenObtained = true;
        });
      }
      
      // Usar debugPrint para asegurar que los logs sean visibles
      ///debugPrint('\n==================================================');
      ///debugPrint('SPLASH_SCREEN: DEVICE TOKEN OBTENIDO: $deviceToken');
      ///debugPrint('SPLASH_SCREEN: PLATAFORMA: $platform');
      ///debugPrint('==================================================\n');
      // Mostrar el objeto JSON que se enviará al backend
      ///debugPrint('\n==================================================');
      ///debugPrint('SPLASH_SCREEN: JSON A ENVIAR AL BACKEND:');
      ///debugPrint('{');
      ///debugPrint('  "deviceToken": "$deviceToken",');
      ///debugPrint('  "platform": "$platform"');
      ///debugPrint('}');
      ///debugPrint('==================================================\n');
    } catch (e) {
      ///debugPrint('SPLASH_SCREEN: Error al inicializar notificaciones: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Aro giratorio con degradado
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.4,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LoadingPainter(
                      progress: _controller.value,
                      strokeWidth: 10.0, // Línea más gruesa
                      startColor: const Color(0xFF38A8E0),
                      endColor: const Color(0xFFBAE2F5),
                    ),
                  );
                },
              ),
            ),
            
            // Logo
            Image.asset(
              'assets/images/NewLogoJustE.png',
              width: MediaQuery.of(context).size.width * 0.20,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  // Verifica sesión en SharedPreferences y navega al home o login
  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    ///debugPrint('SPLASH_SCREEN: Verificando sesión en SharedPreferences...');
    final session = await SessionManager.loadSession();
    debugPrint('DEBUG: Sesión cargada en SplashScreen:');
    debugPrint(session?.toString() ?? 'null');
    final now = DateTime.now().millisecondsSinceEpoch;
    if (session != null && session.expiry > now) {
      ///debugPrint('SPLASH_SCREEN: Sesión válida con token: ${session.token}');
      AuthContext().setUserData(
        token: session.token,
        name: session.name,
        phone: session.phone,
        photo: session.photo,
        userId: session.userId,
      );
      // Verificar si el estado sigue montado antes de navegar
      if (!mounted) {
        ///debugPrint('SPLASH_SCREEN: No montado, abortando navegación');
        return;
      }
      ///debugPrint('SPLASH_SCREEN: Navegando a HomeScreen (/home)');
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      ///debugPrint('SPLASH_SCREEN: Sesión inválida o expirada');
      await SessionManager.clearSession();
      await AuthContext().clearUserData();
      debugPrint('DEBUG: Navegando a /login');
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}

class LoadingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color startColor;
  final Color endColor;

  LoadingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: [startColor, endColor],
      stops: const [0.0, 1.0],
      transform: GradientRotation(2 * math.pi * progress - math.pi / 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(LoadingPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      strokeWidth != oldDelegate.strokeWidth ||
      startColor != oldDelegate.startColor ||
      endColor != oldDelegate.endColor;
}
