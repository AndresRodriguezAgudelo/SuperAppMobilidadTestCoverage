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
import '../widgets/notification_card.dart';
import '../utils/error_utils.dart';

class CambioAceiteScreen extends StatefulWidget {
  final int alertId; // ID de la alerta para actualizaciones

  const CambioAceiteScreen({
    super.key,
    required this.alertId,
  });

  @override
  State<CambioAceiteScreen> createState() => _CambioAceiteScreenState();
}

class _CambioAceiteScreenState extends State<CambioAceiteScreen> {
  late String nombreVencimiento = 'Cambio de Aceite';
  DateTime? fechaVencimiento;
  DateTime? lastUpdateDate; // Fecha de último mantenimiento

  bool isValidNombre =
      true; // Siempre es válido porque el nombre está predefinido
  List<Map<String, dynamic>> selectedReminders = [];
  bool isLoading = false;
  String? errorMessage;
  late final SpecialAlertsBloc _alertsBloc;

  bool get isFormValid {
    return lastUpdateDate != null; // Usar lastUpdateDate en lugar de fechaVencimiento
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
      print('\n🔥 CAMBIO_ACEITE_SCREEN: Error al cargar los detalles: $e');
      if (mounted) {
        setState(() {
          // Limpiar el mensaje de error usando ErrorUtils
          final cleanedError = ErrorUtils.cleanErrorMessage(e);
          errorMessage = 'Error al cargar los detalles: $cleanedError';
          isLoading = false;
        });
        
        // Mostrar notificación al usuario
        NotificationCard.showNotification(
          context: context,
          isPositive: false,
          icon: Icons.error_outline,
          text: ErrorUtils.cleanErrorMessage(e),
          date: DateTime.now(),
          title: 'Error al cargar datos',
          duration: const Duration(seconds: 4),
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
      // Preparar el cuerpo de la solicitud con los recordatorios en el formato correcto
      // Usar lastUpdateDate para la fecha de último mantenimiento
      // Formatear la fecha correctamente para la API, asegurando que solo tenga una Z al final
      String? fechaISO;
      if (lastUpdateDate != null) {
        // Usar el operador ! para indicar que lastUpdateDate no es nulo en este punto
        String isoString = lastUpdateDate!.toIso8601String();
        // Verificar si ya termina en Z para no duplicarla
        fechaISO = isoString.endsWith('Z') ? isoString : "${isoString}Z";
        print('\n📅 CAMBIO_Aceite: Guardando fecha de último mantenimiento: $lastUpdateDate');
        print('\n📅 CAMBIO_Aceite: Fecha ISO formateada correctamente: $fechaISO');
      }
      
      final Map<String, dynamic> body = {
        'expirationType': nombreVencimiento,
        'lastMaintenanceDate': fechaISO,
        'reminders':
            selectedReminders, // Ya está en el formato correcto: [{days: 1}, {days: 7}, etc]
      };

      print('\n💾 EXTINTOR_SCREEN: Guardando alerta con datos:');
      print('ID: ${widget.alertId}');
      print('Datos a enviar en el PATCH: $body');
      print('Es alerta especial: true');

      // Usar el método updateSpecialAlert del SpecialAlertsBloc para alertas especiales
      // Usar la instancia local en lugar de obtenerla a través de Provider
      // Enviar los datos básicos y los recordatorios
      print('\n📅 CAMBIO_Aceite: Enviando fecha a updateSpecialAlertRevertCount: $lastUpdateDate');
      final success = await _alertsBloc.updateSpecialAlertRevertCount(
        widget.alertId,
        nombreVencimiento,
        lastUpdateDate, // Usar lastUpdateDate en lugar de fechaVencimiento
        reminders: selectedReminders,
      );

      // Recargar los datos de la alerta para actualizar el estado en la TopBar
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
            label: 'Cambio de Aceite actualizada correctamente',
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
                print('\n⚠️ CAMBIO_ACEITE: No se pudo obtener un vehículo válido');
                return;
              }
              
              print('\n🚗 CAMBIO_ACEITE: Usando vehículo seleccionado: ${selectedCar["licensePlate"]}');
              vehicleId = selectedCar["id"];

              print(
                  '\n🔄 CAMBIO_ACEITE_SCREEN: Actualizando alertas para vehículo: ${selectedCar["licensePlate"]} (ID: $vehicleId)');

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

  // Método para formatear fechas en formato legible
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      print('Error al formatear fecha: $e');
      return dateString; // Devolver la cadena original si hay un error
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

                    print(
                        '\n🔥 EXTINTOR_SCREEN: Claves disponibles en alertData ya con info: ${alertsBloc.alertData}');

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
                    title: 'Cambio de Aceite',
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


                    // Solo cargar la fecha de la API si no hay una fecha seleccionada por el usuario
                    if (alertData['lastMaintenanceDate'] != null && lastUpdateDate == null) {
                      try {
                        lastUpdateDate = DateTime.parse(alertData['lastMaintenanceDate']);
                        print('\n📅 CAMBIO_Aceite: Cargando fecha de último mantenimiento desde API: $lastUpdateDate');
                      } catch (e) {
                        print('\n❌ Error al parsear lastMaintenanceDate: ${alertData['lastMaintenanceDate']}');
                      }
                    } else {
                      print('\n📅 CAMBIO_Aceite: Manteniendo fecha seleccionada por el usuario: $lastUpdateDate');
                    }
                    
                    print('\n📅 CAMBIO_Aceite: Estado actual - Fecha de último mantenimiento: $lastUpdateDate');
                    print('\n📅 CAMBIO_Aceite: Estado actual - Fecha de vencimiento: $fechaVencimiento');
                    // Actualizar la fecha de vencimiento si existe y no hay una fecha seleccionada por el usuario
                    if (alertData['expirationDate'] != null && fechaVencimiento == null) {
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
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'El cambio de aceite es clave para prolongar la vida útil de su motor,',
                                    ),
                                    TextSpan(
                                      text: 'se recomienda cambiarlo cada 5.000 o 10.000 kilómetros',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Revise el último mantenimiento y configure esta alerta.',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              InputDate(
                                label: 'Fecha de último mantenimiento',
                                value: lastUpdateDate,
                                onChanged: (date) {
                                  print('\n📅 CAMBIO_Aceite: Nueva fecha seleccionada: $date');
                                  setState(() {
                                    lastUpdateDate = date;
                                    fechaVencimiento = date; // Actualizar también fechaVencimiento
                                    print('\n📅 CAMBIO_Aceite: lastUpdateDate actualizado a: $lastUpdateDate');
                                    print('\n📅 CAMBIO_Aceite: fechaVencimiento actualizado a: $fechaVencimiento');
                                  });
                                },
                              ),

                              const SizedBox(height: 25),

                              if (bloc.alertData != null &&
                                  bloc.alertData!['estado'] !=
                                      'Configurar') ...[
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Fecha de vencimiento',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        bloc.alertData?['expirationDate'] !=
                                                null
                                            ? _formatDate(bloc
                                                .alertData!['expirationDate'])
                                            : 'No disponible',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111827),
                                        ),
                                      )
                                    ]),
                                const SizedBox(height: 25),
                              ],

                              // Mostrar mensaje de alerta si está vencido
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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
                                  bloc.alertData!['estado'] != 'Vencido' &&
                                  bloc.alertData!['estado'] !=
                                      'Configurar') ...[
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

                              // Recordatorios adicionales

                              const SizedBox(height: 14),

                              // Banner de servicio
                              if (bloc.alertData != null &&
                                  bloc.alertData!['hasBanner'] == true &&
                                  bloc.alertData!['imageBanner'] != null)
                                Column(
                                  children: [
                                    const SizedBox(height: 0),
                                    // Eliminamos el padding horizontal del BannerWidget envolviéndolo en un Padding negativo
                                    SizedBox(
                                      height: 158,
                                      width: double.infinity,
                                      // Usamos un ClipRRect para mantener los bordes redondeados
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          bloc.alertData!['imageBanner'],
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print(
                                                '\n❌ ERROR CARGANDO IMAGEN DE BANNER: $error');
                                            print(
                                                'URL: ${bloc.alertData!['imageBanner']}');
                                            // Mostrar imagen de respaldo en caso de error
                                            return Image.asset(
                                              'assets/images/BannerSOAT.png',
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                              height: double.infinity,
                                            );
                                          },
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),

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

        // Indicador de carg
      );
  }
}
