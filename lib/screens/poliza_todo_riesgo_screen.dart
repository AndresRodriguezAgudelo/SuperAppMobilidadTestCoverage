import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/inputs/input_date.dart';
import '../widgets/inputs/input_insurer.dart';
import '../models/insurer_model.dart';
import '../widgets/button.dart';
import '../widgets/top_bar.dart';
import '../widgets/alertas/recordatorios_adicionales.dart';
import '../BLoC/special_alerts/special_alerts_bloc.dart';
import '../BLoC/alerts/alerts_bloc.dart';
import '../BLoC/home/home_bloc.dart';
import '../widgets/confirmation_modales.dart';
import '../widgets/banner.dart'; // Importamos el widget Banner
import '../widgets/loading.dart';

class PolizaTodoRiesgoScreen extends StatefulWidget {
  final int alertId; // ID de la alerta para actualizaciones

  const PolizaTodoRiesgoScreen({
    super.key,
    required this.alertId,
  });

  @override
  State<PolizaTodoRiesgoScreen> createState() => _PolizaTodoRiesgoScreenState();
}

class _PolizaTodoRiesgoScreenState extends State<PolizaTodoRiesgoScreen> {
  late String nombreVencimiento = 'Póliza todo riesgo';
  DateTime? fechaVencimiento;
  bool isValidNombre =
      true; // Siempre es válido porque el nombre está predefinido
  List<Map<String, dynamic>> selectedReminders = [];
  bool isLoading = false;
  String? errorMessage;
  late final SpecialAlertsBloc _alertsBloc;
  int? insurerId;
  Insurer? selectedInsurer;
  bool _manuallySelectedInsurer = false; // Indica si el usuario seleccionó manualmente una aseguradora

  bool get isFormValid {
    return fechaVencimiento != null && insurerId != null;
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
          '\n🔥 Poliza todo riesgo_SCREEN: Iniciando carga de alerta ID: ${widget.alertId}');

      // Limpiar los datos anteriores para forzar una recarga completa
      _alertsBloc.reset();

      // Cargar los datos de la alerta
      await _alertsBloc.loadSpecialAlert(widget.alertId);

      // Verificar si los datos se cargaron correctamente
      if (_alertsBloc.alertData != null) {
        _alertsBloc.alertData!.forEach((key, value) {
          print('$key: $value');
        });
      } else {
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
      print('\n🔥 Poliza todo riesgo_SCREEN: Error al cargar los detalles: $e');
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
      final success = await _alertsBloc.updateInsurerAlert(
        widget.alertId,
        fechaVencimiento,
        reminders: selectedReminders,
        insurerId: insurerId, // Pasar el insurerId al método updateInsurerAlert
      );

      // Recargar los datos de la alerta para actualizar el estado en la TopBar
      if (success) {
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
            label: 'Póliza todo riesgo actualizado correctamente',
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
                print('\n⚠️ POLIZA_TODO_RIESGO: No se pudo obtener un vehículo válido');
                return;
              }
              
              print('\n🚗 POLIZA_TODO_RIESGO: Usando vehículo seleccionado: ${selectedCar["licensePlate"]}');
              vehicleId = selectedCar["id"];

              print(
                  '\n🔄 Poliza todo riesgo_SCREEN: Actualizando alertas para vehículo: ${selectedCar["licensePlate"]} (ID: $vehicleId)');

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
                  // Obtener status, color y texto de acción usando solo el bloc
                  final status = alertsBloc.getPolizaStatus(alertData: alertsBloc.alertData, fechaVencimiento: fechaVencimiento);
                  final statusColor = alertsBloc.getPolizaStatusColor(status);
                  final actionText = alertsBloc.getPolizaActionText(status);

                  List<Widget> actionItems = [];
                  if (status != 'Configurar' && status != 'sinAsignar') {
                    actionItems.add(Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 24),
                        child: Center(
                          child: Text(
                            actionText,
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
                    title: 'Póliza todo riesgo',
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
                    
                    // Actualizar la aseguradora si existe
                    if (alertData['insurerId'] != null && 
                        alertData['nameInsurer'] != null) {
                      try {
                        // Crear un nuevo objeto Insurer cada vez para asegurar que se actualice correctamente
                        final newInsurer = Insurer(
                          id: alertData['insurerId'],
                          name: alertData['nameInsurer'],
                        );
                        
                        // Solo actualizar el insurerId si el usuario NO ha seleccionado manualmente una aseguradora
                        if (!_manuallySelectedInsurer) {
                          print('\n💼 POLIZA_SCREEN: Cargando insurerId desde backend: ${alertData['insurerId']}');
                          insurerId = alertData['insurerId'];
                        } else {
                          print('\n💼 POLIZA_SCREEN: Manteniendo insurerId seleccionado manualmente: $insurerId (seleccion manual: $_manuallySelectedInsurer)');
                        }
                        
                        // Solo actualizar el selectedInsurer si es diferente o no existe
                        if (selectedInsurer == null || selectedInsurer!.id != newInsurer.id) {
                          print('\n🛠️ POLIZA_SCREEN: Actualizando aseguradora a: ${newInsurer.name} (ID: ${newInsurer.id})');
                          
                          // Usar Future.microtask para actualizar el estado después del build
                          Future.microtask(() {
                            if (mounted) {
                              setState(() {
                                selectedInsurer = newInsurer;
                              });
                            }
                          });
                        } else {
                          print('\n🛠️ POLIZA_SCREEN: Aseguradora ya cargada: ${selectedInsurer!.name} (ID: ${selectedInsurer!.id})');
                        }
                      } catch (e) {
                        print('\n❌ POLIZA_SCREEN: Error al cargar la aseguradora: $e');
                      }
                    } else {
                      print('\n⚠️ POLIZA_SCREEN: No hay datos de aseguradora en la respuesta');
                      if (alertData['insurerId'] == null) {
                        print('\n⚠️ POLIZA_SCREEN: insurerId es nulo');
                      }
                      if (alertData['nameInsurer'] == null) {
                        print('\n⚠️ POLIZA_SCREEN: nameInsurer es nulo');
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
                                    'La póliza todo riesgo es un seguro que cubre daños a tu vehículo y a terceros. Configura esta alerta para recibir notificaciones antes de su vencimiento.',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // // Mostrar información de depuración
                              // if (selectedInsurer != null)
                              //   Text(
                              //     'Aseguradora seleccionada: ${selectedInsurer!.name} (ID: ${selectedInsurer!.id})',
                              //     style: const TextStyle(fontSize: 12, color: Colors.grey),
                              //   ),
                              // const SizedBox(height: 8),
                              
                              InputInsurer(
                                key: ValueKey(selectedInsurer?.id ?? 'no-insurer'),  // Forzar reconstrucción cuando cambie
                                label: 'Aseguradora',
                                initialValue: selectedInsurer,
                                onChanged: (id, isValid) {
                                  print('\n🛠️ POLIZA_SCREEN: Aseguradora cambiada a ID: $id');
                                  // Usar Future.microtask para evitar setState durante el build
                                  Future.microtask(() {
                                    if (mounted) {
                                      setState(() {
                                        // Convertir el ID de String a int de manera segura
                                        try {
                                          // Usar toString() para asegurar que funcione con cualquier tipo
                                          insurerId = int.parse(id.toString());
                                          print('\n💼 POLIZA_SCREEN: ID convertido exitosamente a int: $insurerId');
                                          // Marcar que el usuario ha seleccionado manualmente una aseguradora
                                          _manuallySelectedInsurer = true;
                                          print('\n💼 POLIZA_SCREEN: Aseguradora seleccionada manualmente: $_manuallySelectedInsurer');
                                        } catch (e) {
                                          print('\n🚨 POLIZA_SCREEN: Error al convertir ID: $e');
                                          insurerId = null;
                                          _manuallySelectedInsurer = false;
                                        }
                                      });
                                    }
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

                               if (bloc.alertData != null &&
                                  bloc.alertData!['hasBanner'] == true &&
                                  bloc.alertData!['imageBanner'] != null) ...[
                                const SizedBox(height: 15),
                                // Implementación del banner con redirección usando el widget BannerWidget
                                SizedBox(
                                  height: 138,
                                  width: double.infinity,
                                  child: BannerWidget(
                                    item: BannerItem(
                                      imagePath: bloc.alertData!['imageBanner'] ?? 'assets/images/bannerImage.png',
                                      title: '',  // Título vacío ya que la imagen del banner ya incluye el texto
                                      message: '', // Mensaje vacío por la misma razón
                                      url: bloc.alertData!['linkBanner'] ?? 'https://apps.clientify.net/forms/simpleembed/#/forms/embedform/228575/39252', // URL para redirección
                                    ),
                                    fullWidth: true,
                                  ),
                                ),
                                const SizedBox(height: 24),
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
