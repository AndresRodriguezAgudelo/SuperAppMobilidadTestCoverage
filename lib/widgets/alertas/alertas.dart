import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/screens/add_vehicle_screen.dart';
import 'package:Equirent_Mobility/screens/generic_alert_screen.dart';
import 'package:Equirent_Mobility/screens/home_screen.dart';
import 'package:Equirent_Mobility/widgets/loading_logo.dart';

import 'alert_card.dart';
import 'vehicle_selector_modal.dart';
import '../../screens/RTM_screen.dart';
import '../../screens/alerta_screen.dart';
import '../../screens/licencia_screen.dart';
import '../../screens/multas_screen.dart';
import '../../screens/pico_placa_screen.dart';
import '../../screens/SOAT_screen.dart';
import '../../screens/revision_frenos_screen.dart';
import '../../screens/extintor_screen.dart';
import '../../screens/kit_carretera_screen.dart';
import '../../screens/poliza_todo_riesgo_screen.dart';
import '../../screens/cambio_llantas_screen.dart';
import '../../screens/cambio_aceite_screen.dart';
import '../../BLoC/home/home_bloc.dart';
import '../../BLoC/alerts/alerts_bloc.dart';
import '../../BLoC/vehicles/vehicles_bloc.dart';
import '../../BLoC/auth/auth_context.dart';
import '../../BLoC/pick_and_plate/pick_and_plate_bloc.dart';
import '../../services/API.dart';

class Alertas extends StatefulWidget {
  const Alertas({super.key});

  @override
  State<Alertas> createState() => _AlertasState();
}

class _AlertasState extends State<Alertas> {
  bool _isLoadingAlert = false; // Estado para overlay de loading

  int? _lastVehicleId;

  bool _isExpanded = false;
  String _selectedPlate = '';
  bool _needsVehicleUpdate = true;
  List<Map<String, dynamic>> _lastKnownVehicles = [];

  @override
  void initState() {
    super.initState();
    
    // Forzar la actualización del vehículo seleccionado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('\n🔄 ALERTAS: Inicializando widget, actualizando vehículo seleccionado');
      _updateSelectedVehicle();
      
      // Forzar una segunda actualización después de un breve retraso
      // para asegurar que se carguen las alertas correctas
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          print('\n🔄 ALERTAS: Verificación secundaria de vehículo seleccionado');
          _updateSelectedVehicle();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final homeBloc = Provider.of<HomeBloc>(context, listen: true);
    
    // Verificar si la lista de vehículos ha cambiado
    final currentVehicles = homeBloc.cars;
    bool vehiclesChanged = _lastKnownVehicles.length != currentVehicles.length;
    
    if (!vehiclesChanged && currentVehicles.isNotEmpty) {
      // Verificar si algún vehículo cambió
      for (int i = 0; i < currentVehicles.length; i++) {
        if (i >= _lastKnownVehicles.length ||
            currentVehicles[i]['id'] != _lastKnownVehicles[i]['id']) {
          vehiclesChanged = true;
          break;
        }
      }
    }
    
    // También verificar si el primer vehículo cambió (como antes)
    final currentVehicle = currentVehicles.isNotEmpty ? currentVehicles[0] : null;
    final currentVehicleId = currentVehicle != null ? currentVehicle['id'] : null;
    
    // Si hubo algún cambio, actualizar el vehículo seleccionado
    if (vehiclesChanged || _lastVehicleId != currentVehicleId) {
      _lastVehicleId = currentVehicleId;
      _needsVehicleUpdate = true; // Forzar la actualización
      
      // Usar Future.microtask para evitar problemas durante el ciclo de construcción
      Future.microtask(() {
        if (mounted) {
          _updateSelectedVehicle();
        }
      });
    }
  }

  // Método para actualizar el vehículo seleccionado
  void _updateSelectedVehicle() {
    final homeBloc = Provider.of<HomeBloc>(context, listen: false);
    final currentVehicles = homeBloc.cars;
    final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
    
    print('\n🔄 ALERTAS: Actualizando vehículo seleccionado');
    print('- Placa actual en Alertas: $_selectedPlate');
    print('- Placa en HomeBloc: ${homeBloc.selectedPlate}');
    print('- Vehículos disponibles: ${currentVehicles.length}');
    
    // Actualizar la última lista conocida
    _lastKnownVehicles = List<Map<String, dynamic>>.from(currentVehicles);
    
    // Forzar la recarga de alertas si venimos de una actualización
    bool forceReload = false;
    
    // Si HomeBloc tiene una placa seleccionada, usarla
    if (homeBloc.selectedPlate.isNotEmpty) {
      // Verificar que la placa exista en los vehículos disponibles
      final plateExists = currentVehicles.any(
        (car) => car['licensePlate'] == homeBloc.selectedPlate
      );
      
      if (plateExists) {
        // Si la placa seleccionada es diferente a la actual, forzar recarga
        if (_selectedPlate != homeBloc.selectedPlate) {
          forceReload = true;
        }
        
        setState(() {
          _selectedPlate = homeBloc.selectedPlate;
          _needsVehicleUpdate = false;
        });
        print('\n🚗 ALERTAS: Usando placa de HomeBloc: $_selectedPlate');
        
        // Obtener el vehículo seleccionado
        final selectedVehicle = homeBloc.getSelectedVehicle();
        if (selectedVehicle != null && selectedVehicle is Map && selectedVehicle['id'] != null) {
          // Cargar alertas para este vehículo
          print('\n💾 ALERTAS: Cargando alertas para vehículo ID: ${selectedVehicle['id']}');
          
          // Forzar recarga de alertas
          if (forceReload) {
            print('\n🔄 ALERTAS: Forzando recarga de alertas');
            // Usar Future.microtask para evitar llamar a reset() durante el ciclo de construcción
            Future.microtask(() {
              alertsBloc.reset(); // Limpiar el estado actual
              alertsBloc.loadAlerts(selectedVehicle['id']);
            });
          } else {
            alertsBloc.loadAlerts(selectedVehicle['id']);
          }
        }
      } else if (currentVehicles.isNotEmpty) {
        // La placa seleccionada no existe, seleccionar la primera
        final firstPlate = currentVehicles.first['licensePlate'];
        setState(() {
          _selectedPlate = firstPlate;
          _needsVehicleUpdate = false;
        });
        print('\n🚗 ALERTAS: Placa no encontrada, seleccionando primera: $_selectedPlate');
        
        // Actualizar HomeBloc
        homeBloc.setSelectedPlate(firstPlate);
        
        // Cargar alertas para este vehículo
        print('\n💾 ALERTAS: Cargando alertas para vehículo ID: ${currentVehicles.first['id']}');
        alertsBloc.reset(); // Limpiar el estado actual
        alertsBloc.loadAlerts(currentVehicles.first['id']);
      }
    } 
    // Si no hay placa seleccionada en HomeBloc pero hay vehículos
    else if (currentVehicles.isNotEmpty) {
      final firstPlate = currentVehicles.first['licensePlate'];
      setState(() {
        _selectedPlate = firstPlate;
        _needsVehicleUpdate = false;
      });
      // Actualizar HomeBloc
      homeBloc.setSelectedPlate(firstPlate);
      print('\n🚗 ALERTAS: No hay placa en HomeBloc, seleccionando primera: $_selectedPlate');
      
      // Cargar alertas para este vehículo
      print('\n💾 ALERTAS: Cargando alertas para vehículo ID: ${currentVehicles.first['id']}');
      // Usar Future.microtask para evitar llamar a reset() durante el ciclo de construcción
      Future.microtask(() {
        alertsBloc.reset(); // Limpiar el estado actual
        alertsBloc.loadAlerts(currentVehicles.first['id']);
      });
    } else {
      setState(() {
        _selectedPlate = 'Sin vehículos';
        _needsVehicleUpdate = false;
      });
      print('\n⚠️ ALERTAS: No hay vehículos disponibles');
    }
  }

  // Método eliminado: _getScreenForNavigation ya no es necesario
  // La navegación ahora se maneja directamente en _handleAlertTap

  Future<void> _handleAlertTap(Map<String, dynamic> alert) async {
    print('\n💥💥💥 ALERTAS: Tap en alerta: $alert');
    print(
        'ID: ${alert['id']}, Tipo: ${alert['expirationType']}, Especial: ${alert['isSpecial']}');

    // Obtener el ID de la alerta o usar un valor predeterminado
    final dynamic alertId = alert['id'] ?? 1;
    final String expirationType = alert['expirationType'] ?? '';

    // Manejar el caso de Pico y Placa de forma especial ya que tiene un flujo diferente
    if (expirationType == 'Pico y placa') {
      // Obtener el AuthContext para acceder al userId
      final authContext = AuthContext();
      final userId = authContext.userId;
      int? userCityId;

      if (userId != null) {
        try {
          // Obtener el cityId directamente de la API
          final apiService = APIService();
          final endpoint = apiService.getUserProfileEndpoint(userId);
          final token = authContext.token;

          print(
              '\n🚦 ALERTAS: Obteniendo datos del usuario para cityId, userId: $userId');

          // Realizar la solicitud HTTP
          final response = await apiService.get(endpoint, token: token);

          // Verificar si la respuesta contiene cityId
          if (response.containsKey('cityId')) {
            userCityId = response['cityId'];
            print(
                '\n🚦 ALERTAS: cityId del usuario obtenido directamente de la API: $userCityId');
          } else if (response.containsKey('data') &&
              response['data'] is Map) {
            // A veces la respuesta viene dentro de un objeto 'data'
            final data = response['data'] as Map<String, dynamic>;
            if (data.containsKey('cityId')) {
              userCityId = data['cityId'];
              print(
                  '\n🚦 ALERTAS: cityId del usuario obtenido de data: $userCityId');
            }
          }
        } catch (e) {
          print('\n⚠️ ALERTAS: Error al obtener cityId del usuario: $e');
        }
      } else {
        print('\n⚠️ ALERTAS: No se pudo obtener el userId del usuario');
      }

      final bloc = PeakPlateBloc();
      setState(() {
        _isLoadingAlert = true;
      });
      if (userCityId != null) bloc.setCityId(userCityId);
      if (_selectedPlate.isNotEmpty) bloc.setPlate(_selectedPlate);
      await bloc.loadAlertData(alertId);
      await bloc.loadPeakPlateData();
      if (!mounted) return;
      setState(() {
        _isLoadingAlert = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => ChangeNotifierProvider.value(
            value: bloc,
            child: PicoPlacaScreen(
              alertId: alertId,
              plate: _selectedPlate,
              cityId: userCityId,
            ),
          ),
        ),
      );
      return; // Salir del método después de manejar Pico y Placa
    }
  
    // Para los demás casos, usar el enfoque original con screenWidget
    late Widget screenWidget;
  
    switch (expirationType) {
      case 'SOAT':
        print('\n🔵 ALERTAS: Navegando a SOATScreen con alertId: $alertId');
        screenWidget = SOATScreen(alertId: alertId);
        break;

      case 'RTM':
        print('\n🔵 ALERTAS: Navegando a RTMScreen con alertId: $alertId');
        screenWidget = RTMScreen(alertId: alertId);
        break;

      case 'Pico y placa':
        // Obtener el AuthContext para acceder al userId
        final authContext = AuthContext();
        final userId = authContext.userId;
        int? userCityId;

        if (userId != null) {
          try {
            // Obtener el cityId directamente de la API
            final apiService = APIService();
            final endpoint = apiService.getUserProfileEndpoint(userId);
            final token = authContext.token;

            print(
                '\n🚦 ALERTAS: Obteniendo datos del usuario para cityId, userId: $userId');

            // Realizar la solicitud HTTP
            final response = await apiService.get(endpoint, token: token);

            // Verificar si la respuesta contiene cityId
            if (response.containsKey('cityId')) {
              userCityId = response['cityId'];
              print(
                  '\n🚦 ALERTAS: cityId del usuario obtenido directamente de la API: $userCityId');
            } else if (response.containsKey('data') &&
                response['data'] is Map) {
              // A veces la respuesta viene dentro de un objeto 'data'
              final data = response['data'] as Map<String, dynamic>;
              if (data.containsKey('cityId')) {
                userCityId = data['cityId'];
                print(
                    '\n🚦 ALERTAS: cityId del usuario obtenido de data: $userCityId');
              }
            }
          } catch (e) {
            print('\n⚠️ ALERTAS: Error al obtener cityId del usuario: $e');
          }
        } else {
          print('\n⚠️ ALERTAS: No se pudo obtener el userId del usuario');
        }

        final bloc = PeakPlateBloc();
        setState(() {
          _isLoadingAlert = true;
        });
        if (userCityId != null) bloc.setCityId(userCityId);
        if (_selectedPlate.isNotEmpty) bloc.setPlate(_selectedPlate);
        await bloc.loadAlertData(alertId);
        await bloc.loadPeakPlateData();
        if (!mounted) return;
        setState(() {
          _isLoadingAlert = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ChangeNotifierProvider.value(
              value: bloc,
              child: PicoPlacaScreen(
                alertId: alertId,
                plate: _selectedPlate,
                cityId: userCityId,
              ),
            ),
          ),
        );
        break;

      case 'Multas':
        print(
            '\n💰 ALERTAS: Navegando a MultasScreen con placa: $_selectedPlate');
        screenWidget = MultasScreen(
          plate: _selectedPlate,
        );
        break;

      case 'Licencia de conducción':
        print('\n🪪 ALERTAS: Navegando a LicenciaScreen');
        screenWidget = const LicenciaScreen();
        break;

      case 'Revisión de frenos':
        print(
            '\n🛑 ALERTAS: Navegando a RevisionFrenosScreen con alertId: $alertId');
        screenWidget = RevisionFrenosScreen(alertId: alertId);
        // Navegar a la pantalla y manejar el resultado
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenWidget),
        );
        
        // Procesar el resultado cuando regresa
        if (result != null && result is Map<String, dynamic> && result['success'] == true) {
          print('\n✅ ALERTAS: Regresó de RevisionFrenosScreen con éxito');
          print('Vehículo ID: ${result['vehicleId']}, Placa: ${result['licensePlate']}');
          
          // Actualizar la placa seleccionada en HomeBloc
          final homeBloc = Provider.of<HomeBloc>(context, listen: false);
          if (result['licensePlate'] != null) {
            homeBloc.setSelectedPlate(result['licensePlate']);
            setState(() {
              _selectedPlate = result['licensePlate'];
              _needsVehicleUpdate = true; // Forzar actualización de vehículo
            });
            
            // Actualizar las alertas para este vehículo
            if (result['vehicleId'] != null) {
              final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
              print('\n🔄 ALERTAS: Actualizando alertas para vehículo ID: ${result['vehicleId']}');
              alertsBloc.reset();
              alertsBloc.loadAlerts(result['vehicleId']);
            }
          }
        }
        return; // Salir del método ya que la navegación ya se manejó

      case 'Extintor':
        print('\n🧯 ALERTAS: Navegando a ExtintorScreen con alertId: $alertId');
        screenWidget = ExtintorScreen(alertId: alertId);
        // Navegar a la pantalla y manejar el resultado
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenWidget),
        );
        
        // Procesar el resultado cuando regresa
        if (result != null && result is Map<String, dynamic> && result['success'] == true) {
          print('\n✅ ALERTAS: Regresó de ExtintorScreen con éxito');
          print('Vehículo ID: ${result['vehicleId']}, Placa: ${result['licensePlate']}');
          
          // Actualizar la placa seleccionada en HomeBloc
          final homeBloc = Provider.of<HomeBloc>(context, listen: false);
          if (result['licensePlate'] != null) {
            homeBloc.setSelectedPlate(result['licensePlate']);
            setState(() {
              _selectedPlate = result['licensePlate'];
              _needsVehicleUpdate = true; // Forzar actualización de vehículo
            });
            
            // Actualizar las alertas para este vehículo
            if (result['vehicleId'] != null) {
              final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
              print('\n🔄 ALERTAS: Actualizando alertas para vehículo ID: ${result['vehicleId']}');
              alertsBloc.reset();
              alertsBloc.loadAlerts(result['vehicleId']);
            }
          }
        }
        return; // Salir del método ya que la navegación ya se manejó

      case 'Kit de carretera':
        print(
            '\n🧰 ALERTAS: Navegando a KitCarreteraScreen con alertId: $alertId');
        screenWidget = KitCarreteraScreen(alertId: alertId);
        // Navegar a la pantalla y manejar el resultado
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenWidget),
        );
        
        // Procesar el resultado cuando regresa
        if (result != null && result is Map<String, dynamic> && result['success'] == true) {
          print('\n✅ ALERTAS: Regresó de KitCarreteraScreen con éxito');
          print('Vehículo ID: ${result['vehicleId']}, Placa: ${result['licensePlate']}');
          
          // Actualizar la placa seleccionada en HomeBloc
          final homeBloc = Provider.of<HomeBloc>(context, listen: false);
          if (result['licensePlate'] != null) {
            homeBloc.setSelectedPlate(result['licensePlate']);
            setState(() {
              _selectedPlate = result['licensePlate'];
              _needsVehicleUpdate = true; // Forzar actualización de vehículo
            });
            
            // Actualizar las alertas para este vehículo
            if (result['vehicleId'] != null) {
              final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
              print('\n🔄 ALERTAS: Actualizando alertas para vehículo ID: ${result['vehicleId']}');
              alertsBloc.reset();
              alertsBloc.loadAlerts(result['vehicleId']);
            }
          }
        }
        return; // Salir del método ya que la navegación ya se manejó

      case 'Póliza todo riesgo':
        print(
            '\n📋 ALERTAS: Navegando a PolizaTodoRiesgoScreen con alertId: $alertId');
        screenWidget = PolizaTodoRiesgoScreen(alertId: alertId);
        // Navegar a la pantalla y manejar el resultado
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenWidget),
        );
        
        // Procesar el resultado cuando regresa
        if (result != null && result is Map<String, dynamic> && result['success'] == true) {
          print('\n✅ ALERTAS: Regresó de PolizaTodoRiesgoScreen con éxito');
          print('Vehículo ID: ${result['vehicleId']}, Placa: ${result['licensePlate']}');
          
          // Actualizar la placa seleccionada en HomeBloc
          final homeBloc = Provider.of<HomeBloc>(context, listen: false);
          if (result['licensePlate'] != null) {
            homeBloc.setSelectedPlate(result['licensePlate']);
            setState(() {
              _selectedPlate = result['licensePlate'];
              _needsVehicleUpdate = true; // Forzar actualización de vehículo
            });
            
            // Actualizar las alertas para este vehículo
            if (result['vehicleId'] != null) {
              final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
              print('\n🔄 ALERTAS: Actualizando alertas para vehículo ID: ${result['vehicleId']}');
              alertsBloc.reset();
              alertsBloc.loadAlerts(result['vehicleId']);
            }
          }
        }
        return; // Salir del método ya que la navegación ya se manejó

      case 'Cambio de llantas':
        print(
            '\n🗡 ALERTAS: Navegando a CambioLlantasScreen con alertId: $alertId');
        screenWidget = CambioLlantasScreen(alertId: alertId);
        // Navegar a la pantalla y manejar el resultado
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenWidget),
        );
        
        // Procesar el resultado cuando regresa
        if (result != null && result is Map<String, dynamic> && result['success'] == true) {
          print('\n✅ ALERTAS: Regresó de CambioLlantasScreen con éxito');
          print('Vehículo ID: ${result['vehicleId']}, Placa: ${result['licensePlate']}');
          
          // Actualizar la placa seleccionada en HomeBloc
          final homeBloc = Provider.of<HomeBloc>(context, listen: false);
          if (result['licensePlate'] != null) {
            homeBloc.setSelectedPlate(result['licensePlate']);
            setState(() {
              _selectedPlate = result['licensePlate'];
              _needsVehicleUpdate = true; // Forzar actualización de vehículo
            });
            
            // Actualizar las alertas para este vehículo
            if (result['vehicleId'] != null) {
              final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
              print('\n🔄 ALERTAS: Actualizando alertas para vehículo ID: ${result['vehicleId']}');
              alertsBloc.reset();
              alertsBloc.loadAlerts(result['vehicleId']);
            }
          }
        }
        return; // Salir del método ya que la navegación ya se manejó

      case 'Cambio de aceite':
        print(
            '\n🛢️ ALERTAS: Navegando a CambioAceiteScreen con alertId: $alertId');
        screenWidget = CambioAceiteScreen(alertId: alertId);
        // Navegar a la pantalla y manejar el resultado
        final aceiteResult = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenWidget),
        );
        
        // Procesar el resultado cuando regresa
        if (aceiteResult != null && aceiteResult is Map<String, dynamic> && aceiteResult['success'] == true) {
          print('\n✅ ALERTAS: Regresó de CambioAceiteScreen con éxito');
          print('Vehículo ID: ${aceiteResult['vehicleId']}, Placa: ${aceiteResult['licensePlate']}');
          
          // Actualizar la placa seleccionada en HomeBloc
          final homeBloc = Provider.of<HomeBloc>(context, listen: false);
          if (aceiteResult['licensePlate'] != null) {
            homeBloc.setSelectedPlate(aceiteResult['licensePlate']);
            setState(() {
              _selectedPlate = aceiteResult['licensePlate'];
              _needsVehicleUpdate = true; // Forzar actualización de vehículo
            });
            
            // Actualizar las alertas para este vehículo
            if (aceiteResult['vehicleId'] != null) {
              final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
              print('\n🔄 ALERTAS: Actualizando alertas para vehículo ID: ${aceiteResult['vehicleId']}');
              alertsBloc.reset();
              alertsBloc.loadAlerts(aceiteResult['vehicleId']);
            }
          }
        }
        return; // Salir del método ya que la navegación ya se manejó

      default:
        // Para cualquier otro tipo de alerta, usar la pantalla genérica
        print(
            '\n🔔 ALERTAS: Navegando a AlertaScreen para tipo: $expirationType');
        print('🆔 ID de alerta: $alertId');
        print('📝 Tipo: ${alert['title']}');
        print('📅 Fecha: ${alert['fecha']}');

        screenWidget = GenericAlertScreen(
          alertId: alertId,
        );
        break;
    }

    // Como screenWidget es 'late', siempre estará inicializado en este punto
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screenWidget),
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      print(
          '\n🔽 EXPANSIÓN CAMBIADA: ${_isExpanded ? "EXPANDIDO" : "COLAPSADO"}');
    });
  }

  Future<void> _showVehicleSelector(HomeBloc homeBloc, VehiclesBloc vehiclesBloc) async {
    final result = await VehicleSelectorModal.show(
      context: context,
      plates: homeBloc.cars.map((v) => v['licensePlate'].toString()).toList(),
      selectedPlate: _selectedPlate,
      onPlateSelected: (plate) {
        print('\n🚗 ALERTAS: Seleccionando nuevo vehículo');
        print('- Placa seleccionada: $plate');

        Map<String, dynamic>? selectedCar;
        try {
          selectedCar = homeBloc.cars.firstWhere(
            (car) => car['licensePlate'] == plate,
          );
        } catch (e) {
          // Si no se encuentra, selectedCar será null
          print('\n⚠️ ALERTAS: No se encontró vehículo con placa: $plate');
        }

        if (selectedCar != null) {
          print('\n🚗 ALERTAS: Vehículo encontrado: $selectedCar');
          
          // Actualizar la placa seleccionada en el widget y en HomeBloc
          setState(() {
            _selectedPlate = plate;
          });
          
          // Actualizar la placa seleccionada en HomeBloc
          homeBloc.setSelectedPlate(plate);
          print('\n🚗 ALERTAS: Placa actualizada en HomeBloc: ${homeBloc.selectedPlate}');

          // Obtenemos el ID del vehículo seleccionado
          final vehicleId = selectedCar['id'];
          print('\n💾 ALERTAS: Obteniendo detalles del vehículo $vehicleId');
          vehiclesBloc.getVehicleDetail(vehicleId).then((_) {
            // Una vez obtenidos los detalles, cargar las alertas
            print('\n💾 ALERTAS: Cargando alertas para el vehículo $vehicleId');
            Provider.of<AlertsBloc>(context, listen: false)
                .loadAlerts(vehicleId);
          });
        }
      },
      onNewPlateAdded: (plate) {
        setState(() {
          _selectedPlate = plate;
        });
        // También actualizar en HomeBloc
        homeBloc.setSelectedPlate(plate);
      },
    );
    // Notificar al HomeScreen si el pop viene del modal
    if (result == '/select_plate' || result == '/add_vehicle') {
      // Buscar el HomeScreen en la jerarquía de widgets y setear la variable
      final homeScreenState = context.findAncestorStateOfType<HomeScreenState>();
      if (homeScreenState != null) {
        homeScreenState.lastPopSource = 'vehicle_selector';
      }
    }
  }

  Widget _buildOptionEmptyCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Widget screen,
    String? subtitle, // <-- nuevo parámetro opcional
  }) {
    return Container(
      height:
          subtitle != null ? 80 : 65, // un poco más de altura si hay subtítulo
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          child: Icon(
            icon,
            color: const Color(0xFF0E5D9E),
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Si estamos en el home, usar pushReplacement para forzar la recarga
          if (ModalRoute.of(context)?.settings.name == '/') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer3<VehiclesBloc, HomeBloc, AlertsBloc>(
          builder: (context, vehiclesBloc, homeBloc, alertsBloc, child) {
            print('\nDEBUG: Construyendo widget Alertas');
            
            // Siempre verificar si la placa seleccionada en HomeBloc coincide con la del widget
            if (homeBloc.selectedPlate != _selectedPlate || _needsVehicleUpdate) {
              print('\n🔄 ALERTAS: Detectado cambio de placa seleccionada');
              print('- Placa en HomeBloc: ${homeBloc.selectedPlate}');
              print('- Placa actual en Alertas: $_selectedPlate');
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _updateSelectedVehicle();
                }
              });
            }

            // Habilitar la actualización para el próximo ciclo si la lista de vehículos cambió
            if (_lastKnownVehicles.length != homeBloc.cars.length) {
              _needsVehicleUpdate = true;
            }
            print('DEBUG: Vehículos disponibles: ${homeBloc.cars}');
            print('DEBUG: Placa seleccionada: $_selectedPlate');

            final bool isLoading = vehiclesBloc.isLoading ||
                homeBloc.isLoading ||
                alertsBloc.isLoading;
            final List<dynamic> vehicles = homeBloc.cars;
            final List<Map<String, dynamic>> alertItems = alertsBloc.alerts;

            // Calcular cuántos items mostrar
            final int totalItems = alertItems.length + 1;
            // Si está expandido, mostrar todos. Si no, mostrar máximo 4 (2 filas de 2 items)
            final int itemsToShow =
                _isExpanded ? totalItems : math.min(4, totalItems);

            print('\n📊 ALERTAS DISPONIBLES: ${alertItems.length}');
            print('📊 TOTAL ITEMS (con botón agregar): $totalItems');
            print('📊 ITEMS A MOSTRAR: $itemsToShow');
            print('📊 ESTADO: ${_isExpanded ? "EXPANDIDO" : "COLAPSADO"}');

            // Si hay vehículos y no hay placa seleccionada, seleccionar el primero y cargar alertas
            if (vehicles.isNotEmpty && _selectedPlate.isEmpty) {
              print('DEBUG: Seleccionando primer vehículo automáticamente');
              final selectedCar = vehicles.first;
              print('DEBUG: Vehículo seleccionado: $selectedCar');

              // Usar Future.microtask para evitar setState durante el build
              Future.microtask(() {
                setState(() {
                  _selectedPlate = selectedCar['licensePlate'];
                });
                print('DEBUG: Nueva placa seleccionada: $_selectedPlate');

                // Primero obtener detalles del vehículo
                print(
                    'DEBUG: Obteniendo detalles del vehículo ${selectedCar['id']}');
                vehiclesBloc.getVehicleDetail(selectedCar['id']).then((_) {
                  // Una vez obtenidos los detalles, cargar las alertas
                  print(
                      'DEBUG: Cargando alertas para el vehículo ${selectedCar['id']}');
                  alertsBloc.loadAlerts(selectedCar['id']);
                });
              });
            }

            // Verificar estados de carga específicos
            final bool isLoadingVehicles = homeBloc.isLoading && homeBloc.cars.isEmpty;
            final bool isLoadingAlerts = alertsBloc.isLoading && alertsBloc.alerts.isEmpty;
            final bool isLoadingVehicleDetails = vehiclesBloc.isLoading && vehiclesBloc.currentVehicle == null;
            final bool shouldShowLoading = isLoadingVehicles || isLoadingAlerts || isLoadingVehicleDetails;
            
            print('\n🔄 ESTADO DE CARGA:');
            print('- Vehículos cargando: $isLoadingVehicles (homeBloc.isLoading: ${homeBloc.isLoading})');
            print('- Alertas cargando: $isLoadingAlerts (alertsBloc.isLoading: ${alertsBloc.isLoading})');
            print('- Detalles de vehículo cargando: $isLoadingVehicleDetails (vehiclesBloc.isLoading: ${vehiclesBloc.isLoading})');
            print('- Mostrar pantalla de carga: $shouldShowLoading');

            return Container(
              padding: const EdgeInsets.all(16),
              child: shouldShowLoading
                  ? const Center(child: LoadingLogo(size: 100))
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Alertas',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _showVehicleSelector(homeBloc, vehiclesBloc),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0E5D9E),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      vehicles.isEmpty
                                          ? 'Sin vehículos'
                                          : _selectedPlate,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 255, 255, 255),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down,
                                        color: Color.fromARGB(255, 255, 255, 255)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Si no hay vehículos, usamos una altura fija más pequeña para el contenedor
                        vehicles.isEmpty && !isLoadingVehicles
                            ? SizedBox(
                                height: 120, // Altura reducida para el caso vacío
                                child: _buildOptionEmptyCard(
                                  context: context,
                                  icon: Icons.directions_car,
                                  label: 'Agregar un vehiculo',
                                  subtitle:
                                      'Registra un vehículo para gestionar tus alertas',
                                  screen: const AgregarVehiculoScreen(),
                                ),
                              )
                            : AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                child: GridView.builder(
                                  key: ValueKey(_isExpanded),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 1.88,
                                  ),
                                  itemCount: itemsToShow,
                                  itemBuilder: (context, index) {
                                    // Si es el último ítem y estamos mostrando el botón de agregar
                                    if (index == itemsToShow - 1 &&
                                        itemsToShow > alertItems.length) {
                                      return AlertCard(
                                        isNew: true,
                                        title: '',
                                        status: '',
                                        progress: 0,
                                        onTap: () {
                                          final homeBloc = Provider.of<HomeBloc>(
                                              context,
                                              listen: false);
                                          Map<String, dynamic>? selectedCar;
                                          try {
                                            selectedCar = homeBloc.cars.firstWhere(
                                              (car) => car['licensePlate'] == _selectedPlate,
                                            );
                                          } catch (e) {
                                            // Si no se encuentra, selectedCar será null
                                            print('\n⚠️ ALERTAS: No se encontró vehículo con placa: $_selectedPlate');
                                          }
                                          final selectedVehicleId =
                                              selectedCar != null
                                                  ? selectedCar['id']
                                                  : null;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AlertaScreen(
                                                  vehicleId: selectedVehicleId),
                                            ),
                                          );
                                        },
                                      );
                                    }

                                    // Verificar que el índice sea válido antes de acceder a alertItems
                                    if (index >= alertItems.length) {
                                      // Si el índice está fuera de rango, mostrar una tarjeta vacía o de error
                                      return const SizedBox(); // O puedes retornar una tarjeta de error
                                    }

                                    final alert = alertItems[index];
                                    print(
                                        '\n📌 ALERTA[$index]: ${alert['title']} - Estado: ${alert['status']} - ID: ${alert['id']}');
                                    // Convertir la fecha de String a DateTime si existe, o null si no existe
                                    DateTime? fechaDateTime;
                                    if (alert['fecha'] != null &&
                                        alert['fecha'].toString().isNotEmpty) {
                                      try {
                                        // Intentar parsear la fecha - asumiendo formato ISO
                                        fechaDateTime = DateTime.parse(
                                            alert['fecha'].toString());
                                      } catch (e) {
                                        // Si hay error al parsear, dejar como null
                                        print(
                                            'Error al parsear fecha: ${alert['fecha']}');
                                        fechaDateTime = null;
                                      }
                                    }

                                    return AlertCard(
                                      isNew: false,
                                      title: alert['title'] ?? '',
                                      status: alert['status'] ??
                                          'Configurar', // Usar el status original del backend
                                      progress:
                                          (alert['percentage'] ?? 0).toDouble(),
                                      iconName: alert['icon'] ??
                                          '', // Pasamos el nombre del icono desde los datos de la alerta
                                      id: alert['id'] ??
                                          0, // Pasar el ID de la alerta
                                      isSpecial: alert['isSpecial'] ??
                                          false, // Pasar si es especial
                                      fecha:
                                          fechaDateTime, // Pasar la fecha como DateTime o null
                                      onTap: () => _handleAlertTap(alert),
                                    );
                                  },
                                ),
                              ),
                        if (vehicles.isNotEmpty && alertItems.length > 3)
                          TextButton(
                            onPressed: _toggleExpansion,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //Text(
                                //  _isExpanded ? 'Ver menos' : 'Ver más',
                                //  style: const TextStyle(color: Color(0xFF38A8E0), fontWeight: FontWeight.w500),
                                //),
                                //const SizedBox(width: 4),
                                Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 28,
                                    color: const Color(0xFF38A8E0)),
                              ],
                            ),
                          ),
                      ],
                    ),
              );
          },
        ),
        if (_isLoadingAlert)
          Container(
            color: Colors.white.withOpacity(0.85),
            child: const Center(
              child: LoadingLogo(size: 80),
            ),
          ),
      ],
    );
  }
}

