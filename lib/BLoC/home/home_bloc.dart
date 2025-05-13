import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../services/API.dart';
import '../auth/auth_context.dart';
import '../services/services_bloc.dart';
import '../alerts/alerts_bloc.dart';

class HomeBloc extends ChangeNotifier {
  
  List<dynamic> _cars = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;
  int _totalGuides = 0;
  bool _isInitialized = false;
  String? _lastPopSource;
  String? get lastPopSource => _lastPopSource;
  List<dynamic> get cars => _cars;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalGuides => _totalGuides;
  bool get isInitialized => _isInitialized;

  // Variable para mantener la placa del vehículo seleccionado
  String _selectedPlate = '';
  String get selectedPlate => _selectedPlate;
  
  // Método para establecer la placa seleccionada
  void setSelectedPlate(String plate) {
    print('\n🚗 HOME_BLOC: Estableciendo placa seleccionada: $plate');
    _selectedPlate = plate;
    notifyListeners();
  }
  
  // Método para obtener el vehículo seleccionado
  dynamic getSelectedVehicle() {
    if (_selectedPlate.isEmpty || _cars.isEmpty) return null;
    
    try {
      // Buscar el vehículo con la placa seleccionada
      for (var car in _cars) {
        if (car['licensePlate'] == _selectedPlate) {
          return car;
        }
      }
      
      // Si no se encuentra, devolver el primer vehículo si existe
      return _cars.isNotEmpty ? _cars.first : null;
    } catch (e) {
      print('\n⚠️ HOME_BLOC: Error al obtener vehículo seleccionado: $e');
      return _cars.isNotEmpty ? _cars.first : null;
    }
  }

  static final HomeBloc _instance = HomeBloc._internal();
  factory HomeBloc() => _instance;

  HomeBloc._internal();

  /// Inicializa todos los datos críticos de Home (vehículos, servicios, alertas, guías, etc)
  Future<void> initializeHomeData({required ServicesBloc servicesBloc, required AlertsBloc alertsBloc}) async {
    _isLoading = true;
    debugPrint('[HomeBloc] _isLoading = true (initializeHomeData)');
    notifyListeners();
    print('🔄 [HomeBloc] INICIANDO CARGA GLOBAL');
    try {
      print('🚗 [HomeBloc] Cargando vehículos...');
      await vehicleCall();
      print('🚗 [HomeBloc] Vehículos cargados: ${_cars.length}');

      print('🔄 [HomeBloc] Cargando servicios, alertas y guías en paralelo...');
      await Future.wait([
        () async {
          print('🛠️ [HomeBloc] Iniciando carga de servicios...');
          await servicesBloc.getServices();
          print('🛠️ [HomeBloc] Servicios cargados');
        }(),
        if (_cars.isNotEmpty)
          () async {
            print('🚨 [HomeBloc] Iniciando carga de alertas para vehículo: ${_cars.first['id']}');
            await alertsBloc.loadAlerts(_cars.first['id']);
            print('🚨 [HomeBloc] Alertas cargadas para vehículo: ${_cars.first['id']}');
          }(),
        () async {
          print('📚 [HomeBloc] Iniciando carga de guías...');
          await loadTotalGuides();
          print('📚 [HomeBloc] Guías cargadas');
        }(),
      ]);
      print('✅ [HomeBloc] Carga global completada');
    } catch (e) {
      _error = e.toString();
      print('❌ [HomeBloc] Error en carga global: $_error');
    } finally {
      _isLoading = false;
      debugPrint('[HomeBloc] _isLoading = false (initializeHomeData)');
      notifyListeners();
      print('🔄 [HomeBloc] isLoading = false');
    }
  }

  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();


  void viewInitialization({required ServicesBloc servicesBloc, required AlertsBloc alertsBloc}) {
    print('INICIALIZANDO VISTA DE HOME (carga global)');
    initializeHomeData(servicesBloc: servicesBloc, alertsBloc: alertsBloc);
  }

  Future<void> vehicleCall() async {
    // Cargar vehículos del usuario
    try {
      _isLoading = true;
      debugPrint('[HomeBloc] _isLoading = true (vehicleCall)');
      _error = null;
      notifyListeners();

      final response = await _apiService.get(
        _apiService.getCarsEndpoint,
        queryParams: {
          'page': '1',
          'take': '10',
        },
        token: _authContext.token,
      );

      _cars = List<Map<String, dynamic>>.from(response['data']);
      
      // Si no hay placa seleccionada y hay vehículos disponibles, seleccionar el primero
      if (_selectedPlate.isEmpty && _cars.isNotEmpty) {
        _selectedPlate = _cars.first['licensePlate'];
        print('\n🚗 HOME_BLOC: Seleccionando primer vehículo automáticamente: $_selectedPlate');
      } else if (_cars.isNotEmpty) {
        // Verificar si la placa seleccionada todavía existe en la lista
        final plateExists = _cars.any((car) => car['licensePlate'] == _selectedPlate);
        if (!plateExists) {
          _selectedPlate = _cars.first['licensePlate'];
          print('\n🚗 HOME_BLOC: Placa seleccionada no existe, cambiando a: $_selectedPlate');
        }
      }
      print('🚗 VEHÍCULOS OBTENIDOS: ${_cars.length}');
    } catch (e) {
      _error = e.toString();
      print('❌ ERROR OBTENIENDO VEHÍCULOS: $_error');
    } finally {
      // Aseguramos que _isLoading se establezca a false siempre
      _isLoading = false;
      debugPrint('[HomeBloc] _isLoading = false (vehicleCall)');
      notifyListeners();
    }
  }
  
  // Método para habilitar las peticiones (poner el switch en 0)
  void enableRequests() {
 
  }
  
  // Método para deshabilitar las peticiones (poner el switch en 1)
  void disableRequests() {
 
  }
  
  Future<void> loadTotalGuides() async {
    try {
      print('\n📚 [HomeBloc] OBTENIENDO TOTAL DE GUÍAS');
      
      // Usamos los mismos parámetros que en GuidesBloc.loadGuides para asegurar
      // que obtenemos la misma respuesta
      final response = await _apiService.get(
        _apiService.getAllGuidesEndpoint,
        token: _authContext.token,
        queryParams: {
          'page': '1',
          'take': '100',
          'order': 'ASC',
        },
      );
      
      print('📄 [HomeBloc] Respuesta de guías recibida');
      
      // Verificar si la respuesta contiene el total de guías
      if (response['totalCount'] != null) {
        _totalGuides = response['totalCount'];
        print('📊 [HomeBloc] Total de guías (totalCount): $_totalGuides');
      } else if (response['categories'] != null) {
        // Si no hay totalCount pero hay categorías, contamos el total de items
        int total = 0;
        final categories = response['categories'] as List;
        print('📑 [HomeBloc] Número de categorías: ${categories.length}');
        
        for (var category in categories) {
          if (category['items'] != null) {
            final items = category['items'] as List;
            total += items.length;
            print('📋 [HomeBloc] Categoría: ${category['categoryName']} - Items: ${items.length}');
          }
        }
        _totalGuides = total;
        print('📊 [HomeBloc] Total de guías (conteo manual): $_totalGuides');
      } else {
        _totalGuides = 0;
        print('⚠️ [HomeBloc] No se encontraron guías');
      }
      
      print('✅ [HomeBloc] Total final de guías: $_totalGuides');
      notifyListeners();
    } catch (e) {
      print('❌ [HomeBloc] ERROR OBTENIENDO TOTAL DE GUÍAS: $e');
      _totalGuides = 0;
    }
  }

  Future<void> initialize() async {
   
  }



  Future<void> getCars({int page = 1, int take = 10, bool force = false}) async {
   
  }

  void reset() {

  }
  
  void clearCars() {

  }  

  /// Fuerza la recarga de los vehículos desde el servidor
  /// Este método se llama cuando se elimina un vehículo para actualizar la lista
  Future<void> forceReload() async {
    print('🔄 [HomeBloc] FORZANDO RECARGA DE VEHÍCULOS');
    try {
      // Solo recargamos los vehículos, no todo el home
      await vehicleCall();
      print('✅ [HomeBloc] Vehículos recargados: ${_cars.length}');
      // Establecer isLoading a false ya que vehicleCall() no lo hace
      _isLoading = false;
      debugPrint('[HomeBloc] _isLoading = false (forceReload)');
      // Notificar a los listeners para que se actualice la UI
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('[HomeBloc] _isLoading = false (forceReload - error)');
      print('❌ [HomeBloc] ERROR RECARGANDO VEHÍCULOS: $e');
      notifyListeners();
    }
  }


  set lastPopSource(String? value) {

  }

}
