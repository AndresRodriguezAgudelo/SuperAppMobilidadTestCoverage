import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/widgets/notification_card.dart';
import '../widgets/top_bar.dart';
import '../widgets/button.dart';
import '../widgets/loading.dart';
import '../widgets/modales.dart';
import '../BLoC/historial_vehicular/historial_vehicular_bloc.dart';
import 'historial_vehicular_screen.dart';
import '../BLoC/vehicles/vehicles_bloc.dart';
import '../BLoC/home/home_bloc.dart';
import '../services/API.dart';
import '../BLoC/auth/auth_context.dart';

class DetalleVehiculoScreen extends StatefulWidget {
  final String placa;
  final int vehicleId;

  const DetalleVehiculoScreen({
    super.key,
    required this.placa,
    required this.vehicleId,
  });

  @override
  State<DetalleVehiculoScreen> createState() => _DetalleVehiculoScreenState();
}

class _DetalleVehiculoScreenState extends State<DetalleVehiculoScreen> {
  bool _isDeleting = false; // Variable para controlar el estado de eliminación
  Widget _buildInfoRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  late final VehiclesBloc _vehiclesBloc;

  @override
  void initState() {
    super.initState();
    _vehiclesBloc = VehiclesBloc();
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vehiclesBloc.getVehicleDetail(widget.vehicleId);
    });
  }

  @override
  void dispose() {
    _vehiclesBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Forzar recarga de vehículos en el home
        final homeBloc = Provider.of<HomeBloc>(context, listen: false);
        homeBloc.forceReload();
        return true;
      },
      child: ChangeNotifierProvider.value(
        value: _vehiclesBloc,
        child: Consumer<VehiclesBloc>(
          builder: (context, vehiclesBloc, _) {
            return Loading(
              isLoading: vehiclesBloc.isLoading || _isDeleting,
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: TopBar(
                    screenType: ScreenType.progressScreen,
                    title: widget.placa,
                    actionItems: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          CustomModal.show(
                            context: context,
                            icon: Icons.info_outline,
                            iconColor: Colors.white,
                            title:
                                '¿Estas seguro de que deseas eliminar este vehiculo?',
                            content: 'Esta acción no se puede deshacer',
                            buttonText: 'Confirmar',
                            secondButtonText: 'Cancelar',
                            onButtonPressed: () async {
                              Navigator.pop(context); // Cerrar modal
                              // Mostrar loading mientras se elimina el vehículo
                              setState(() => _isDeleting = true);
                              try {
                                final success = await _vehiclesBloc
                                    .deleteVehicle(widget.vehicleId);
                                if (success && mounted) {
                                  // Forzar recarga de vehículos en el home ANTES de navegar de vuelta
                                  final homeBloc = Provider.of<HomeBloc>(
                                      context,
                                      listen: false);

                                  await homeBloc.forceReload();
                                  // Mostrar notificación de éxito
                                  NotificationCard.showNotification(
                                    context: context,
                                    isPositive: true,
                                    icon: Icons.check_circle,
                                    text: 'Vehículo eliminado exitosamente',
                                    date: DateTime.now(),
                                    title: 'Éxito',
                                  );
                                  // Regresar a la pantalla anterior
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (mounted) {
                                  NotificationCard.showNotification(
                                    context: context,
                                    isPositive: false,
                                    icon: Icons.error,
                                    text: 'Error al eliminar el vehículo: $e',
                                    date: DateTime.now(),
                                    title: 'Error',
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isDeleting = false);
                                }
                              }
                            },
                            buttonColor: Color(0xFF50B6E6),
                            secondButtonColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            labelSecondButtonColor: Color(0xFF50B6E6),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Consumer<VehiclesBloc>(
                        builder: (context, vehiclesBloc, child) {
                          // El estado de carga ahora se maneja con el widget Loading

                          if (vehiclesBloc.error != null) {
                            return Center(
                              child: Text(
                                'Error: ${vehiclesBloc.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          final vehicle = vehiclesBloc.currentVehicle;
                          if (vehicle == null) {
                            return const Center(
                                child: Text(
                                    'No se encontró información del vehículo'));
                          }

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                _buildInfoRow('Marca', vehicle['brand']),
                                _buildInfoRow('Modelo', vehicle['model']),
                                _buildInfoRow('Clase', vehicle['class']),
                                _buildInfoRow('Linea', vehicle['line']),
                                _buildInfoRow('Servicio', vehicle['service']),
                                _buildInfoRow('Combustible', vehicle['fuel']),
                                _buildInfoRow('Color', vehicle['color']),
                                _buildInfoRow('Pasajeros',
                                    vehicle['passagers'].toString()),
                                _buildInfoRow('VIN', vehicle['vin']),
                                _buildInfoRow('Serial', vehicle['serial']),
                                _buildInfoRow(
                                    'Número motor', vehicle['numberEngine']),
                                _buildInfoRow(
                                    'Cilindraje', vehicle['capacityEngine']),
                                _buildInfoRow('Fecha de matricula',
                                    vehicle['dateRegister']),
                                _buildInfoRow('Ciudad de matricula',
                                    vehicle['cityRegisterName']),
                                _buildInfoRow(
                                  'Organismo de tránsito',
                                  vehicle['organismTransit'],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 50.0),
                      child: Button(
                        text: 'Ver historial vehicular',
                        action: () async {
                          // Consumir el endpoint getReloadExpirationEndpoint antes de navegar
                          // Variables para almacenar el mensaje y el estado de error
                          String mensaje = '';
                          bool esError = false;
                          Map<String, dynamic> response = {};
                          
                          try {
                            final apiService = APIService();
                            final authContext = Provider.of<AuthContext>(context, listen: false);
                            
                            // Mostrar indicador de carga mientras se consume el endpoint
                            setState(() {
                              _isDeleting = true; // Reutilizamos esta variable para mostrar el indicador de carga
                            });
                            
                            debugPrint('\n🔴🔴🔴 PUNTO DE VERIFICACIÓN 1: Antes de consumir el endpoint');
                            debugPrint('Consumiendo endpoint getReloadExpirationEndpoint con name=VehicleHistory y expirationId=0');
                            
                            try {
                              // Consumir el endpoint con name=VehicleHistory y expirationId=0
                              response = await apiService.reloadExpiration(
                                'vehicle-history',
                                token: authContext.token,
                                expirationId: 0,
                                vehicleId: widget.vehicleId, // Incluir el ID del vehículo
                              );
                              
                              // Imprimir la respuesta completa del endpoint
                              debugPrint('\n==================================================');
                              debugPrint('✅ RESPUESTA del endpoint getReloadExpirationEndpoint:');
                              debugPrint('$response');
                              
                              // Procesar la respuesta
                              if (response.containsKey('status')) {
                                debugPrint('📊 Status: ${response['status']}');
                                // Si el status es diferente de success, considerarlo como error
                                if (response['status'] != 'success') {
                                  esError = true;
                                }
                              }
                              
                              if (response.containsKey('message')) {
                                mensaje = response['message'].toString();
                                debugPrint('📝 Mensaje: $mensaje');
                              } else {
                                // Si no hay mensaje en la respuesta
                                mensaje = 'Información actualizada correctamente';
                              }
                              
                              if (response.containsKey('data')) {
                                debugPrint('📦 Datos: ${response['data']}');
                              }
                              
                              debugPrint('==================================================\n');
                              debugPrint('Endpoint getReloadExpirationEndpoint consumido correctamente');
                            } catch (apiError) {
                              // Capturar error específico de la API
                              debugPrint('\n==================================================');
                              debugPrint('❌ ERROR al consumir getReloadExpirationEndpoint: $apiError');
                              debugPrint('==================================================\n');
                              
                              // Extraer el mensaje de error
                              if (apiError is APIException) {
                                mensaje = apiError.message;
                                debugPrint('📝 Mensaje de error extraído: $mensaje');
                              } else {
                                mensaje = apiError.toString();
                              }
                              esError = true;
                            }
                          } catch (e) {
                            // Capturar cualquier otro error inesperado
                            debugPrint('\n==================================================');
                            debugPrint('❌ ERROR INESPERADO: $e');
                            debugPrint('==================================================\n');
                            mensaje = 'No se pudo obtener información actualizada';
                            esError = true;
                          } finally {
                            // Ocultar indicador de carga
                            if (mounted) {
                              setState(() {
                                _isDeleting = false;
                              });
                            }
                            
                            // Continuar con la navegación independientemente del resultado
                            if (mounted) {
                              final historialBloc = HistorialVehicularBloc();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider.value(
                                    value: historialBloc,
                                    child: HistorialVehicularScreen(
                                      placa: widget.placa,
                                      mensajeNotificacion: mensaje,
                                      esErrorNotificacion: esError,
                                    ),
                                  ),
                                ),
                              ).then((_) {
                                // Limpiar el bloc cuando se regrese de la pantalla
                                historialBloc.reset();
                                historialBloc.dispose();
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
