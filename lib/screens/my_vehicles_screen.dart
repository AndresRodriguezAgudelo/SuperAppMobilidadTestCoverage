import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/button.dart';
import '../widgets/top_bar.dart';
import '../widgets/modales.dart';
import 'add_vehicle_screen.dart';
import 'detalle_vehiculo_screen.dart';
import '../BLoC/home/home_bloc.dart';
import '../BLoC/alerts/alerts_bloc.dart';

class MisVehiculosScreen extends StatefulWidget {
  const MisVehiculosScreen({super.key});

  @override
  State<MisVehiculosScreen> createState() => _MisVehiculosScreenState();
}

class _MisVehiculosScreenState extends State<MisVehiculosScreen> {
  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeBloc = Provider.of<HomeBloc>(context, listen: false);
      // Siempre actualizar los vehículos al entrar a la pantalla
      homeBloc.getCars();
    });
  }

  void _showLimitModal(BuildContext context) {
    CustomModal.show(
      context: context,
      icon: Icons.info_outline,
      iconColor: Colors.white,
      title: 'Límite alcanzado',
      content: 'Solo puedes agregar hasta 2 vehículos. Si necesitas gestionar otro, elimina uno existente o contáctanos para más opciones',
      buttonText: 'Aceptar',
    );
  }

  Widget _buildVehicleItem(Map<String, dynamic> vehicle) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleVehiculoScreen(
              placa: vehicle['licensePlate'].toString(),
              vehicleId: vehicle['id'],
            ),
          ),
        );
        // Actualizar la lista de vehículos después de regresar del detalle
        if (!mounted) return;
        final homeBloc = Provider.of<HomeBloc>(context, listen: false);
        homeBloc.getCars();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F7FC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF38A8E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehículo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehicle['licensePlate'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeBloc = Provider.of<HomeBloc>(context);
    final vehicles = homeBloc.cars;
    final bool isLimitReached = vehicles.length >= 2;
    
    if (homeBloc.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // Forzar recarga de vehículos y alertas en el home
        final homeBloc = Provider.of<HomeBloc>(context, listen: false);
        homeBloc.forceReload();
        
        // Forzar recarga de alertas si hay vehículos
        if (homeBloc.cars.isNotEmpty) {
          final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
          alertsBloc.loadAlerts(homeBloc.cars.first['id']);
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          screenType: ScreenType.progressScreen,
          title: 'Mis Vehículos',
          onBackPressed: () {
            // Forzar recarga de vehículos y alertas en el home
            final homeBloc = Provider.of<HomeBloc>(context, listen: false);
            homeBloc.forceReload();
            
            // Forzar recarga de alertas si hay vehículos
            if (homeBloc.cars.isNotEmpty) {
              final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
              alertsBloc.loadAlerts(homeBloc.cars.first['id']);
            }
            
            // Navegar explícitamente al home
            Navigator.pushNamedAndRemoveUntil(
              context, 
              '/home', 
              (route) => false
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return _buildVehicleItem(vehicle);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 50.0),
            child: Opacity(
              opacity: isLimitReached ? 0.5 : 1.0,
              child: Button(
                text: 'Agregar nuevo vehículo',
                action: isLimitReached
                  ? () => _showLimitModal(context)
                  : () async {
                      final newPlate = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AgregarVehiculoScreen(),
                        ),
                      );
                      if (newPlate != null) {
                        // Refresh car list after adding new vehicle
                        final homeBloc = Provider.of<HomeBloc>(context, listen: false);
                        await homeBloc.getCars();
                        
                        // Cargar alertas para el nuevo vehículo
                        if (homeBloc.cars.isNotEmpty) {
                          final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
                          await alertsBloc.loadAlerts(homeBloc.cars.first['id']);
                        }
                      }
                    },
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
