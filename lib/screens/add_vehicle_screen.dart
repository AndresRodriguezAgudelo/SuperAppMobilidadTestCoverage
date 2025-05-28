import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/inputs/input_text.dart';
import '../widgets/inputs/input_select.dart';
import '../widgets/button.dart';
import '../widgets/loading.dart';
import '../widgets/notification_card.dart';
import '../BLoC/document_types/document_types_bloc.dart';
import '../BLoC/home/home_bloc.dart';
import '../BLoC/alerts/alerts_bloc.dart';
import '../utils/error_utils.dart';
import 'simple_loading_screen.dart';
import 'my_vehicles_screen.dart';

class AgregarVehiculoScreen extends StatefulWidget {
  const AgregarVehiculoScreen({super.key});

  @override
  State<AgregarVehiculoScreen> createState() => _AgregarVehiculoScreenState();
}

class _AgregarVehiculoScreenState extends State<AgregarVehiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final DocumentTypesBloc _documentTypesBloc;
  String _placa = '';
  Map<String, dynamic>? _tipoDocumento;
  String _numeroDocumento = '';
  bool _isPlacaValid = false;
  bool _isNumeroDocumentoValid = false;

  @override
  void initState() {
    super.initState();
    _documentTypesBloc = DocumentTypesBloc();

    // Deshabilitar las peticiones al iniciar el proceso de agregar vehículo
    final homeBloc = HomeBloc();
    homeBloc.disableRequests();
    print('\n🔒 PETICIONES DESHABILITADAS al iniciar agregar vehículo');

    // Usar post-frame callback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _documentTypesBloc.getDocumentTypes(
        search: '',
        order: 'ASC',
        page: 1,
        take:
            50, // Aumentamos el take para asegurar que obtengamos todos los tipos de documento
      );
    });
  }

  @override
  void dispose() {
    _documentTypesBloc.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _isPlacaValid &&
        _tipoDocumento != null &&
        _isNumeroDocumentoValid &&
        !_documentTypesBloc.isLoading;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _documentTypesBloc,
      child: Consumer<DocumentTypesBloc>(
        builder: (context, bloc, _) {
          return Loading(
            isLoading: bloc.isLoading,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: TopBar(
                  screenType: ScreenType.progressScreen,
                  title: 'Nuevo Vehículo',
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '*Ingresa el documento del propietario tal como aparece en la tarjeta de propiedad.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              InputText(
                                label: 'Placa',
                                type: InputType.plateCar,
                                onChanged: (value, isValid) {
                                  setState(() {
                                    _placa = value.toUpperCase();
                                    _isPlacaValid = isValid && value.isNotEmpty;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              Consumer<DocumentTypesBloc>(
                                builder: (context, bloc, child) {
                                  // El estado de carga ahora se maneja con el widget Loading

                                  if (bloc.error != null) {
                                    return Center(
                                      child: Text(
                                        'Error: ${bloc.error}',
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    );
                                  }

                                  final documentTypes = bloc.documentTypes;
                                  if (documentTypes.isEmpty) {
                                    return const Center(
                                      child: Text(
                                          'No hay tipos de documento disponibles'),
                                    );
                                  }

                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      bottomSheetTheme:
                                          const BottomSheetThemeData(
                                        modalBarrierColor: Colors.black54,
                                      ),
                                    ),
                                    child: InputSelect(
                                      label:
                                          'Tipo de documento del propietario',
                                      options: documentTypes
                                          .map((type) =>
                                              type['typeName'].toString())
                                          .toList(),
                                      onChanged: (value, isValid) {
                                        setState(() {
                                          _tipoDocumento =
                                              documentTypes.firstWhere(
                                            (type) =>
                                                type['typeName'].toString() ==
                                                value,
                                          );
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              InputText(
                                label: 'Número de documento del propietario',
                                type: InputType.id,
                                onChanged: (value, isValid) {
                                  setState(() {
                                    _numeroDocumento = value;
                                    _isNumeroDocumentoValid =
                                        isValid && value.isNotEmpty;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 60.0),
                    child: Button(
                      text: 'Agregar vehículo',
                      action: _isFormValid
                          ? () {
                              // Preparar el bloc para la creación del vehículo antes de navegar
                              _documentTypesBloc.prepareForVehicleCreation();
                              
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => SimpleLoadingScreen(
                                      tasks: [
                                        () async {
                                          try {
                                            // Llamar a createVehicle sin actualizar el estado internamente
                                            // Ahora createVehicle lanzará una excepción si hay un error
                                            await _documentTypesBloc
                                                .createVehicle(
                                              licensePlate:
                                                  _placa.toUpperCase(),
                                              numberDocument: _numeroDocumento,
                                              typeDocumentId:
                                                  _tipoDocumento!['id'],
                                            );
                                            
                                            // Actualizar el estado después de la operación exitosa
                                            _documentTypesBloc.finishVehicleCreation();
                                            final homeBloc =
                                                Provider.of<HomeBloc>(ctx,
                                                    listen: false);
                                            homeBloc.enableRequests();
                                            await homeBloc.forceReload();
                                            if (homeBloc.cars.isNotEmpty) {
                                              // Buscar el vehículo recién creado por su placa
                                              Map<String, dynamic>? newVehicle;
                                              
                                              // Buscar el vehículo con la placa correspondiente
                                              for (var car in homeBloc.cars) {
                                                if (car['licensePlate'] == _placa.toUpperCase()) {
                                                  newVehicle = car;
                                                  break;
                                                }
                                              }
                                              
                                              // Si no se encuentra, usar el primer vehículo
                                              if (newVehicle == null && homeBloc.cars.isNotEmpty) {
                                                newVehicle = homeBloc.cars.first;
                                              }
                                              
                                              // Verificar que newVehicle no sea nulo y tenga un ID antes de cargar alertas
                                              if (newVehicle != null && newVehicle['id'] != null) {
                                                final alertsBloc =
                                                    Provider.of<AlertsBloc>(ctx,
                                                        listen: false);
                                                await alertsBloc
                                                    .loadAlerts(newVehicle['id']);
                                              } else {
                                                print('\n⚠️ ADD_VEHICLE: No se pudo obtener un vehículo válido para cargar alertas');
                                              }
                                            }
                                            return null; // Todo ok
                                          } catch (e) {
                                            // Actualizar el estado con el error
                                            _documentTypesBloc.finishVehicleCreation(error: e.toString());
                                            return e.toString();
                                          }
                                        },
                                      ],
                                      builder: (context, results) {
                                        final error = results.isNotEmpty
                                            ? results[0]
                                            : null;
                                        if (error != null) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            // Limpiar el mensaje de error usando ErrorUtils
                                            final cleanedError = ErrorUtils.cleanErrorMessage(error);
                                            
                                            NotificationCard.showNotification(
                                              context: context,
                                              isPositive: false,
                                              icon: Icons.error,
                                              text: cleanedError,
                                              date: DateTime.now(),
                                              title:
                                                  'Error al agregar vehículo',
                                            );
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const MisVehiculosScreen()),
                                              (route) => false,
                                            );
                                          });
                                          return const Scaffold(
                                              body: SizedBox.shrink());
                                        }
                                        return const MisVehiculosScreen();
                                      },
                                    ),
                                  ),
                                );
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
