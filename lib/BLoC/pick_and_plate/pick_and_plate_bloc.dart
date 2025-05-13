import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/API.dart';
import '../auth/auth_context.dart';

class PeakPlateBloc extends ChangeNotifier {
  // Estado
  bool _isLoading = false;
  String? _error;
  dynamic _alertId;
  int? _cityId;
  
  // Datos de pico y placa
  List<Map<String, dynamic>> _cities = [];
  Map<String, dynamic>? _selectedCity;
  String? _plate;
  Map<String, dynamic>? _peakPlateData;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  dynamic get alertId => _alertId;
  int? get cityId => _cityId;
  List<Map<String, dynamic>> get cities => _cities;
  Map<String, dynamic>? get selectedCity => _selectedCity;
  String? get plate => _plate;
  Map<String, dynamic>? get peakPlateData => _peakPlateData;
  bool get canDrive {
    print('\n🚦 PEAK_PLATE_BLOC: canDrive - Verificando si puede circular hoy');
    if (_peakPlateData == null) {
      print('\n🚦 PEAK_PLATE_BLOC: canDrive - No hay datos de pico y placa');
      return true; // Por defecto, si no hay datos, asumimos que se puede circular
    }
    
    // Verificar si existe el campo canDrive directo
    if (_peakPlateData!.containsKey('canDrive')) {
      final result = _peakPlateData!['canDrive'] == true;
      print('\n🚦 PEAK_PLATE_BLOC: canDrive - Campo canDrive encontrado: $result');
      return result;
    }
    
    // Si no existe canDrive, verificar las restricciones diarias para hoy
    final today = DateTime.now();
    return canDriveOnDate(today);
  }
  String? get restrictionTime => _peakPlateData != null ? _peakPlateData!['restrictionTime']?.toString() : 'no disponible';
  
  // Constructor
  PeakPlateBloc() {
    print('\n🚦 PEAK_PLATE_BLOC: Inicializando bloc');
    print('\n🚦 PEAK_PLATE_BLOC: Fecha y hora de inicialización: ${DateTime.now()}');
  }
  
  // Cargar datos iniciales
  Future<void> loadAlertData(dynamic alertId) async {
    print('\n🚦 PEAK_PLATE_BLOC: loadAlertData - Iniciando con alertId: $alertId');
    _isLoading = true;
    _alertId = alertId;
    notifyListeners();
    
    try {
      // Cargar ciudades primero
      print('\n🚦 PEAK_PLATE_BLOC: loadAlertData - Cargando ciudades...');
      await loadCities();
      
      // Intentar obtener el ID de usuario y su ciudad desde AuthContext
      try {
        final authContext = AuthContext();
        final userId = authContext.userId;
        
        if (userId != null) {
          print('\n🚦 PEAK_PLATE_BLOC: loadAlertData - Obteniendo datos de usuario ID: $userId');
          
          // Obtener perfil del usuario para conseguir su cityId
          final apiService = APIService();
          final userResponse = await apiService.get(
            apiService.getUserProfileEndpoint(userId),
            token: authContext.token,
          );
          
          if (userResponse.containsKey('data') && 
              userResponse['data'] != null &&
              userResponse['data'] is Map<String, dynamic>) {
            final userData = userResponse['data'] as Map<String, dynamic>;
            
            // Verificar si el usuario tiene una ciudad asignada
            if (userData.containsKey('cityId') && userData['cityId'] != null) {
              final cityId = userData['cityId'];
              print('\n🚦 PEAK_PLATE_BLOC: loadAlertData - Ciudad del usuario encontrada: $cityId');
              
              print('\n🚦 PEAK_PLATE_BLOC: loadAlertData - Ciudad del usuario encontrada: $cityId');
              _cityId = cityId; // Guardar el cityId del usuario
              
              // Verificar si las ciudades ya están cargadas
              if (_cities.isNotEmpty) {
                // Buscar la ciudad en la lista de ciudades cargadas
                final city = _cities.firstWhere(
                  (city) => city['id'] == cityId,
                  orElse: () => <String, dynamic>{},
                );
                
                if (city.isNotEmpty) {
                  print('\n🚦 PEAK_PLATE_BLOC: loadAlertData - Estableciendo ciudad: ${city['cityName']}');
                  _selectedCity = city;
                  notifyListeners();
                  
                  // Si hay placa, cargar datos de pico y placa
                  if (_plate != null && _plate!.isNotEmpty) {
                    loadPeakPlateData();
                  }
                } else {
                  print('\n⚠️ PEAK_PLATE_BLOC: loadAlertData - Ciudad con ID $cityId no encontrada en la lista actual');
                  // Cargar más ciudades para intentar encontrar la del usuario
                  _loadMoreCities();
                }
              } else {
                print('\n⚠️ PEAK_PLATE_BLOC: loadAlertData - No hay ciudades cargadas aún, se intentará establecer la ciudad después');
              }
            }
          }
        }
      } catch (e) {
        print('\n⚠️ PEAK_PLATE_BLOC: loadAlertData - Error al obtener datos del usuario: $e');
        // No establecemos _error aquí para no interrumpir el flujo principal
      }
      
      // Obtener datos de la alerta para conseguir la placa
      final apiService = APIService();
      final authContext = AuthContext();
      final response = await apiService.get(
        apiService.getSpecialAlertEndpoint(alertId),
        token: authContext.token,
      );
      
      print('\n🚦 PEAK_PLATE_BLOC: loadAlertData - Respuesta de alerta recibida');
      
      // Verificar si hay datos de placa
      if (response.containsKey('data') &&
          response['data'] != null &&
          response['data'] is Map<String, dynamic>) {
        final alertData = response['data'] as Map<String, dynamic>;

        // Verificar si hay una placa en la alerta
        if (alertData.containsKey('plate') && alertData['plate'] != null) {
          final plate = alertData['plate'].toString();
          print('\n🚦 PEAK_PLATE_BLOC: loadAlertData - Placa encontrada: $plate');
          _plate = plate;
          notifyListeners();
        }
      }
      
      // Si tenemos placa y ciudad, cargar datos de pico y placa
      if (_selectedCity != null && _plate != null && _plate!.isNotEmpty) {
        await loadPeakPlateData();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('\n❌ PEAK_PLATE_BLOC: loadAlertData - Error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Cargar más ciudades (página 2 en adelante)
  Future<void> _loadMoreCities() async {
    try {
      print('\n🚦 PEAK_PLATE_BLOC: _loadMoreCities - Cargando más ciudades');
      final apiService = APIService();
      
      // Parámetros para cargar la página 2
      final queryParams = {
        'page': '2',
        'take': '100',
        'skip': '10',
        'order': 'ASC',
        'search': '',
      };
      
      // Construir URL con parámetros
      final uri = Uri.parse('${APIService.baseUrl}${apiService.callCitysEndpoint}');
      final urlWithParams = uri.replace(queryParameters: queryParams);
      
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      final response = await http.get(
        urlWithParams,
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> ciudadesJson = jsonResponse['data'];
          
          // Convertir cada ciudad a un Map<String, dynamic>
          final List<Map<String, dynamic>> nuevasCiudades = ciudadesJson
              .map((ciudad) => {
                    'id': ciudad['id'],
                    'cityName': ciudad['cityName'],
                  })
              .toList();
          
          // Agregar las nuevas ciudades a la lista existente
          _cities.addAll(nuevasCiudades);
          print('\n🚦 PEAK_PLATE_BLOC: _loadMoreCities - ${nuevasCiudades.length} ciudades adicionales cargadas');
          print('\n🚦 PEAK_PLATE_BLOC: _loadMoreCities - Total de ciudades: ${_cities.length}');
          
          // Verificar si ahora podemos encontrar la ciudad del usuario
          if (_cityId != null) {
            final cityToSelect = _cities.firstWhere(
              (city) => city['id'] == _cityId,
              orElse: () => <String, dynamic>{},
            );
            
            if (cityToSelect.isNotEmpty) {
              print('\n🚦 PEAK_PLATE_BLOC: _loadMoreCities - Ciudad encontrada: ${cityToSelect['cityName']}');
              _selectedCity = cityToSelect;
              notifyListeners();
              
              // Si hay placa, cargar datos de pico y placa
              if (_plate != null && _plate!.isNotEmpty) {
                await loadPeakPlateData();
              }
            } else {
              print('\n⚠️ PEAK_PLATE_BLOC: _loadMoreCities - Ciudad con ID $_cityId no encontrada en ninguna página');
            }
          }
        }
      }
    } catch (e) {
      print('\n❌ PEAK_PLATE_BLOC: _loadMoreCities - Error: $e');
    }
  }
  

  
  // Cargar ciudades
  Future<void> loadCities() async {
    if (_isLoading) {
      print('\n⚠️ PEAK_PLATE_BLOC: loadCities - Ya hay una carga en progreso, se omite');
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('\n🚦 PEAK_PLATE_BLOC: loadCities - Iniciando carga de ciudades');
      final apiService = APIService();
      
      // Parámetros de paginación requeridos por el backend
      final queryParams = {
        'page': '1',
        'take': '100',
        'skip': '0',
        'order': 'ASC',
        'search': '',
      };
      
      // Construir URL con parámetros
      final uri = Uri.parse('${APIService.baseUrl}${apiService.callCitysEndpoint}');
      final urlWithParams = uri.replace(queryParameters: queryParams);
      
      print('\n🚦 PEAK_PLATE_BLOC: loadCities - URL de petición: $urlWithParams');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      print('\n🚦 PEAK_PLATE_BLOC: loadCities - Headers: $headers');
      print('\n🚦 PEAK_PLATE_BLOC: loadCities - Query params: $queryParams');
      
      print('\n🚦 PEAK_PLATE_BLOC: loadCities - Enviando petición GET...');
      final response = await http.get(
        urlWithParams,
        headers: headers,
      );
      
      print('\n🚦 PEAK_PLATE_BLOC: loadCities - Respuesta recibida con código: ${response.statusCode}');
      print('\n🚦 PEAK_PLATE_BLOC: loadCities - Cuerpo de la respuesta: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('\n🚦 PEAK_PLATE_BLOC: loadCities - Datos decodificados: $data');
        _cities = List<Map<String, dynamic>>.from(data['data']);
        print('\n🚦 PEAK_PLATE_BLOC: loadCities - Ciudades cargadas: ${_cities.length}');
        if (_cities.isNotEmpty) {
          print('\n🚦 PEAK_PLATE_BLOC: loadCities - Primera ciudad: ${_cities.first}');
        }
        
        // Si tenemos un cityId, seleccionamos la ciudad correspondiente
        if (_cityId != null) {
          _selectedCity = _cities.firstWhere(
            (city) => city['id'] == _cityId,
            orElse: () => _cities.isNotEmpty ? _cities.first : <String, dynamic>{},
          );
          
          if (_selectedCity != null) {
            print('\n🚦 PEAK_PLATE_BLOC: Ciudad preseleccionada: ${_selectedCity!['CityName']}');
          }
        }
      } else {
        _error = 'Error al cargar las ciudades: ${response.statusCode}';
        print('\n⚠️ PEAK_PLATE_BLOC: $_error');
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      print('\n⚠️ PEAK_PLATE_BLOC: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Seleccionar ciudad
  void selectCity(Map<String, dynamic> city) {
    _selectedCity = city;
    print('\n🚦 PEAK_PLATE_BLOC: Ciudad seleccionada: ${city['CityName']}');
    
    // Si tenemos una placa, cargamos los datos de pico y placa
    if (_plate != null && _plate!.isNotEmpty) {
      loadPeakPlateData();
    }
    
    notifyListeners();
  }
  
  // Alias para selectCity para mantener consistencia con la UI
  void setSelectedCity(Map<String, dynamic> city) {
    selectCity(city);
  }
  
  // Establecer placa
  void setPlate(String plate) {
    print('\n🚦 PEAK_PLATE_BLOC: setPlate - INICIANDO MÉTODO');
    print('\n🚦 PEAK_PLATE_BLOC: setPlate - Placa recibida: "$plate"');
    
    _plate = plate;
    print('\n🚦 PEAK_PLATE_BLOC: Placa establecida: $plate');
    
    // Si tenemos una ciudad seleccionada, cargamos los datos de pico y placa
    if (_selectedCity != null) {
      print('\n🚦 PEAK_PLATE_BLOC: setPlate - Ciudad seleccionada: $_selectedCity');
      print('\n🚦 PEAK_PLATE_BLOC: setPlate - Cargando datos de pico y placa...');
      // Forzar un pequeño retraso para asegurarnos de que la UI se actualice primero
      Future.delayed(Duration(milliseconds: 100), () {
        loadPeakPlateData();
      });
    } else {
      print('\n🚦 PEAK_PLATE_BLOC: setPlate - No hay ciudad seleccionada');
    }
    
    notifyListeners();
  }
  
  // Método para seleccionar una ciudad manualmente
  void setCity(Map<String, dynamic> city) {
    print('\n🚦 PEAK_PLATE_BLOC: setCity - INICIANDO MÉTODO');
    print('\n🚦 PEAK_PLATE_BLOC: setCity - Ciudad recibida: $city');
    print('\n🚦 PEAK_PLATE_BLOC: setCity - Tipo de ciudad: ${city.runtimeType}');
    print('\n🚦 PEAK_PLATE_BLOC: setCity - Claves disponibles: ${city.keys.toList()}');
    
    // Verificar si ya tenemos esta ciudad seleccionada para evitar bucles
    if (_selectedCity != null && _selectedCity!['id'] == city['id']) {
      print('\n🚦 PEAK_PLATE_BLOC: setCity - La ciudad ya está seleccionada, omitiendo');
      return;
    }
    
    // Si la ciudad tiene nombre 'Cargando...' y tenemos la lista de ciudades, intentar encontrar la ciudad real
    if ((city.containsKey('cityName') && city['cityName'] == 'Cargando...') && _cities.isNotEmpty) {
      print('\n🚦 PEAK_PLATE_BLOC: setCity - Buscando ciudad real por ID: ${city['id']}');
      
      try {
        final cityMatch = _cities.firstWhere(
          (c) => c['id'] == city['id'],
          orElse: () => city,
        );
        
        // Si encontramos una coincidencia con nombre real, usar esa ciudad
        if (cityMatch.containsKey('cityName') && cityMatch['cityName'] != 'Cargando...') {
          print('\n🚦 PEAK_PLATE_BLOC: setCity - Ciudad real encontrada: ${cityMatch['cityName']}');
          city = Map<String, dynamic>.from(cityMatch); // Usar una copia de la ciudad encontrada
        }
      } catch (e) {
        print('\n⚠️ PEAK_PLATE_BLOC: setCity - Error al buscar ciudad real: $e');
      }
    }
    
    // Verificar si contiene la clave cityName o CityName
    String? cityName;
    if (city.containsKey('cityName')) {
      cityName = city['cityName'].toString();
      print('\n🚦 PEAK_PLATE_BLOC: setCity - Usando clave "cityName": $cityName');
    } else if (city.containsKey('CityName')) {
      cityName = city['CityName'].toString();
      print('\n🚦 PEAK_PLATE_BLOC: setCity - Usando clave "CityName": $cityName');
    } else {
      // Buscar alguna clave que contenga 'city' o 'name'
      for (var key in city.keys) {
        if (key.toString().toLowerCase().contains('city') || key.toString().toLowerCase().contains('name')) {
          cityName = city[key].toString();
          print('\n🚦 PEAK_PLATE_BLOC: setCity - Usando clave alternativa "$key": $cityName');
          break;
        }
      }
    }
    
    print('\n🚦 PEAK_PLATE_BLOC: Seleccionando ciudad: ${cityName ?? 'Desconocida'}');
    
    // Guardar la ciudad anterior para verificar si realmente cambió
    final oldCityId = _cityId;
    
    // Actualizar la ciudad seleccionada
    _selectedCity = Map<String, dynamic>.from(city); // Crear una copia para evitar referencias compartidas
    _cityId = city['id'];
    
    // Notificar cambios antes de cargar datos adicionales
    notifyListeners();
    
    // Si la ciudad realmente cambió y tenemos una placa, cargamos los datos de pico y placa
    if (oldCityId != _cityId && _plate != null && _plate!.isNotEmpty) {
      print('\n🚦 PEAK_PLATE_BLOC: setCity - Ciudad cambió de $oldCityId a $_cityId, cargando datos de pico y placa...');
      // Usar un pequeño retraso para evitar múltiples llamadas simultáneas
      Future.delayed(Duration(milliseconds: 300), () {
        if (!_isLoading) { // Solo cargar si no hay otra carga en progreso
          loadPeakPlateData();
        }
      });
    } else if (_plate != null && _plate!.isNotEmpty) {
      print('\n🚦 PEAK_PLATE_BLOC: setCity - Hay placa pero la ciudad no cambió, evaluando si cargar datos...');
      // Si la ciudad no cambió pero tenemos placa y no hay datos cargados, cargar datos
      if (_peakPlateData == null) {
        print('\n🚦 PEAK_PLATE_BLOC: setCity - No hay datos de pico y placa, cargando...');
        Future.delayed(Duration(milliseconds: 300), () {
          if (!_isLoading) {
            loadPeakPlateData();
          }
        });
      }
    } else {
      print('\n🚦 PEAK_PLATE_BLOC: setCity - No hay placa establecida');
    }
  }
  
  // Método para establecer la ciudad directamente por ID
  Future<void> setCityId(int cityId) async {
    print('\n🚦 PEAK_PLATE_BLOC: setCityId - Estableciendo ciudad con ID: $cityId');
    
    // Verificar si la ciudad ya está seleccionada
    if (_selectedCity != null && _selectedCity!['id'] == cityId) {
      print('\n🚦 PEAK_PLATE_BLOC: setCityId - Ciudad ya seleccionada, no se hace nada');
      return;
    }
    
    // Si no tenemos ciudades cargadas, cargarlas primero
    if (_cities.isEmpty) {
      print('\n🚦 PEAK_PLATE_BLOC: setCityId - No hay ciudades cargadas, cargando primero...');
      await loadCities();
    }
    
    // Buscar la ciudad en la lista de ciudades disponibles
    Map<String, dynamic> cityMatch = {};
    if (_cities.isNotEmpty) {
      // Intentar encontrar la ciudad por ID
      try {
        cityMatch = _cities.firstWhere(
          (city) => city['id'] == cityId,
          orElse: () => <String, dynamic>{'id': cityId, 'cityName': 'Ciudad desconocida'},
        );
        print('\n🚦 PEAK_PLATE_BLOC: setCityId - Ciudad encontrada: ${cityMatch['cityName']}');
      } catch (e) {
        print('\n⚠️ PEAK_PLATE_BLOC: setCityId - Error al buscar ciudad: $e');
        cityMatch = {'id': cityId, 'cityName': 'Ciudad desconocida'};
      }
    } else {
      // Si no se pudieron cargar las ciudades, crear un objeto temporal
      cityMatch = {'id': cityId, 'cityName': 'Ciudad desconocida'};
      print('\n🚦 PEAK_PLATE_BLOC: setCityId - No se pudieron cargar las ciudades, usando objeto temporal');
    }
    
    // Crear una copia para evitar problemas de referencia
    final Map<String, dynamic> cityData = Map<String, dynamic>.from(cityMatch);
    
    // Usar el método setCity existente para mantener la consistencia
    // y asegurar que todas las validaciones y lógica se apliquen
    setCity(cityData);
    print('\n🚦 PEAK_PLATE_BLOC: setCityId - Ciudad establecida mediante setCity');
  }
  
  // Cargar datos de pico y placa
  Future<void> loadPeakPlateData() async {
    print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - INICIANDO MÉTODO');
    
    if (_isLoading) {
      print('\n⚠️ PEAK_PLATE_BLOC: loadPeakPlateData - Ya hay una carga en progreso, se omite');
      return;
    }
    
    if (_selectedCity == null) {
      print('\n⚠️ PEAK_PLATE_BLOC: loadPeakPlateData - No hay ciudad seleccionada');
      return;
    } else {
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Ciudad seleccionada: $_selectedCity');
    }
    
    if (_plate == null || _plate!.isEmpty) {
      print('\n⚠️ PEAK_PLATE_BLOC: loadPeakPlateData - No hay placa establecida');
      return;
    } else {
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Placa establecida: $_plate');
    }
    
    // Guardar los valores actuales para verificar si cambian durante la carga
    final currentCityId = _selectedCity!['id'];
    final currentPlate = _plate;
    
    _isLoading = true;
    _error = null;
    _peakPlateData = null;
    notifyListeners();
    
    try {
      // Verificar si la ciudad o placa han cambiado durante la carga
      if (_selectedCity == null || _selectedCity!['id'] != currentCityId || _plate != currentPlate) {
        print('\n⚠️ PEAK_PLATE_BLOC: loadPeakPlateData - La ciudad o placa cambiaron durante la carga, cancelando');
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Contenido de _selectedCity: $_selectedCity');
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Tipo de _selectedCity: ${_selectedCity.runtimeType}');
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Claves disponibles: ${_selectedCity!.keys.toList()}');
      
      // Intentar obtener el nombre de la ciudad (puede estar como 'cityName' o 'CityName')
      String? cityName;
      if (_selectedCity!.containsKey('cityName')) {
        cityName = _selectedCity!['cityName'].toString();
        print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Usando clave "cityName": $cityName');
      } else if (_selectedCity!.containsKey('CityName')) {
        cityName = _selectedCity!['CityName'].toString();
        print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Usando clave "CityName": $cityName');
      } else {
        print('\n⚠️ PEAK_PLATE_BLOC: loadPeakPlateData - No se encontró clave para el nombre de la ciudad');
        // Intentar usar la primera clave disponible que contenga la palabra "city" o "name"
        for (var key in _selectedCity!.keys) {
          if (key.toString().toLowerCase().contains('city') || key.toString().toLowerCase().contains('name')) {
            cityName = _selectedCity![key].toString();
            print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Usando clave alternativa "$key": $cityName');
            break;
          }
        }
      }
      
      // Si aún no tenemos nombre de ciudad o es 'Cargando...', intentar buscar la ciudad por ID en la lista de ciudades
      if ((cityName == null || cityName == 'Cargando...') && _cities.isNotEmpty) {
        try {
          print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Buscando ciudad por ID: ${_selectedCity!['id']} en ${_cities.length} ciudades');
          
          // Imprimir las ciudades disponibles para debug
          for (var i = 0; i < _cities.length && i < 5; i++) {
            print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Ciudad[$i]: ${_cities[i]}');
          }
          
          final cityMatch = _cities.firstWhere(
            (city) => city['id'] == _selectedCity!['id'],
            orElse: () => _cities.first,
          );
          
          // Actualizar el objeto _selectedCity completo para tener datos consistentes
          _selectedCity = Map<String, dynamic>.from(cityMatch);
          cityName = cityMatch['cityName'].toString();
          
          print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Ciudad encontrada por ID en lista: $cityName');
          print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - _selectedCity actualizado: $_selectedCity');
          
          // Notificar a los listeners del cambio en _selectedCity
          notifyListeners();
        } catch (e) {
          print('\n⚠️ PEAK_PLATE_BLOC: loadPeakPlateData - Error al buscar ciudad por ID: $e');
          if (_cities.isNotEmpty) {
            cityName = _cities.first['cityName'].toString();
            print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Usando primera ciudad disponible: $cityName');
          }
        }
      }
      
      // Si aún no tenemos nombre de ciudad, usar un valor predeterminado
      if (cityName == null || cityName.isEmpty) {
        cityName = 'bogota';
        print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Usando ciudad predeterminada: $cityName');
      }
      
      // Convertir el nombre de la ciudad a minúsculas y limpiar espacios
      cityName = cityName.toLowerCase().trim();
      // Reemplazar espacios por guiones para la URL
      cityName = cityName.replaceAll(' ', '-');
      // Limpiar la placa (quitar espacios y caracteres especiales)
      String cleanPlate = _plate!.trim().replaceAll(' ', '');
      
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Iniciando carga para ciudad: $cityName, placa: $cleanPlate');
      final apiService = APIService();
      
      // Construir URL con parámetros
      final endpoint = apiService.getPeakPlateEndpoint(cityName, cleanPlate);
      final url = '${APIService.baseUrl}$endpoint';
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Endpoint: $endpoint');
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - URL completa: $url');
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Consultando pico y placa para ciudad: $cityName (ID: ${_selectedCity!['id']}) y placa: $cleanPlate');
      
      // Obtener el token de autenticación desde AuthContext
      final authContext = AuthContext();
      final token = authContext.token;
      
      // Crear headers con el token
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      // Agregar el token si está disponible
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Headers: $headers');
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Token: ${token ?? 'No disponible'}');
      
      // Verificar de nuevo si la ciudad o placa han cambiado
      if (_selectedCity == null || _selectedCity!['id'] != currentCityId || _plate != currentPlate) {
        print('\n⚠️ PEAK_PLATE_BLOC: loadPeakPlateData - La ciudad o placa cambiaron antes de enviar la petición, cancelando');
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Enviando petición GET...');
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Respuesta recibida con código: ${response.statusCode}');
      print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Cuerpo de la respuesta: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Datos decodificados: $data');
        
        // Analizar la estructura de datos recibida
        print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Tipo de datos: ${data.runtimeType}');
        if (data is Map) {
          print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Claves disponibles: ${data.keys.toList()}');
          
          // Verificar si hay restricciones diarias
          if (data.containsKey('dailyRestrictions')) {
            final restrictions = data['dailyRestrictions'];
            print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Restricciones diarias: $restrictions');
          }
          
          // Verificar si hay restricciones semanales
          if (data.containsKey('weeklyRestrictions')) {
            final weeklyRestrictions = data['weeklyRestrictions'];
            print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Restricciones semanales: $weeklyRestrictions');
          }
          
          // Verificar si hay un campo canDrive directo
          if (data.containsKey('canDrive')) {
            print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Campo canDrive: ${data['canDrive']}');
          }
          
          // Verificar si hay campos para cada día de la semana
          final daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
          for (final day in daysOfWeek) {
            if (data.containsKey(day)) {
              print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Restricción para $day: ${data[day]}');
            }
          }
        }
        
        _peakPlateData = data;
        print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Datos guardados en _peakPlateData');
        
        // Verificar si puede circular hoy
        final today = DateTime.now();
        final canDriveToday = canDriveOnDate(today);
        print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Hoy es ${_getDayOfWeekName(today.weekday)}, día ${today.day}');
        print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - ¿Puede circular hoy? ${canDriveToday ? 'Sí' : 'No'}');
        print('\n🚦 PEAK_PLATE_BLOC: loadPeakPlateData - Valor del getter canDrive: ${canDrive ? 'Sí' : 'No'}');
      } else {
        _error = 'Error al cargar los datos de pico y placa: ${response.statusCode}';
        print('\n⚠️ PEAK_PLATE_BLOC: $_error');
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      print('\n⚠️ PEAK_PLATE_BLOC: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Verificar si se puede circular en una fecha específica
  bool canDriveOnDate(DateTime date) {
    print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - Verificando restricción para el día: ${date.day}');
    
    if (_peakPlateData == null) {
      print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - No hay datos de pico y placa');
      return true; // Por defecto, si no hay datos, asumimos que se puede circular
    }
    
    print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - Datos disponibles: $_peakPlateData');
    print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - Claves disponibles: ${_peakPlateData!.keys.toList()}');
    
    // Primero verificamos si hay un campo específico para el día de hoy
    final dayOfWeek = _getDayOfWeekName(date.weekday);
    if (_peakPlateData!.containsKey(dayOfWeek)) {
      final dayStatus = _peakPlateData![dayOfWeek];
      print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - Estado para $dayOfWeek: $dayStatus');
      
      // Si el valor es booleano, lo usamos directamente
      if (dayStatus is bool) {
        return dayStatus;
      }
      
      // Si es un mapa, buscamos un campo que indique el estado
      if (dayStatus is Map) {
        if (dayStatus.containsKey('status')) {
          return dayStatus['status'] == true;
        }
        if (dayStatus.containsKey('canDrive')) {
          return dayStatus['canDrive'] == true;
        }
        if (dayStatus.containsKey('restricted')) {
          return dayStatus['restricted'] != true; // Si está restringido, NO puede circular
        }
      }
    }
    
    // Verificar si hay un campo dailyRestrictions
    if (_peakPlateData!.containsKey('dailyRestrictions')) {
      final restrictions = _peakPlateData!['dailyRestrictions'] as List<dynamic>;
      print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - Total de restricciones diarias: ${restrictions.length}');
      
      // Buscar la restricción para el día específico
      try {
        final dayRestriction = restrictions.firstWhere(
          (restriction) => restriction['day'] == date.day,
          orElse: () => {'day': date.day, 'status': true}, // Por defecto, si no hay restricción, se puede circular
        );
        
        print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - Restricción para el día ${date.day}: $dayRestriction');
        
        // Si status es true, se puede circular; si es false, hay restricción
        if (dayRestriction.containsKey('status')) {
          final canDrive = dayRestriction['status'] == true;
          print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - ¿Puede circular el día ${date.day}? ${canDrive ? 'Sí' : 'No'}');
          return canDrive;
        }
        
        // Si hay un campo restricted, la lógica es inversa (true = no puede circular)
        if (dayRestriction.containsKey('restricted')) {
          final canDrive = dayRestriction['restricted'] != true;
          print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - ¿Puede circular el día ${date.day}? ${canDrive ? 'Sí' : 'No'}');
          return canDrive;
        }
      } catch (e) {
        print('\n⚠️ PEAK_PLATE_BLOC: canDriveOnDate - Error al procesar restricciones: $e');
      }
    }
    
    // Verificar si hay un campo weeklyRestrictions
    if (_peakPlateData!.containsKey('weeklyRestrictions')) {
      final weeklyRestrictions = _peakPlateData!['weeklyRestrictions'];
      print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - Restricciones semanales: $weeklyRestrictions');
      
      if (weeklyRestrictions is Map && weeklyRestrictions.containsKey(dayOfWeek)) {
        final dayStatus = weeklyRestrictions[dayOfWeek];
        if (dayStatus is bool) {
          return dayStatus;
        }
        if (dayStatus is Map) {
          if (dayStatus.containsKey('status')) {
            return dayStatus['status'] == true;
          }
          if (dayStatus.containsKey('canDrive')) {
            return dayStatus['canDrive'] == true;
          }
          if (dayStatus.containsKey('restricted')) {
            return dayStatus['restricted'] != true; // Si está restringido, NO puede circular
          }
        }
      }
    }
    
    // Si llegamos aquí, no encontramos información específica para este día
    print('\n🚦 PEAK_PLATE_BLOC: canDriveOnDate - No se encontró información específica para el día ${date.day}');
    return true; // Por defecto, asumimos que se puede circular
  }
  
  // Obtener el nombre del día de la semana
  String _getDayOfWeekName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return 'unknown';
    }
  }
  
  // Obtener el mes y año actuales de los datos de pico y placa
  Map<String, int> getCurrentPeriod() {
    if (_peakPlateData == null) {
      final now = DateTime.now();
      return {'year': now.year, 'month': now.month};
    }
    
    return {
      'year': _peakPlateData!['year'] ?? DateTime.now().year,
      'month': _peakPlateData!['month'] ?? DateTime.now().month,
    };
  }
  
  // Refrescar datos y actualizar perfil del usuario con la ciudad seleccionada
  Future<void> refresh() async {
    print('\n🚦 PEAK_PLATE_BLOC: refresh - Iniciando actualización');
    
    // Verificar si hay una ciudad seleccionada
    if (_selectedCity != null) {
      try {
        // Obtener el ID del usuario desde AuthContext
        final authContext = AuthContext();
        final userId = authContext.userId;
        
        if (userId != null) {
          print('\n🚦 PEAK_PLATE_BLOC: refresh - UserId: $userId');
          print('\n🚦 PEAK_PLATE_BLOC: refresh - Ciudad seleccionada: ${_selectedCity!['cityName']} (ID: ${_selectedCity!['id']})');
          
          // Crear el cuerpo de la solicitud con el ID de la ciudad
          final body = {
            'cityId': _selectedCity!['id'],
          };
          
          // Realizar la solicitud PATCH para actualizar el perfil del usuario
          final apiService = APIService();
          final response = await apiService.patch(
            apiService.updateUserProfileEndpoint(userId),
            body: body,
            token: authContext.token,
          );
          
          print('\n✅ PEAK_PLATE_BLOC: refresh - Perfil actualizado correctamente');
          print('\n📋 Respuesta: $response');
        } else {
          print('\n⚠️ PEAK_PLATE_BLOC: refresh - No se encontró el ID del usuario');
        }
      } catch (e) {
        print('\n❌ PEAK_PLATE_BLOC: refresh - Error al actualizar el perfil: $e');
        _error = e.toString();
        notifyListeners();
      }
    }
    
    // Continuar con la carga de datos de pico y placa
    if (_selectedCity != null && _plate != null && _plate!.isNotEmpty) {
      await loadPeakPlateData();
    } else {
      await loadCities();
    }
  }
  
  // Reiniciar el estado
  void reset() {
    _isLoading = false;
    _error = null;
    _alertId = null;
    _cityId = null;
    _cities = [];
    _selectedCity = null;
    _plate = null;
    _peakPlateData = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    print('\n🚦 PEAK_PLATE_BLOC: Dispose');
    super.dispose();
  }
}
