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

      ///debugPrint('MAIN: Firebase inicializado correctamente');
    } else {
      ///debugPrint('MAIN: Firebase ya estaba inicializado');
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

  // Inicializar el sistema de notificaciones
  NotificationScreen.initialize();
  ///debugPrint('MAIN: Sistema de notificaciones inicializado');

  runApp(const RestartWidget(child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Función global para reiniciar la app (útil para logout)
void restartApp(BuildContext context) {
  RestartWidget.restartApp(context);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/notifications': (context) => const NotificationScreen(),
          '/mis_vehiculos': (context) => const MisVehiculosScreen(),
          '/guias': (context) => const GuiasScreen(),
          '/servicios': (context) => OurServiciosScreen(),
          '/pagos': (context) => const PagosScreen(),
          '/legal': (context) => const LegalScreen(),
          '/validation': (context) => const ValidationCodeScreen(),
          '/registro': (context) => const RegisterUserScreen(),
          '/mi_perfil': (context) => const MiPerfilScreen(),
        },
      ),
    );
  }
}
