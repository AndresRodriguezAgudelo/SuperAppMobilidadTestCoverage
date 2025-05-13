import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../widgets/inputs/input_text.dart';
import '../widgets/inputs/input_date.dart';
import '../widgets/button.dart';
import '../widgets/loading.dart';
import '../widgets/top_bar.dart';
import '../BLoC/special_alerts/special_alerts_bloc.dart';
import '../BLoC/home/home_bloc.dart';
import '../BLoC/alerts/alerts_bloc.dart';
import '../widgets/confirmation_modales.dart';

class AlertaScreen extends StatefulWidget {
  final int? vehicleId;
  const AlertaScreen({super.key, this.vehicleId});

  @override
  State<AlertaScreen> createState() => _AlertaScreenState();
}

class _AlertaScreenState extends State<AlertaScreen> {
  String nombreVencimiento = '';
  DateTime? fechaVencimiento;
  bool isValidNombre = false;
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> selectedReminders = [];
  late final SpecialAlertsBloc _alertsBloc;

  bool get isFormValid => isValidNombre && fechaVencimiento != null;
  
  @override
  void initState() {
    super.initState();
    _alertsBloc = SpecialAlertsBloc();
  }
  
  @override
  void dispose() {
    _alertsBloc.reset();
    super.dispose();
  }
  
  Future<void> _saveAlert() async {
    if (!isFormValid) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Obtener el ID del vehículo actual desde el parámetro recibido
      final homeBloc = Provider.of<HomeBloc>(context, listen: false);
      int? vehicleId = widget.vehicleId;
      Map<String, dynamic>? selectedCar;
      
      if (homeBloc.cars.isNotEmpty && vehicleId != null) {
        try {
          selectedCar = homeBloc.cars.firstWhere(
            (car) => car['id'] == vehicleId,
          );
        } catch (e) {
          // Si no se encuentra, selectedCar seguirá siendo null
          print('\n⚠️ No se encontró vehículo con ID: $vehicleId');
        }
        print('\n🚗 Vehículo seleccionado: ${selectedCar != null ? selectedCar["licensePlate"] : "No encontrado"} (ID: $vehicleId)');
      }
      
      if (vehicleId == null) {
        throw Exception('No se pudo obtener el ID del vehículo');
      }

      // Preparar los recordatorios (por defecto 1 día y 7 días antes)
      if (selectedReminders.isEmpty) {
        selectedReminders = [
          {"days": 1},
          {"days": 7},
        ];
      }

      print('\n💾 ALERTA_SCREEN: Creando nuevo vencimiento con datos:');
      print('Nombre: $nombreVencimiento');
      print('Fecha: $fechaVencimiento');
      print('ID Vehículo: $vehicleId');
      print('Recordatorios: $selectedReminders');

      // Crear el nuevo vencimiento usando el SpecialAlertsBloc
      final newExpirationId = await _alertsBloc.createExpiration(
        nombreVencimiento,
        fechaVencimiento,
        vehicleId,
        reminders: selectedReminders,
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        if (newExpirationId != null) {
          // Mostrar confirmación
          showConfirmationModal(
            context,
            attitude: 1, // Positivo (éxito)
            label: 'Vencimiento creado correctamente',
          );
          
          // Forzar la actualización de las alertas antes de regresar al home
          try {
            // Actualizar las alertas usando el AlertsBloc
            final alertsBloc = Provider.of<AlertsBloc>(context, listen: false);
            await alertsBloc.loadAlerts(vehicleId);
            print('\n✅ Alertas actualizadas correctamente');
          } catch (e) {
            print('\n⚠️ No se pudieron actualizar las alertas: $e');
          }

          // Navegar de regreso al home
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pop(context, true); // Regresar con resultado exitoso
            }
          });
          Navigator.pop(context, true);
            
        } else {
          // Mostrar error
          showConfirmationModal(
            context,
            attitude: 0, // Negativo (error)
            label: 'No se pudo crear el vencimiento: ${_alertsBloc.error ?? "Error desconocido"}',
          );
        }
      }
    } catch (e) {
      print('\n❌ Error al crear vencimiento: $e');
      print('\n❌ TIPO DE ERROR: ${e.runtimeType}');
      print('\n❌ CONTENIDO COMPLETO DEL ERROR:');
      print(e.toString());
      
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });

        // Extraer el mensaje específico de error si está disponible
        String errorMsg = 'Error al crear vencimiento';
        try {
          // Convertir el error a string y verificar si contiene un JSON
          String errorStr = e.toString();
          print('\n🔍 Buscando JSON en el error...');
          
          // Buscar patrones específicos en el mensaje de error
          if (errorStr.contains('errors')) {
            print('\n✅ Encontrado campo "errors" en el mensaje');
            
            // Extraer la parte JSON del mensaje de error
            int startIndex = errorStr.indexOf('{');
            int endIndex = errorStr.lastIndexOf('}') + 1;
            
            print('\n📍 Índices JSON: start=$startIndex, end=$endIndex');
            
            if (startIndex >= 0 && endIndex > startIndex) {
              String jsonStr = errorStr.substring(startIndex, endIndex);
              print('\n📝 JSON extraído: $jsonStr');
              
              Map<String, dynamic> errorData = json.decode(jsonStr);
              print('\n📐 JSON decodificado: $errorData');
              
              // Verificar si contiene el campo errors y extraer el mensaje específico
              if (errorData.containsKey('errors')) {
                print('\n✅ Campo "errors" encontrado en el JSON');
                var errors = errorData['errors'];
                print('\n📑 Contenido de errors: $errors (tipo: ${errors.runtimeType})');
                
                if (errors is List && errors.isNotEmpty) {
                  print('\n✅ Lista de errores no vacía: ${errors.length} errores');
                  var firstError = errors[0];
                  print('\n📑 Primer error: $firstError (tipo: ${firstError.runtimeType})');
                  
                  if (firstError is Map && firstError.containsKey('message')) {
                    print('\n✅ Mensaje específico encontrado: ${firstError['message']}');
                    errorMsg = firstError['message'];
                  } else {
                    print('\n❌ El primer error no contiene campo "message"');
                  }
                } else {
                  print('\n❌ La lista de errores está vacía o no es una lista');
                }
              } else {
                print('\n❌ No se encontró el campo "errors" en el JSON decodificado');
              }
            } else {
              print('\n❌ No se pudo extraer un JSON válido del mensaje de error');
            }
          } else {
            print('\n❌ No se encontró el patrón "errors" en el mensaje');
          }
        } catch (jsonError) {
          print('\n❌ Error al parsear el mensaje de error: $jsonError');
          // Si hay error al parsear, usar el mensaje original
          errorMsg = 'Error al crear vencimiento: $e';
        }

        print('\n💬 Mensaje de error final: "$errorMsg"');
        
        // Mostrar error con el mensaje específico
        showConfirmationModal(
          context,
          attitude: 0, // Negativo (error)
          label: errorMsg,
        );
      }
    }
  }

  @override

  Widget build(BuildContext context) {
    // Obtener el vehículo actual usando el vehicleId recibido
    final homeBloc = Provider.of<HomeBloc>(context, listen: false);
    Map<String, dynamic>? currentVehicle;
    
    if (widget.vehicleId != null) {
      try {
        currentVehicle = homeBloc.cars.firstWhere(
          (car) => car['id'] == widget.vehicleId,
        );
      } catch (e) {
        // Si no se encuentra, currentVehicle seguirá siendo null
        print('\n⚠️ No se encontró vehículo con ID: ${widget.vehicleId}');
      }
    } else if (homeBloc.cars.isNotEmpty) {
      currentVehicle = homeBloc.cars[0];
    }
    final currentVehicleId = currentVehicle != null ? currentVehicle['id'] : null;
    print('\n🚗 ALERTA_SCREEN: Vehículo actual: $currentVehicle');
    print('🆔 ALERTA_SCREEN: ID del vehículo actual: $currentVehicleId');
    return Loading(
      isLoading: isLoading,
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: const TopBar(
          title: 'Nuevo vencimiento',
          screenType: ScreenType.progressScreen,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configure esta alerta personalizada con algún requisito que necesite renovar de forma periódica, nosotros le avisamos.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 24),
                    InputText(
                      label: 'Nombre del vencimientos',
                      type: InputType.text,
                      onChanged: (value, isValid) {
                        setState(() {
                          nombreVencimiento = value;
                          isValidNombre = isValid;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    InputDate(
                      label: 'Fecha de vencimiento',
                      value: fechaVencimiento,
                      onChanged: (value) {
                        setState(() {
                          fechaVencimiento = value;
                        });
                      },
                      isRequired: true,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Button(
                text: 'Agregar vencimiento',
                isLoading: isLoading,
                action: () async {
                  if (isFormValid) {
                    await _saveAlert();
                  } else {
                    print('❌ Formulario inválido');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}