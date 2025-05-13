import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/top_bar.dart' show ScreenType;
import '../widgets/historialVehicular/historial_vehicular_card.dart';
import '../widgets/inputs/input_select.dart';
import '../widgets/historialVehicular/historial_vehicular_lista_data.dart';
import '../BLoC/historial_vehicular/historial_vehicular_bloc.dart';

class HistorialVehicularScreen extends StatefulWidget {
  final String placa;

  const HistorialVehicularScreen({
    super.key,
    required this.placa,
  });

  @override
  State<HistorialVehicularScreen> createState() =>
      _HistorialVehicularScreenState();
}

class _HistorialVehicularScreenState extends State<HistorialVehicularScreen> {
  String? _selectedArea;
  final List<String> _areas = [
    'Historial de trámites',
    'Multas',
    'Accidentes',
    'Novedades de traspaso',
    'Medidas cautelares',
  ];

  @override
  void initState() {
    super.initState();
    // Cargar datos cuando se inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = Provider.of<HistorialVehicularBloc>(context, listen: false);
      bloc.loadHistorialVehicular(widget.placa);
    });
  }

  Widget _buildContent() {
    return Consumer<HistorialVehicularBloc>(
      builder: (context, bloc, child) {
        // Si no se ha seleccionado ninguna área, mostrar el logo
        if (_selectedArea == null) {
          return Expanded(
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF38A8E0), width: 8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(42.0),
                  child: Image.asset(
                    'assets/images/NewLogoJustE.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        }



        // Para áreas que usan lista
        switch (_selectedArea) {
          case 'Accidentes':
            if (bloc.isLoadingAccidentes) {
              return _buildLoadingIndicator('Cargando información de accidentes...');
            }
            
            if (bloc.errorAccidentes != null) {
              return _buildErrorWidget(
                bloc.errorAccidentes!, 
                () => bloc.loadAccidentes(bloc.placa!)
              );
            }
            
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListaDataHistorialVehicular(
                data: bloc.getAccidentesFormateados(),
              ),
            );

          case 'Novedades de traspaso':
            if (bloc.isLoadingNovedades) {
              return _buildLoadingIndicator('Cargando novedades de traspaso...');
            }
            
            if (bloc.errorNovedades != null) {
              return _buildErrorWidget(
                bloc.errorNovedades!, 
                () => bloc.loadNovedadesTraspaso(bloc.placa!)
              );
            }
            
            return Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListaDataHistorialVehicular(
                        data: bloc.getNovedadesFormateadas(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        children: const [
                          Icon(Icons.info, color: Color(0xFF38A8E0)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Resuelva cualquier novedad de traspaso pendiente para evitar problemas legales.',
                              style: TextStyle(fontSize: 14, color: Color(0xFF222222)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

          case 'Medidas cautelares':
            if (bloc.isLoadingMedidas) {
              return _buildLoadingIndicator('Cargando medidas cautelares...');
            }
            
            if (bloc.errorMedidas != null) {
              return _buildErrorWidget(
                bloc.errorMedidas!, 
                () => bloc.loadMedidasCautelares(bloc.placa!)
              );
            }
            
            return Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListaDataHistorialVehicular(
                        data: bloc.getMedidasFormateadas(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        children: const [
                          Icon(Icons.info, color: Color(0xFF38A8E0)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Asegúrese de resolver todas las novedades pendientes con su vehículo, evite sanciones y contratiempos.',
                              style: TextStyle(fontSize: 14, color: Color(0xFF222222)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

          case 'Multas':
            if (bloc.isLoadingMultas) {
              return _buildLoadingIndicator('Cargando información de multas...');
            }
            
            if (bloc.errorMultas != null) {
              return _buildErrorWidget(
                bloc.errorMultas!, 
                () => bloc.loadMultas(bloc.placa!)
              );
            }
            
            final multas = bloc.multas;
            if (multas == null ||
                multas['detallesComparendos']?.isEmpty == true) {
              return const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Color(0xFF666666),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Estos datos no están disponibles por ahora',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final mensaje = multas['mensaje'] ?? '';
            if (mensaje == '✅ No hay multas ni comparendos pendientes.') {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 150,
                    height: 150,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sigue cuidando tu historial y conduciendo responsablemente.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }
            final cantidadMultas = multas['detallesComparendos']?.length ?? 0;
            return Expanded(
              child: ListView.builder(
                itemCount: cantidadMultas,
                itemBuilder: (context, index) {
                  final multa = multas['detallesComparendos'][index];
                  final placa = multas['placa'] ?? '';
                  final multaConPlaca = <String, dynamic>{
                    ...Map<String, dynamic>.from(multa),
                    'placa': placa,
                  };
                  return HistorialVehicularCard(
                    data: multaConPlaca,
                    isMulta: true,
                  );
                },
              ),
            );

          case 'Historial de trámites':
            {
              if (bloc.isLoadingTramites) {
                return _buildLoadingIndicator('Cargando historial de trámites...');
              }
              
              if (bloc.errorTramites != null) {
                return _buildErrorWidget(
                  bloc.errorTramites!, 
                  () => bloc.loadHistorialTramites(bloc.placa!)
                );
              }
              
              final historial = bloc.historialTramites;
              final historyList =
                  (historial != null && historial['history'] is List)
                      ? historial['history'] as List
                      : null;
              if (historyList != null && historyList.isNotEmpty) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      final tramite = historyList[index];
                      return HistorialVehicularCard(
                        data: tramite,
                        isMulta: false,
                      );
                    },
                  ),
                );
              } else {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Color(0xFF666666),
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            'Estos datos no están disponibles por ahora',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }

          default:
            return const Expanded(child: SizedBox.shrink());
        }
      },
    );
  }

  // Widget para mostrar indicador de carga
  Widget _buildLoadingIndicator(String message) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar errores
  Widget _buildErrorWidget(String errorMessage, VoidCallback onRetry) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          TopBar(
            screenType: ScreenType.progressScreen,
            onBackPressed: () => Navigator.pop(context),
            title: 'Historial Vehicular',
          ),
          if (_selectedArea != 'Multas') Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Última Actualización:'),
                Builder(
                  builder: (context) {
                    String fecha = 'no disponible';
                    final bloc = Provider.of<HistorialVehicularBloc>(context,
                        listen: false);
                    if (_selectedArea == 'Historial de trámites') {
                      final historial = bloc.historialTramites;
                      if (historial != null &&
                          historial['ultimateUpdate'] != null) {
                        try {
                          final date =
                              DateTime.parse(historial['ultimateUpdate']).subtract(const Duration(hours: 5));
                          fecha =
                              "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                        } catch (_) {
                          fecha = 'no disponible';
                        }
                      }
                    } else if (_selectedArea == 'Accidentes') {
                      final accidentes = bloc.accidentes;
                      if (accidentes != null && accidentes['ultimateUpdate'] != null) {
                        try {
                          final date = DateTime.parse(accidentes['ultimateUpdate']).subtract(const Duration(hours: 5));
                          fecha = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                        } catch (_) {
                          fecha = 'no disponible';
                        }
                      }
                    } else if (_selectedArea == 'Novedades de traspaso') {
                      final novedades = bloc.novedadesTraspaso;
                      if (novedades != null && novedades['ultimateUpdate'] != null) {
                        try {
                          final date = DateTime.parse(novedades['ultimateUpdate']).subtract(const Duration(hours: 5));
                          fecha = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                        } catch (_) {
                          fecha = 'no disponible';
                        }
                      }
                    } else if (_selectedArea == 'Medidas cautelares') {
                      final medidas = bloc.medidasCautelares;
                      if (medidas != null && medidas['ultimateUpdate'] != null) {
                        try {
                          final date = DateTime.parse(medidas['ultimateUpdate']).subtract(const Duration(hours: 5));
                          fecha = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                        } catch (_) {
                          fecha = 'no disponible';
                        }
                      }
                    }
                    return Text(
                      fecha,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Contenedor del vehículo
          Container(
            margin: const EdgeInsets.all(16),
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
                  Text(
                    widget.placa,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selector de área
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InputSelect(
              label: 'Área a revisar',
              options: _areas,
              onChanged: (String value, bool selected) {
                setState(() {
                  _selectedArea = selected ? value : null;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Contenido dinámico
          _buildContent(),
        ],
      ),
    );
  }
}
