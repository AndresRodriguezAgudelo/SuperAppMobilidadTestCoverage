import 'package:flutter/foundation.dart';
import '../home/home_bloc.dart';
import '../services/services_bloc.dart';
import '../alerts/alerts_bloc.dart';

/// BLoC para orquestar la carga de datos al entrar al Home
class LoadingBloc extends ChangeNotifier {
  bool isLoading = false;
  bool isComplete = false;
  String? error;

  /// Inicia la carga de datos necesarios para el Home
  Future<void> startLoading() async {
    isLoading = true;
    isComplete = false;
    error = null;
    notifyListeners();

    try {
      debugPrint('LOADING_BLOC: Iniciando carga de datos del Home');
      // Pedir HomeBloc que habilite peticiones y luego esperar a que
      // tanto HomeBloc como ServicesBloc terminen de cargar
      final homeBloc = HomeBloc();
      final servicesBloc = ServicesBloc();

      homeBloc.enableRequests();

      // 1) Obtener carros (necesario para saber vehicleId)
      await homeBloc.getCars(force: true);

      // 2) Si hay vehículo, cargar alertas de ese primero
      final alertsBloc = AlertsBloc();
      if (homeBloc.cars.isNotEmpty) {
        await alertsBloc.loadAlerts(homeBloc.cars.first['id']);
      }

      // 3) En paralelo: guías totales y servicios
      await Future.wait([
        homeBloc.loadTotalGuides(),
        servicesBloc.getServices(),
      ]);
      debugPrint('LOADING_BLOC: Carga de datos completada');
      isComplete = true;
    } catch (e) {
      debugPrint('LOADING_BLOC: Error al cargar datos: $e');
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
