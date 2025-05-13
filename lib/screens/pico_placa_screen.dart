import 'package:flutter/material.dart';
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

        ///debugPrint('\n🚦 PICO_PLACA_SCREEN: Consumer - Reconstruyendo con estado:');
        ///debugPrint('  - isLoading: ${bloc.isLoading}');
        ///debugPrint('  - error: ${bloc.error}');
        ///debugPrint('  - alertId: ${bloc.alertId}');
        ///debugPrint('  - cityId: ${bloc.cityId}');
        ///debugPrint('  - cities: ${bloc.cities.length} ciudades');
        ///debugPrint('  - selectedCity: ${bloc.selectedCity != null ? bloc.selectedCity!['cityName'] : 'null'}');
        ///debugPrint('  - plate: ${bloc.plate}');
        ///debugPrint('  - peakPlateData: ${bloc.peakPlateData != null ? 'Disponible' : 'null'}');
        ///debugPrint('  - canDrive: ${bloc.canDrive}');

        return Loading(
          isLoading: bloc.isLoading,
          child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: TopBar(
              screenType: ScreenType.progressScreen,
              title: 'Pico y Placa',
              onBackPressed: () => Navigator.pop(context),
              actionItems: bloc.selectedCity == null
                  ? [] // No mostrar nada si no hay ciudad seleccionada
                  : bloc.canDrive
                      ? [
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxHeight: 24),
                              child: Center(
                                child: Text(
                                  'No Permitido',
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
                if (bloc.selectedCity != null &&
                    bloc.peakPlateData != null)
                  Text(
                    bloc.canDrive
                        ? 'Su placa NO puede circular hoy en la ciudad escogida, puede cambiarla según sus preferencias de movilidad. ⚠️ ¡Evite multas! ⚠️ Aplica T&C'
                        : 'Su placa SI puede circular hoy en la ciudad escogida, puede cambiarla según sus preferencias de movilidad. ⚠️ ¡Evite multas! ⚠️ Aplica T&C',
                    style: const TextStyle(fontSize: 14, height: 1.4),
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
                  initialCityId: bloc.cityId?.toString() ?? cityId?.toString(),
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

                if (bloc.selectedCity != null) Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Horario de restricción:',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    Text(
                      bloc.restrictionTime ??
                          'Actualizara pronto...',
                      //'6:00 am a 9:00 pm',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
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
                  action: bloc.selectedCity == null ? null : () async {
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

                      // Forzar la actualización de las alertas antes de regresar
                      try {
                        print('\n🔄 PICO_PLACA_SCREEN: Actualizando HomeBloc y AlertsBloc');

                        // Obtener instancia del HomeBloc
                        final homeBloc = Provider.of<HomeBloc>(context, listen: false);

                        // Forzar recarga de vehículos en el HomeBloc
                        homeBloc.forceReload();
                        print('\n🔄 PICO_PLACA_SCREEN: HomeBloc.forceReload() ejecutado');

                        // Obtener instancia del AlertsBloc
                        final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);

                        // Si hay vehículos disponibles, actualizar las alertas del primero
                        if (homeBloc.cars.isNotEmpty) {
                          final selectedCar = homeBloc.cars.first;
                          final vehicleId = selectedCar["id"];

                          print('\n🔄 PICO_PLACA_SCREEN: Actualizando alertas para vehículo: ${selectedCar["licensePlate"]} (ID: $vehicleId)');

                          // Actualizar las alertas
                          if (vehicleId != null) {
                            await alertsBloc.loadAlerts(vehicleId);
                            print('\n✅ PICO_PLACA_SCREEN: Alertas actualizadas correctamente');
                          }
                        }
                      } catch (e) {
                        print('\n⚠️ PICO_PLACA_SCREEN: Error al actualizar alertas: $e');
                        // No mostrar error al usuario, ya que la operación principal fue exitosa
                      }

                      // Esperar un momento antes de navegar para que el modal sea visible
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (context.mounted) {
                          // Navegar de regreso al home
                          Navigator.of(context).pop(true); // Regresar con resultado exitoso
                        }
                      });
                    } catch (e) {
                      // Cerrar el indicador de carga
                      Navigator.of(context).pop();

                      // Mostrar mensaje de error
                      showConfirmationModal(
                        context,
                        attitude: 0, // Negativo (error)
                        label: 'Error al guardar la ciudad',
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
