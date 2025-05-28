import 'dart:io';
// superapp_movilidad
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widgets/restart_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'route_observer.dart';

import 'BLoC/auth/auth_context.dart';
import 'BLoC/home/home_bloc.dart';
import 'BLoC/services/services_bloc.dart';
import 'BLoC/images/image_bloc.dart';
import 'BLoC/guides/guides_bloc.dart';
import 'BLoC/alerts/alerts_bloc.dart';
import 'BLoC/vehicles/vehicles_bloc.dart';
import 'BLoC/profile/profile_bloc.dart';
import 'BLoC/loading/loading_bloc.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/validation_code_screen.dart';
import 'screens/register_user_screen.dart';
import 'screens/my_vehicles_screen.dart';
import 'screens/guias_screen.dart';
import 'screens/our_services_screen.dart';
import 'screens/pagos_screen.dart';
import 'screens/legal_screen.dart';
import 'screens/my_profile_screen.dart';
import 'screens/notification_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Inicializar Firebase con opciones específicas para cada plataforma
  try {
    if (Firebase.apps.isEmpty) {
      if (Platform.isIOS) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyDMlIzmWgRpzM-OBsx9gPGOgSa1axpMim0",
            appId: "1:110335781419:ios:87316a5799278c9406986e",
            messagingSenderId: "110335781419",
            projectId: "supeappmovilidad",
            storageBucket: "supeappmovilidad.firebasestorage.app",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    }
  } catch (e) {
    ///debugPrint('MAIN: Error al inicializar Firebase: $e');
  }

  // Initialize WebView platform
  late final WebViewPlatform platform;
  if (WebViewPlatform.instance == null) {
    if (identical(0, 0.0)) {
      platform = WebKitWebViewPlatform();
    } else {
      platform = AndroidWebViewPlatform();
    }
    WebViewPlatform.instance = platform;
  }
  // Inicializar la pantalla de notificaciones
  NotificationScreen.initialize();
  
  // Inicializar el servicio de notificaciones para manejar notificaciones en segundo plano
  try {
    await NotificationService().initialize();
    debugPrint('MAIN: Servicio de notificaciones inicializado correctamente');
  } catch (e) {
    debugPrint('MAIN: Error al inicializar el servicio de notificaciones: $e');
  }

  runApp(const RestartWidget(child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void restartApp(BuildContext context) {
  RestartWidget.restartApp(context);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Verificar si hay navegación pendiente al iniciar la app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('\n==================================================');
      debugPrint('MYAPP: VERIFICANDO NAVEGACIÓN PENDIENTE AL INICIAR LA APP');
      if (NotificationService.hasPendingNavigation()) {
        debugPrint('MYAPP: ¡NAVEGACIÓN PENDIENTE DETECTADA!');
        
        // Procesar la navegación pendiente directamente si tenemos un contexto válido
        // Usar un retraso más largo para asegurar que la app esté completamente inicializada
        Future.delayed(const Duration(milliseconds: 1500), () {
          final context = navigatorKey.currentContext;
          if (context != null) {
            debugPrint('MYAPP: PROCESANDO NAVEGACIÓN PENDIENTE DIRECTAMENTE DESDE INIT');
            NotificationService.processPendingNavigation(context);
          } else {
            debugPrint('MYAPP: NO HAY CONTEXTO VÁLIDO PARA PROCESAR NAVEGACIÓN EN INIT');
          }
        });
      }
      debugPrint('==================================================\n');
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cuando la app vuelve a primer plano, verificar si hay navegación pendiente
    if (state == AppLifecycleState.resumed) {
      debugPrint('\n==================================================');
      debugPrint('MYAPP: APP RESUMED - VERIFICANDO NAVEGACIÓN PENDIENTE');
      if (NotificationService.hasPendingNavigation()) {
        debugPrint('MYAPP: ¡NAVEGACIÓN PENDIENTE DETECTADA EN RESUMED!');
        
        // Procesar la navegación pendiente directamente si tenemos un contexto válido
        Future.delayed(const Duration(milliseconds: 500), () {
          final context = navigatorKey.currentContext;
          if (context != null) {
            debugPrint('MYAPP: PROCESANDO NAVEGACIÓN PENDIENTE DIRECTAMENTE');
            NotificationService.processPendingNavigation(context);
          } else {
            debugPrint('MYAPP: NO HAY CONTEXTO VÁLIDO PARA PROCESAR NAVEGACIÓN');
          }
        });
      }
      debugPrint('==================================================\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RouteObserver<ModalRoute<dynamic>>>(
          create: (_) => routeObserver,
        ),
        ChangeNotifierProvider(create: (_) => AuthContext()),
        ChangeNotifierProvider(create: (_) => HomeBloc()),
        ChangeNotifierProvider(create: (_) => GuidesBloc()),
        ChangeNotifierProvider(create: (_) => ServicesBloc()),
        ChangeNotifierProvider(create: (_) => ImageBloc()),
        ChangeNotifierProvider(create: (_) => AlertsBloc()),
        ChangeNotifierProvider(create: (_) => VehiclesBloc()),
        ChangeNotifierProvider(create: (_) => ProfileBloc()),
        ChangeNotifierProvider(create: (_) => LoadingBloc()),
      ],
      child: MaterialApp(
        title: 'SuperApp Movilidad',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        navigatorObservers: [routeObserver],
        // Implementar un generador de rutas personalizado para evitar el error de Navigator vacío
        onGenerateRoute: (RouteSettings settings) {
          debugPrint('MAIN: Generando ruta: ${settings.name}');
          
          // Si la ruta es nula o vacía, redirigir a SplashScreen
          if (settings.name == null || settings.name!.isEmpty) {
            return MaterialPageRoute(
              settings: const RouteSettings(name: '/'),
              builder: (context) => const SplashScreen(),
            );
          }
          
          // Mapeo de rutas a widgets
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (context) => const SplashScreen());
            case '/login':
              return MaterialPageRoute(builder: (context) => const LoginScreen());
            case '/home':
              return MaterialPageRoute(builder: (context) => const HomeScreen());
            case '/notifications':
              return MaterialPageRoute(builder: (context) => const NotificationScreen());
            case '/mis_vehiculos':
              return MaterialPageRoute(builder: (context) => const MisVehiculosScreen());
            case '/guias':
              return MaterialPageRoute(builder: (context) => const GuiasScreen());
            case '/servicios':
              return MaterialPageRoute(builder: (context) => OurServiciosScreen());
            case '/pagos':
              return MaterialPageRoute(builder: (context) => const PagosScreen());
            case '/legal':
              return MaterialPageRoute(builder: (context) => const LegalScreen());
            case '/validation':
              // Pasar los argumentos a la pantalla de validación
              return MaterialPageRoute(
                builder: (context) => const ValidationCodeScreen(),
                settings: settings, // Pasar los argumentos originales
              );
            case '/registro':
              // Pasar los argumentos a la pantalla de registro
              return MaterialPageRoute(
                builder: (context) => const RegisterUserScreen(),
                settings: settings, // Pasar los argumentos originales
              );
            case '/mi_perfil':
              return MaterialPageRoute(builder: (context) => const MiPerfilScreen());
            default:
              // Si la ruta no existe, redirigir a HomeScreen
              debugPrint('MAIN: Ruta no encontrada: ${settings.name}, redirigiendo a HomeScreen');
              return MaterialPageRoute(builder: (context) => const HomeScreen());
          }
        },
        // No necesitamos initialRoute porque ya tenemos onGenerateRoute
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
        ],
        theme: ThemeData(
          useMaterial3: true,
        ),
        // Usamos initialRoute para asegurar que siempre haya una ruta inicial
        initialRoute: '/',
      ),
    );
  }
}
