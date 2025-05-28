import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/BLoC/alerts/alerts_bloc.dart';
import 'package:Equirent_Mobility/BLoC/services/services_bloc.dart';
import 'package:Equirent_Mobility/screens/guias_screen.dart';
import '../widgets/top_bar.dart';
import '../widgets/leftMenu/left_menu.dart';
import '../widgets/banners_run_way.dart';
import '../widgets/alertas/alerts.dart';
import '../widgets/nuestrosServicios/our_services.dart';
import '../BLoC/home/home_bloc.dart';
import '../services/notification_service.dart';
import 'package:Equirent_Mobility/widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();


}

class HomeScreenState extends State<HomeScreen> with RouteAware {
  // Variable para rastrear si llegamos al HomeScreen desde el botón de atrás
  bool _arrivedFromBackButton = false;
  String? lastPopSource;

  @override
  void initState() {
    super.initState();
    debugPrint('\n==================================================');
    debugPrint('HOME_SCREEN: initState llamado');
    debugPrint('==================================================\n');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeBloc = Provider.of<HomeBloc>(context, listen: false);
      final servicesBloc = Provider.of<ServicesBloc>(context, listen: false);
      final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
      homeBloc.viewInitialization(servicesBloc: servicesBloc, alertsBloc: alertsBloc);
      
      // Verificar si hay navegación pendiente desde una notificación
      debugPrint('\n==================================================');
      debugPrint('HOME_SCREEN: VERIFICANDO NAVEGACIÓN PENDIENTE');
      
      // Verificar inmediatamente si hay navegación pendiente
      if (NotificationService.hasPendingNavigation()) {
        debugPrint('HOME_SCREEN: ¡NAVEGACIÓN PENDIENTE DETECTADA!');
        
        // Aumentar el retraso para asegurar que la UI esté completamente inicializada
        // y que todos los BLoCs estén disponibles
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            debugPrint('HOME_SCREEN: EJECUTANDO NAVEGACIÓN PENDIENTE AHORA');
            NotificationService.processPendingNavigation(context);
          }
        });
      } else {
        debugPrint('HOME_SCREEN: No hay navegación pendiente');
      }
      
      // Configurar un listener para verificar nuevamente después de que la pantalla esté completamente construida
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && NotificationService.hasPendingNavigation()) {
          debugPrint('HOME_SCREEN: NAVEGACIÓN PENDIENTE DETECTADA EN POST-FRAME');
          NotificationService.processPendingNavigation(context);
        }
      });
      
      // Configurar un listener para verificar nuevamente si llega una notificación mientras la app está abierta
      // Esto es útil si la notificación llega después de que la app ya está abierta
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && NotificationService.hasPendingNavigation()) {
          debugPrint('HOME_SCREEN: Navegación pendiente detectada en verificación secundaria');
          NotificationService.processPendingNavigation(context);
        }
      });
      
      debugPrint('==================================================\n');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Registrar el RouteObserver y guardar la referencia
    try {
      _routeObserver = Provider.of<RouteObserver<ModalRoute<dynamic>>>(context, listen: false);
      if (ModalRoute.of(context) != null) {
        _routeObserver!.subscribe(this, ModalRoute.of(context)!);
        debugPrint('HOME_SCREEN: didChangeDependencies llamado - RouteObserver registrado');
      } else {
        debugPrint('HOME_SCREEN: didChangeDependencies llamado - ModalRoute es null');
      }
    } catch (e) {
      debugPrint('HOME_SCREEN: Error al registrar RouteObserver: $e');
    }
  }

  // Guardar una referencia al RouteObserver
  RouteObserver<ModalRoute<dynamic>>? _routeObserver;
  
  @override
  void dispose() {
    // Desuscribir del RouteObserver de manera segura
    if (_routeObserver != null) {
      _routeObserver!.unsubscribe(this);
      debugPrint('HOME_SCREEN: dispose llamado - desuscripción segura del RouteObserver');
    } else {
      debugPrint('HOME_SCREEN: dispose llamado - no hay RouteObserver para desuscribir');
    }
    super.dispose();
  }

  // Este método se llama cuando esta pantalla se vuelve visible después de que otra pantalla se cierra
  @override
  void didPopNext() {
    super.didPopNext();
    debugPrint('\n==================================================');
    debugPrint('HOME_SCREEN: didPopNext llamado - Regresando a HomeScreen desde otra pantalla');
    debugPrint('HOME_SCREEN: Posiblemente llegando desde el botón de atrás');
    _arrivedFromBackButton = true;
    
    // Actualizar las alertas cuando se regresa al Home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final homeBloc = Provider.of<HomeBloc>(context, listen: false);
        final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
        
        // Forzar la recarga de vehículos para asegurar que tenemos la lista actualizada
        homeBloc.vehicleCall().then((_) {
          // Obtener el vehículo seleccionado actual (después de cargar desde SharedPreferences)
          final selectedVehicle = homeBloc.getSelectedVehicle();
          
          if (selectedVehicle != null && selectedVehicle['id'] != null) {
            debugPrint('HOME_SCREEN: Actualizando alertas para el vehículo seleccionado: ${selectedVehicle['licensePlate']} (ID: ${selectedVehicle['id']})');
            
            // Resetear y cargar las alertas para el vehículo seleccionado
            alertsBloc.reset();
            alertsBloc.loadAlerts(selectedVehicle['id']);
          } else {
            debugPrint('HOME_SCREEN: No se pudo obtener el vehículo seleccionado');
          }
        });
      }
    });
    
    debugPrint('==================================================\n');
  }

  // Este método se llama cuando esta pantalla se vuelve visible por primera vez
  @override
  void didPush() {
    super.didPush();
    debugPrint('\n==================================================');
    debugPrint('HOME_SCREEN: didPush llamado - HomeScreen mostrado por primera vez');
    debugPrint('==================================================\n');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<HomeBloc>().isLoading;
    debugPrint('[HomeScreen] build: isLoading = $isLoading');
    return Loading(
      isLoading: isLoading,
      child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          screenType: ScreenType.baseScreen,
        ),
      ),
        drawer: const LeftMenu(),
              floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GuiasScreen()),
              );
            },
            backgroundColor: const Color(0xFF38A8E0),
            shape: const CircleBorder(),
            child: const Icon(Icons.map_outlined, color: Colors.white),
          ),
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              child: Center(
                child: Text(
                  '${context.watch<HomeBloc>().totalGuides}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16),
              BannerRunWay(),
              SizedBox(height: 24),
              Alertas(),
              NuestrosServicios(),
              SizedBox(height: 54),
            ],
          ),
        ),
      ),
    );
  }
}
