import 'package:flutter/foundation.dart';
import '../../services/API.dart';
import '../auth/auth_context.dart';

class HistorialVehicularBloc extends ChangeNotifier {
  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();
  
  // Control de caché para evitar múltiples llamadas
  DateTime? _lastTramitesLoadTime;
  final _cacheValidityDuration = const Duration(minutes: 5); // Caché válida por 5 minutos

  // Estados para cada tipo de historial
  Map<String, dynamic>? _historialTramites;
  Map<String, dynamic>? _multas;
  Map<String, dynamic>? _accidentes;
  Map<String, dynamic>? _novedadesTraspaso;
  Map<String, dynamic>? _medidasCautelares;

  // Estados de carga individuales
  bool _isLoadingTramites = false;
  bool _isLoadingMultas = false;
  bool _isLoadingAccidentes = false;
  bool _isLoadingNovedades = false;
  bool _isLoadingMedidas = false;

  // Estados de error individuales
  String? _errorTramites;
  String? _errorMultas;
  String? _errorAccidentes;
  String? _errorNovedades;
  String? _errorMedidas;

  String? _placa;

  // Getters para datos
  Map<String, dynamic>? get historialTramites => _historialTramites;
  Map<String, dynamic>? get multas => _multas;
  Map<String, dynamic>? get accidentes => _accidentes;
  Map<String, dynamic>? get novedadesTraspaso => _novedadesTraspaso;
  Map<String, dynamic>? get medidasCautelares => _medidasCautelares;

  // Getters para estados de carga
  bool get isLoadingTramites => _isLoadingTramites;
  bool get isLoadingMultas => _isLoadingMultas;
  bool get isLoadingAccidentes => _isLoadingAccidentes;
  bool get isLoadingNovedades => _isLoadingNovedades;
  bool get isLoadingMedidas => _isLoadingMedidas;

  // Getter general de carga (para compatibilidad)
  bool get isLoading =>
      _isLoadingTramites ||
      _isLoadingMultas ||
      _isLoadingAccidentes ||
      _isLoadingNovedades ||
      _isLoadingMedidas;

  // Getters para errores
  String? get errorTramites => _errorTramites;
  String? get errorMultas => _errorMultas;
  String? get errorAccidentes => _errorAccidentes;
  String? get errorNovedades => _errorNovedades;
  String? get errorMedidas => _errorMedidas;

  // Getter general de error (para compatibilidad)
  String? get error =>
      _errorTramites ??
      _errorMultas ??
      _errorAccidentes ??
      _errorNovedades ??
      _errorMedidas;

  String? get placa => _placa;
  
  // Método para establecer la placa sin iniciar cargas
  void setPlaca(String placa) {
    _placa = placa;
    notifyListeners();
  }

  // Método para iniciar todas las cargas (pero de forma independiente)
  Future<void> loadHistorialVehicular(String placa) async {
    _placa = placa;

    // Limpiar errores previos
    _errorTramites = null;
    _errorMultas = null;
    _errorAccidentes = null;
    _errorNovedades = null;
    _errorMedidas = null;

    notifyListeners();

    // Iniciar todas las cargas de forma independiente
    loadHistorialTramites(placa);
    loadMultas(placa);
    loadAccidentes(placa);
    loadNovedadesTraspaso(placa);
    loadMedidasCautelares(placa);
  }

  // Métodos individuales para cargar cada tipo de datos
  Future<void> loadHistorialTramites(String placa) async {
    // Si ya tenemos datos y la caché es válida, no volver a cargar
    if (_historialTramites != null && 
        _lastTramitesLoadTime != null &&
        DateTime.now().difference(_lastTramitesLoadTime!) < _cacheValidityDuration) {
      return;
    }
    
    if (_isLoadingTramites) return;

    try {
      _isLoadingTramites = true;
      _errorTramites = null;
      notifyListeners();

      await _loadHistorialTramites(placa);
      _lastTramitesLoadTime = DateTime.now(); // Actualizar tiempo de carga
    } catch (e) {
      print('\n❌ ERROR CARGANDO HISTORIAL DE TRÁMITES');
      print('📡 Error: $e');
      _errorTramites = 'No se pudo cargar el historial de trámites';
    } finally {
      _isLoadingTramites = false;
      notifyListeners();
    }
  }

  Future<void> loadMultas(String placa) async {
    if (_isLoadingMultas) return;

    try {
      _isLoadingMultas = true;
      _errorMultas = null;
      notifyListeners();

      await _loadMultas(placa);
    } catch (e) {
      print('\n❌ ERROR CARGANDO MULTAS');
      print('📡 Error: $e');
      _errorMultas = 'No se pudo cargar la información de multas';
    } finally {
      _isLoadingMultas = false;
      notifyListeners();
    }
  }

  Future<void> loadAccidentes(String placa) async {
    if (_isLoadingAccidentes) return;

    try {
      _isLoadingAccidentes = true;
      _errorAccidentes = null;
      notifyListeners();

      await _loadAccidentes(placa);
    } catch (e) {
      print('\n❌ ERROR CARGANDO ACCIDENTES');
      print('📡 Error: $e');
      _errorAccidentes = 'No se pudo cargar la información de accidentes';
    } finally {
      _isLoadingAccidentes = false;
      notifyListeners();
    }
  }

  Future<void> loadNovedadesTraspaso(String placa) async {
    if (_isLoadingNovedades) return;

    try {
      _isLoadingNovedades = true;
      _errorNovedades = null;
      notifyListeners();

      await _loadNovedadesTraspaso(placa);
    } catch (e) {
      print('\n❌ ERROR CARGANDO NOVEDADES DE TRASPASO');
      print('📡 Error: $e');
      _errorNovedades =
          'No se pudo cargar la información de novedades de traspaso';
    } finally {
      _isLoadingNovedades = false;
      notifyListeners();
    }
  }

  Future<void> loadMedidasCautelares(String placa) async {
    if (_isLoadingMedidas) return;

    try {
      _isLoadingMedidas = true;
      _errorMedidas = null;
      notifyListeners();

      await _loadMedidasCautelares(placa);
    } catch (e) {
      print('\n❌ ERROR CARGANDO MEDIDAS CAUTELARES');
      print('📡 Error: $e');
      _errorMedidas = 'No se pudo cargar la información de medidas cautelares';
    } finally {
      _isLoadingMedidas = false;
      notifyListeners();
    }
  }

  Future<dynamic> _loadHistorialTramites(String placa) async {
    try {
      final endpoint = _apiService.getVehicleHistoryEndpoint(placa);
      print('\n📡 Llamando al endpoint de historial de trámites: $endpoint');
      final response = await _apiService.get(
        endpoint,
        token: _authContext.token,
      );
      _historialTramites = response;
      print('\n✅ Datos de historial de trámites recibidos correctamente');
      return response;
    } catch (e) {
      print('\n❌ Error cargando historial de trámites: $e');
      _historialTramites = null;
      return e;
    }
  }
  
  // Método para forzar la recarga del historial de trámites (útil para pull-to-refresh)
  Future<void> forceReloadHistorialTramites(String placa) async {
    print('\n🔄 Forzando recarga de historial de trámites');
    _lastTramitesLoadTime = null; // Invalidar caché
    return loadHistorialTramites(placa);
  }

  Future<dynamic> _loadMultas(String placa) async {
    try {
      final response = await _apiService.get(
        _apiService.getVehicleFinesEndpoint(placa),
        token: _authContext.token,
      );
      _multas = response;
      return response;
    } catch (e) {
      if (e.toString().contains('La página no respondió a tiempo')) {
        print('Timeout al cargar multas');
        _multas = {'message': 'Servicio no disponible temporalmente'};
        return null;
      }
      print('Error cargando multas: $e');
      _multas = null;
      return e;
    }
  }

  Future<dynamic> _loadAccidentes(String placa) async {
    try {
      final response = await _apiService.get(
        _apiService.getVehicleAccidentsEndpoint(placa),
        token: _authContext.token,
      );
      print('\n🔎 [Accidentes] RESPUESTA DEL ENDPOINT:');
      print(response);
      _accidentes = response;
      return response;
    } catch (e) {
      print('Error cargando accidentes: $e');
      _accidentes = null;
      return e;
    }
  }

  Future<dynamic> _loadNovedadesTraspaso(String placa) async {
    try {
      final response = await _apiService.get(
        _apiService.getVehicleTransferHistoryEndpoint(placa),
        token: _authContext.token,
      );
      _novedadesTraspaso = response;
      return response;
    } catch (e) {
      print('Error cargando novedades de traspaso: $e');
      _novedadesTraspaso = null;
      return e;
    }
  }

  Future<dynamic> _loadMedidasCautelares(String placa) async {
    try {
      final endpoint =
          _apiService.getVehiclePrecautionaryMeasuresEndpoint(placa);
      final response = await _apiService.get(
        endpoint,
        token: _authContext.token,
      );
      print('\n🔎 [Medidas Cautelares] RESPUESTA: $response');
      _medidasCautelares = response;
      return response;
    } catch (e) {
      print('Error cargando medidas cautelares: $e');
      _medidasCautelares = null;
      return e;
    }
  }

  // Métodos para transformar los datos a la estructura esperada
  List<Map<String, dynamic>> getAccidentesFormateados() {
    if (_accidentes == null) return [];

    final accidents = _accidentes!['accidents'];
    return [
      {
        'label': 'Total de accidentes',
        'value': accidents['totalAccidents'].toString()
      },
      {
        'label': 'Ciudad de último accidente',
        'value': accidents['cityLastAccident']
      },
      {
        'label': 'Indicador de accidentalidad',
        'value': '${accidents['accidentIndicator']}%'
      },
      {
        'label': 'Días desde último accidente',
        'value': accidents['daysSinceLastAccident'].toString()
      },
    ];
  }

  List<Map<String, dynamic>> getNovedadesFormateadas() {
    if (_novedadesTraspaso == null) return [];

    final transfer = _novedadesTraspaso!['transferHistory'];
    return [
      {'label': 'Prenda', 'value': transfer['pledge']},
      { 'label': 'Medidas cautelares', 'value': transfer['precautionaryMeasures'] },
      {'label': 'SOAT vigente', 'value': transfer['soatActive']},
      {'label': 'RTM', 'value': transfer['rtmStatus']},
    ];
  }

  List<Map<String, dynamic>> getMedidasFormateadas() {
    if (_medidasCautelares == null) return [];

    final measures = _medidasCautelares!['precautionaryMeasures'];
    if (measures == null) return [];

    // Imprimimos los valores para depuración
    print('\n🔍 Valores de medidas cautelares:');
    measures.forEach((key, value) {
      print('$key: $value (${value?.runtimeType})');
    });

    try {

      bool customParse(dynamic value) {
        if (value is String && value == 'No disponible') return true;
        if (value is bool) return value;
        return false; // fallback para valores nulos o inesperados
      }

      return [
        {'label': 'Embargo', 'value': customParse(measures['embargo'])},
        {'label': 'Decomiso', 'value': customParse(measures['impound'])},
        {'label': 'Secuestro', 'value': customParse(measures['kidnapping'])},
        {
          'label': 'Denuncio por robo',
          'value': customParse(measures['reportedTheft'])
        },
        {
          'label': 'Accidente con muerto',
          'value': customParse(measures['fatalAccident'])
        },
        // {'label': 'Traspaso abierto', 'value': customParse(measures['openTransfer'])},
      ];
    } catch (e) {
      print('\n❌ Error formateando medidas cautelares: $e');
      return [];
    }
  }

  void reset() {
    if (!isLoading) {
      // Resetear datos
      _historialTramites = null;
      _multas = null;
      _accidentes = null;
      _novedadesTraspaso = null;
      _medidasCautelares = null;

      // Resetear estados de carga
      _isLoadingTramites = false;
      _isLoadingMultas = false;
      _isLoadingAccidentes = false;
      _isLoadingNovedades = false;
      _isLoadingMedidas = false;

      // Resetear errores
      _errorTramites = null;
      _errorMultas = null;
      _errorAccidentes = null;
      _errorNovedades = null;
      _errorMedidas = null;

      _placa = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
