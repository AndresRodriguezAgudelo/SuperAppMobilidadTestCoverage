import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/inputs/input_date.dart';
import '../widgets/button.dart';
import '../widgets/top_bar.dart';
import '../widgets/alertas/recordatorios_adicionales.dart';
import '../BLoC/special_alerts/special_alerts_bloc.dart';
import '../BLoC/alerts/alerts_bloc.dart';
import '../BLoC/home/home_bloc.dart';
import '../widgets/confirmation_modales.dart';
import '../widgets/loading.dart';

class ExtintorScreen extends StatefulWidget {
  final int alertId; // ID de la alerta para actualizaciones

  const ExtintorScreen({
    super.key,
    required this.alertId,
  });

  @override
  State<ExtintorScreen> createState() => _ExtintorScreenState();
}

class _ExtintorScreenState extends State<ExtintorScreen> {
  late String nombreVencimiento = 'Extintor';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlertDetails();
    });
  }

  @override
  void dispose() {
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
          '\n🔥 EXTINTOR_SCREEN: Iniciando carga de alerta ID: ${widget.alertId}');

      // Limpiar los datos anteriores para forzar una recarga completa
      _alertsBloc.reset();

      // Cargar los datos de la alerta
      await _alertsBloc.loadSpecialAlert(widget.alertId);

      // Verificar si los datos se cargaron correctamente
      if (_alertsBloc.alertData != null) {
        print('\n🔥 EXTINTOR_SCREEN: Datos cargados correctamente');
        print('Claves disponibles: ${_alertsBloc.alertData!.keys.toList()}');
        _alertsBloc.alertData!.forEach((key, value) {
          print('$key: $value');
        });
      } else {
        print('\n🔥 EXTINTOR_SCREEN: No se pudieron cargar los datos');
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
      print('\n🔥 EXTINTOR_SCREEN: Error al cargar los detalles: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar los detalles: $e';
          isLoading = false;
        });
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
      // Preparar el cuerpo de la solicitud con los recordatorios en el formato correcto
      final Map<String, dynamic> body = {
        'expirationType': nombreVencimiento,
        'expirationDate': fechaVencimiento?.toIso8601String(),
        'reminders':
            selectedReminders, // Ya está en el formato correcto: [{days: 1}, {days: 7}, etc]
      };
      final success = await _alertsBloc.updateSpecialAlert(
        widget.alertId,
        nombreVencimiento,
        fechaVencimiento,
        reminders: selectedReminders,
      );
      if (success) {
        print(
            '\n🔄 EXTINTOR_SCREEN: Recargando datos de la alerta después de guardar');

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
            label: 'Extintor actualizado correctamente',
          );

          // Variables para almacenar la información del vehículo
          dynamic vehicleId;
          Map<String, dynamic>? selectedCar;
          
          // Forzar la actualización de las alertas antes de regresar
          try {
            final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
            // Obtener el ID del vehículo actual
            final homeBloc = Provider.of<HomeBloc>(context, listen: false);
            if (homeBloc.cars.isNotEmpty) {
              // Buscar el vehículo seleccionado o usar el primero si no hay selección
              // Obtener el vehículo seleccionado usando HomeBloc
              final selectedVehicle = homeBloc.getSelectedVehicle();
              selectedCar = (selectedVehicle != null && selectedVehicle is Map && selectedVehicle['id'] != null) 
                  ? selectedVehicle as Map<String, dynamic>
                  : (homeBloc.cars.isNotEmpty ? homeBloc.cars.first : null);
              
              if (selectedCar == null || !selectedCar.containsKey('id') || !selectedCar.containsKey('licensePlate')) {
                print('\n⚠️ EXTINTOR: No se pudo obtener un vehículo válido');
                return;
              }
              
              print('\n🚗 EXTINTOR: Usando vehículo seleccionado: ${selectedCar["licensePlate"]}');
              vehicleId = selectedCar["id"];

              print(
                  '\n🔄 EXTINTOR_SCREEN: Actualizando alertas para vehículo: ${selectedCar["licensePlate"]} (ID: $vehicleId)');

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
              return; // Salir si no hay vehículos
            }
          } catch (e) {
            print('\n⚠️ No se pudieron actualizar las alertas: $e');
            return; // Salir en caso de error
          }

          // Esperar un momento antes de navegar para que el modal sea visible
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && selectedCar != null && vehicleId != null) {
              // Navegar de regreso al home con información del vehículo seleccionado
              Navigator.of(context).pop({
                'success': true,
                'vehicleId': vehicleId,
                'licensePlate': selectedCar["licensePlate"],
              }); // Regresar con resultado exitoso y datos del vehículo
            } else if (mounted) {
              // Si no tenemos datos del vehículo, regresar con éxito simple
              Navigator.of(context).pop(true);
            }
          });
          // No hacer pop inmediatamente para evitar doble navegación
          // Navigator.of(context).pop(true);
        } else {
          setState(() {
            isLoading = false;
          });

          // Mostrar mensaje de error con ConfirmationModal
          showConfirmationModal(
            context,
            attitude: 0, // Negativo (error)
            label:
                'No se pudo actualizar la alerta: ${_alertsBloc.error ?? 'Intenta nuevamente'}',
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Mostrar mensaje de error con ConfirmationModal
      if (mounted) {
        showConfirmationModal(
          context,
          attitude: 0, // Negativo (error)
          label: 'Error al guardar: $e',
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
    return Loading(
      isLoading: isLoading,
      child: ChangeNotifierProvider.value(
        value: _alertsBloc,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Consumer<SpecialAlertsBloc>(
              builder: (context, alertsBloc, _) {
                // Obtener el estado del extintor directamente de la propiedad 'estado'
                String? status;
                if (alertsBloc.alertData != null) {
                  // Imprimir todas las claves disponibles para depuración
                  print(
                      '\n🔥 EXTINTOR_SCREEN: Claves disponibles en alertData: ${alertsBloc.alertData!.keys.toList()}');

                  // Usar directamente la propiedad 'estado' que viene del backend
                  if (alertsBloc.alertData!.containsKey('estado')) {
                    status = alertsBloc.alertData!['estado'];
                    print(
                        '\n🔥 EXTINTOR_SCREEN: Estado encontrado en "estado": $status');
                  }

                    // Si aún no encontramos el estado, intentar inferirlo de otros campos
                    if (status == null) {
                      print(
                          '\n🔥 EXTINTOR_SCREEN: No se encontró estado explícito, intentando inferirlo...');

                      // Imprimir todos los valores para depuración
                      alertsBloc.alertData!.forEach((key, value) {
                        print('\n🔥 EXTINTOR_SCREEN: $key: $value');
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
                              '\n🔥 EXTINTOR_SCREEN: Fecha de vencimiento: $expirationDate, diferencia en días: $difference');

                          if (difference < 0) {
                            status = 'Vencido';
                          } else if (difference < 30) {
                            status = 'Por vencer';
                          } else {
                            status = 'Vigente';
                          }

                          print(
                              '\n🔥 EXTINTOR_SCREEN: Estado inferido a partir de la fecha: $status');
                        } catch (e) {
                          print(
                              '\n🔥 EXTINTOR_SCREEN: Error al inferir estado: $e');
                        }
                      } else {
                        print(
                            '\n🔥 EXTINTOR_SCREEN: No se encontró fecha de vencimiento para inferir estado');
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
                            '\n🔥 EXTINTOR_SCREEN: Estado inferido a partir de la fecha local: $status');
                      } else {
                        // Valor por defecto si no hay información
                        status = 'Configurar';
                        print(
                            '\n🔥 EXTINTOR_SCREEN: Usando estado por defecto: $status');
                      }
                    }
                  } else {
                    print(
                        '\n🔥 EXTINTOR_SCREEN: No hay datos de alerta disponibles');
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
                          '\n🔥 EXTINTOR_SCREEN: Estado inferido a partir de la fecha local (sin datos): $status');
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
                    title: 'Extintor',
                    screenType: ScreenType.progressScreen,
                    onBackPressed: () => Navigator.pop(context),
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
                      } catch (e) {
                        print(
                            'Error al parsear la fecha: ${alertData['expirationDate']}');
                      }
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

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Mostrar la descripción de la alerta desde el bloc si está disponible
                              Text(
                                bloc.alertData?['description'] ??
                                    'El extintor es un elemento de seguridad obligatorio en tu vehículo. Recuerda verificar su fecha de vencimiento y mantenerlo en buen estado.',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B7280),
                                ),
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
                                Row(
                                  children: [
                                    Container(
                                      width: 15,
                                      height: 15,
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF38A8E0),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        // Usamos Center para centrar el contenido
                                        child: Text(
                                          'i',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      // Este widget permite que el texto ocupe el espacio restante
                                      child: Text(
                                        'Te avisaremos un dia antes y el dia de vencimiento para que no se te pase.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF6B7280),
                                        ),
                                        softWrap:
                                            true, // El texto se ajusta automáticamente a varias líneas
                                      ),
                                    ),
                                  ],
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
                                  bloc.alertData!['estado'] != 'Configurar'
                                  ) ...[
                                const SizedBox(height: 8),
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
                    ],
                  );
                },
              ),
            ),
          ),
        ),


      );
  }
}
