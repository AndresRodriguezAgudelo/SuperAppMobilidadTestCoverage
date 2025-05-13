import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../widgets/top_bar.dart';

import '../widgets/progress_steps.dart';

import '../widgets/identidadSteps/step_one.dart';
import '../widgets/identidadSteps/step_three.dart';
import '../widgets/identidadSteps/step_two.dart';

import '../widgets/modales.dart';
import '../widgets/confirmation_modales.dart';
import '../BLoC/auth/user_bloc.dart';
import '../BLoC/auth/auth.dart';
import '../BLoC/auth/auth_context.dart';
import '../BLoC/vehicles/vehicles_bloc.dart';
import '../BLoC/home/home_bloc.dart';
import '../BLoC/alerts/alerts_bloc.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  late String phoneNumber;
  int currentStep = 1;
  bool isStepValid = false;
  bool isStep3Valid = false;
  final PageController _pageController = PageController();
  final GlobalKey<StepOneState> _stepOneKey = GlobalKey<StepOneState>();
  final GlobalKey<StepThreeState> _stepThreeKey = GlobalKey<StepThreeState>();
  final UserBloc _userBloc = UserBloc();
  final AuthBloc _authBloc = AuthBloc();
  final AuthContext _authContext = AuthContext();
  final VehiclesBloc _vehiclesBloc = VehiclesBloc();
  bool _isCreatingUser = false;
  bool _isLoggingIn = false;

  // Datos del formulario
  String? verificationCode;
  String? name;
  String? email;
  String? selectedType;
  String? selectedCity;
  bool acceptedTerms = false;
  String? placa;
  String? tipoDocumentoPropietario;
  String? documentoPropietario;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    phoneNumber = ModalRoute.of(context)?.settings.arguments as String? ?? '';
  }

  void _validateStep1(String code, bool isValid) {
    setState(() {
      verificationCode = code;
      isStepValid = code.length == 4;
    });
  }

  void _validateStep2(String? newName, String? newEmail, String? newCity,
      bool newAcceptedTerms) {
    setState(() {
      name = newName;
      email = newEmail;
      selectedCity = newCity;
      acceptedTerms = newAcceptedTerms;
      isStepValid = name != null &&
          email != null &&
          selectedCity != null &&
          acceptedTerms;
    });
  }

  void _validateStep3(String? newPlaca, String? newTipoDoc, String? newDoc) {
    setState(() {
      placa = newPlaca;
      tipoDocumentoPropietario = newTipoDoc;
      documentoPropietario = newDoc;
      isStep3Valid = placa != null &&
          tipoDocumentoPropietario != null &&
          documentoPropietario != null;
      isStepValid = isStep3Valid;
    });
  }

  Future<bool> _createUser() async {
    print('\n🔄 INICIANDO CREACIÓN DE USUARIO');
    
    if (_isCreatingUser) {
      print('\n⚠️ Ya hay una operación de creación en proceso, ignorando llamada');
      return false;
    }

    if (!mounted) {
      print('\n⚠️ Widget no montado antes de iniciar creación de usuario');
      return false;
    }

    setState(() {
      _isCreatingUser = true;
      _isLoggingIn = true; // Sincronizar ambas variables de loading
    });

    try {
      final cityId = int.tryParse(selectedCity ?? '') ?? 0;
      
      print('\n📝 DATOS PARA CREAR USUARIO:');
      print('- Email: $email');
      print('- Nombre: $name');
      print('- Ciudad ID: $cityId');
      print('- Teléfono: $phoneNumber');
      print('- Términos aceptados: $acceptedTerms');
      
      final response = await _userBloc.createUser(
        email: email!,
        name: name!,
        accepted: acceptedTerms,
        cityId: cityId,
        phone: phoneNumber,
      );

      if (!mounted) {
        print('\n⚠️ Widget no montado después de crear usuario en API');
        return false;
      }

      print('\n✅ RESPUESTA DE CREACIÓN DE USUARIO:');
      print('- Respuesta: $response');
      
      // Verificar que la respuesta contenga los datos esperados
      if (response['user'] == null || response['token'] == null) {
        print('\n❌ Error: Respuesta del servidor no contiene datos de usuario o token');
        throw Exception('Respuesta inválida del servidor');
      }

      // Guardar el token y datos del usuario en el AuthContext
      final userData = response['user'];
      _authContext.setUserData(
        token: response['token'],
        name: userData['name'],
        phone: userData['phone'].toString(),
        photo: userData['photo'],
        userId: userData['id'],
      );
      
      print('\n🆔 ID DE USUARIO GUARDADO EN REGISTRO: ${userData["id"]}');

      showConfirmationModal(
        context,
        label: '¡Usuario creado exitosamente!',
        attitude: 1,
      );

      return true;
    } catch (e) {
      print('\n❌ ERROR CREANDO USUARIO: $e');
      
      if (!mounted) {
        print('\n⚠️ Widget no montado durante manejo de error');
        return false;
      }

      showConfirmationModal(
        context,
        label: 'Error al crear el usuario. Por favor intenta nuevamente.',
        attitude: 0,
      );
      return false;
    } finally {
      if (mounted) {
        print('\n🔄 Restableciendo estados de loading en _createUser');
        setState(() {
          _isCreatingUser = false;
          _isLoggingIn = false; // Sincronizar ambas variables de loading
        });
      } else {
        print('\n⚠️ Widget no montado en finally de _createUser');
      }
    }
  }

  Future<void> _finishRegistration() async {
    if (_isLoggingIn || !mounted) return;

    setState(() {
      _isLoggingIn = true;
      _isCreatingUser = true; // Asegurar que ambas variables de loading estén sincronizadas
    });
    
    print('\n🔄 INICIANDO FINALIZACIÓN DE REGISTRO');

    try {
      print('----------------------------------------');
      print('🏁 FINALIZANDO REGISTRO');
      print('----------------------------------------');
      print('🚗 Placa: ${placa ?? 'No registrada'}');
      print('📃 Tipo documento: ${tipoDocumentoPropietario ?? 'No registrado'}');
      print('📝 Documento: ${documentoPropietario ?? 'No registrado'}');
      print('----------------------------------------');

      // Registrar el vehículo si los datos están presentes
      if (placa != null && tipoDocumentoPropietario != null && documentoPropietario != null) {
        // Activar loading en step three
        _stepThreeKey.currentState?.setLoading(true);

        try {
          // 1. Habilitar las peticiones antes de crear el vehículo
          final homeBloc = HomeBloc();
          homeBloc.enableRequests();
          print('\n🔓 PETICIONES HABILITADAS antes de crear vehículo en registro');

          // 2. Obtener el ID del tipo de documento del string (asumiendo que viene en formato 'ID - Nombre')
          final typeDocumentId = int.tryParse(tipoDocumentoPropietario!.split(' - ').first) ?? 0;
          
          // 3. Crear el vehículo
          print('\n🚗 CREANDO VEHÍCULO EN REGISTRO DE USUARIO');
          print('- Placa: $placa');
          print('- Tipo documento: $tipoDocumentoPropietario (ID: $typeDocumentId)');
          print('- Número documento: $documentoPropietario');
          
          final success = await _vehiclesBloc.createVehicle(
            licensePlate: placa!,
            numberDocument: documentoPropietario!,
            typeDocumentId: typeDocumentId,
          );

          if (success) {
            // 4. Si el vehículo se creó correctamente, actualizar la lista de vehículos
            print('\n🔄 ACTUALIZANDO LISTA DE VEHÍCULOS después de crear uno nuevo');
            await homeBloc.getCars(force: true);
            
            // 5. Verificar que se haya cargado el vehículo
            if (homeBloc.cars.isNotEmpty) {
              print('\n🔍 BUSCANDO VEHÍCULO RECIÉN CREADO: $placa');
              final newVehicle = homeBloc.cars.firstWhere(
                (car) => car['licensePlate'] == placa!.toUpperCase(),
                orElse: () => homeBloc.cars.first,
              );
              
              print('\n🚗 VEHÍCULO ENCONTRADO:');
              print('- ID: ${newVehicle['id']}');
              print('- Placa: ${newVehicle['licensePlate']}');
              
              // 6. Cargar alertas para el nuevo vehículo
              print('\n🔔 CARGANDO ALERTAS para el vehículo ${newVehicle['id']}');
              final alertsBloc = AlertsBloc();
              await alertsBloc.loadAlerts(newVehicle['id']);
              print('\n✅ PROCESO COMPLETO: Vehículo creado y alertas cargadas');
            } else {
              print('\n⚠️ ADVERTENCIA: No se encontraron vehículos después de crear uno nuevo');
            }
          } else {
            // Mostrar modal de error pero continuar con la navegación
            if (mounted) {
              CustomModal.show(
                context: context,
                icon: Icons.error_outline,
                title: 'Advertencia',
                content: 'Tu cuenta ha sido creada correctamente, pero hubo un problema al registrar el vehículo: ${_vehiclesBloc.error ?? "Error desconocido"}',
                buttonText: 'Continuar',
                onButtonPressed: () {
                  // Cerrar el modal
                  Navigator.pop(context);
                  // Ir a la pantalla principal
                  Navigator.pushReplacementNamed(context, '/home');
                },
              );
              setState(() {
                _isLoggingIn = false;
                _isCreatingUser = false; // Asegurar que ambas variables estén sincronizadas
              });
              print('\n⚠️ Saliendo de _finishRegistration después de mostrar modal de error');
              return; // Salir del método para evitar la navegación automática
            }
          }
        } catch (e) {
          print('\n❌ ERROR REGISTRANDO VEHÍCULO: $e');
          // Mostrar modal de error pero continuar con la navegación
          if (mounted) {
            CustomModal.show(
              context: context,
              icon: Icons.error_outline,
              title: 'Advertencia',
              content: 'Tu cuenta ha sido creada correctamente, pero hubo un problema al registrar el vehículo. Podrás agregar tu vehículo más tarde.',
              buttonText: 'Continuar',
              onButtonPressed: () {
                // Cerrar el modal
                Navigator.pop(context);
                // Ir a la pantalla principal
                Navigator.pushReplacementNamed(context, '/home');
              },
            );
            // Asegurar que ambas variables de loading se establezcan a false antes de salir
            setState(() {
              _isLoggingIn = false;
              _isCreatingUser = false;
            });
            print('\n⚠️ Saliendo de _finishRegistration después de error al registrar vehículo');
            return; // Salir del método para evitar la navegación automática
          }
        } finally {
          // Desactivar loading en step three
          _stepThreeKey.currentState?.setLoading(false);
        }
      }

      if (!mounted) {
        print('\n⚠️ Widget no montado antes de navegar a home');
        return;
      }
      
      print('\n🏠 Navegando a pantalla principal');
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('❌ Error finalizando registro: $e');
      if (!mounted) return;

      showConfirmationModal(
        context,
        label: 'Error al finalizar el registro. Por favor intenta nuevamente.',
        attitude: 0,
      );
    } finally {
      if (mounted) {
        print('\n🔄 Restableciendo estados de loading');
        setState(() {
          _isLoggingIn = false;
          _isCreatingUser = false; // Asegurar que ambas variables de loading estén sincronizadas
        });
      } else {
        print('\n⚠️ Widget no montado en finally de _finishRegistration');
      }
    }
  }

  void _nextStep() async {
    print('\n🔄 EJECUTANDO _nextStep - Paso actual: $currentStep');
    
    // Evitar múltiples llamadas si ya está en proceso
    if (_isCreatingUser || _isLoggingIn) {
      print('\n⚠️ Ya hay una operación en proceso, ignorando llamada a _nextStep');
      return;
    }
    
    if (currentStep < 3) {
      if (currentStep == 1) {
        print('\n🔑 Validando OTP antes de continuar al paso 2');
        // Validar OTP antes de continuar
        await _stepOneKey.currentState?.validateOTP();
        if (!isStepValid) {
          print('\n❌ Validación de OTP falló, no se continúa');
          return; // Si la validación falló, no continuar
        }
        
        if (!mounted) {
          print('\n⚠️ Widget no montado después de validar OTP');
          return;
        }
        
        print('\n✅ OTP validado correctamente, avanzando al paso 2');
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          currentStep++;
          isStepValid = name != null &&
              email != null &&
              selectedCity != null &&
              acceptedTerms;
        });
      } else if (currentStep == 2) {
        print('\n👤 Creando usuario antes de continuar al paso 3');
        // Crear usuario antes de continuar al paso 3
        final userCreated = await _createUser();
        if (!mounted) {
          print('\n⚠️ Widget no montado después de crear usuario');
          return;
        }
        
        // Solo avanzar si el usuario fue creado exitosamente
        if (userCreated) {
          print('\n✅ Usuario creado exitosamente, avanzando al paso 3');
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            currentStep++;
            isStepValid = isStep3Valid;
          });
        } else {
          print('\n❌ No se pudo crear el usuario, permaneciendo en paso 2');
        }
      }
    } else if (currentStep == 3 && isStep3Valid) {
      print('\n🏁 En paso 3 con datos válidos, finalizando registro');
      _finishRegistration();
    } else {
      print('\n⚠️ No se cumplieron las condiciones para avanzar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


      resizeToAvoidBottomInset: true,

      
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: 'Registro de usuario',
          screenType: ScreenType.progressScreen,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressSteps(
                    totalSteps: 3,
                    currentStep: currentStep,
                  ),
                  const SizedBox(height: 40),


                  Expanded(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 220, // Altura ajustada al contenido  
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            StepOne(
                              key: _stepOneKey,
                              phoneNumber: phoneNumber,
                              onValidate: _validateStep1,
                            ),
                            StepTwo(
                              onValidate: _validateStep2,
                              acceptedTerms: acceptedTerms,
                            ),
                            StepThree(
                              key: _stepThreeKey,
                              onValidate: _validateStep3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 25),
                  if (currentStep == 3) ...[
                    // Solo mostrar en el paso 3
                    Center(
                      child: Button(
                        text: 'Continuar sin registrar vehículo',
                        action: () {
                          CustomModal.show(
                            context: context,
                            icon: Icons.warning_rounded,
                            iconColor: Colors.orange,
                            title: '¿Estás seguro?',
                            content:
                                'Si continúas sin registrar un vehículo, algunas funciones de la aplicación no estarán disponibles.',
                            buttonText: 'Continuar sin vehículo',
                            onButtonPressed: _finishRegistration,
                            secondButtonText: 'Registrar vehículo',
                            onSecondButtonPressed: () => Navigator.pop(context),
                            buttonColor: Colors.red,);
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                  Center(
                    child: Button(
                      text: currentStep < 3 ? 'Continuar' : 'Finalizar',
                      action: isStepValid ? ((_isCreatingUser || _isLoggingIn) ? null : _nextStep) : null,
                      isLoading: _isCreatingUser || _isLoggingIn,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}