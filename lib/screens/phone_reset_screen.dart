import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../widgets/top_bar.dart';

import '../widgets/progress_steps.dart';

import '../widgets/resetSteps/step_one.dart';
import '../widgets/resetSteps/step_three.dart';
import '../widgets/resetSteps/step_two.dart';
import '../widgets/resetSteps/step_four.dart';

import '../widgets/confirmation_modales.dart';
import '../BLoC/auth/auth_context.dart';
import '../BLoC/reset_phone/reset_phone_bloc.dart';

class PhoneResetScreen extends StatefulWidget {
  const PhoneResetScreen({super.key});

  @override
  State<PhoneResetScreen> createState() => _PhoneResetScreenState();
}

class _PhoneResetScreenState extends State<PhoneResetScreen> {
  String email = '';
  String phoneNumber = '';
  String recoveryCode = '';
  int currentStep = 1;
  bool isStepValid = false;
  final PageController _pageController = PageController();
  final GlobalKey<StepOneState> _stepOneKey = GlobalKey<StepOneState>();
  final GlobalKey<StepThreeState> _stepThreeKey = GlobalKey<StepThreeState>();
  final GlobalKey<StepTwoState> _stepTwoKey = GlobalKey<StepTwoState>();
  final GlobalKey<StepFourStatus> _stepFourKey = GlobalKey<StepFourStatus>();
  final AuthContext _authContext = AuthContext();
  final ResetPhoneBloc _resetPhoneBloc = ResetPhoneBloc();
  bool _isLoading = false;

  // Datos del formulario
  String? verificationCode;

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
  }

  void _validateStep1(String emailValue, bool isValid) {
    setState(() {
      email = emailValue;
      isStepValid = isValid;
    });
  }

  void _validateStep2(String code, bool isValid) {
    setState(() {
      recoveryCode = code;
      isStepValid = isValid;
    });
  }

  void _validateStep3(String phone, bool isValid) {
    setState(() {
      phoneNumber = phone;
      isStepValid = isValid;
    });
  }

  void _validateStep4(String code, bool isValid) {
    setState(() {
      verificationCode = code;
      isStepValid = isValid;
    });
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _nextStep() async {
    print('📌 Entramos a _nextStep function');

    if (!isStepValid) {
      showConfirmationModal(
        context,
        label: 'Por favor completa todos los campos requeridos',
        attitude: 0,
      );
      return;
    }

    // Validaciones específicas según el paso actual
    switch (currentStep) {
      case 1:
        // Paso 1: Solicitar código OTP al email
        print('📌 Procesando paso 1: Solicitar código OTP al email');
        await _stepOneKey.currentState?.validateOTP();
        
        // Solo avanzar si el paso sigue siendo válido después de la validación
        if (!isStepValid) {
          print('❌ Validación del paso 1 falló, no avanzamos');
          return;
        }
        break;
        
      case 2:
        // Paso 2: Validar código OTP recibido por email
        print('📌 Procesando paso 2: Validar código OTP de recuperación');
        await _stepTwoKey.currentState?.validateOTP();
        
        // Solo avanzar si el paso sigue siendo válido después de la validación
        if (!isStepValid) {
          print('❌ Validación del paso 2 falló, no avanzamos');
          return;
        }
        break;
        
      case 3:
        // Paso 3: Actualizar número de teléfono
        print('📌 Procesando paso 3: Actualizar número de teléfono');
        await _stepThreeKey.currentState?.updatePhoneNumber();
        
        // Solo avanzar si el paso sigue siendo válido después de la actualización
        if (!isStepValid) {
          print('❌ Actualización del teléfono falló, no avanzamos');
          return;
        }
        break;
    }
    
    if (currentStep < 4) {
      setState(() {
        currentStep++;
        isStepValid = false;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Si acabamos de avanzar al paso 4, solicitar el OTP de login
      if (currentStep == 4) {
        print('📌 Avanzamos al paso 4: Solicitando OTP de login');
        _requestLoginOTP();
      }
    }
  }
  
  // Método para solicitar OTP de login al llegar al paso 4
  Future<void> _requestLoginOTP() async {
    if (phoneNumber.isEmpty) {
      print('❌ Error: No hay número de teléfono para solicitar OTP');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      print('📌 Solicitando OTP de login para el teléfono: $phoneNumber');
      await _resetPhoneBloc.requestLoginOTP(phoneNumber);
      setState(() => _isLoading = false);
      
      showConfirmationModal(
        context,
        label: '¡Código enviado a tu nuevo número!',
        attitude: 1,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Error al solicitar OTP de login: $e');
      
      showConfirmationModal(
        context,
        label: 'Error al enviar el código. ${_resetPhoneBloc.error ?? 'Intenta nuevamente.'}',
        attitude: 0,
      );
    }
  }
  
  // Método para validar el último paso y finalizar el proceso
  Future<void> _validateFinalStep() async {
    print('📌 Validando paso final');
    await _stepFourKey.currentState?.validateOTP();
    
    if (isStepValid) {
      print('✅ Validación final exitosa, redirigiendo al home');
      _goToHome();
    } else {
      print('❌ Validación final falló');
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
          title: '',
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
                    totalSteps: 4,
                    currentStep: currentStep,
                  ),
                  const SizedBox(height: 40),


                  Expanded(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 290, // Altura ajustada al contenido  
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            StepOne(
                              key: _stepOneKey,
                              resetPhoneBloc: _resetPhoneBloc,
                              onValidate: _validateStep1,
                            ),
                            StepTwo(
                              key: _stepTwoKey,
                              resetPhoneBloc: _resetPhoneBloc,
                              email: email,
                              onValidate: _validateStep2,
                            ),
                            StepThree(
                              key: _stepThreeKey,
                              resetPhoneBloc: _resetPhoneBloc,
                              onValidate: _validateStep3,
                            ),
                            StepFour(
                              key: _stepFourKey,
                              resetPhoneBloc: _resetPhoneBloc,
                              phoneNumber: phoneNumber,
                              onValidate: _validateStep4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 25),
                  Center(
                    child: Button(
                      text: currentStep < 4 ? 'Continuar' : 'Finalizar',
                      action: isStepValid ? (_isLoading ? null : (currentStep == 4 ? _validateFinalStep : _nextStep)) : null,
                      isLoading: _isLoading,
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