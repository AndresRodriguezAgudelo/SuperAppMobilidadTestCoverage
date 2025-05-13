import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/top_bar.dart';
import '../widgets/button.dart';
import '../widgets/historialVehicular/historial_vehicular_card.dart';
import '../BLoC/multas/multas_bloc.dart';
import '../widgets/loading.dart';

class MultasScreen extends StatefulWidget {
  final String? plate;

  const MultasScreen({super.key, this.plate});

  @override
  State<MultasScreen> createState() => _MultasScreenState();
}

class _MultasScreenState extends State<MultasScreen> {
  final MultasBloc _multasBloc = MultasBloc();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Iniciar la carga de datos después de que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    if (widget.plate != null && widget.plate!.isNotEmpty) {
      print('\n🚗 MULTAS_SCREEN: Placa recibida: ${widget.plate}');
      _multasBloc.setPlate(widget.plate!);
    } else {
      print('\n⚠️ MULTAS_SCREEN: No se recibió una placa válida');
      // Podríamos mostrar un mensaje o redirigir al usuario
    }
    _isFirstLoad = false;
  }

  Color _getStatusColor() {
    return _multasBloc.tieneMultas
        ? const Color(0xFFE05D38)  // Rojo claro para cuando hay multas
        : const Color(0xFF0B9E7C);  // Verde para cuando no hay multas
  }

  // ignore: unused_element
  String _getActionItemText() {
    return _multasBloc.tieneMultas
        ? 'Con multas'
        : 'Sin multas';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} - '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} '
           '${dateTime.hour >= 12 ? 'pm' : 'am'}';
  }

  Widget _buildMainContent(bool isLoading, bool hasError, bool hasMultas, MultasBloc multasBloc) {
    // Si está cargando, mostrar indicador de progreso

    // Si hay un error, mostrar mensaje de error
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              multasBloc.error!.contains('tiempo') || multasBloc.error!.contains('temporalmente') 
                  ? 'El servicio de consulta de multas no está disponible temporalmente. Por favor, intenta más tarde.'
                  : multasBloc.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Si no hay datos aún (primera carga)
    if (multasBloc.multasData == null && _isFirstLoad) {
      return const Center(
        child: Text('Ingresa una placa para consultar multas'),
      );
    }

    // Si hay multas, mostrar lista
    if (hasMultas && multasBloc.multasData != null) {
      final multas = multasBloc.multasData!.detallesComparendos;
      final currencyFormat = NumberFormat.currency(
        locale: 'es_CO',
        symbol: '\$',
        decimalDigits: 0,
      );

      return Column(
        children: [
          const SizedBox(height: 6),
          // Lista de multas
          Expanded(
            child: ListView.builder(
              itemCount: multas.length,
              itemBuilder: (context, index) {
                final multa = multas[index];
                return HistorialVehicularCard(
                  isMulta: true,
                  data: multa.toCardData(placa: multasBloc.multasData!.placa),
                );
              },
            ),
          ),
        ],
      );
    }

    // Si no hay multas, mostrar mensaje de felicitación
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 260,
          height: 260,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/images/sinMultasImg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Felicidades! No tienes multas vigentes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Sigue cuidando tu historial y conduciendo responsablemente.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider.value(
    value: _multasBloc,
    child: Consumer<MultasBloc>(
      builder: (context, multasBloc, _) {
        final isLoading = multasBloc.isLoading;
        final hasError = multasBloc.error != null;
        final hasMultas = multasBloc.tieneMultas;
        final ultimaActualizacion = multasBloc.ultimaActualizacion;

        return Loading(
          isLoading: isLoading,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: TopBar(
                screenType: ScreenType.progressScreen,
                title: 'Multas',
                onBackPressed: () => Navigator.pop(context),
                actionItems: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 24),
                          child: Center(
                            child: Text(
                              _getActionItemText(),
                              style: const TextStyle(
                                color: Color.fromARGB(221, 255, 255, 255),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'El cumplimiento de las normas de tránsito es clave para garantizar la seguridad vial. '
                    'El respeto de las señales, límites de velocidad y reglas de prioridad ayuda a evitar '
                    'colisiones y reduce el riesgo de accidentes. Aplica T&C',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // Contenido principal (carga, error, multas o sin multas)
                  Expanded(
                    child: _buildMainContent(isLoading, hasError, hasMultas, multasBloc),
                  ),

                  const SizedBox(height: 24),

                  // Última actualización y botón
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Última actualización',
                            style: TextStyle(color: Colors.black54),
                          ),
                          if (ultimaActualizacion != null)
                            Text(
                              _formatDateTime(ultimaActualizacion),
                              style: const TextStyle(color: Colors.black54),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Button(
                        text: 'Refrescar cambios',
                        icon: Icons.refresh,
                        action: () {
                          multasBloc.refresh();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

}
