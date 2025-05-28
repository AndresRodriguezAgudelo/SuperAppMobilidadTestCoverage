import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/widgets/inputs/input_text.dart';
import '../widgets/inputs/input_date.dart';
import '../widgets/button.dart';
import '../widgets/top_bar.dart';
import '../widgets/alertas/recordatorios_adicionales.dart';
import '../BLoC/special_alerts/special_alerts_bloc.dart';
import '../BLoC/alerts/alerts_bloc.dart';
import '../BLoC/home/home_bloc.dart';
import '../widgets/confirmation_modales.dart';
import '../widgets/modales.dart';
import '../widgets/loading.dart';
import '../utils/error_utils.dart';

class GenericAlertScreen extends StatefulWidget {
  final int alertId; // ID de la alerta para actualizaciones

  const GenericAlertScreen({
    super.key,
    required this.alertId,
  });

  @override
  State<GenericAlertScreen> createState() => _GenericAlertScreenState();
}

class _GenericAlertScreenState extends State<GenericAlertScreen> {
  String? nombreVencimiento; // Almacena el valor original del backend
  String? nuevoNombreAlerta; // Almacena el nuevo valor ingresado por el usuario
  DateTime? fechaVencimiento;
  bool isValidNombre =
      true; // Siempre es válido porque el nombre está predefinido
  List<Map<String, dynamic>> selectedReminders = [];
  bool isLoading = false;
  String? errorMessage;
  late final SpecialAlertsBloc _alertsBloc;

  bool get isFormValid {
    return fechaVencimiento != null;
  }

  @override
  void initState() {
    super.initState();
    _alertsBloc = SpecialAlertsBloc();
    // Cargar los detalles después de que el widget se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlertDetails();
    });
  }

  @override
  void dispose() {
    // No llamamos a dispose() en _alertsBloc porque es un singleton
    // Solo limpiamos los datos para que no interfieran con futuras instancias
    _alertsBloc.reset();
    super.dispose();
  }

  Future<void> _loadAlertDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Cargar los detalles de la alerta especial usando el SpecialAlertsBloc
      print(
          '\n🔥 GENERIC_ALERT_SCREEN: Iniciando carga de alerta ID: ${widget.alertId}');

      // Limpiar los datos anteriores para forzar una recarga completa
      _alertsBloc.reset();

      // Cargar los datos de la alerta
      await _alertsBloc.loadSpecialAlert(widget.alertId);

      // Verificar si los datos se cargaron correctamente
      if (_alertsBloc.alertData != null) {
        print('\n🔥 GENERIC_ALERT_SCREEN: Datos cargados correctamente');
        print('Claves disponibles: ${_alertsBloc.alertData!.keys.toList()}');
        _alertsBloc.alertData!.forEach((key, value) {
          print('$key: $value');
        });

        // Actualizar nombreVencimiento con el valor de expirationType si existe y si nombreVencimiento aún no ha sido inicializado
        if (_alertsBloc.alertData!.containsKey('expirationType') &&
            _alertsBloc.alertData!['expirationType'] != null) {
          final expirationTypeValue = _alertsBloc.alertData!['expirationType'];
          print(
              '\n🔥 GENERIC_ALERT_SCREEN: Valor de expirationType encontrado: $expirationTypeValue');

          // Solo actualizar nombreVencimiento si es null o si es la carga inicial
          if (nombreVencimiento == null) {
            setState(() {
              nombreVencimiento = expirationTypeValue;
              // Inicializar también nuevoNombreAlerta con el mismo valor
              nuevoNombreAlerta = expirationTypeValue;
            });
            print(
                '\n🔥 GENERIC_ALERT_SCREEN: Nombre de vencimiento inicializado a: $nombreVencimiento');
            print(
                '\n🔥 GENERIC_ALERT_SCREEN: Nuevo nombre de alerta inicializado a: $nuevoNombreAlerta');
          } else {
            setState(() {
              // Asegurarse de que nuevoNombreAlerta tenga el valor actual si no ha sido modificado
              nuevoNombreAlerta ??= nombreVencimiento;
            });
            print(
                '\n🔥 GENERIC_ALERT_SCREEN: Nombre de vencimiento ya existe: $nombreVencimiento, no se sobrescribe');
          }
        } else {
          print(
              '\n🔥 GENERIC_ALERT_SCREEN: No se encontró la clave expirationType en los datos');
        }
      } else {
        print('\n🔥 GENERIC_ALERT_SCREEN: No se pudieron cargar los datos');
        if (_alertsBloc.error != null) {
          print('Error: ${_alertsBloc.error}');
        }
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('\n🔥 GENERIC_ALERT_SCREEN: Error al cargar los detalles: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar los detalles: $e';
          isLoading = false;
        });
      }
    }
  }

  // Función para eliminar la alerta de vencimiento
  Future<void> _deleteAlert() async {
    if (!isFormValid) return;

    // Mostrar diálogo de confirmación antes de eliminar usando CustomModal
    bool confirmDelete = false;

    // Mostrar el diálogo de confirmación
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomModal(
          icon: Icons.info_outline,
          iconColor: Color.fromARGB(255, 255, 255, 255),
          title: '¿Estás seguro de que deseas eliminar este vencimiento?',
          content: 'Esta acción no se puede deshacer',
          buttonText: 'Confirmar',
          secondButtonText: 'Cancelar',
          secondButtonColor: const Color.fromARGB(255, 255, 255, 255),
          labelSecondButtonColor: Color(0xFF2FA8E0),
          onSecondButtonPressed: () {
            Navigator.of(context).pop();
          },
          onButtonPressed: () {
            confirmDelete = true;
            Navigator.of(context).pop();
          },
        );
      },
    );

    // Si el usuario cancela la eliminación, no hacer nada
    if (!confirmDelete) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print(
          '\n🗑️ GENERIC_ALERT_SCREEN: Eliminando alerta con ID: ${widget.alertId}');

      // Usar el método deleteSpecialAlert del SpecialAlertsBloc
      final success = await _alertsBloc.deleteSpecialAlert(widget.alertId);

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        if (success) {
          // Mostrar modal de confirmación
          showConfirmationModal(
            context,
            attitude: 1, // Positivo (éxito)
            label: 'Vencimiento eliminado correctamente',
          );

          // Forzar la actualización de las alertas antes de regresar
          try {
            final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
            final homeBloc = Provider.of<HomeBloc>(context, listen: false);

            if (homeBloc.cars.isNotEmpty) {
              // Obtener el vehículo seleccionado usando HomeBloc
              final selectedVehicle = homeBloc.getSelectedVehicle();
              final selectedCar = (selectedVehicle != null && selectedVehicle is Map && selectedVehicle['id'] != null) 
                  ? selectedVehicle 
                  : (homeBloc.cars.isNotEmpty ? homeBloc.cars.first : null);
              
              if (selectedCar == null || !selectedCar.containsKey('id')) {
                print('\n⚠️ GENERIC_ALERT_SCREEN: No se pudo obtener un vehículo válido');
                return;
              }
              
              final vehicleId = selectedCar["id"];
              
              print('\n🚗 GENERIC_ALERT_SCREEN: Usando vehículo seleccionado: ${selectedCar["licensePlate"]}');

              print(
                  '\n🔄 GENERIC_ALERT_SCREEN: Actualizando alertas para vehículo: ${selectedCar["licensePlate"]} (ID: $vehicleId)');

              if (vehicleId != null) {
                await alertsBloc.loadAlerts(vehicleId);
                print('✅ Alertas actualizadas correctamente');
              }
            }
          } catch (e) {
            print('\n⚠️ No se pudieron actualizar las alertas: $e');
          }

          // Navegar al home y recargar las alertas
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              // Navegar al home (pop hasta la raíz)
              Navigator.pop(context, true);

              // Recargar las alertas en el home
              try {
                final homeBloc = Provider.of<HomeBloc>(context, listen: false);
                final alertsBloc =
                    Provider.of<AlertsBloc>(context, listen: false);

                if (homeBloc.cars.isNotEmpty) {
                  // Obtener el vehículo seleccionado usando HomeBloc
                  final selectedVehicle = homeBloc.getSelectedVehicle();
                  final selectedCar = (selectedVehicle != null && selectedVehicle is Map && selectedVehicle['id'] != null) 
                      ? selectedVehicle 
                      : (homeBloc.cars.isNotEmpty ? homeBloc.cars.first : null);
                  
                  if (selectedCar == null || !selectedCar.containsKey('id') || !selectedCar.containsKey('licensePlate')) {
                    print('\n⚠️ GENERIC_ALERT_SCREEN: No se pudo obtener un vehículo válido');
                    return;
                  }
                  
                  print('\n🚗 GENERIC_ALERT: Usando vehículo seleccionado: ${selectedCar["licensePlate"]}');
                  final vehicleId = selectedCar["id"];

                  if (vehicleId != null) {
                    // Forzar recarga de alertas en el home
                    alertsBloc.loadAlerts(vehicleId);
                    print(
                        '\n🔄 HOME: Recargando alertas después de eliminar vencimiento');
                  }
                }
              } catch (e) {
                print('\n⚠️ Error al recargar alertas en el home: $e');
              }
            }
          });
          Navigator.pop(context, true);
        } else {
          // Mostrar mensaje de error con mensaje limpio
          showConfirmationModal(
            context,
            attitude: 0, // Negativo (error)
            label:
                'No se pudo eliminar el vencimiento: ${ErrorUtils.cleanErrorMessage(_alertsBloc.error ?? 'Intenta nuevamente')}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Mostrar mensaje de error con mensaje limpio
        showConfirmationModal(
          context,
          attitude: 0, // Negativo (error)
          label: 'Error al eliminar el vencimiento: ${ErrorUtils.cleanErrorMessage(e)}',
        );
      }
    }
  }

  Future<void> _saveAlert() async {
    if (!isFormValid) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Determinar qué nombre de alerta usar: el nuevo si existe, o el original como respaldo
      String nombreAlertaFinal;
      if (nuevoNombreAlerta != null && nuevoNombreAlerta!.trim().isNotEmpty) {
        // Usar el nuevo nombre ingresado por el usuario
        nombreAlertaFinal = nuevoNombreAlerta!;
        print(
            '\n💾 GENERIC_ALERT_SCREEN: Usando el nuevo nombre ingresado por el usuario: "$nombreAlertaFinal"');
      } else if (nombreVencimiento != null &&
          nombreVencimiento!.trim().isNotEmpty) {
        // Usar el nombre original si no hay uno nuevo
        nombreAlertaFinal = nombreVencimiento!;
        print(
            '\n💾 GENERIC_ALERT_SCREEN: Usando el nombre original: "$nombreAlertaFinal"');
      } else {
        // Usar un valor predeterminado si ambos son nulos o vacíos
        nombreAlertaFinal = 'Alerta Personalizada';
        print(
            '\n⚠️ GENERIC_ALERT_SCREEN: Ambos nombres son nulos o vacíos, usando valor predeterminado: "$nombreAlertaFinal"');
      }

      print(
          '\n💾 GENERIC_ALERT_SCREEN: Nombre de alerta a guardar: "$nombreAlertaFinal"');

      // Preparar el cuerpo de la solicitud con los recordatorios en el formato correcto
      final Map<String, dynamic> body = {
        'expirationType': nombreAlertaFinal,
        'expirationDate': fechaVencimiento?.toIso8601String(),
        'reminders':
            selectedReminders, // Ya está en el formato correcto: [{days: 1}, {days: 7}, etc]
      };

      print('\n💾 GENERIC_ALERT_SCREEN: Guardando alerta con datos:');
      print('ID: ${widget.alertId}');
      print('Datos: $body');
      print('Es alerta especial: true');

      // Usar el método updateSpecialAlert del SpecialAlertsBloc para alertas especiales
      // Usar la instancia local en lugar de obtenerla a través de Provider
      // Enviar los datos básicos y los recordatorios
      final success = await _alertsBloc.updateSpecialAlert(
        widget.alertId,
        nombreAlertaFinal, // Usar el nombre final determinado anteriormente
        fechaVencimiento,
        reminders: selectedReminders,
      );

      // Recargar los datos de la alerta para actualizar el estado en la TopBar
      if (success) {
        print(
            '\n🔄 GENERIC_ALERT_SCREEN: Recargando datos de la alerta después de guardar');

        // Forzar una recarga completa de la alerta para actualizar el estado
        _alertsBloc.reset();
        await _alertsBloc.loadSpecialAlert(widget.alertId);

        // Forzar una actualización de la UI
        if (mounted) {
          setState(() {
            // Solo actualizar el estado de carga
            isLoading = false;
          });
        }
      }

      if (mounted) {
        if (success) {
          // Primero mostrar el modal de confirmación
          showConfirmationModal(
            context,
            attitude: 1, // Positivo (éxito)
            label: 'Alerta personalizada actualizada correctamente',
          );

          // Forzar la actualización de las alertas antes de regresar
          try {
            final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
            // Obtener el ID del vehículo actual
            final homeBloc = Provider.of<HomeBloc>(context, listen: false);
            if (homeBloc.cars.isNotEmpty) {
              // Obtener el vehículo seleccionado usando HomeBloc
              final selectedVehicle = homeBloc.getSelectedVehicle();
              final selectedCar = (selectedVehicle != null && selectedVehicle is Map && selectedVehicle['id'] != null) 
                  ? selectedVehicle 
                  : (homeBloc.cars.isNotEmpty ? homeBloc.cars.first : null);
              
              if (selectedCar == null || !selectedCar.containsKey('id')) {
                print('\n⚠️ GENERIC_ALERT_SCREEN: No se pudo obtener un vehículo válido');
                return;
              }
              
              final vehicleId = selectedCar["id"];
              
              print('\n🚗 GENERIC_ALERT_SCREEN: Usando vehículo seleccionado: ${selectedCar["licensePlate"]}');

              print(
                  '\n🔄 GENERIC_ALERT_SCREEN: Actualizando alertas para vehículo: ${selectedCar["licensePlate"]} (ID: $vehicleId)');

              // Asegurarse de que el ID del vehículo es válido
              if (vehicleId != null) {
                // Actualizar las alertas
                await alertsBloc.loadAlerts(vehicleId);
                print('✅ Alertas actualizadas correctamente');
              } else {
                print('\n⚠️ ID de vehículo no válido');
              }
            } else {
              print('\n⚠️ No hay vehículos disponibles');
            }
          } catch (e) {
            print('\n⚠️ No se pudieron actualizar las alertas: $e');
          }

          // Esperar un momento antes de navegar para que el modal sea visible
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              // Navegar de regreso al home
              Navigator.of(context).pop(true); // Regresar con resultado exitoso
            }
          });
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            isLoading = false;
          });

          // Mostrar mensaje de error con ConfirmationModal y limpiar el mensaje
          showConfirmationModal(
            context,
            attitude: 0, // Negativo (error)
            label:
                'No se pudo actualizar la alerta: ${ErrorUtils.cleanErrorMessage(_alertsBloc.error ?? 'Intenta nuevamente')}',
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Mostrar mensaje de error con ConfirmationModal y limpiar el mensaje
      if (mounted) {
        showConfirmationModal(
          context,
          attitude: 0, // Negativo (error)
          label: 'Error al guardar: ${ErrorUtils.cleanErrorMessage(e)}',
        );
      }
    }
  }

  Widget _buildInfoContainer({
    required String title,
    required String content,
    required IconData icon,
    Color backgroundColor = const Color(0xFFE8F7FC),
    Color iconBackgroundColor = const Color(0xFF0E5D9E),
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el vehículo actual igual que en alertas.dart
    final homeBloc = Provider.of<HomeBloc>(context, listen: false);
    final currentVehicle = homeBloc.cars.isNotEmpty ? homeBloc.cars[0] : null;
    final currentVehicleId = currentVehicle != null ? currentVehicle['id'] : null;
    
    print('\n🚗 GENERIC_ALERT_SCREEN: Vehículo actual: $currentVehicle');
    print('🆔 GENERIC_ALERT_SCREEN: ID del vehículo actual: $currentVehicleId');

    return Loading(
      isLoading: isLoading,
      child: Stack(
        children: [
          ChangeNotifierProvider.value(
            value: _alertsBloc,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Consumer<SpecialAlertsBloc>(
                builder: (context, alertsBloc, _) {
                  // Obtener el estado del extintor directamente de la propiedad 'estado'
                  String? status;
                  String expirationType =
                      'Alerta Personalizada'; // Valor predeterminado

                  if (alertsBloc.alertData != null) {
                    // Imprimir todas las claves disponibles para depuración
                    print(
                        '\n🔥 GENERIC_ALERT_SCREEN: Claves disponibles en alertData: ${alertsBloc.alertData!.keys.toList()}');

                    // Usar directamente la propiedad 'estado' que viene del backend
                    if (alertsBloc.alertData!.containsKey('estado')) {
                      status = alertsBloc.alertData!['estado'];
                      print(
                          '\n🔥 GENERIC_ALERT_SCREEN: Estado encontrado en "estado": $status');
                    }

                    if (alertsBloc.alertData!.containsKey('expirationType')) {
                      expirationType = alertsBloc.alertData!['expirationType'];
                      // Solo asignar el valor del backend a nombreVencimiento si aún no se ha inicializado
                      nombreVencimiento ??= expirationType;
                      print(
                          '\n🔥 GENERIC_ALERT_SCREEN: Tipo de expiración encontrado: $expirationType');
                      print(
                          '\n🔥 GENERIC_ALERT_SCREEN: Nombre de vencimiento actual: $nombreVencimiento');
                    }

                    // Si aún no encontramos el estado, intentar inferirlo de otros campos
                    if (status == null) {
                      print(
                          '\n🔥 GENERIC_ALERT_SCREEN: No se encontró estado explícito, intentando inferirlo...');

                      // Imprimir todos los valores para depuración
                      alertsBloc.alertData!.forEach((key, value) {
                        print('\n🔥 GENERIC_ALERT_SCREEN: $key: $value');
                      });

                      // Intentar inferir el estado a partir de la fecha de vencimiento
                      if (alertsBloc.alertData!.containsKey('expirationDate') &&
                          alertsBloc.alertData!['expirationDate'] != null) {
                        try {
                          final expirationDate = DateTime.parse(
                              alertsBloc.alertData!['expirationDate']);
                          final now = DateTime.now();
                          final difference =
                              expirationDate.difference(now).inDays;

                          print(
                              '\n🔥 GENERIC_ALERT_SCREEN: Fecha de vencimiento: $expirationDate, diferencia en días: $difference');

                          if (difference < 0) {
                            status = 'Vencido';
                          } else if (difference < 30) {
                            status = 'Por vencer';
                          } else {
                            status = 'Vigente';
                          }

                          print(
                              '\n🔥 GENERIC_ALERT_SCREEN: Estado inferido a partir de la fecha: $status');
                        } catch (e) {
                          print(
                              '\n🔥 GENERIC_ALERT_SCREEN: Error al inferir estado: $e');
                        }
                      } else {
                        print(
                            '\n🔥 GENERIC_ALERT_SCREEN: No se encontró fecha de vencimiento para inferir estado');
                      }
                    }

                    // Si después de todo no tenemos un estado, usar un valor por defecto
                    if (status == null) {
                      if (fechaVencimiento != null) {
                        // Inferir a partir de la fecha local
                        final now = DateTime.now();
                        final difference =
                            fechaVencimiento!.difference(now).inDays;

                        if (difference < 0) {
                          status = 'Vencido';
                        } else if (difference < 30) {
                          status = 'Por vencer';
                        } else {
                          status = 'Vigente';
                        }

                        print(
                            '\n🔥 GENERIC_ALERT_SCREEN: Estado inferido a partir de la fecha local: $status');
                      } else {
                        // Valor por defecto si no hay información
                        status = 'Configurar';
                        print(
                            '\n🔥 GENERIC_ALERT_SCREEN: Usando estado por defecto: $status');
                      }
                    }
                  } else {
                    print(
                        '\n🔥 GENERIC_ALERT_SCREEN: No hay datos de alerta disponibles');
                    if (fechaVencimiento != null) {
                      // Inferir a partir de la fecha local si no hay datos de alerta
                      final now = DateTime.now();
                      final difference =
                          fechaVencimiento!.difference(now).inDays;

                      if (difference < 0) {
                        status = 'Vencido';
                      } else if (difference < 30) {
                        status = 'Por vencer';
                      } else {
                        status = 'Vigente';
                      }

                      print(
                          '\n🔥 GENERIC_ALERT_SCREEN: Estado inferido a partir de la fecha local (sin datos): $status');
                    }
                  }

                  // Determinar si mostrar el indicador y qué color usar
                  List<Widget> actionItems = [];

                  if (status != null &&
                      status != 'Configurar' &&
                      status != 'sinAsignar') {
                    // Determinar color y texto según el estado
                    Color bgColor;
                    String statusText = status;

                    switch (status) {
                      case 'Vencido':
                        bgColor = Colors.red;
                        break;
                      case 'Por vencer':
                        bgColor = const Color(0xFFF5A462); // Amarillo
                        break;
                      case 'Vigente':
                        bgColor = const Color(0xFF0B9E7C); // Verde
                        break;
                      default:
                        bgColor = Colors.grey;
                    }

                    actionItems.add(Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 24),
                        child: Center(
                          child: Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ));
                  }

                  return TopBar(
                    title: nombreVencimiento,
                    screenType: ScreenType.expirationScreen, // Cambiado a expirationScreen para siempre navegar al home
                    actionItems: actionItems,
                  );
                },
              ),
            ),
            body: SafeArea(
              child: Consumer<SpecialAlertsBloc>(
                builder: (context, bloc, _) {
                  // Actualizar variables locales con datos del bloc cuando estén disponibles
                  if (!bloc.isLoading && bloc.alertData != null) {
                    final alertData = bloc.alertData!;

                    // Actualizar la fecha de vencimiento si existe
                    if (alertData['expirationDate'] != null &&
                        fechaVencimiento == null) {
                      try {
                        fechaVencimiento =
                            DateTime.parse(alertData['expirationDate']);
                        nombreVencimiento = alertData['expirationType'];
                      } catch (e) {
                        print(
                            'Error al parsear la fecha: ${alertData['expirationDate']}');
                      }
                    }

// Actualizar nombreVencimiento y nuevoNombreAlerta sin setState (no se debe llamar setState durante build)
                    if (alertData['expirationType'] != null &&
                        nombreVencimiento != alertData['expirationType']) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          final backendValue = alertData['expirationType'];
                          // Solo actualizar nuevoNombreAlerta si el usuario no lo ha editado manualmente
                          if (nuevoNombreAlerta == null ||
                              nuevoNombreAlerta == '' ||
                              nuevoNombreAlerta == nombreVencimiento) {
                            nuevoNombreAlerta = backendValue;
                            print(
                                '\n🔥 GENERIC_ALERT_SCREEN: nuevoNombreAlerta inicializada desde backend: $nuevoNombreAlerta');
                          }
                          nombreVencimiento = backendValue;
                        });
                        print(
                            '\n🔥 GENERIC_ALERT_SCREEN: nombreVencimiento actualizado en el Consumer: $nombreVencimiento');
                      });
                    }

                    // Actualizar los recordatorios si existen
                    if (alertData['reminders'] != null &&
                        selectedReminders.isEmpty) {
                      selectedReminders = List<Map<String, dynamic>>.from(
                          alertData['reminders']);
                    }

                    // Actualizar el estado de carga fuera del build
                    if (isLoading) {
                      // Usar Future.microtask para programar la actualización del estado después del build
                      Future.microtask(() {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      });
                    }
                  }


                  if (bloc.isLoading ||
                      (nuevoNombreAlerta == null &&
                          nombreVencimiento == null)) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Mostrar la descripción de la alerta desde el bloc si está disponible
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: 'Configure esta alerta personalizada',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' con algún requisito que necesite renovar de forma periódica, nosotros le avisamos.',
                              style: const TextStyle(),
                            ),
                          ],
                        ),
                      ),


                              const SizedBox(height: 25),

                              // ignore: avoid_print

                              InputText(
                                label: 'Nombre de la alerta',
                                defaultValue:
                                    nuevoNombreAlerta ?? nombreVencimiento,
                                type: InputType.text,
                                onChanged: (value, isValid) {
                                  setState(() {
                                    nuevoNombreAlerta = value;
                                    print(
                                        '\n📝 GENERIC_ALERT_SCREEN: Nuevo nombre de alerta ingresado: "$value"');
                                  });
                                },
                              ),
                              const SizedBox(height: 24),

                              InputDate(
                                label: 'Fecha de vencimiento',
                                value: fechaVencimiento,
                                onChanged: (date) {
                                  setState(() {
                                    fechaVencimiento = date;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),

                              if (bloc.alertData != null &&
                                  bloc.alertData!['estado'] != 'Vencido' &&
                                  bloc.alertData!['estado'] !=
                                      'Configurar') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15),
                        child: Row(
                          children: const [
                            Icon(Icons.info, color: Color(0xFF38A8E0)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Te avisaremos un día antes y el día de vencimiento para que no se te pase.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                                const SizedBox(height: 25),
                              ],

                              if (bloc.alertData != null &&
                                  bloc.alertData!['estado'] == 'Vencido') ...[
                                SizedBox(
                                  child: _buildInfoContainer(
                                    title:
                                        'Registra la nueva información para seguir recibiendo alertas',
                                    content: '¿Actualizaste este ítem?',
                                    icon: Icons.error,
                                    backgroundColor: const Color(0xFFFADDD7),
                                    iconBackgroundColor:
                                        const Color(0xFFE05C3A),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              if (bloc.alertData != null &&
                                  bloc.alertData!['estado'] != 'Vencido' &&
                                  bloc.alertData!['estado'] !=
                                      'Configurar') ...[
                                const SizedBox(height: 1),
                                RecordatoriosAdicionales(
                                  selectedReminders: selectedReminders,
                                  onChanged: (reminders) {
                                    setState(() {
                                      selectedReminders = reminders;
                                    });
                                  },
                                ),
                              ],

                              // Mensaje de error si existe
                              if (errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    errorMessage!,
                                    style:
                                        TextStyle(color: Colors.red.shade800),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Botón de guardar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Button(
                          text: bloc.alertData != null &&
                                  bloc.alertData!['estado'] == 'Vencido'
                              ? 'Actualizar información'
                              : 'Guardar',
                          isLoading: isLoading,
                          action: isFormValid ? _saveAlert : null,
                        ),
                      ),

                      // Solo mostrar el botón de eliminar si el estado no es "Configurar"
                      if (bloc.alertData != null &&
                          bloc.alertData!['estado'] != 'Configurar')
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Button(
                            text: 'Eliminar vencimiento',
                            backgroundColor: Colors.white,
                            isLoading: isLoading,
                            action: isFormValid ? _deleteAlert : null,
                            textColor: Colors.red,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
  }
}
