import 'package:flutter/material.dart';
import '../utils/error_utils.dart';
import '../widgets/notification_card.dart';
import 'package:provider/provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/inputs/input_city.dart';
import '../widgets/pico_placa.dart';
import '../widgets/button.dart';
import '../widgets/loading.dart';
import '../widgets/confirmation_modales.dart';
import '../BLoC/pick_and_plate/pick_and_plate_bloc.dart';
import '../BLoC/home/home_bloc.dart';
import '../BLoC/alerts/alerts_bloc.dart';

class PicoPlacaScreen extends StatelessWidget {
  final dynamic alertId;
  final String? plate; // Placa opcional
  final int? cityId; // ID de la ciudad del usuario (opcional)

  // No podemos usar const con un constructor que tiene un cuerpo
  PicoPlacaScreen({
    super.key,
    required this.alertId,
    this.plate,
    this.cityId,
  }) {
    print(
        '\n🚦 PICO_PLACA_SCREEN: Constructor llamado con alertId: $alertId, plate: $plate, cityId: $cityId');
  }

  @override
  Widget build(BuildContext context) {
    print(
        '\n🚦 PICO_PLACA_SCREEN: build - Iniciando construcción de la pantalla');

    return Consumer<PeakPlateBloc>(
      builder: (context, bloc, _) {
        return Loading(
          isLoading: bloc.isLoading,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: TopBar(
                screenType: ScreenType.expirationScreen, // Cambiado a expirationScreen para siempre navegar al home
                title: 'Pico y Placa',
                actionItems: bloc.selectedCity == null
                    ? [] // No mostrar nada si no hay ciudad seleccionada
                    : bloc.canDrive
                        ? [
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(224, 92, 58, 1.0),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxHeight: 24),
                                child: Center(
                                  child: Text(
                                    'No Salir',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ]
                        : [
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Color(0xFF0B9E7C),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxHeight: 24),
                                child: Center(
                                  child: Text(
                                    'Permitido Salir',
                                    style: const TextStyle(
                                      color: Color.fromARGB(221, 255, 255, 255),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Grupo 2: Mensaje informativo o mensaje de selección de ciudad
                  if (bloc.selectedCity != null && bloc.peakPlateData != null)
                    bloc.canDrive
                        ? RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Su placa',
                                ),
                                TextSpan(
                                  text: ' NO ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      'puede circular hoy en la ciudad escogida, puede cambiarla según sus preferencias de movilidad. ',
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(Icons.warning_amber_outlined,
                                      color: Colors.amber, size: 18),
                                ),
                                TextSpan(
                                  text: ' ¡Evite multas! ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(Icons.warning_amber_outlined,
                                      color: Colors.amber, size: 18),
                                ),
                                TextSpan(
                                  text: ' Aplica T&C.',
                                ),
                              ],
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Su placa',
                                ),
                                TextSpan(
                                  text: ' SI ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      'puede circular hoy en la ciudad escogida, puede cambiarla según sus preferencias de movilidad. ',
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(Icons.warning_amber_rounded,
                                      color: Colors.amber, size: 18),
                                ),
                                TextSpan(
                                  text: ' ¡Evite multas! ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(Icons.warning_amber_rounded,
                                      color: Colors.amber, size: 18),
                                ),
                                TextSpan(
                                  text: ' Aplica T&C.',
                                ),
                              ],
                            ),
                          )
                  else
                    const Text(
                      'Por favor seleccione una ciudad para ver las restricciones de pico y placa.',
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 16),
                  // Grupo 1: Selector de ciudad usando InputCity que maneja la carga de ciudades internamente
                  InputCity(
                    label: 'Ciudad de circulacion',
                    // Solo pasar el initialCityId en la carga inicial, no en cada reconstrucción
                    initialCityId:
                        bloc.cityId?.toString() ?? cityId?.toString(),
                    onChanged: (value, isValid) {
                      // La lógica de actualización del bloc ahora está en el InputCity
                      print(
                          '\n🚦 PICO_PLACA_SCREEN: InputCity - Ciudad seleccionada: $value');
                    },
                  ),

                  const SizedBox(height: 16),

                  // Widget Pico Placa - Mostrarlo siempre, independientemente del estado
                  PicoPlaca(),
                  const SizedBox(height: 8),

                  if (bloc.selectedCity != null)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(247, 247, 247, 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Horario de restricción: ',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                            const SizedBox(width: 50),
                            Text(
                              bloc.restrictionTime ?? 'Actualizara pronto...',
                              //'6:00 am a 9:00 pm',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 34),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button(
                    text: 'Guardar',
                    action: bloc.selectedCity == null
                        ? null
                        : () async {
                            print(
                                '\n🚦 PICO_PLACA_SCREEN: Botón - Actualizar presionado');

                            try {
                              // Llamar al método refresh que ahora actualiza el perfil del usuario
                              await bloc.refresh();

                              // Cerrar el indicador de carga
                              Navigator.of(context).pop();

                              // Mostrar mensaje de éxito
                              showConfirmationModal(
                                context,
                                attitude: 1, // Positivo (éxito)
                                label: 'Ciudad guardada correctamente',
                              );

                              // Variables para almacenar la información del vehículo
                              dynamic vehicleId;
                              Map<String, dynamic>? selectedCar;

                              // Forzar la actualización de las alertas antes de regresar
                              try {
                                print(
                                    '\n🔄 PICO_PLACA_SCREEN: Actualizando HomeBloc y AlertsBloc');

                                // Obtener instancia del HomeBloc
                                final homeBloc = Provider.of<HomeBloc>(context,
                                    listen: false);

                                // Forzar recarga de vehículos en el HomeBloc
                                homeBloc.forceReload();
                                print(
                                    '\n🔄 PICO_PLACA_SCREEN: HomeBloc.forceReload() ejecutado');

                                // Obtener instancia del AlertsBloc
                                final alertsBloc = Provider.of<AlertsBloc>(
                                    context,
                                    listen: false);

                                // Si hay vehículos disponibles, actualizar las alertas del seleccionado
                                if (homeBloc.cars.isNotEmpty) {
                                  // Obtener el vehículo seleccionado usando HomeBloc
                                  final selectedVehicle =
                                      homeBloc.getSelectedVehicle();
                                  selectedCar = (selectedVehicle != null &&
                                          selectedVehicle is Map &&
                                          selectedVehicle['id'] != null)
                                      ? selectedVehicle as Map<String, dynamic>
                                      : (homeBloc.cars.isNotEmpty
                                          ? homeBloc.cars.first
                                          : null);

                                  if (selectedCar != null &&
                                      selectedCar.containsKey('id') &&
                                      selectedCar.containsKey('licensePlate')) {
                                    print(
                                        '\n🚗 PICO_PLACA: Usando vehículo seleccionado: ${selectedCar["licensePlate"]}');
                                    vehicleId = selectedCar["id"];

                                    // Actualizar las alertas
                                    if (vehicleId != null) {
                                      await alertsBloc.loadAlerts(vehicleId);
                                      print(
                                          '\n✅ PICO_PLACA_SCREEN: Alertas actualizadas correctamente');
                                    }
                                  } else {
                                    print(
                                        '\n⚠️ PICO_PLACA: No se pudo obtener un vehículo válido');
                                  }
                                }
                              } catch (e) {
                                print(
                                    '\n⚠️ PICO_PLACA_SCREEN: Error al actualizar alertas: $e');
                                // No mostrar error al usuario, ya que la operación principal fue exitosa
                              }

                              // Esperar un momento antes de navegar para que el modal sea visible
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                if (context.mounted &&
                                    selectedCar != null &&
                                    vehicleId != null) {
                                  // Navegar de regreso al home con información del vehículo seleccionado
                                  Navigator.of(context).pop({
                                    'success': true,
                                    'vehicleId': vehicleId,
                                    'licensePlate': selectedCar["licensePlate"],
                                  }); // Regresar con resultado exitoso y datos del vehículo
                                } else if (context.mounted) {
                                  // Si no tenemos datos del vehículo, regresar con éxito simple
                                  Navigator.of(context).pop(true);
                                }
                              });
                            } catch (e) {
                              // Cerrar el indicador de carga
                              Navigator.of(context).pop();

                              // Mostrar mensaje de error con mensaje limpio
                              showConfirmationModal(
                                context,
                                attitude: 0, // Negativo (error)
                                label:
                                    'Error al guardar la ciudad: ${ErrorUtils.cleanErrorMessage(e)}',
                              );

                              // Limpiar el mensaje de error para la notificación
                              final cleanedError = ErrorUtils.cleanErrorMessage(e);

                              // Alternativamente, mostrar notificación
                              NotificationCard.showNotification(
                                context: context,
                                isPositive: false,
                                icon: Icons.error_outline,
                                text: cleanedError,
                                date: DateTime.now(),
                                title: 'Error al guardar',
                                duration: const Duration(seconds: 4),
                              );
                            }
                          },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
